# Jamf Information Rename

Script used for automatic/smart renaming based on information stored in Jamf. Ideally, this is used in combination with Inventory Preload or a similar bulk update solution such as [The MUT](https://github.com/mike-levenick/mut). This could also be used in combination with manual user-input via Self Service, or as part of an onboarding or enrollment process. The advantage to this script is that a computer’s name can be updated by simply updating these fields in Jamf with this script set as a recurring policy, as these fields are writable via Jamf recon and the API. 

A Jamf API user with read access must be specified in variables 5 & 6, with the name format defined in variable 4, as one of the following options: `location`, `asset`, or `network`. If no format is specified, serial number is used instead. 

## Rename Computer Based on Jamf Location Info
**DEPT-BLDGROOM-POSITION (ABC-BLDG123-01)**

Renames computers based on computer location info set in Jamf, using serial number lookup. Pulls multiple pieces of info from location for each computer record and combines into a computer name. Converts full building and department names in Jamf's Network Organization settings into standard abbreviations, defined in this script. 

This could be used for one-to-many deployments such as shared computer labs where workstations are individually numbered. In this example, the “position” field is used in a one-to-many deployment with no primary user. This information could also be stored in a custom EA field. 

## Rename Computer Based on Asset Tag
**PREFIX-ASSET (ABC-123456)**

Renames a computer based on asset tag info set in Jamf, using serial number lookup. Specify a shared company abbreviation as a prefix in variable 7.

## Rename Computer Based on Hardware Address
**PREFIX-ADDRESS (ABC-X0X2X3X4Y0X0)**

This renames using the hardware address of en0 of the Mac, for use in environments where the hardware address may be desirable as a unique name. 

## Rename Computer Based on Serial Number
**PREFIX-SERIAL (ABC-X0XX234XYXYX)**

This simply renames using the serial number of the Mac, ensuring you have unique names. 

* * *

This script builds on [this script by McLeanSchool](https://www.jamf.com/jamf-nation/discussions/26699/computer-rename-based-on-jamfpro-object-attributes). 
