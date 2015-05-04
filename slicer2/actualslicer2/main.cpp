#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <iostream>
#include <sndfile.hh>
#include <vector>
#include <string>
#include <algorithm>

#define FADE_LENGTH 20
#define BUF_FRAMES 4096

char in_filename[4096];

using namespace std;

class SoundStream {
  public:
    virtual bool hasNext() =0;
    virtual void next(short data[]) =0;
    virtual int channels() =0;
};

class Slice : public SoundStream {
  public:
    long start, end, index;
    sf_count_t length;
    short *sample_data;
    int chans;
    Slice(short *sample_data, sf_count_t length, int channels, long start, long end);
    bool hasNext();
    void next(short data[]);
    int channels();
};

Slice::Slice(short *sample_data, sf_count_t length, int channels, long start, long end) {
  this->sample_data = sample_data;
  this->chans = channels;
  this->start = start;
  this->end = end;
  this->length = length;
  this->index = start;
}

bool Slice::hasNext() {
  return index < length;
}

void Slice::next(short out[]) {
  for (int i = 0; i < channels(); i ++) {
    out[i] = sample_data[index * chans + i];
  }
  index ++;
}

int Slice::channels() {
  return chans;
}

class FadeIn : public SoundStream {
  SoundStream *source;
  long length;
  int index;
  public:
    FadeIn(SoundStream *source, long length);
    ~FadeIn();
    bool hasNext();
    void next(short data[]);
    int channels();
};

FadeIn::FadeIn(SoundStream *source, long length) {
  this->source = source;
  this->length = length;
  this->index = 0;
}

FadeIn::~FadeIn() {
  delete source;
}

bool FadeIn::hasNext() {
  return source->hasNext();
}

double get_volume(double in) {
  return 1 - (1 - in) * (1 - in);
}

void FadeIn::next(short out[]) {
  double volume = get_volume(min(1.0, (double)index / length));
  source->next(out);
  for (int i = 0; i < channels(); i ++) {
    out[i] = lrint(out[i] * volume);
  }
  this->index ++;
}

int FadeIn::channels() {
  return source->channels();
}

class FadeOut : public SoundStream {
  SoundStream *source;
  long length;
  long hold;
  int index;
  public:
    FadeOut(SoundStream *source, long hold, long length);
    ~FadeOut();
    bool hasNext();
    void next(short data[]);
    int channels();
};

FadeOut::~FadeOut() {
  delete source;
}

FadeOut::FadeOut(SoundStream *source, long hold, long length) {
  this->source = source;
  this->hold = hold;
  this->length = length;
  this->index = 0;
}

bool FadeOut::hasNext() {
  return source->hasNext() && index < hold + length;
}

void FadeOut::next(short out[]) {
  double volume = get_volume(min(1.0, max(0.0, 1.0 + (double)(hold - index) / length)));
  source->next(out);
  for (int i = 0; i < channels(); i ++) {
    out[i] = lrint(out[i] * volume);
  }
  this->index ++;
}

int FadeOut::channels() {
  return source->channels();
}



struct VectorFile {
  public:
    string filename;
    SoundStream *stream;
};

char string_buffer[4096];

int main(int argc, char *argv[]) {

  gets(in_filename);
  SndfileHandle handle(in_filename, SFM_READ, 0);

  if (bool(handle)) {

    sf_count_t frames = handle.frames();
    int samplerate = handle.samplerate();
    int channels = handle.channels();
    printf("[%s]\n - %lld frames @ %d\n", in_filename, frames, samplerate);

    printf("going to alloc %lld\n", frames * channels);
    short *source_data = new short[frames * channels];
    printf("read: %lld of %lld\n", handle.readf(source_data, frames), frames);

    int count;
    gets(string_buffer);
    sscanf(string_buffer, "%d", &count);

    vector<Slice *> slices;
    vector<string> out_filenames;
    for (int i = 0; i < count; i ++) {
      double start_second, end_second;
      gets(string_buffer);
      out_filenames.push_back(string(string_buffer));
      gets(string_buffer);
      sscanf(string_buffer, "%lf%lf", &start_second, &end_second);
      long start = lrint(start_second * samplerate);
      long end = lrint(end_second * samplerate);
      slices.push_back(new Slice(source_data, frames, channels, start, end));
    }

    vector<SoundStream *> streams;
    for (int i = 0; i < slices.size(); i ++) {
      Slice *slice = slices[i];
      long length = slice->end - slice->start;
      SoundStream *stream = slice;
      if (i > 0) {
        stream = new FadeIn(stream, FADE_LENGTH);
      }
      stream = new FadeOut(stream, length, FADE_LENGTH);
      streams.push_back(stream);
    }

    for (int i = 0; i < streams.size(); i ++) {
      SoundStream *stream = streams[i];
      string out_filename = out_filenames[i];
      printf(" -> %s\n", out_filename.c_str());
      SndfileHandle out_handle(out_filename, SFM_WRITE, SF_FORMAT_WAV | SF_FORMAT_PCM_16, stream->channels(), samplerate);
      if (bool(out_handle)) {
        short buffer[stream->channels() * BUF_FRAMES];
        long buf_count = 0;
        while (stream->hasNext()) {
          if (buf_count >= BUF_FRAMES) {
            out_handle.writef(buffer, buf_count);
            buf_count = 0;
          }
          int start_index = buf_count * stream->channels();
          stream->next(&buffer[start_index]);
          buf_count ++;
        }
        if (buf_count > 0) {
          out_handle.writef(buffer, buf_count);
        }
      } else {
        printf("    -> write error!!\n");
      }
      delete stream;
    }

    delete[] source_data;

  } else {
    printf("Handler wtf\n");
    return 1;
  }
  return 0;
}
