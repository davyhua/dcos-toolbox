#!/bin/bash

set -o errexit -o nounset -o pipefail

dcos package install --yes --cli dcos-enterprise-cli
dcos security org service-accounts keypair -l 4096 marathon-lb-private-key.pem marathon-lb-public-key.pem
dcos security org service-accounts create -p marathon-lb-public-key.pem -d "dcos_marathon_lb service account" dcos_marathon_lb || true
dcos security org service-accounts show dcos_marathon_lb
curl -skSL -X PUT -H 'Content-Type: application/json' -d '{"description": "Marathon Services"}' -H "Authorization: token=$(dcos config show core.dcos_acs_token)" "$(dcos config show core.dcos_url)/acs/api/v1/acls/dcos:service:marathon:marathon:services:%252F" || true
curl -skSL -X PUT -H 'Content-Type: application/json' -d '{"description": "Marathon Events"}' -H "Authorization: token=$(dcos config show core.dcos_acs_token)" "$(dcos config show core.dcos_url)/acs/api/v1/acls/dcos:service:marathon:marathon:admin:events" || true
curl -skSL -X PUT -H "Authorization: token=$(dcos config show core.dcos_acs_token)" "$(dcos config show core.dcos_url)/acs/api/v1/acls/dcos:service:marathon:marathon:services:%252F/users/dcos_marathon_lb/read" || true
curl -skSL -X PUT -H "Authorization: token=$(dcos config show core.dcos_acs_token)" "$(dcos config show core.dcos_url)/acs/api/v1/acls/dcos:service:marathon:marathon:admin:events/users/dcos_marathon_lb/read
dcos security secrets create-sa-secret marathon-lb-private-key.pem dcos_marathon_lb marathon-lb" || true
dcos security secrets list /
dcos security secrets get /marathon-lb --json | jq -r .value | jq
tee marathon-lb-secret-options.json <<'EOF'
{
    "marathon-lb": {
        "secret_name": "marathon-lb"
    }
}
EOF
dcos package install --options=marathon-lb-secret-options.json --yes marathon-lb
