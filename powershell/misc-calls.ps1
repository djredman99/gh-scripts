$org='djredman99-org'
$num=4

# list the projects in org
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

"Projects" + $projects

# get a specific project
$project = gh api graphql -F login=$org -F number=$num -f query='
  query($login: String!, $number: Int!) {
      organization(login: $login) {
        projectV2(number: $number) {
          id
          title
        }
      }
    }
'

"Project" + $project


# get the items in a specific project
$items = gh api graphql -F login=$org -F number=$num -f query='
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
                }
                ... on PullRequest {
                  id
                  title
                  number
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
"Items" + $items

$org = 'djredman99-org'
$repo = 'issues-demo'
$num = 5

# get a specific issue in a specific repo
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
}
'
"Item" + $item
