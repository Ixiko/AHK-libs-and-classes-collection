# Define parameters
#$tfsCollectionUrl = New-Object System.URI("http://tfs1.dcsl.local:8080/tfs/ExclaimerProducts");
param([string]$tfsCollectionUrl);
if ($tfsCollectionUrl.Equals("")){
    Exit
}
$tfsCollectionUrl = New-Object System.URI($tfsCollectionUrl);

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
$projectService = $tfsCollection.GetService([Microsoft.TeamFoundation.Server.ICommonStructureService]);

# Query all the projects 
$projects = $projectService.ListAllProjects();

$arr = @{}

foreach ($project in $projects) 
{ 
  #Write-Host Finding environments for project $project.Name

  # Query all environments in this project 
  $labEnvironmentQuerySpec = New-Object Microsoft.TeamFoundation.Lab.Client.LabEnvironmentQuerySpec; 
  $labEnvironmentQuerySpec.Disposition = [Microsoft.TeamFoundation.Lab.Client.LabEnvironmentDisposition]::Active; 
  $labEnvironmentQuerySpec.Project = $project.Name;


  $labEnvironments = $labService.QueryLabEnvironments($labEnvironmentQuerySpec);

  #$arr["foo"] = "bar"
  if ($labEnvironments.Count)
  {
      $arr[$project.Name] = @{}
      foreach ($environment in $labEnvironments) 
      { 
        if ($environment.LabSystems.Count)
        {
            $arr[$project.Name][$environment.Name] = @{}
    
            foreach ($machine in $environment.LabSystems)
            {
                if ($machine.ComputerName)
                {
                    $arr[$project.Name][$environment.Name][$machine.Name] = $machine.ComputerName
                }
            }
        }
      }
    }  
}

$str = ConvertTo-Json($arr) -Depth 10
Write-Host $str
