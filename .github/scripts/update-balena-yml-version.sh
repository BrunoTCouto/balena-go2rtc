#!/bin/sh

FILE="balena.yml"
VERSION=$1

if [ -z "$VERSION" ]; then
  echo "Version is not provided"
  exit 1
fi

sed -i.bak "s/^version: .*/version: $VERSION/" $FILE

if [ $? -eq 0 ]; then
  echo "Updated version to $VERSION in $FILE"
else
  echo "Failed to update version in $FILE"
  exit 1
fi