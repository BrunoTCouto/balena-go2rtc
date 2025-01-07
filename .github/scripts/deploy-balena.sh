#!/usr/bin/env bash
# Release deploys a given version of the app to balena.

set -e

# Set Balena CLI version
BALENA_CLI_VERSION="20.2.1"

# Install balena-cli if not already installed
if ! command -v balena >/dev/null; then
  echo "Installing balena-cli version $BALENA_CLI_VERSION"
  curl -L "https://github.com/balena-io/balena-cli/releases/download/v${BALENA_CLI_VERSION}/balena-cli-v${BALENA_CLI_VERSION}-linux-x64-standalone.zip" -o balena-cli.zip
  unzip balena-cli.zip -d balena-cli
  sudo mv balena-cli/balena-cli/balena /usr/local/bin/
  rm -rf balena-cli balena-cli.zip
fi

if [[ -z $BALENA_TOKEN ]]; then
  echo 'Error: $BALENA_TOKEN must be set (get from https://dashboard.balena-cloud.com/preferences/access-tokens)' >&2
  exit 1
fi

if [[ -z $FLEET ]]; then
  echo 'Error: $FLEET must be set (e.g. org/name)' >&2
  exit 1
fi

# Metadata
draft=false
SHA="$(git rev-parse HEAD)"

echo "Starting balena deployment: draft=$draft, tag='$NEW_RELEASED_VERSION', SHA='$SHA'"

tags=("sha" "$SHA")

args=("$FLEET" "--nocache")

if [[ $draft == true ]]; then
  args+=("--draft")
else
  tags+=("version" "$NEW_RELEASED_VERSION")
fi

args+=("--release-tag" "${tags[@]}")

echo "Logging in to balena cloud"
balena login --token "$BALENA_TOKEN"

echo "Executing balena"
set -x
balena push "${args[@]}"