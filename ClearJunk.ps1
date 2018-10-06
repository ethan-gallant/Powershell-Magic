<#
.SYNOPSIS
    This script is intended to run the delete task on the office share folder every Friday
.DESCRIPTION
    The idea of this script is to move everything into its own folder inside of the Admin access only directory with a folder
    dated timestamp. This is done to avoid accidental deletions and to ensure recovery is possible if required.
.NOTES
    File Name      : ClearJunk.ps1
    Author         : E.J Gallant (ethan@exclnetworks.com)
    Prerequisite   : PowerShell V2 over Vista and upper.
    Copyright 2018 - Excl Networks (https://exclnetworks.com)
#>

#Create static variables
$deletedPath = "S:\Junk"
$deletedFolderName = "Deleted"
$deletedFolderPath = "S:\OfficeShare\Junk\Deleted"

#Create the date folder if it doesnt already exist
$plannedDir = "$($deletedFolderPath)\$((Get-Date).ToString('yyyy-MM-dd'))"

if(!(Test-Path -Path $plannedDir )){
    New-Item -ItemType directory -Path $plannedDir
}
#


#Get children of folder to query
$files = Get-ChildItem $deletedPath
#

#Loop through the files to be deleted
for ($i = 0; $i -lt $files.Count; $i++){

    #If the file is the deleted folder itself lets skip it
    if($files[$i].Name -ieq $deletedFolderName){
        continue
    }

    #Move the item to the new chosen path
    Move-Item -Path $files[$i].FullName -Destination $plannedDir

}
#

#Let em know it works
echo "Files Moved Successfully"
