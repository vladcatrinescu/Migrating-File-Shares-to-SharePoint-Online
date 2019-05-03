$cred = (Get-Credential vlad@globomantics.org)
$sourceFiles = 'C:\Demos\Legal Contracts'
$sourcePackage = 'C:\Demos\Migration\Package_Source'
$targetPackage = 'C:\Demos\Migration\Package_Target'
$targetWeb = 'https://globomanticsorg.sharepoint.com/sites/GLobomanticsMigration'
$targetDocLib = 'LegalDocs'
$adminSite = 'https://globomanticsorg-admin.sharepoint.com'
$azureAccountName = 'globomanticsorg'
$azureAccountKey = 'PbA31nSje6PvMCV8f2j5PNOlNJdtntRH0ZAmVfAGhimO8Gj/oYDpZH2D7ZAMmxcYXAAl0Jy0rm6H6yDhi9368A=='
$azureQueueName = 'TestMigration'
Connect-SPOService -Url $adminSite -Credential $cred

$tempPackage = New-SPOMigrationPackage -SourceFilesPath $SourceFiles -OutputPackagePath $sourcePackage -TargetWebUrl $targetWeb -TargetDocumentLibraryPath $targetDocLib -NoAzureADLookup -ReplaceInvalidCharacters

$FinalPackage = ConvertTo-SPOMigrationTargetedPackage -SourceFilesPath $SourceFiles -SourcePackagePath $sourcePackage -OutputPackagePath $targetPackage -TargetWebUrl $targetWeb -TargetDocumentLibraryPath $targetDocLib -Credential $cred -ParallelImport

$UploadJob = Set-SPOMigrationPackageAzureSource -SourceFilesPath $sourceFiles -SourcePackagePath $targetPackage -AzureQueueName $azureQueueName -AccountName $azureAccountName -AccountKey $azureAccountKey

$MigrationJob = Submit-SPOMigrationJob -TargetWebUrl $targetWeb -MigrationPackageAzureLocations $UploadJob -Credentials $cred

$status = Get-SPOMigrationJobProgress -AzureQueueUri $UploadJob.ReportingQueueUri -Credentials $cred
