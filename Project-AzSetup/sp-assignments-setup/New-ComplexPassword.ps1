workflow New-ComplexPassWord {
  <# Future Updates
    - securesting? 
    - extend randomeness: https://poshhelp.wordpress.com/2017/01/30/why-you-should-stop-using-generatepassword/
    #>
  param(
    [Parameter(Mandatory = $false)]
    [int]$PwdLength = 20,
    [Parameter(Mandatory = $false)]
    [int]$NonAlphaNumChar = 2
  )
  # generate new password (20 characters, minimum 2 alphanumeric characters)
  $null = [Reflection.Assembly]::LoadWithPartialName("System.Web")
  [String] $NewPassWord = [System.Web.Security.Membership]::GeneratePassword($PwdLength, $NonAlphaNumChar)

  return $NewPassWord
}