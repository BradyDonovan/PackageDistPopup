# PackageDistPopup
I got tired of waiting for package distribution in my environment, so I wrote something to notify me when it's done. 

# Usage
```powershell
Invoke-PackageDistributionNotification.ps1 -packageID CM000000
```
Run as admin so `sSiteCode` can be pulled from WMI, otherwise it will not work. Assumptions are also made that you have access to your SMS Provider and can run WMI queries against it.
