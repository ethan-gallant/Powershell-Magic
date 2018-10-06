<#
.SYNOPSIS
    This script shutsdown the workstations at night
.DESCRIPTION
    The script is set off at a set time in the task scheduler and turns off all the computers in an office organizational unit in our active directory.
.NOTES
    File Name      : ShutdownWorkstations.ps1
    Author         : E.J Gallant (ethan@exclnetworks.com)
    Prerequisite   : PowerShell V2 over Vista and upper.
    Copyright 2018 - ExclNetworks (https://exclnetworks.com)
#>

$computers = Get-ADComputer -Filter * -SearchBase "OU=Desktops, OU=MYOU, DC=corp, DC=MYDOMAIN, DC=COM"

for($i = 0; $i -lt $computers.Count; $i++){

	if(Test-Connection  -computername $computers[$i].Name -BufferSize 16 -Count 1 -Quiet){
		echo $computers[$i].Name is online
		Stop-Computer -Force -AsJob $computers[$i].Name
	} else {
		echo $computers[$i].Name is offline
	}

}