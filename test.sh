#!/bin/bash

# Set your target directory path here
DIR=".tmp"

# Safety check - if the dir does not exist, then exit
if [ ! -d "$DIR" ]; then
  echo "Directory $DIR does not exist."
  exit 1
fi

shopt -s dotglob
rm -rf "$DIR"/*
shopt -u dotglob


# Create new file with specified name and content
cat << EOF > "$DIR/honeycomb.toml"
go_module_path = "github.com/foo/bar"
EOF

go run main.go init .tmp

cd .tmp && go run main.go noop