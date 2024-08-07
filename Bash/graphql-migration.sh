#!/bin/bash

# Set GitHub token and GraphQL API URL
GITHUB_TOKEN="${GITHUB_TOKEN:-_github_token}"
GRAPHQL_API_URL="https://api.github.com/graphql"

# Check if required environment variables are set
if [ -z "$GITHUB_TOKEN" ] || [ "$GITHUB_TOKEN" == "__token" ]; then
  echo "Error: GITHUB_TOKEN is not set."
  exit 1
fi

if [ -z "$ORG_LOGIN" ]; then
  echo "Error: ORG_LOGIN is not set."
  exit 1
fi

# Function to perform a GraphQL query
graphql_query() {
  local query=$1
  curl -s -X POST -H "Authorization: bearer $GITHUB_TOKEN" -H "Content-Type: application/json" \
    --data "{\"query\": \"$query\"}" $GRAPHQL_API_URL
}

# Function to get the organization ID
get_org_id() {
  local org_login=$1
  local query="query {
    organization(login: \"$org_login\") {
      login
      id
      name
    }
  }"
  graphql_query "$query"
}

# Function to start the import process
start_import() {
  local org_id=$1
  local query="mutation {
    startImport(input: {organizationId: \"$org_id\"}) {
      migration {
        uploadUrl
        guid
        id
        state
      }
    }
  }"
  graphql_query "$query"
}

# Function to check the status of the import
check_import_status() {
  local org_login=$1
  local migration_guid=$2
  local query="query {
    organization(login: \"$org_login\") {
      migration(guid: \"$migration_guid\") {
        guid
        id
        state
        uploadUrl
      }
    }
  }"
  graphql_query "$query"
}

# Function to upload the archive file
upload_archive() {
  local upload_url=$1
  local file_path=$2
  curl --request PATCH \
    --url "$upload_url" \
    --header "authorization: bearer $GITHUB_TOKEN" \
    --header "accept: application/vnd.github.wyandotte-preview+json" \
    --header "content-type: application/gzip" \
    --data-binary @"$file_path"
}

# Function to prepare the import
prepare_import() {
  local migration_id=$1
  local query="mutation {
    prepareImport(input: {migrationId: \"$migration_id\"}) {
      migration {
        guid
        id
        state
      }
    }
  }"
  graphql_query "$query"
}

# Function to check for conflicts
check_conflicts() {
  local org_login=$1
  local migration_guid=$2
  local query="query(
    \$login: String!,
    \$guid: String!
  ){
    organization (login: \$login) {
      migration (
        guid: \$guid
      )
      {
        guid
        id
        state
        conflicts {
          modelName
          sourceUrl
          targetUrl
          recommendedAction
          notes
        }
      }
    }
  }"
  graphql_query "$query"
}

# Function to apply mappings
apply_mappings() {
  local migration_id=$1
  local query="mutation(
    \$migrationId: ID!
  ){
    addImportMapping(input: {
      migrationId: \$migrationId,
      mappings: [
        {
          modelName: \"user\",
          sourceUrl: \"https://example-gh.source/octocat\",
          targetUrl: \"https://github.com/octocat\",
          action: MAP
        },
        {
          modelName: \"user\",
          sourceUrl: \"https://example-gh.source/hubot\",
          targetUrl: \"https://github.com/hubot\",
          action: SKIP
        },
        {
          modelName: \"user\",
          sourceUrl: \"https://example-gh.source/monalisa\",
          targetUrl: \"https://github.com/monalisa\",
          action: SKIP
        },
        {
          modelName: \"organization\",
          sourceUrl: \"https://example-gh.source/octo-org\",
          targetUrl: \"https://github.com/import-testing\",
          action: MAP
        }
      ]})
    {
      migration {
        state
        guid
      }
    }
  }"
  graphql_query "$query"
}

# Perform the import
perform_import() {
  local migration_id=$1
  local query="mutation {
    finalizeImport(input: {migrationId: \"$migration_id\"}) {
      migration {
        state
        guid
      }
    }
  }"
  graphql_query "$query"
}

# Function to perform an audit of migratable resources
audit_migration() {
  local org_login=$1
  local migration_guid=$2
  local migratable_resources_after=$3
  local query="query(
    \$login: String!,
    \$guid: String!,
    \$migratable_resources_after: String
  ){
    organization(login: \$login) {
      migration(guid: \$guid) {
        state
        guid
        id
        migratableResources(
          first: 100
          after: \$migratable_resources_after
          state: IMPORTED
        ) {
          pageInfo {
            endCursor
            hasNextPage
          }
          totalCount
          edges {
            node{
              modelName
              sourceUrl
              targetUrl
              state
              warning
            }
          }
        }
      }
    }
  }"
  graphql_query "$query"
}

# Example usage of get_org_id function
org_login="$ORG_LOGIN"
org_response=$(get_org_id "$org_login")
org_id=$(echo $org_response | jq -r '.data.organization.id')

echo "Organization ID: $org_id"

# Start the import process
import_response=$(start_import "$org_id")
upload_url=$(echo $import_response | jq -r '.data.startImport.migration.uploadUrl')
migration_guid=$(echo $import_response | jq -r '.data.startImport.migration.guid')
migration_id=$(echo $import_response | jq -r '.data.startImport.migration.id')
migration_state=$(echo $import_response | jq -r '.data.startImport.migration.state')

echo "Upload URL: $upload_url"
echo "Migration GUID: $migration_guid"
echo "Migration ID: $migration_id"
echo "Migration State: $migration_state"

# Upload the archive file
archive_file_path="path/to/your/archive.tar.gz"
upload_archive "$upload_url" "$archive_file_path"

# Prepare the import
prepare_response=$(prepare_import "$migration_id")
prepare_state=$(echo $prepare_response | jq -r '.data.prepareImport.migration.state')

echo "Prepare Import State: $prepare_state"

# Check the status of the import
status_response=$(check_import_status "$org_login" "$migration_guid")
migration_status=$(echo $status_response | jq -r '.data.organization.migration.state')

echo "Migration Status: $migration_status"

# Check for conflicts
conflicts_response=$(check_conflicts "$org_login" "$migration_guid")
conflicts=$(echo $conflicts_response | jq -r '.data.organization.migration.conflicts')

echo "Conflicts: $conflicts"

# Apply mappings if conflicts are found
if [ "$conflicts" != "[]" ]; then
  echo "Conflicts detected, applying mappings..."
  apply_mappings "$migration_id"
  echo "Mappings applied."
else
  echo "No conflicts detected."
fi



# Call perform_import function
perform_import_response=$(perform_import "$migration_id")
perform_import_state=$(echo $perform_import_response | jq -r '.data.finalizeImport.migration.state')

echo "Perform Import State: $perform_import_state"

migratable_resources_after="0"
audit_response=$(audit_migration "$org_login" "$migration_guid" "$migratable_resources_after")
echo "Audit Response: $audit_response"