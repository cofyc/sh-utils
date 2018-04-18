#!/usr/bin/env bash

ROOT=$(unset CDPATH && cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source ${ROOT}/tap-functions
source ${ROOT}/utils.sh

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

# utils::in_list
LIST="apple orange banana"
if utils::in_list "apple" $LIST; then
    pass
else
    fail
fi
if ! utils::in_list "pineapple" $LIST; then
    pass
else
    fail
fi

# in_array
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
