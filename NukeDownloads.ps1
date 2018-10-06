<#
.SYNOPSIS
    This script is to be ran on a daily basis and deletes all downloads from users directories
.DESCRIPTION
    This script is designed to keep downloads folders clean and remove any need for unneccecary backups.
.NOTES
    File Name      : NukeDownloads.ps1
    Author         : E.J Gallant (ethan@exclnetworks.com)
    Prerequisite   : PowerShell V2 over Vista and upper.
    Copyright 2018 - ExclNetworks (https://exclnetworks.com)
#>

#Create static variables
$path = "S:\Users" #FileServer drive and users directory

#Delete all the files in the downloads folders
Get-ChildItem -Path $path\*\Downloads -Recurse -Force -ErrorAction SilentlyContinue | foreach { $_.Delete()}