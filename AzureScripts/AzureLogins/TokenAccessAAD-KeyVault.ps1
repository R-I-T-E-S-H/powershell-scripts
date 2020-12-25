function Get-OAuth2Uri
(
[string]$vaultName
)
{
  $response = try { Invoke-RestMethod -Method GET -Uri "https://$vaultName.vault.azure.net/keys" -Headers @{} } catch { $_.Exception.Response }
  $authHeader = $response.Headers['www-authenticate']
  $endpoint = [regex]::match($authHeader, 'authorization="(.*?)"').Groups[1].Value

  return "$endpoint/oauth2/token"
}



function Get-AccessToken
(
  [string]$vaultName,
  [string]$aadClientId,
  [string]$aadClientSecret
)
{
  $oath2Uri = Get-OAuth2Uri -vaultName $vaultName

  $body = 'grant_type=client_credentials'
  $body += '&client_id=' + $aadClientId
  $body += '&client_secret=' + [Uri]::EscapeDataString($aadClientSecret)
  $body += '&resource=' + [Uri]::EscapeDataString("https://vault.azure.net")

  $response = Invoke-RestMethod -Method POST -Uri $oath2Uri -Headers @{} -Body $body

  return $response.access_token
}

function Get-Keys
(
  [string]$accessToken,
  [string]$vaultName
)
{
  $headers = @{ 'Authorization' = "Bearer $accessToken" }
  $queryUrl = "https://$vaultName.vault.azure.net/Keys" + '?api-version=2016-10-01'
  #$queryUrl = "https://$vaultName.vault.azure.net/Secrets" + '?api-version=2016-10-01'

  $keyResponse = Invoke-RestMethod -Method GET -Uri $queryUrl -Headers $headers

  return $keyResponse.value
}


  $vaultName = ''
  $aadClientId = ''
  $aadClientSecret = ''
  
  $accessToken = Get-AccessToken -vaultName $vaultName -aadClientId $aadClientId -aadClientSecret $aadClientSecret
  Get-Keys -accessToken $accessToken -vaultName $vaultName

