#!/bin/bash

# Script to ensure .github and infra folders are committed and pushed to remote

echo "Making sure .github and infra folders are tracked by Git..."

# Add the folders explicitly
git add -f .github/ infra/

# Commit the changes
git commit -m "Add .github workflows and infrastructure files"

# Push to remote
git push

echo "Done! The .github and infra folders should now be pushed to your remote repository."
