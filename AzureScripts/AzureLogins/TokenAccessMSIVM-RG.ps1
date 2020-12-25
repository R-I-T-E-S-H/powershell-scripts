###############Request Token##############
$params = @{

Uri = "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fmanagement.azure.com%2F"
Headers = @{Metadata="true"}

}

$content = Invoke-WebRequest @params
Write-Output $content

$parsedcontent = $content | ConvertFrom-Json
$accessToken = $parsedcontent.access_token

Write-Output "Access Token is 'n 'n$($accessToken)"


#############Request Resource with Token############
$rgInfoRestparams = @{

Uri = "https://management.azure.com/subscriptions/<>/resourceGroups/<rgname>?api-version=2014-04-01"
#https://management.azure.com/subscriptions/7fd5afcb-ddc2-4d3f-bc22-b34f54991de2/resourceGroups/PowerAuthRG?api-version=2014-04-01

Method = "GET"
Content = "application/json"
Headers = @{Authorization = "Bearer $accessToken"}

}

$rgRestInfo = (Invoke-WebRequest @rgInfoRestparams).content

Write-Output $rgRestInfo

