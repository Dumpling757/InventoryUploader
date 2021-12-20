<#
.SYNOPSIS
    InventoryUploader
.DESCRIPTION
    When inventories are uploaded to an old RayVentory Server directly, this script uploads the inventories to a Scan Engine
.INPUTS
    $OriginWarehousePath: Location of the original Warehouse. e. g. "C:\RayVentory" this parameter must not end with a slash!
    $DestinationScanengine: HTTP(S) Path of the Scan Engine, where the Inventories are to be uploaded to.
    [$Certificate]: Path to Certificate used for Upload
    [$UploadUser]: User for authentication towards the Scan Engine
    [$UploadPassword]: Password for authentication towards the Scan Engine
.OUTPUTS
    Output (if any)
.NOTES
    General notes
#>


$OriginWarehousePath = "E:\RayVentory"
$DestinationScanengine = "https://sam-bhyp-b03.cmp.ad.bhyp.de:443"
$Certificate = $null
$UploadUser = $null
$UploadPassword = $null


if($UploadUser -and $UploadPassword) {
    [securestring]$SecPWD = ConvertTo-SecureString $UploadPassword -AsPlainText -Force
    [pscredential]$Credential = New-Object System.Management.Automation.PSCredential ($UploadUser, $SecPWD)
}

Get-ChildItem -Path "$OriginWarehousePath\Incoming\Inventories\*" -Filter "*.gz" | ForEach-Object {
    
    if($Certificate -and !($UploadUser -and $UploadPassword)) {

       $upload = Invoke-WebRequest -Uri $DestinationScanengine -Method Put -InFile $_ -ContentType "text/plain" -Certificate $Certificate
    }

    elseif(!$Certificate -and ($UploadUser -and $UploadPassword)) {

        $upload = Invoke-WebRequest -Uri $DestinationScanengine -Method Put -InFile $_ -ContentType "text/plain" -Credential $Credential
    }

    elseif($Certificate -and ($UploadUser -and $UploadPassword)) {

        $upload = Invoke-WebRequest -Uri $DestinationScanengine -Method Put -InFile $_ -ContentType "text/plain" -Certificate $Certificate -Credential $Credential
    }
    else {
        $upload = Invoke-WebRequest -Uri $DestinationScanengine -Method Put -InFile $_ -ContentType "text/plain"
    }
       if(($upload.StatusCode -eq 200)) {
           # Remove-Item -Path $_
           Move-Item -Path $_ -Destination "$PSScriptRoot/Processed/"
       }
       else {
           Move-Item -Path $_ -Destination "$PSScriptRoot/BadLogs/"
       }
    
}