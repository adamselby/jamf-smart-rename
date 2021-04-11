# Jamf Information Rename

Scripts related to automatic/smart renaming based on information stored in Jamf. 

## Rename Computer Based on Asset Tag
**PREFIX-ASSET (ABC-123456)**

Renames a computer based on asset tag info set in Jamf, using serial number lookup. Specify a shared company abbreviation as a prefix in variable 6. 

## Rename Computer Based on Jamf Location Info
**DEPT-BLDGROOM-POSITION (ABC-BLDG123-01)**

Renames computers based on computer location info set in Jamf, using serial number lookup. Pulls multiple pieces of info from location for each computer record and combines into a computer name. Converts full building names in Jamf's Network Organization settings into standard building abbreviations. These will need to be manually specified once in the script. This could be used for one-to-many deployments such as shared computer labs where workstations are individually numbered. We store this information in the *position* field, since no user is assigned to it, but you could also use an Extension Attribute.  

* * *

These are best-used when you can load information into Jamf via Inventory Preload, or MUT. You could also use this in combination with manual user-input via Self Service or as part of initial setup and enrollment. This also means that a computer’s name can be updated by simply updating these fields, which are writable via Jamf recon. 
