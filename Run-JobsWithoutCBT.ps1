#Launch the Veeam PowerShell Plugins
. "C:\Program Files\Veeam\Backup and Replication\Backup\Install-VeeamToolkit.ps1"

#Gather VMware Jobs
$Jobs = Get-VBRJob | ? { $_.BackupPlatform -match "VMware" -and $_.JobType -eq "Backup" }

#Run each job with change tracking disabled, then re-enable
foreach ($Job in $Jobs) {
	#If job is running, wait for it to complete before moving on
	$JobStopped = $false
	while(!$JobStopped) {	
			Get-VBRJob -Name $Job.name | ? { $_.IsRunning -ne $true } | % { $JobStopped = $true}
			Sleep -Seconds 10
		}
	
	#Disable CBT and start the job
	$Job | Set-VBRJobAdvancedViOptions -UseChangeTracking $false | Out-Null
	$Job | Start-VBRJob | Out-Null
	
	$JobStopped = $false
	#Wait for the job to complete running before moving on
	while(!$JobStopped) {	
			Get-VBRJob -Name $Job.name | ? { $_.IsRunning -ne $true } | % { $JobStopped = $true }
			Sleep -Seconds 10
		}
	
	#Enable CBT after the job has stopped
	$Job | Set-VBRJobAdvancedViOptions -UseChangeTracking $true | Out-Null

}
