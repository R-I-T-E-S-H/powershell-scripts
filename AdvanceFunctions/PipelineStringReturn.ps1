#To make pipeline enable function use begin-process-end block
function get-PSfiles ()
{
#begin executes once
begin
    {
    $retval = "Here are some Powershell Files"
    }
#process executes for each pipeline input
process
    {
        if($_.name -like "*.ps1")
        {
        $retval += "`t$($_.Name) `r `n"
        #Above expression is equal to below commented expression
        #$retval = $retval +"`t" + $_.Name + "`r `n"
        #'t Tab Character
        #'r Carriage Return
        #'n Line Feed
        #$() Tells PS to execute expression inside () first
        }
    }
end
#end block exectes once after process
    {
    return $retval
    }
}

$output = get-childitem -Recurse | get-PSFiles
$output.GetType()