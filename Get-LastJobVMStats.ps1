#Searching for Jobs I'd Like
$Jobs = Get-VBRJob | ? { $_.Name -match "My Jobs" }

#capture the results in $results
$results = invoke-command -script {
	foreach ($Job in $Jobs) {
		#stepping through each job's latest session
		$LastSession = $Job.FindLastSession()
		
		#gathering job info
		$JobName = $Job.Name
		$JobState = $LastSession.State
		$JobStart = $LastSession.CreationTime
		$JobEnd = $LastSession.EndTime
		$JobResult = $LastSession.Result
		
		#gathering job's tasks info
		$TaskSessions = $LastSession | Get-VBRTaskSession
		
		#returning all the results as one line per record
		$TaskSessions | % {
			select  Name, Status, @{n="AvgSpeed-MBs";e={[int]($_.progress.AvgSpeed / 1MB)}}

			New-Object psobject -Property ([ordered]@{
					"Job Name" = $JobName
					"Job State" = $JobState
					"Job Start" = $JobStart
					"VM Name" = $_.Name
					"Status" = $_.Status
					"QueuedTime" = $_.info.QueuedTime
					"Start Time" = $_.progress.StartTime
					"Duration" = $_.progress.Duration
					"AvgSpeed-MBs" = [math]::Round(($_.progress.AvgSpeed / 1MB),2)
			})
		}
	}
}

#displaying the results
$results | ft *