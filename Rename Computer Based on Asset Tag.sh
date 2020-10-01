#!/bin/sh
# Based on a script by McLeanSchool posted to this thread on Jamf Nation
# https://www.jamf.com/jamf-nation/discussions/26699/computer-rename-based-on-jamfpro-object-attributes
# Updated to use the asset tag field

# Load API account from variables, and optional prefix

jssUser=$4
jssPass=$5
prefix=$6

# Pull device serial number for lookup

serialNumber=$(ioreg -c IOPlatformExpertDevice -d 2 | awk -F\" '/IOPlatformSerialNumber/{print $(NF-1)}')

echo "Looking up info for $prefix $serialNumber"

# Use API to pull general info

locationInfo=$(curl -k https://jss.example.com/JSSResource/computers/serialnumber/${serialNumber}/subset/general -H "Accept: application/xml" --user "${jssUser}:${jssPass}")

# Parse out computer info

assetTag=$(echo $locationInfo | /usr/bin/awk -F'<asset_tag>|</asset_tag>' '{print $2}' | tr [a-z] [A-Z])

echo "Found this info… asset tag: $assetTag "

if [ -z "$assetTag" ]
then
    assetTag="$serialNumber"
fi

# Assemble the computer name using the format Prefix-Asset and update records

computerName="${prefix}-${assetTag}"
computerName=`echo ${computerName:0:15}`
echo "Setting computer name to $computerName"
/usr/sbin/scutil --set ComputerName "$computerName"
/usr/sbin/scutil --set LocalHostName "$computerName"
/usr/sbin/scutil --set HostName "$computerName"
dscacheutil -flushcache