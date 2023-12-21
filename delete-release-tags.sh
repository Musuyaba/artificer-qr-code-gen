#!/bin/bash

# Fetch all tags
git fetch

# Get all tag names
tags=$(git tag)

for tag in $tags
do
  # Delete tag from local repository
  git tag -d $tag

  # Delete tag from remote repository
  git push origin :refs/tags/$tag
done

echo "All tags have been deleted."
read -p "Press enter to continue ..."