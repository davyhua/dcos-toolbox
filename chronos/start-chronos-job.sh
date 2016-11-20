#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

echo "Starting Chronos Job: ${1}"

curl -skSL -X PUT -H "Authorization: token=$(dcos config show core.dcos_acs_token)" -H "Content-Type: application/json" "$(dcos config show core.dcos_url)/service/chronos/scheduler/job/${1}"
