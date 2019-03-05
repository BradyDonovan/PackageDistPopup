param (
    [string]$packageID
)

function Get-PackageDistributionStatus {
    <#
    .SYNOPSIS
    Query the SMS provider for distribution status.
    
    .DESCRIPTION
    Continuously query the SMS provider for package distribution status from parameter input, then return a success message when it's finished. Need to be local admin for site code pull from WMI.
    
    .PARAMETER packageID
    PackageID to query.
    
    .EXAMPLE
    Internal function to this script so you likely won't need to use this outside, but if you'd like..
    Get-PackageDistributionStatus -packageID CM000000
    
    .NOTES
    Contact information:
    https://github.com/BradyDonovan
    #>
    

    param (
        [parameter(Mandatory = $true)]
        [string]$packageID 
    )
    process {
        $siteCode = (Invoke-WmiMethod -Name GetAssignedSite -Namespace "root\ccm" -Class SMS_Client).sSiteCode # grab site code from WMI
        $providerMachineName = (Get-WmiObject -Namespace "root\ccm" -Query "select CurrentManagementPoint from SMS_Authority").CurrentManagementPoint # grab MP from WMI
    
        # grab package dist info until it's not in progress
        try {
            DO {
                $inProgress = Get-WmiObject -Namespace "root\SMS\site_$siteCode" -Query "Select NumberInProgress from SMS_ObjectContentExtraInfo WHERE PackageID = '$packageID'" -ComputerName $providerMachineName
            }
            UNTIL ($inProgress.NumberInProgress -eq 0)
            $complete = "Package distribution for $packageID complete."
            Return $complete
        }
        catch {
            "Query to $providerMachineName failed. Reason: $_"
        }
    }
}
function Show-DistributionPopupComplete {
    <#
    .SYNOPSIS
    Show a popup with failed dynamic install applications.
    
    .DESCRIPTION
    N/A
    
    .EXAMPLE
    Show-FailedApplicationsPopup -ApplicationList $failedAppsArray
    
    .NOTES
    Contact information:
    https://github.com/BradyDonovan
    #>
    param (
        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Message
    )
    begin {
        try {
            $wshell = New-Object -ComObject Wscript.Shell
        }
        catch {
            Throw "$_"
        }
    }
    process {
        $wshell = New-Object -ComObject Wscript.Shell
        $wshell.Popup($message, 0, "Package Distribution Status", 4096) # system modal popup so it overlays everything
    }
}


$distStatus = Get-PackageDistributionStatus -packageID $packageID # will only have output when distribution is complete; you won't see a popup until distribution is complete
Show-DistributionPopupComplete -Message $distStatus
