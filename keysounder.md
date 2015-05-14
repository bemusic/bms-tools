---
layout: default
title: Keysounder
css: |
    textarea.bt-area { height: 10em; }
---

Keysounder
==========

This tool is the prototype version for use with iBMSC.
Please check out the [BMS Sound Matcher](compiler.html)

<div id="main" class="row">
  <div class="col-md-6">
    <h2>Input iBMSC Clipboard</h2>
    <p>
      <textarea id="bt-in" class="form-control bt-area"></textarea>
    </p>
    <p class="text-right" id="bt-go"></p>
  </div>
  <div class="col-md-6">
    <h2>Output</h2>
    <p>
      <textarea id="bt-out" class="form-control bt-area" readonly></textarea>
    </p>
    <pre><strong>Output:</strong><br /><span id="bt-err"></span></pre>
  </div>
</div>

<!--
Keysound = 4-20
BGM = 26+
-->

<script src="http://code.jquery.com/jquery-1.11.3.min.js"></script>
<script src="keysounder.js"></script>


About
-----

__Keysounder__ assigns keysounds to notes.

__Limitations:__ Your BMS notechart _MUST NOT_ use objects `Z1`-`ZZ`.

### 1. In iBMSC, put your keysounds in BGM tracks.

### 2. Put notes in KEY tracks.

Use object `Z1` for referring to notes in `BGM1` column, `Z2` for `BGM2`, and so on.

### 3. Cut them and paste in this application.

### 4. 3
















