#!/usr/bin/env bash
# Release deploys a given version of the app
# to balena.

set -e

if ! command -v balena >/dev/null; then
  echo "Ensuring balena-cli is usable"
  asdf install
fi

if [[ -z $BALENA_TOKEN ]]; then
  # shellcheck disable=SC2016 # Why: We don't want it to be printed
  echo 'Error: $BALENA_TOKEN must be set (get from https://dashboard.balena-cloud.com/preferences/access-tokens)' >&2
  exit 1
fi

if [[ -z $FLEET ]]; then
  # shellcheck disable=SC2016 # Why: We don't want it to be printed
  echo 'Error: $FLEET must be set (e.g. org/name)' >&2
  exit 1
fi

# Metadata
draft=false
tag="$(git describe --tags --exact-match HEAD 2>/dev/null || true)"
SHA="$(git rev-parse HEAD)"

# If not on a tag, then we create a draft which isn't
# automatically deployed to devices but still usable.
if [[ $tag == "" ]]; then
  draft=true
fi

echo "Starting balena deployment: draft=$draft,tag='$tag',SHA='$SHA'"

tags=("sha" "$SHA")

args=("$FLEET" "--nocache" "--registry-secrets" "/tmp/image_pull_secrets.yaml")

if [[ $draft == true ]]; then
  args+=("--draft")
else
  tags+=("version" "$tag")
fi

args+=("--release-tag" "${tags[@]}")

echo "Logging in to balena cloud"
balena login --token "$BALENA_TOKEN"

echo "Executing balena"
set -x
balena push "${args[@]}"