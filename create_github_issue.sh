#!/bin/bash

# Load environment variables from .env if it exists
if [ -f .env ]; then
    export $(cat .env | xargs)
fi

# Ensure the required variables are set
if [ -z "$GITHUB_AUTH_TOKEN" ]; then
    echo "Error: GITHUB_AUTH_TOKEN is not set. Please set it in your .env file or as an environment variable."
    exit 1
fi

# Define base API URL
BASE_API_URL="https://api.github.com/repos/ajpieroni"

# Prompt for repository name
echo "Enter the repository name (e.g., owner/repository):"
read -r repository

# Prompt for issue title
echo "Enter the issue title:"
read -r title

# Fixed assignee
assignee="ajpieroni"

# Create JSON payload
payload=$(cat <<EOF
{
  "title": "$title",
  "assignees": ["$assignee"]
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