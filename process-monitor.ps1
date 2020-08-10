
$col = @{}
$myExeOutput = & Get-Process
Write-Output $myExeOutput | ForEach-Object {
	$col[$_.Id] = $_.ProcessName
}
Start-Sleep 1

function sendNotification {
	Add-Type -AssemblyName System.Windows.Forms 
	$global:balloon = New-Object System.Windows.Forms.NotifyIcon
	$path = (Get-Process -id $pid).Path
	$balloon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path) 
	$balloon.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Warning 
	$balloon.BalloonTipText = $args[0]
	$balloon.BalloonTipTitle = "Warning : " 
	$balloon.Visible = $true 
	$balloon.ShowBalloonTip(5000)
}

$surveillance = @{}

while (1) {
	$myExeOutput = & Get-Process

	$Newcol = @{}
	Write-Output $myExeOutput | ForEach-Object {
		$line = $_
		if ($col[$line.Id] -ne $line.ProcessName) {
			$notification = 'New process --> ' + $line.ProcessName + '(' + $line.Id + ')'
			write-host $notification
			$surveillance[$line.Id] = $line.ProcessName
			sendNotification $notification
		}
		$Newcol[$line.Id] = $line.ProcessName
	}
	$col = $Newcol

	$Newsurveillance = @{}
	$surveillance.Keys | ForEach-Object {
		$id = $_
		if (!($col.ContainsKey($id) -and $col[$id] -eq $surveillance[$id])) {
			$notification = 'Process finished --> ' + $surveillance[$id] + '(' + $Id + ')'
			write-host $notification
		} else {
			$Newsurveillance[$Id] = $surveillance[$Id]
		}
	}
	$surveillance = $Newsurveillance

	Start-Sleep 1
}
