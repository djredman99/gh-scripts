$org='djredman99-org'

# if you need to auth
# $env:GH_TOKEN = '<add your PAT>'
# gh auth login


$repos = gh api graphql --paginate -F login=$org --jq '.[].organization.repositories.nodes[]' -f query='
  query($login: String!) {
      organization(login: $login) {
        repositories(first: 100) {
          nodes {
            name
          }
          totalCount
          pageInfo {
            hasNextPage
            endCursor
            startCursor
            hasPreviousPage
          }
        }
      }
    }
'

$r = $repos | ConvertFrom-Json
$r | foreach {  
   
    $h = gh api repos/$($org)/$($_.name)/hooks
    $webhooks = $h | ConvertFrom-Json
    $wh_count = $webhooks | measure
    "Repo " + $_.name + " has:"
    "    " + $wh_count.Count + " webhook(s)"

    $s = gh api repos/$($org)/$($_.name)/actions/secrets
    $secrets = $s | ConvertFrom-Json
    $secret_count = $secrets | measure
    "    " + $secret_count.Count + " secret(s)"

    $v = gh api repos/$($org)/$($_.name)/actions/variables
    $variables = $v | ConvertFrom-Json
    $variable_count = $variables | measure
    "    " + $variable_count.Count + " variable(s)"
}

