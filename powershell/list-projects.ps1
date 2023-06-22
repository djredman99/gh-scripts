$org='djredman99-org'


$projects = gh api graphql -F login=$org -f query='
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
    
    "Project is " + $_.number + ":" + $_.title + $_.id
}