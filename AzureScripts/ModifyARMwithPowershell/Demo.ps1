$templatePath = 'C:\Technical\PSight\powershell-devops-playbook\04\demos\demos\Converting PowerShell to ARM\arm_template.json'
$armTemplate = Get-Content -Path $templatePath -Raw | ConvertFrom-Json
$armTemplate.resources | Select-Object {$_.name}

## Look to find how to add the resource
https://docs.microsoft.com/en-us/azure/templates/

## Define our snippet
$snippetJson = @'
{
	"type": "Microsoft.Storage/storageAccounts",
	"name": "adbpluralsightstorage",
	"apiVersion": "2019-04-01",
	"location": "[resourceGroup().location]",
	"sku": {
		"name": "Standard_LRS"
	},
	"properties": {}
}
'@

$resource = $snippetJson | ConvertFrom-Json
$armTemplate.resources.Count += $resource

$armTemplate

$armTemplate | ConvertTo-Json -Depth 100 | foreach { [System.Text.RegularExpressions.Regex]::Unescape($_) } | Set-Content -Path 'C:\modfied-armtemplate.json'

Get-Content -Path 'C:\modfied-armtemplate.json'


.\ARMTemplateMods.ps1
New-AzArmTemplateResource -Json $snippetJson
New-AzArmTemplateResource -Json $snippetJson | Set-AzArmTemplate -TemplatePath $templatePath
Get-Content -Path $templatePath