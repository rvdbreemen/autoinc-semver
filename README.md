# autoinc-semver

Automatic semantic version number generator

- [Usage](#usage)
- [update-boiler-version](#update-boiler-version)
- [update-version.py](#update-versionpy)

---

## Usage

- **Mac/Linux**

  ```shell
  ./semver-incr-build.sh ./version.h
  ```

- **Windows**

  ```shell
  semver-incr-build.bat ./version.h
  ```

Just use the prebuild option of vscode call this script to increment the build number.
It will automatically find the major.minor.patch+build values and then auto increment the buildnumber.
Also it will timestamp date and time of the buildprocess into the file.
This script generates version numbers folloing the Semantic Version 2.0 (See <http://semver.org>)

It creates an Adruino C/C++ compatible file you can include in your aduino sketch to reflect the version number.

The content of the file will look something like this:

```C
#pragma once

// The version number conforms to semver.org format
#define _VERSION_MAJOR 0
#define _VERSION_MINOR 0
#define _VERSION_PATCH 0
#define _VERSION_BUILD 1
#define _VERSION_PRERELEASE
#define _VERSION_DATE "16-07-2020"
#define _VERSION_TIME "18:31:48"
#define _SEMVER_CORE "0.0.0"
#define _SEMVER_BUILD "0.0.0+1"
#define _VERSION_FULL "0.0.0+1"
#define _VERSION_NOBUILD "0.0.0 (16-07-2020)"
#define _VERSION "0.0.0+1 (16-07-2020)"
// The version information is created automatically, more information here: https://github.com/rvdbreemen/autoinc-semver
```

The MAJOR, MINOR and PATCH are set manually. BUILD will auto-increment each time you call the script. TIME and DATE are set to the moment in time you call the script. The VERSION_ONLY, VERSION_NOBUILD and VERSION are all constructed from the previous set of parameters.

There are two versions of this script, one that can be used for Windows (batch) and one for Linux/MacOS (bash).

The use pre build scripts with VSCode and the Aduino plugin is [explained here](https://github.com/Microsoft/vscode-arduino#options).  
Simply goto the arduino.json and add the following line to the options:  
`"prebuild": "<script path>/semver-incr-build ./version.h"`

How to use the Arduino IDE the pre-build hooks, [read this Arduino documentation](https://arduino.github.io/arduino-cli/platform-specification/#pre-and-post-build-hooks-since-arduino-ide-165). And [this topic](https://forum.arduino.cc/index.php?topic=586019.0) on the hooks on the forum.

It comes down to this:

1. Open the `platform.txt` in this directory: `C:\Users\<username>\AppData\Local\Arduino15\packages\esp8266\hardware\esp8266\2.7.1`
2. Then add the following line to execute the script on each build:
   `recipe.hooks.sketch.prebuild.0.pattern=D:\<directory location of script>\autoinc-semver\semver-incr-build.bat {build.source.path}\version.h`

## update-boiler-version

To update my source files, I created another script. It looks for the signature of the "version" boiler plate
and then replaces it with the version found in the version header file. Before it makes any changes, it commits
to github. Then it updates all the relevant source files to the current version. To finally commit and tag with
the current version.

To modify it to your needs, just go and change it in the file itself. If you like to live dangerous, then you
could do without github (not recommended). Otherwise, just enjoy the magic of auto-semver and this script.

If anyone enjoys writting in bash, please do a pull request to get it added.

Change the scripts to your needs, it's up to you now.

This script is released to enjoy!

## update-version.py

2024-04-17 After a couple of years I could not get the update-boiler-version.bat to work. Not sure what to do
I realized that maybe co-pilot & chatgpt could help me convert to Python. After about 1 hour of work and feeding
my original batch script first. I created this script, it seems to do about the same as the batch file did before.
It updates the relevant version information in the file headers of each relevant file.

Enjoy the script...

```plain
=================================================================================
MIT License

Copyright (c) 2020 Robert van den Breemen

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
=================================================================================
```
