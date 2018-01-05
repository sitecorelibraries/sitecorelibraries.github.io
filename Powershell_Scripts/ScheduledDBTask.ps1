$TaskName = "ScheduledDBBackupTask"
$TaskCommand = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
$TaskScript = "D:\DB_Backup.ps1"

$Action = New-ScheduledTaskAction -Execute $TaskCommand -Argument "-NONInteractive -NoLogo -NoProfile -File $TaskScript"

$Trigger = New-ScheduledTaskTrigger -Daily -At '05:35PM'

$Task = New-ScheduledTask -Action $Action -Trigger $Trigger -Settings (New-ScheduledTaskSettingsSet)

$Task | Register-ScheduledTask -TaskName $TaskName
