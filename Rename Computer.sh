#!/bin/sh

# Load API account from variables

jamfUser=$5
jamfPass=$6

format=$4
prefix=$7

# Pull device serial number for lookup
serialNumber=$(ioreg -c IOPlatformExpertDevice -d 2 | awk -F\" '/IOPlatformSerialNumber/{print $(NF-1)}')
echo "Looking up info for $serialNumber"

function nameUsingLocation {
	# Use API to pull location info
	locationInfo=$(curl -k https://jss.example.com/JSSResource/computers/serialnumber/${serialNumber}/subset/location -H "Accept: application/xml" --user "${jamfUser}:${jamfPass}" -s)

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
	computerName="${locationDepartmentAbbreviation}-${locationBuildingAbbreviation}${locationRoom}-${locationPosition}"
	computerName=$(echo ${computerName:0:15})
}

function nameUsingAsset {
	# Use API to pull general info
	locationInfo=$(curl -k https://jss.example.com/JSSResource/computers/serialnumber/${serialNumber}/subset/general -H "Accept: application/xml" --user "${jamfUser}:${jamfPass}")

	# Parse out computer info
	assetTag=$(echo $locationInfo | /usr/bin/awk -F'<asset_tag>|</asset_tag>' '{print $2}' | tr [a-z] [A-Z])
	echo "Found this info… asset tag: $assetTag "

	if [ -z "$assetTag" ]
	then
	    assetTag="$serialNumber"
	fi

	# Assemble the computer name using the format Prefix-Asset and update records
	computerName="${prefix}-${assetTag}"
	computerName=$(echo ${computerName:0:15})
}

function nameUsingSerial {
	# Assemble the computer name using the format Prefix-Asset and update records
	computerName="${prefix}-${serialNumber}"
}

function nameUsingNetwork {
	# Lookup hardware address
	hardwareAddress=$(ifconfig en1 | awk '/ether/{print $2}' | tr -d ':')
	# Assemble the computer name using the format Prefix-Asset and update records
	computerName="${prefix}-${hardwareAddress}"
}

if [[ "${format}" == "location" ]] ; then 
	nameUsingLocation
elif [[ "${format}" == "asset" ]] ; then 
	nameUsingAsset
elif [[ "${format}" == "network" ]] ; then 
	nameUsingNetwork
else
	nameUsingSerial
fi

echo "Setting computer name to $computerName…"
/usr/sbin/scutil --set ComputerName "$computerName"
/usr/sbin/scutil --set LocalHostName "$computerName"
/usr/sbin/scutil --set HostName "$computerName"
dscacheutil -flushcache

exit 0
