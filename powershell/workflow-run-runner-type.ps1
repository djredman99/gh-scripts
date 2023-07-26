$org='djredman99-org'
$repo='Demo-One'

$hosted = @("ubuntu-latest", "windows-latest", "macos-latest", "ubuntu-22.04", "ubuntu-20.04", "windows-2022", "windows-2019", "macos-12", "macos-latest-xl", "macos-12-xl", "macos-11")
$large_runner_name = ""

# if you need to auth
# $TOKEN = '<add your PAT>'
# echo $TOKEN | gh auth login --with-token
"" ; "" ; "" ; ""
   
$r = gh api repos/$($org)/$($repo)/actions/runs
$runs = $r | ConvertFrom-Json
Write-Host "REPO" $repo "has" $runs.total_count "workflow runs"   -ForegroundColor Green
"" 

if ($runs.total_count -gt 0) {
    $runs.workflow_runs | foreach {
        Write-Host "WORKFLOW" $_.name ":" -ForegroundColor Yellow
        $x = gh api repos/$($org)/$($repo)/actions/runs/$($_.id)
        $run = $x | ConvertFrom-Json
        $j = gh api repos/$($org)/$($repo)/actions/runs/$($run.id)/attempts/1/jobs
        $jobs = $j | ConvertFrom-Json
    
        $jobs.jobs | foreach {
            "JOB: " + $_.name
            "  ran on --- [" + $_.labels + "]"

            $isHosted = $false
            $isLarge = $false
            # Check if label(s) matches hosted runner using $hosted array      
            $_.labels | foreach {
                if ($hosted -contains $_){
                    $isHosted = $true
                }
                elseif($large_runner_name -eq $_){
                    $isLarge = $true
                }
            }

            if ($isHosted){
                "   RUNNER-TYPE is Hosted"
            }
            elseif ($isLarge) {
                "   RUNNER-TYPE is Large Runner"
            }
            else {
                "   RUNNER-TYPE is Self-Hosted"
            }
            
        }

        "" ; ""
    }
}

