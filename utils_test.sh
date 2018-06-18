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
if utils::wget http://example.org/ | grep "Example Domain" >/dev/null; then
    pass "wget text"
else
    fail "wget text"
fi

function test_wget_binary() {
    (
        # run in subshell to avoid overriding trap handler
        python -m SimpleHTTPServer >/dev/null 2>&1 &
        local pid=$!
        dd if=/dev/urandom of=test.bin bs=10M count=1 &>/dev/null
        trap 'kill $pid && wait 2>/dev/null && rm test.bin' EXIT
        local expected got
        expected=$(md5sum test.bin | cut -d ' ' -f 1)
        got=$(utils::wget http://localhost:8000/test.bin | md5sum - | cut -d ' ' -f 1)
        [[ "$got" != "" ]] && [[ "$got" == "$expected" ]]
    )
}

if test_wget_binary; then
    pass "wget binary"
else
    fail "wget binary"
fi
