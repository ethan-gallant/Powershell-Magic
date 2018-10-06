<#
.SYNOPSIS
    This script backs up patterson to the cloud
.DESCRIPTION
    The script runs two async threads, one for shared files and one for data. They each upload to the cloud by themselves
    using the provided credentials.
.NOTES
    File Name      : CloudBackup.ps1
    Author         : E.J Gallant (ethan@exclnetworks.com)
    Prerequisite   : PowerShell V2 over Vista and upper.
    Copyright 2018 - ExclNetworks (https://exclnetworks.com)
#>

$timing = Measure-Command {

#Ensure 7 zip is installed
if (-not (test-path "$env:ProgramFiles\7-Zip\7z.exe")) {throw "$env:ProgramFiles\7-Zip\7z.exe needed"} 



###Source and target variables
$DataDir = "C:\Eaglesoft\Data"
$SharedFilesDir = "C:\Eaglesoft\Shared Files"
$Target = "C:\Scripts\BackupDir"
$GCPKey = "C:\Scripts\Credentials\backup-gcp-sa.json"
$GCPAccount = "backupaccount@your-gcp-project.iam.gserviceaccount.com"
$GCPStorageBucket = "mycompany-backups" 
$Password = "I would advise changing this and using a rolling key or timestamp"
###

#####STATIC VARIABLES DO NOT TOUCH!#####
$date = (Get-Date).ToString('yyyy-MM-dd')
$backupFileName = "PattersonBackup-$($date)"
$fullBackupPath= "$($target)\$($backupFileName)"
########################################

#Lets init our credentials
#NOTE THIS THROWS AN ERROR FOR NO REASON
gcloud auth activate-service-account $($GCPAccount) --key-file=$($GCPKey)
echo "Authentication with Google Cloud Servers successful"

#Backup the Data

$dataJob = start-job -Name DataBackup -Argument "$($fullBackupPath)","$($DataDir)","$($Password)","$($GCPStorageBucket)" { 
param($fullBackupPath,$DataDir,$Password,$GCPStorageBucket)
#Create an alias for 7zip    
set-alias sz "$env:ProgramFiles\7-Zip\7z.exe"  

echo "Zipping Data folder..."
sz a "$($fullBackupPath)-Data.7z" "$($DataDir)" -p"$($Password)" -mhe=on
echo "=====Finished Zipping Data====="

#Upload Data Backup
echo "Uploading Data..."
gsutil cp "$($fullBackupPath)-Data.7z" gs://$($GCPStorageBucket)/
echo "=====DATA UPLOADED====="

}

$sharedFilesJob = start-job -Name SharedFilesBackup -Argument "$($fullBackupPath)","$($SharedFilesDir)","$($Password)","$($GCPStorageBucket)" { 
param($fullBackupPath,$SharedFilesDir,$Password,$GCPStorageBucket)

set-alias sz "$env:ProgramFiles\7-Zip\7z.exe" 

#Backup Shared Files
echo "Zipping Shared Files folder"
sz a "$($fullBackupPath)-SharedFiles.7z" "$($SharedFilesDir)" -p"$($Password)" -mhe=on
echo "=====Finished Zipping Shared Files====="



#Upload Shared Files Backup
echo "Uploading Shared Files..."
gsutil cp "$($fullBackupPath)-SharedFiles.7z" gs://$($GCPStorageBucket)/
echo "=====SHARED FILES UPLOADED====="

}

Wait-Job $dataJob
Wait-Job $sharedFilesJob
Receive-Job $dataJob
Receive-Job $SharedFilesJob

}
echo "BACKUP COMPLETED SUCCESSFULLY ON $($date)"
echo "This backup took approxiately $($timing.Hours) hours and $($timing.Minutes) minutes."