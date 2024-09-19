#!/bin/bash

DIR_NAME="bar"

# Check if the dir exists, if not then create it
if [ ! -d "$DIR_NAME" ]; then
  echo "Directory $DIR_NAME does not exist."
  echo "Creating directory $DIR_NAME"
  mkdir -p "$DIR_NAME"
fi

# Clear the directory
shopt -s dotglob
rm -rf "$DIR_NAME"/*
shopt -u dotglob

# Copy the content from honeycomb_default.toml
cp honeycomb_default.toml "$DIR_NAME/honeycomb.toml"

if ! go run main.go init $DIR_NAME; then
  exit 1
fi

pushd $DIR_NAME

make bin
make ui

popd
