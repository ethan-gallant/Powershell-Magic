<#
.SYNOPSIS
    This script renames all .jpeg files to the extention .jpg
.DESCRIPTION
    Why would anyone want this might you ask? Well im glad you asked because its due to how horrid medical software is.
	The $10,000 dental software that my office uses cant handle the extention .jpeg so its required to rename everything
	with the new file extention.
.NOTES
    File Name      : FSWatch.ps1
    Author         : E.J Gallant (ethan@exclnetworks.com)
    Prerequisite   : PowerShell V2 over Vista and upper.
    Copyright 2018 - ExclNetworks (https://exclnetworks.com)
#>

$folder = "S:\Junk"
$filter = "*.jpeg"
$Watcher = New-Object IO.FileSystemWatcher $folder, $filter -Property @{ 
    IncludeSubdirectories = $true
    NotifyFilter = [IO.NotifyFilters]'FileName, LastWrite'
}
$onCreated = Register-ObjectEvent $Watcher Created -SourceIdentifier FileCreated -Action {
   $path = $Event.SourceEventArgs.FullPath
   $name = $Event.SourceEventArgs.Name
   $changeType = $Event.SourceEventArgs.ChangeType
   $timeStamp = $Event.TimeGenerated
   Write-Host "The file '$name' was $changeType at $timeStamp"
   Write-Host $path
   Rename-Item $path $([System.IO.Path]::ChangeExtension($path, ".jpg"))
}

$onRenamed = Register-ObjectEvent $Watcher Renamed -SourceIdentifier FileRenamed -Action {
   $path = $Event.SourceEventArgs.FullPath
   $name = $Event.SourceEventArgs.Name
   $changeType = $Event.SourceEventArgs.ChangeType
   $timeStamp = $Event.TimeGenerated
   Write-Host "The file '$name' was $changeType at $timeStamp"
   Write-Host $path
   Rename-Item $path $([System.IO.Path]::ChangeExtension($path, ".jpg"))
}