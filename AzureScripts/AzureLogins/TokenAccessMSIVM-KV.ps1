Connect-AzAccount -msi -Subscription ytytytytytytytyyt
$secret = Get-AzKeyVaultSecret -VaultName XXXX -name yyyyy
$secret.VaultName