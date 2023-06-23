# This script uses the GraphQL API to move Org-level projectsV2 (new projects as opposed to classic projects) from one org to another 
# since the GEI migration tool does not yet support this.  Also, it is likely that support in GEI, once added, would only do so
# in the case of an org-to-org migration

# IT ALSO has movie quotes for fun, which was a topic of conversation with the customer I created this for at the time :)

﻿# If you need to do this with two different auth'd account (GHEC to EMU for example) you would just need
# to add the gh auth login calls previous to switching to calls against the different orgs:
#    $env:GH_TOKEN = $source_PAT
#    gh auth login
#    .
#    .
#    .
#    $env:GH_TOKEN = $target_PAT
#    gh auth login


$sourceOrg = 'djredman99-org';
$sourceProjectNumber = 3;

$targetOrg = 'djredman99-org';
$targetProjectNumber = 6;
$targetProjectID = ''

# To turn off the movie quotes, but why would you?? :)
$moviequotes = $true

Write-Host "              ..---HERE WE GO---.." 
Write-Host "              ....------------...." 
Write-Host "              ......--------......" 
Write-Host "              ........----........"
Write-Host "              .........--........."


gh api https://api.github.com/octocat

# Check to see if a project is set
if ($moviequotes) { Write-Host "ADRIAAAAAANNNNNN" -ForegroundColor Cyan }
if ($sourceProjectNumber -is [int]){
    "Checking source project..."
    # get a specific project
    $project = gh api graphql -F login=$sourceOrg -F number=$sourceProjectNumber -f query='
      query($login: String!, $number: Int!) {
          organization(login: $login) {
            projectV2(number: $number) {
              id
              number
              title
            }
          }
        }
    '
    $p = $project | ConvertFrom-Json
    Write-Host "Project to duplicate: NUMBER:" $p.data.organization.projectv2.number "TITLE:" $p.data.organization.projectv2.title -ForegroundColor Green

}
else
{
    Write-Host "No SOURCE project set...listing projects"
    # list the projects in org
    $projects = gh api graphql -F login=$sourceOrg -f query='
      query($login: String!) {
          organization(login: $login) {
            projectsV2(first: 100) {
              nodes {
                id
                number
                title
              }
            }
          }
        }
    '
    $p = $projects | ConvertFrom-Json
    $p.data.organization.projectsv2.nodes | foreach {
    
        Write-Host "Available Projects are " $_.number ":" $_.title -ForegroundColor Green
    } 
    if ($moviequotes) { Write-Host "You’re A Disease. I’m The Cure" -ForegroundColor Cyan }
    exit 0
}

if ($targetProjectNumber -is [int]){
    "Checking target project..."
    # get a specific project
    $project = gh api graphql -F login=$targetOrg -F number=$targetProjectNumber -f query='
      query($login: String!, $number: Int!) {
          organization(login: $login) {
            projectV2(number: $number) {
              id
              number
              title
            }
          }
        }
    '
    $p = $project | ConvertFrom-Json
    Write-Host "Project to add items to: NUMBER:" $p.data.organization.projectv2.number "TITLE:" $p.data.organization.projectv2.title -ForegroundColor Green
    $targetProjectID = $p.data.organization.projectv2.id
    Write-Host "The ID of the project to add items to is:" $targetProjectID
}
else
{
    Write-Host "No TARGET project set...listing projects"
    # list the projects in org
    $projects = gh api graphql -F login=$targetOrg -f query='
      query($login: String!) {
          organization(login: $login) {
            projectsV2(first: 100) {
              nodes {
                id
                number
                title
              }
            }
          }
        }
    '
    $p = $projects | ConvertFrom-Json
    $p.data.organization.projectsv2.nodes | foreach {
    
        Write-Host "Available Projects are " $_.number ":" $_.title -ForegroundColor Green
    } 
    if ($moviequotes) { Write-Host "You’re A Disease. I’m The Cure" -ForegroundColor Cyan}
    exit 0
}

if ($moviequotes) { Write-Host "Cut me Mick" -ForegroundColor Cyan}
# Find Project Items in source
Write-Host "Getting project items from source"
if ($moviequotes) { Write-Host "I'll be BACK" -ForegroundColor Yellow}
$items = gh api graphql -F login=$sourceOrg -F number=$sourceProjectNumber  -f query='
     query($login: String!, $number: Int!){
      organization(login: $login) {
        projectV2(number: $number) {
          id
          title
          items(first: 100) {
            nodes {
              content {
                ... on Issue {
                  id
                  number
                  title
                  repository {
                    name
                  }
                }
                ... on PullRequest {
                  id
                  title
                  number
                  repository {
                    name
                  }
                }
                ... on DraftIssue {
                  id
                  title
                }
              }
              type
            }
          }
        }
      }
    }
'



# Add project items to target
$i = $items | ConvertFrom-Json
$count = $i.data.organization.projectV2.items.nodes | measure
#echo $count

#echo @($i.data.organization.projectV2.items.nodes).Count

if ($count.Count -gt 0) {
    Write-Host "Found Items to link:"
    $i.data.organization.projectv2.items.nodes | foreach {
    
        Write-Host "Source Item is Repository :" $_.content.repository.name ":" $_.type ":" $_.content.number ":" $_.content.title  -ForegroundColor Green
        Write-Host "Getting target item..."

        $org = $targetOrg
        $repo = $_.content.repository.name
        $num = $_.content.number
        $item = ''
        $id = ''

        if ($_.type -eq "ISSUE" ) {
            $item = gh api graphql -F login=$org -F repo=$repo -F number=$num -f query='
                query($login: String!, $repo: String!, $number: Int!) {
                  organization(login: $login) {
                    repository(name: $repo) {
                      id
                      issue(number: $number) {
                        id
                        title
                      }
                    }
                  }
                }'
            Write-Host "The Item is" $item -ForegroundColor Green
            $i = $item | ConvertFrom-Json
            if ($i.data.organization.repository.issue -ne "null") {
                Write-Host "Found the target item..." $i.data.organization.repository.issue.title
                if ($moviequotes) { Write-Host "Did we just become Best Friends?!?" -ForegroundColor Magenta }
                "ID is" + $i.data.organization.repository.issue.id
                $id = $i.data.organization.repository.issue.id
            }

        }
        elseif ($_.type -eq "PULL_REQUEST") {
            $item = gh api graphql -F login=$org -F repo=$repo -F number=$num -f query='
                query($login: String!, $repo: String!, $number: Int!) {
                  organization(login: $login) {
                    repository(name: $repo) {
                      id
                      pullRequest(number: $number) {
                        id
                        title
                      }
                    }
                  }
                }'
            Write-Host "The Item is" $item -ForegroundColor Green
            $i = $item | ConvertFrom-Json
            if ($i.data.organization.repository.pullRequest -ne "null") {
                Write-Host "Found the target item..." $i.data.organization.repository.pullRequest.title
                if ($moviequotes) { Write-Host "Did we just become Best Friends?!?" -ForegroundColor Magenta }
                $id = $i.data.organization.repository.pullRequest.id.PSObject.Copy()
            }

        }
        else {
            Write-Host "I don't know the type of item...I'm bailing" -ForegroundColor Red
            exit 1
        }

        Write-Host "Linking to project..." -NoNewline
        $itemID = $id
        Write-Host "Item ID:" $itemID
        $response = gh api graphql -F pID=$targetProjectID -F iID=$itemID -f query=' mutation($pID: ID!, $iID: ID!) { addProjectV2ItemById(input: {projectId: $pID contentId: $iID}) { item { id } } }'
        Write-Host "The response" $response
        if ($moviequotes) { Write-Host "If it bleeds, we can kill it" -ForegroundColor Yellow }
    }

    Write-Host "Process complete"
  

}
else {
    Write-Host "No items found in the project, NOTHING TO MOVE" -ForegroundColor Red
}



if ($moviequotes) { Write-Host "Hasta la vista, baby!" -ForegroundColor Yellow }
