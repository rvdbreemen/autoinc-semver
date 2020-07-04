# autoinc-semver
Automatic semantic version number generator

Usage: semver-build.bat e.g. semver-build.bat ./version.h

Just use the prebuild option of vscode call this script to increment the build number. 
It will automatically find the major.minor.patch+build values and then auto increment the buildnumber. 
Also it will timestamp date and time of the buildprocess into the file.
This script generates version numbers folloing the Semantic Version 2.0 (See http://semver.org)

It creates a C/C++ compatible file you can include in your aduino sketch to reflect the version number.

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

This script is released to the public domain. Enjoy!
