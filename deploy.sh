#!/bin/bash

# Config
function_name="ChatterBotSkillHandler"

echo "Starting deploy..."

# Make a temporary copy of the directory
temp_dir="tmp-package"
cp -r "venv/lib/python3.9/site-packages/." "$temp_dir"

if [ $? -ne 0 ]; then
  echo "Error: Failed to copy directory"
  exit 1
fi

# Copy all python files from current directory into the temporary directory
find . -maxdepth 1 -name '*.py' -exec cp {} "$temp_dir/" \;

if [ $? -ne 0 ]; then
  echo "Error: Failed to copy Python files"
  exit 1
fi

# Zip up the temporary directory (quietly)
zip_name="package.zip"
cd "$temp_dir"
zip -rq "$zip_name" .
rm -rf "../$zip_name"
mv "$zip_name" ..
cd ..
rm -rf "$temp_dir"

if [ $? -ne 0 ]; then
  echo "Error: Failed to zip the directory"
  exit 1
fi

# Delete the temporary directory
rm -rf "$temp_dir"

if [ $? -ne 0 ]; then
  echo "Error: Failed to delete the temporary directory"
  exit 1
fi

echo "Successfully created $zip_name"

aws lambda update-function-code --function-name "$function_name" --zip-file "fileb://$(pwd)/$zip_name"

rm -rf "$zip_name"

echo "Successfully deployed changes"