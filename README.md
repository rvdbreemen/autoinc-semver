# autoinc-semver
Automatic semantic version number generator

Usage: semver-build.bat e.g. ```semver-build.bat ./version.h```

Just use the prebuild option of vscode call this script to increment the build number. 
It will automatically find the major.minor.patch+build values and then auto increment the buildnumber. 
Also it will timestamp date and time of the buildprocess into the file.
This script generates version numbers folloing the Semantic Version 2.0 (See http://semver.org)

It creates an Adruino C/C++ compatible file you can include in your aduino sketch to reflect the version number.

The content of the file will look something like this: 
```C
#define _VERSION_MAJOR 0 
#define _VERSION_MINOR 0
#define _VERSION_PATCH 1 
#define _VERSION_BUILD 41 
#define _VERSION_DATE 04-07-2020 
#define _VERSION_TIME 14:40:18 
#define _VERSION_ONLY 0.0.1 
#define _VERSION_NOBUILD 0.0.1 (04-07-2020) 
#define _VERSION 2.0.3+41 (04-07-2020)
```

The MAJOR, MINOR and PATCH are set manually. BUILD will auto-increment each time you call the script. TIME and DATE are set to the moment in time you call the script. The VERSION_ONLY, VERSION_NOBUILD and VERSION are all constructed from the previous set of parameters. 

There are two versions of this script, one that can be used for Windows (batch) and one for Linux/MacOS (bash). 

To use this with VSCode and the Aduino plugin, just goto the arduino.json and add the following line:
"prebuild": "<script path>/semver-incr-build ./version.h"

How to use the Arduino IDE the pre-build hooks, [read this Arduino documentation](https://arduino.github.io/arduino-cli/platform-specification/#pre-and-post-build-hooks-since-arduino-ide-165). And [this topic](https://forum.arduino.cc/index.php?topic=586019.0) on the hooks on the forum. 

Change the script to your needs, it's up to you now.

This script is released to the public domain. Enjoy!
