#!/bin/bash

# Config
# -----------------------------------------------------------------
function_name="ChatterBotSkillHandler"

# Helpers
# -----------------------------------------------------------------
show_progress() {
    while true; do
        sleep 0.25
        printf "."
    done
}

cleanup() {
    kill $progress_pid 2>/dev/null
    printf "\nDeploy interrupted.\n"
    exit 1
}

trap 'cleanup' SIGINT

# Deploy
# -----------------------------------------------------------------
echo "Starting deploy ..."
printf "Creating package zip "
show_progress &
progress_pid=$!

# Make a temporary copy of the directory
temp_dir="tmp-package"
cp -r "venv/lib/python3.9/site-packages/." "$temp_dir"

# Copy all python files from current directory into the temporary directory
find . -maxdepth 1 -name '*.py' -exec cp {} "$temp_dir/" \;

# Zip up the temporary directory (quietly)
zip_name="package.zip"
cd "$temp_dir"
zip -rq "$zip_name" .
rm -rf "../$zip_name"
mv "$zip_name" ..
cd ..
rm -rf "$temp_dir"

kill $progress_pid
wait $progress_pid 2>/dev/null
printf "Done.\n"

printf "Deploying changes ..."
show_progress &
progress_pid=$!

# Upload changes to AWS lambda function
aws lambda update-function-code --function-name "$function_name" --zip-file "fileb://$(pwd)/$zip_name"
rm -rf "$zip_name"

kill $progress_pid
wait $progress_pid 2>/dev/null
printf "Done.\n"
echo "Successfully deployed changes"