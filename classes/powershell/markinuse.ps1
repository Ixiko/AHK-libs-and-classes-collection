# Define parameters
param([string]$tfsCollectionUrl, [string]$projectName, [string]$environmentName, [string]$state)
#$state = ToInt32($state);
#$tfsCollectionUrl = New-Object System.URI("http://tfs1.dcsl.local:8080/tfs/ExclaimerProducts"); 
#$projectName = "Email Alias Manager I"; 
#$environmentName = "NI EAM Smoke Test";

# Load Client Assembly 
$baseDir = Split-Path -parent $PSCommandPath
add-type -Path "$baseDir\Microsoft.VisualStudio.Services.Common.dll";
add-type -Path "$baseDir\Microsoft.TeamFoundation.Common.dll";
add-type -Path "$baseDir\Microsoft.TeamFoundation.Client.dll";
add-type -Path "$baseDir\Microsoft.TeamFoundation.Lab.Client.dll";
add-type -Path "$baseDir\Microsoft.TeamFoundation.Lab.Common.dll";

# Connect to tfs 
$tfsCollection = [Microsoft.TeamFoundation.Client.TfsTeamProjectCollectionFactory]::GetTeamProjectCollection($tfsCollectionUrl); 
$labService = $tfsCollection.GetService([Microsoft.TeamFoundation.Lab.Client.LabService]);

# Query for environments 
$labEnvironmentQuerySpec = New-Object Microsoft.TeamFoundation.Lab.Client.LabEnvironmentQuerySpec; 
$labEnvironmentQuerySpec.Project = $projectName; 
$labEnvironmentQuerySpec.Disposition = [Microsoft.TeamFoundation.Lab.Client.LabEnvironmentDisposition]::Active;

$labEnvironments = $labService.QueryLabEnvironments($labEnvironmentQuerySpec); 
foreach ($environment in $labEnvironments) 
{ 
   $envName = $environment.Name; 
   if ($envName -eq $environmentName) 
   { 
     $matchingEnvironment = $environment; 
   } 
}

# whether the environment is already in use 
$inUseMarker = $matchingEnvironment.GetInUseMarker();

if ($state -eq 1){
    if ($inUseMarker -eq $null) 
    { 
       Write-Host Marking Environment as in use;

       $matchingEnvironment.SetInUseMarker("Reserving the environment for script testing purpose"); 
    } 
    else 
    { 
       Write-Host Environment is already in use since $inUseMarker.Timestamp by $inUseMarker.User with details $inUseMarker.Comment; 
    }
} else {
    Write-Host Marking environment as not in use
    $matchingEnvironment.RemoveInUseMarker();
}