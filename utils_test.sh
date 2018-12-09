#!/usr/bin/env bash

ROOT=$(unset CDPATH && cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=/dev/null
source "${ROOT}/tap-functions"
# shellcheck source=./utils.sh
source "${ROOT}/utils.sh"

set +o errexit
set +o nounset

plan_no_plan

# utils::retry
utils::retry 1 3 ls / &>/dev/null
okx [ $? -eq 0 ]

utils::retry 1 3 ls /does_not_exist &>/dev/null
okx [ $? -ne 0 ]

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
        utils::retry 1 3 nc -z -v localhost 8000
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

# in_array
ARRAY=(apple orange banana 'good fruit')
okx utils::in_array apple "${ARRAY[@]}"
okx utils::in_array 'good fruit' "${ARRAY[@]}"
okx ! utils::in_array pineapple "${ARRAY[@]}"

# join_by
ARRAY=(a b c aa bb cc)
is "a,b,c,aa,bb,cc" $(utils::join_by , "${ARRAY[@]}") "join_by"
