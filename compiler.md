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

<p id="bt-translator"></p>

<div id="main" class="row">
  <div class="col-md-5">
    <div id="bc-dropzone" class="bt-dropzone">
      Loading...
    </div>
  </div>
  <div class="col-md-7">
    <ul id="bc-output">
      <li data-i18n="bsm.app.pleasedrop">Please drop a BMS file into the dropzone at the left.</li>
    </ul>
  </div>
</div>

<script src="http://code.jquery.com/jquery-1.11.3.min.js"></script>
<script src="lib/i18n.js"></script>
<script src="vendor/FileSaver.js"></script>
<script src="compiler.js"></script>
<script src="compiler-strings.js"></script>

---

<span data-i18n="bsm.about.title">About</span>
-----

<span data-i18n="bsm.about.intro">BMS Sound Matcher lets you create note patterns more comfortably
by matching notes and BGM objects.</span>
__<span data-i18n="bsm.about.more">See the tutorial below to understand how.</span>__



<span data-i18n="bsm.howto.title">How to use?</span>
-----------

<div class="row">
  <div class="col-xs-12">
    <p class="bt-image-l">
      <img src="images/compiler/before.png" alt="Before" />
    </p>
    <p>
      <strong>1.&nbsp; <span data-i18n="bsm.howto.1.title">Create your pattern using Z1, Z2, Z3, … objects.</span></strong>
    </p>
    <p><span data-i18n="bsm.howto.1.description">For example, Z1 corresponds to 1st BGM track. Z2 corresponds to 2nd BGM track, and so on.</span></p>
  </div>
</div>

<div class="row">
  <div class="col-md-7">
    <br>
    <p><strong>2.&nbsp; <span data-i18n="bsm.howto.2.title">Drop the BMS file into this application.</span></strong></p>
    <p><span data-i18n="bsm.howto.2.description">After you drop the BMS file, this application will process the BMS
      and matches the notes object with corresponding BGM keysound objects.</span></p>
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
    <p><strong>3.&nbsp; <span data-i18n="bsm.howto.3.title">Download the generated BMS file.</span></strong></p>
    <p><span data-i18n="bsm.howto.3.description">After processing is finished, your browser will download the generated BMS file.</span></p>
  </div>
</div>

<div class="row">
  <div class="col-xs-12">
    <p class="bt-image-l">
      <img src="images/compiler/after.png" alt="After" />
    </p>
    <p>
      <strong>4.&nbsp; <span data-i18n="bsm.howto.4.title">Your BMS is now keysounded!</span></strong>
    </p>
    <p>
      <span data-i18n="bsm.howto.4.description">That's it! No more dragging notes around to create a pattern.</span>
    </p>
  </div>
</div>



<span data-i18n="bsm.limitations.title">Limitations</span>
-----------

- <span data-i18n="bsm.limitations.reserved">Objects __Z1__–__ZZ__ are reserved. You cannot use them in musical score.</span>
- <span data-i18n="bsm.limitations.browser">Supports Chrome 42 and Firefox 37.</span>



<span data-i18n="bsm.tech.title">Technical Information</span>
---------------------

- <span data-i18n="bsm.tech.worker">The worker is written in Ruby, compiled into JavaScript using <a href="http://opalrb.org/" data-element="opal_link">Opal</a>.
- <span data-i18n="bsm.tech.offline"><a href="https://github.com/bemusic/bms-tools/tree/master/bms-compiler" data-element="offline_link" data-i18n="bsm.tech.offline_link">Offline version is available</a> as a Ruby command-line script.</span>
