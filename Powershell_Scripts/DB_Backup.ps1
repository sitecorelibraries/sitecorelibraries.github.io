$Server = 'Put Your ServerName'
$Database = 'Database Name for Backup'
$FilePath = 'TargetLocation\DatabaseName.bak'
Backup-SqlDatabase -ServerInstance $Server -Database $Database -BackupFile $FilePath 