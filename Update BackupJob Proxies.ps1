<#
.SYNOPSIS
    Update Veeam Backup Jobs with new specific site Proxies
.DESCRIPTION
    The script grabs the desired proxies, backup jobs, and then
	disable auto-proxy detection while using the proxies
	specified per location.
.NOTES
    File Name      : Update BackupJob Proxies.ps1
    Author         : Justin Bennett (justin@allthingstechie.net)
    Date           : 2016-08-02
	Version	       : 1.0
	Revisions      : 1.0 Original
.LINK
.EXAMPLE
    .\Update BackupJob Proxies.ps1
#>
#Load Veeam Snap-in
Add-PSSnapin VeeamPSSnapin

#Connect to VBR Server
Connect-VBRServer -Server veeamstore.local
 
#Get Proxies
$Proxies = Get-VBRViProxy

#Assign Site Specific Proxies
$SiteAProxies = $Proxies | ? { $_.Name -match "proxy1.sitea.local|proxy2.siteb.local" }
$SiteBProxies = $Proxies | ? { $_.Name -match "proxy1.siteb.local" }

#Get Backup Jobs
$BackupJobs = Get-VBRJob | ? { $_.IsBackupJob }

#Get Site Specific Jobs
$SiteABackupJobs = $BackupJobs | ? { $_.Name -match "SiteA" }
$SiteBBackupJobs = $BackupJobs | ? { $_.Name -match "SiteB" }

#Update Job's - Disable AutoDetect and Manual Set Proxies

$SiteABackupJobs | % {
	$_.Options.JobOptions.SourceProxyAutoDetect = $false
	$_ | Set-VBRJobProxy -Proxy $SiteAProxies
}

$SiteBBackupJobs | % {
	$_.Options.JobOptions.SourceProxyAutoDetect = $false
	$_ | Set-VBRJobProxy -Proxy $SiteBProxies
}