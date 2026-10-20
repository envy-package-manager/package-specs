#!/usr/bin/env bash
# Install each manifest given, and check that every product it declares landed.
# Carries on past a failure so one run reports every broken manifest, each as an
# annotation on the workflow run.
#
#   install.sh <manifest>...
set -Euo pipefail

failed=0

for manifest in "$@"; do
  name=${manifest##*/}
  echo "::group::$name"

  problem=""
  if ! envy install --manifest "$manifest"; then
    problem="envy install failed"
  elif ! paths=$(envy product --manifest "$manifest" --json | jq -r '.[]'); then
    problem="envy could not list the products"
  else
    # Every product in this bundle is a path into its package. jq on Windows
    # writes CRLF.
    while IFS= read -r path; do
      path=${path%$'\r'}
      if [[ -n "$path" && ! -e "$path" ]]; then
        echo "missing: $path"
        problem="a product is missing from the installed package"
      fi
    done <<<"$paths"
  fi

  echo "::endgroup::"

  if [[ -n "$problem" ]]; then
    echo "::error title=$name::$problem"
    failed=1
  fi
done

exit "$failed"
