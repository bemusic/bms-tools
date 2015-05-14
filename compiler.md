---
layout: default
title: BMS Sound Matcher
css: |
    textarea.bt-area { height: 10em; }
    .bt-dropzone {
        border: 3px dashed #aaa; border-radius: 2em;
        text-align: center; padding: 5em 1em;
        margin-bottom: 1em; }
    .bt-dropzone.is-hover { background: #ff8; }
    .bt-image-l { background: #ddd; text-align: center; }
---

BMS Sound Matcher <small>by flicknote</small>
============

<div id="main" class="row">
  <div class="col-md-5">
    <div id="bc-dropzone" class="bt-dropzone">
      Loading...
    </div>
  </div>
  <div class="col-md-7">
    <ul id="bc-output">
      <li>Please drop a BMS file into the dropzone at the left.</li>
    </ul>
  </div>
</div>

<script src="http://code.jquery.com/jquery-1.11.3.min.js"></script>
<script src="vendor/FileSaver.js"></script>
<script src="compiler.js"></script>

---

About
-----

BMS Sound Matcher lets you create note patterns more comfortably
by matching notes and BGM objects.
__See the tutorial below to understand how.__



How to use?
-----------

<div class="row">
  <div class="col-xs-12">
    <p class="bt-image-l">
      <img src="images/compiler/before.png" alt="Before" />
    </p>
    <p>
      <strong>1.&nbsp; Create your pattern using Z1, Z2, Z3, … objects.</strong>
    </p>
    <p>For example, Z1 corresponds to 1st BGM track. Z2 corresponds to 2nd BGM track, and so on.</p>
  </div>
</div>

<div class="row">
  <div class="col-md-7">
    <br>
    <p><strong>2.&nbsp; Drop the BMS file into this application.</strong></p>
    <p>After you drop the BMS file, this application will process the BMS
      and matches the notes object with corresponding BGM keysound objects.</p>
  </div>
  <div class="col-md-5">
    <p class="bt-image-s">
      <img src="images/compiler/drop.png" alt="Drop" />
    </p>
  </div>
</div>

<div class="row">
  <div class="col-md-6">
    <p class="bt-image-s">
      <img src="images/compiler/download.png" alt="Download" />
    </p>
  </div>
  <div class="col-md-6">
    <br>
    <p><strong>3.&nbsp; Download the generated BMS file.</strong></p>
    <p>After processing is finished, your browser will download the generated BMS file.</p>
  </div>
</div>

<div class="row">
  <div class="col-xs-12">
    <p class="bt-image-l">
      <img src="images/compiler/after.png" alt="After" />
    </p>
    <p>
      <strong>4.&nbsp; Your BMS is now keysounded!</strong>
    </p>
    <p>
      That's it! No more dragging notes around to create a pattern.
    </p>
  </div>
</div>



Limitations
-----------

- Objects __Z1__–__ZZ__ are reserved. You cannot use it in musical score.
- Supports Chrome 42 and Firefox 37.



Technical Information
---------------------

- The worker is written in Ruby, compiled into JavaScript using [Opal](http://opalrb.org/).
- [Offline version is available](https://github.com/bemusic/bms-tools/tree/master/bms-compiler) as a Ruby command-line script.




