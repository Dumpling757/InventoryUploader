<#
.SYNOPSIS
    InventoryUploader
    Author: Marius Ulbrich
    Version: 1.0.0.0
    Company: Raynet GmbH

.DESCRIPTION
    When inventories are uploaded to an old RayVentory Server directly, this script uploads the inventories to a Scan Engine
.INPUTS
    $OriginWarehousePath: Location of the original Warehouse. e. g. "C:\RayVentory" this parameter must not end with a slash!
    $DestinationScanengine: HTTP(S) Path of the Scan Engine, where the Inventories are to be uploaded to.

.OUTPUTS
    Output (if any)
.NOTES
    General notes

#>


$OriginWarehousePath = "E:\RayVentory"
$DestinationScanengine = "https://sam-bhyp-b03.cmp.ad.bhyp.de/"


$Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
$Logfile = "InventoryUploader-$Stamp.log"

New-Item  -Path $PSScriptRoot -ItemType "file" -Name $Logfile
function WriteLog
{
    Param ([string]$LogString)
    $Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
    $LogMessage = "$Stamp $LogString"
    Add-content $LogFile -value $LogMessage
}

Get-ChildItem -Path "$OriginWarehousePath\Incoming\Inventories\" | ForEach-Object {
    
    $Destination = $DestinationScanengine + $_

       $upload = Invoke-WebRequest -Uri $Destination -Method Put -InFile $_ -UseDefaultCredentials

    if(($upload.StatusCode -eq 200)) {
        # Remove-Item -Path $_
        Move-Item -Path $_ -Force -Destination "$PSScriptRoot/Processed/"
        WriteLog "$_ successfully uploaded"
    }
    else {
        Move-Item -Path $_ -Force -Destination  "$PSScriptRoot/BadLogs/"
        WriteLog "$_ was not uploaded but can be found here: $PSScriptRoot/BadLogs/"
    }
    
}