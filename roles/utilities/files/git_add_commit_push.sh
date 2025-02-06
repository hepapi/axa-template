#!/bin/bash
# =============================
# Description: 
#     This script adds, commits and pushes the specified files to the specified Git repository
# Args:
#     REPO_DIR: The path to the repository directory
#     REPO_BRANCH: Repo Branch
#     GIT_COMMIT_MESSAGE: Commit message
#     UPDATE_FILES_REL_PATHS: comma-separated list of file paths relative to the repository directory
#     SSH_KEY_PATH: Path to the SSH key to use for auth with the Git repository. Set empty("") to use HTTPS acceess. 
# =============================

echo "Repo directory: $REPO_DIR, branch: $REPO_BRANCH"

echo "Update files relative paths: $UPDATE_FILES_REL_PATHS"

# Check if UPDATE_FILES_REL_PATHS is set and not empty
if [[ -z "${UPDATE_FILES_REL_PATHS}" ]]; then
    echo "ERROR: UPDATE_FILES_REL_PATHS environment variable is not set or is empty"
    exit 1
fi

# Check if REPO_DIR is set and not empty
if [[ -z "${REPO_DIR}" ]]; then
    echo "ERROR: REPO_DIR environment variable is not set or is empty"
    exit 1
fi

# Navigate into the specified repository directory
cd "${REPO_DIR}"

# Convert the comma-separated string into an array using tr to replace commas with spaces
file_paths=($(echo "${UPDATE_FILES_REL_PATHS}" | tr ',' ' '))

# Loop over the array and add each file path to the Git repository
for path in "${file_paths[@]}"
do
    echo "git add $path"
    git add "$path"
done
echo "--------------"

git status
echo "--------------"


# Commit the changes
git commit -m "$GIT_COMMIT_MESSAGE"

if [[ -z "$SSH_KEY_PATH" ]]; then
    echo 'Using HTTPS access because $SSH_KEY_PATH is an empty string'
else
    # SSH_KEY_PATH has some value, use SSH access
    ssh-add $SSH_KEY_PATH 
fi

# git remote set-url origin $REPO_SSH_URI
# Push the changes
echo "--------------"
echo "git push"
push_output=$(git push 2>&1 | tee /dev/fd/2)
echo $push_output