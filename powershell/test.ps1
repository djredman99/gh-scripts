$org='djredman99-org'

# if you need to auth
# $TOKEN = '<add your PAT>'
# echo $TOKEN | gh auth login --with-token


    $r = gh api repos/$($org)/Demo-one/actions/runs
    $runs = $r | ConvertFrom-Json
    "Repo " + $_.name + " has: " + $runs.total_count + " workflow runs" 

    # if ($runs.total_count -gt 0) {
    #     $runs.workflow_runs | foreach {
    #         "Workflow " + $_.name + ":"
    #         $_
    #         $run = gh api repos/$($org)/$($_.name)/actions/runs/$($_.id)
    #         $run
    #     }
    # }

    $run = gh api repos/$($org)/Demo-one/actions/runs/5672993812
    $j = gh api repos/$($org)/Demo-one/actions/runs/5672993812/attempts/1/jobs
    $jobs = $j | ConvertFrom-Json

    $jobs.jobs | foreach {
        $_.workflow_name + " job: " + $_.name + " ran on --- " + $_.labels
    }


