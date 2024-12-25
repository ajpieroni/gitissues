#!/bin/bash

# Get the directory of the current script
SCRIPT_DIR=$(dirname "$(realpath "$0")")

# Load environment variables from .env in the script's directory
if [ -f "$SCRIPT_DIR/.env" ]; then
    export $(cat "$SCRIPT_DIR/.env" | xargs)
fi

# Ensure the required variables are set
if [ -z "$GITHUB_AUTH_TOKEN" ]; then
    echo "Error: GITHUB_AUTH_TOKEN is not set. Please set it in your .env file located at $SCRIPT_DIR or as an environment variable."
    exit 1
fi

# Define base API URL
BASE_API_URL="https://api.github.com/repos"

# Detect repository from Git if in a Git folder
if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    repo_url=$(git remote get-url origin)
    # Extract owner/repository from URL
    repository=$(echo "$repo_url" | sed -E 's/.*github\.com[:\/]([^/]+\/[^/]+)\.git/\1/')
    echo "Detected repository: $repository"
else
    # Prompt for repository name if not in a Git folder
    echo "Enter the repository name (e.g., repository-name only):"
    read -r repo_name
    # Prepend "ajpieroni/" to the repository name
    repository="ajpieroni/$repo_name"
    echo "Using repository: $repository"
fi

# Prompt for issue title
echo "Enter the issue title:"
read -r title

# Fixed assignee
assignee="ajpieroni"

# Create JSON payload
payload=$(cat <<EOF
{
  "title": "$title",
  "assignees": ["$assignee"],
  "labels": ["untriaged"]
}
EOF
)

# Make the API call
API_URL="$BASE_API_URL/$repository/issues"
echo "API URL: $API_URL"  # Debugging: Print API URL
response=$(curl -s -o /dev/null -w "%{http_code}" -X POST \
-H "Authorization: Bearer $GITHUB_AUTH_TOKEN" \
-H "Content-Type: application/json" \
-d "$payload" \
"$API_URL")

# Handle response
if [ "$response" -eq 201 ]; then
  echo "Issue created successfully in repository $repository!"
else
  echo "Failed to create issue in repository $repository. HTTP Status Code: $response"
fi