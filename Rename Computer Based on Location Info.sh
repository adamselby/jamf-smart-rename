#!/bin/sh
# Based on a script by McLeanSchool posted to this thread on Jamf Nation
# https://www.jamf.com/jamf-nation/discussions/26699/computer-rename-based-on-jamfpro-object-attributes
# Updated to pull specific info needed for our naming, from the Jamf location info
# Building and department abbreviations are specified in this script

# Load API account from variables

jssUser=$4
jssPass=$5

# Pull device serial number for lookup

serialNumber=$(ioreg -c IOPlatformExpertDevice -d 2 | awk -F\" '/IOPlatformSerialNumber/{print $(NF-1)}')

echo "Looking up info for $serialNumber"

# Use API to pull location info

locationInfo=$(curl -k https://jss.example.com/JSSResource/computers/serialnumber/${serialNumber}/subset/location -H "Accept: application/xml" --user "${jssUser}:${jssPass}" -s)

# Parse out computer info

locationDepartment=$(echo $locationInfo | /usr/bin/awk -F'<department>|</department>' '{print $2}' | tr [a-z] [A-Z])
locationBuilding=$(echo $locationInfo | /usr/bin/awk -F'<building>|</building>' '{print $2}' | tr [a-z] [A-Z])
locationRoom=$(echo $locationInfo | /usr/bin/awk -F'<room>|</room>' '{print $2}' | tr [a-z] [A-Z])
locationPosition=$(echo $locationInfo | /usr/bin/awk -F'<position>|</position>' '{print $2}' | tr [a-z] [A-Z])

echo "Found this info… \ndepartment: $locationDepartment \nbuilding: $locationBuilding \nroom: $locationRoom \nposition: $locationPosition "

if [ -z "$locationDepartment" ]
then
    locationDepartment="$serialNumber"
fi
if [ -z "$locationBuilding" ]
then
    locationBuilding="$serialNumber"
fi
if [ -z "$locationRoom" ]
then
    locationRoom="$serialNumber"
fi
if [ -z "$locationPosition" ]
then
    locationPosition="$serialNumber"
fi

# Match department name to its abbreviation
# Department abbreviations for departments that exist in Jamf's Network Organization settings

if [ "$locationDepartment" == "Administrative" ]
then
	locationDepartmentAbbreviation="ADMN"
	echo "Found this abbreviation… dept: $locationDepartmentAbbreviation"
fi

if [ "$locationDepartment" == "Engineering" ]
then
	locationDepartmentAbbreviation="ENGR"
	echo "Found this abbreviation… dept: $locationDepartmentAbbreviation"
fi

if [ "$locationDepartment" == "Marketing" ]
then
	locationDepartmentAbbreviation="MKTG"
	echo "Found this abbreviation… dept: $locationDepartmentAbbreviation"
fi

# Match building name to its abbreviation
# Building abbreviations for buildings that exist in Jamf's Network Organization settings

if [ "$locationBuilding" == "Main Building" ]
then
	locationBuildingAbbreviation="MAIN"
	echo "Found this abbreviation bldg: $locationBuildingAbbreviation"
fi

if [ "$locationBuilding" == "Research Building" ]
then
	locationBuildingAbbreviation="RSCH"
	echo "Found this abbreviation bldg: $locationBuildingAbbreviation"
fi

if [ "$locationBuilding" == "Annex Building" ]
then
	locationBuildingAbbreviation="ANNX"
	echo "Found this abbreviation bldg: $locationBuildingAbbreviation"
fi

# Assemble the computer name using the format DEPT-BLDGROOM-POSITION (ABC-BLDG123-01)

COMPUTERNAME="${locationDepartmentAbbreviation}-${locationBuildingAbbreviation}${locationRoom}-${locationPosition}"
COMPUTERNAME=`echo ${COMPUTERNAME:0:15}`
echo "Setting computer name to $COMPUTERNAME…"
/usr/sbin/scutil --set ComputerName "$COMPUTERNAME"
/usr/sbin/scutil --set LocalHostName "$COMPUTERNAME"
/usr/sbin/scutil --set HostName "$COMPUTERNAME"
dscacheutil -flushcache