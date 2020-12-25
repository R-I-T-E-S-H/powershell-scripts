function Get-AValue ()
{
[CmdletBinding()] #Needed to indicate advance function
param (
        [Parameter( Mandatory = $true,
                    HelpMessage = 'Please enter integer value One'
                    )]
        [int] $one,
        [Parameter( Mandatory = $false,
                    HelpMessage = 'Please enter integer value Two, default is 42'
                    )]
        [int] $two = 42
    )
begin {}
process {
            return $one * $two
        }
end {}

}