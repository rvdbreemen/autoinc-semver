#!/bin/bash
#
# This script auto increment a header file, that can be included in your projects
# Using the format as described by Semantic Version 2.0 format (Read more https://semver.org/)
# Note: this script does not implement pre-release tagging at this point
echo "Let's increment the buildnumber"
file=$1
echo "Processing file [$1]"

if [ -z "$file" ]; then
	echo "Usage: $0 <filename>"
fi

# Create timestamp
TIMESTAMP=$(date '+%d/%m/%Y')
Hour=$(date '+%H')
Minute=$(date '+%M')
Second=$(date '+%S')
Day=$(date '+%d')
Month=$(date '+%m')
Year=$(date '+%Y')
echo "$TIMESTAMP"

# clear version numbers
MAJOR=
MINOR=
PATCH=
BUILD=
VERSION=


# echo Parse %1 for major.minor.patch-build values and parse them
IFS=' '
while read -r line
do
#	echo "$line"
	read -ra tokens <<< "$line"
	val=${tokens[2]//[!0-9]/}
	case ${tokens[1]} in
	        _VERSION_MAJOR)
                   	MAJOR=$val
			;;
		_VERSION_MINOR)
			MINOR=$val
			;;
		_VERSION_PATCH)
			PATCH=$val
			;;
		_VERSION_BUILD)
			BUILD=$val
			;;
	esac
done <"$file"

if [ "$MAJOR$MINOR$PATCH$BUILD" == "" ] ;  then
        echo "Initializing [$file] to default values:"
        MAJOR=0
        MINOR=0
        PATCH=0
        BUILD=0
fi

VERSION="$MAJOR.$MINOR.$PATCH+$BUILD"
echo "Found version: $VERSION"

# now auto increment build number by 1
BUILD=$((BUILD+1))
VERSION="$MAJOR.$MINOR.$PATCH+$BUILD"
echo "Increment build $BUILD"
echo "Version is: $VERSION"

# write the version numbers out to the file
echo "//The version number conforms to semver.org format">$file
echo "#define _VERSION_MAJOR ${MAJOR}">>$file
echo "#define _VERSION_MINOR $MINOR">>$file
echo "#define _VERSION_PATCH $PATCH">>$file
echo "#define _VERSION_BUILD $BUILD">>$file
echo "#define _VERSION_DATE $TIMESTAMP">>$file
echo "#define _VERSION_TIME $Hour:$Minute:$Second">>$file
echo "#define _VERSION_ONLY $MAJOR.$MINOR.$PATCH">>$file
echo "#define _VERSION_NOBUILD $MAJOR.$MINOR.$PATCH ($TIMESTAMP)">>$file
echo "#define _VERSION $VERSION ($TIMESTAMP)">>$file

# clear version numbers
MAJOR=
MINOR=
PATCH=
BUILD=
VERSION=
TIMESTAMP=
echo $VERSION

exit 1
