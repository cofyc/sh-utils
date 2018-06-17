#!/usr/bin/env bash

ROOT=$(unset CDPATH && cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=/dev/null
source "${ROOT}/tap-functions"
# shellcheck source=./utils.sh
source "${ROOT}/utils.sh"

set +o errexit
set +o nounset

plan_no_plan

# utils::retry_with_times
utils::retry_with_times 3 ls / &>/dev/null
okx [ $? -eq 0 ]

utils::retry_with_times 3 ls /does_not_exist &>/dev/null
okx [ $? -ne 0 ]

## utils::retry_with_sleep
utils::retry_with_sleep 3 ls / &>/dev/null
okx [ $? -eq 0 ]

utils::retry_with_sleep 1 ls /does_not_exist &>/dev/null
okx [ $? -ne 0 ]

# utils::in_array
ARRAY=(apple orange banana 'good fruit')
if utils::in_array apple "${ARRAY[@]}"; then
    pass
else
    fail
fi
if ! utils::in_array pineapple "${ARRAY[@]}"; then
    pass
else
    fail
fi

# utils::wget
tmpfile=$(mktemp)
# shellcheck disable=SC2064
trap "test -f $tmpfile && rm $tmpfile || true" EXIT
utils::wget http://example.org/ > "$tmpfile"
if grep "Example Domain" "$tmpfile" >/dev/null; then
    pass
else
    fail
fi
