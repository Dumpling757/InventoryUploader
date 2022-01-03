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


}

Get-ChildItem -Path "$OriginWarehousePath\Incoming\Inventories\" | ForEach-Object {
    
    $Destination = $DestinationScanengine + $_.Name

       $upload = Invoke-WebRequest -Uri $Destination -Method Put -InFile $_.FullName -UseDefaultCredentials

    if(($upload.StatusCode -eq 200)) {
        # Remove-Item -Path $_
        Move-Item -Path $_.FullName -Force -Destination "$PSScriptRoot/Processed/"
        Write-Output "$_ successfully uploaded"
    }
    else {
        Move-Item -Path $_.FullName -Force -Destination  "$PSScriptRoot/BadLogs/"
        Write-Output "$_ was not uploaded but can be found here: $PSScriptRoot/BadLogs/"
    }
    
}