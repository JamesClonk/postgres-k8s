#!/bin/bash
set -e
set -u

helm template postgres --namespace=postgres "$(pwd)/vendor/bitnami/postgresql-ha" --values="values.yml" |
    ytt --ignore-unknown-comments -f - |
    kbld --lock-output "../../postgresql-ha/rendered/image.lock.yml" -f - > "../../postgresql-ha/rendered/postgresql-ha.yml"
