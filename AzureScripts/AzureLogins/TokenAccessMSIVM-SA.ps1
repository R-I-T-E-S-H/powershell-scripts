Connect-AzAccount -msi -Subscription YYYYYYYYY

$context = New-AzStorageContext -StorageAccountName powerauthsg -UseConnectedAccount
New-AzStorageContainer -name docs -Context $context
Set-AzStorageBlobContent -file helloworld.txt -Container docs -Blob hellowworld.txt -BlobType Block -Context $context



