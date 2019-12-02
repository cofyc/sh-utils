#!/usr/bin/env bash

ROOT=$(unset CDPATH && cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=/dev/null
source "${ROOT}/tap-functions"
# shellcheck source=./utils.sh
source "${ROOT}/utils.sh"

set +o errexit
set +o nounset

plan_no_plan

# version_le
okx utils::version_le "v1.16.1" "v1.16.2"
okx utils::version_le "v1.16.2" "v1.16.2"
okx ! utils::version_le "v1.16.2" "v1.16.1"

# version_ge
okx ! utils::version_ge "v1.16.1" "v1.16.2"
okx utils::version_ge "v1.16.2" "v1.16.2"
okx utils::version_ge "v1.16.2" "v1.16.1"
