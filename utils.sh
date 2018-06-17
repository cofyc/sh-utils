#!/bin/bash

#
# Examples: utils::retry_with_times 3 git pull
#
function utils::retry_with_times() {
    local n=${1:-0}
    local code=0
    until [ "$n" -le 0 ]; do
        "${@:2}"
        code=$?
        if [ $code -eq 0 ]; then
            return 0
        fi
        n=$((n-1))
    done
    return $code
}

#
# Examples: utils::retry_with_sleep 3 git pull
#
function utils::retry_with_sleep() {
    local n=${1:-0}
    shift
    for i in $(seq 1 "$n"); do
        if "$@"; then
            return 0
        else
            sleep "$i"
        fi
    done
    "$@"
}

# Check item is in array or not.
# http://stackoverflow.com/a/1063367/288089
function utils::in_array() {
    local i=$1
    shift
    local a=("${@}")
    local e
    for e in "${a[@]}"; do
        [[ "$e" == "$i" ]] && return 0;
    done
    return 1
}

#
# wget alternative implementation
#
# See https://unix.stackexchange.com/a/83927/206361
#
# Usage:
#
#   utils::wget http://mirrors.aliyun.com/repo/Centos-7.repo > /etc/yum.repos.d/CentOS-Base.repo
#
# Notes:
#
#  - this only depends on bash 2.04 or above with the /dev/tcp pseudo-device enabled
#  - does not support https
#
function utils::wget() {
    : "${DEBUG:=0}"
    local URL=$1
    local tag="Connection: close"

    if [ -z "${URL}" ]; then
        printf "Usage: %s \"URL\" [e.g.: %s http://www.google.com/]" \
               "${FUNCNAME[0]}" "${FUNCNAME[0]}"
        return 1;
    fi
    read -r proto server path <<<"${URL//// }"
    local SCHEME=${proto//:*}
    local PATH=/${path// //}
    local HOST=${server//:*}
    local PORT=${server//*:}
    if [[ "$SCHEME" != "http" ]]; then
        printf 'sorry, %s only support http\n' "${FUNCNAME[0]}"
        return 1
    fi
    [[ x"${HOST}" == x"${PORT}" ]] && PORT=80
    [[ $DEBUG -eq 1 ]] && echo "SCHEME=$SCHEME" >&2
    [[ $DEBUG -eq 1 ]] && echo "HOST=$HOST" >&2
    [[ $DEBUG -eq 1 ]] && echo "PORT=$PORT" >&2
    [[ $DEBUG -eq 1 ]] && echo "PATH=$PATH" >&2

    if ! exec 3<> "/dev/tcp/${HOST}/${PORT}"; then
        return $?
    fi
    if ! echo -en "GET ${PATH} HTTP/1.1\\r\\nHost: ${HOST}\\r\\n${tag}\\r\\n\\r\\n" >&3; then
        return $?
    fi
    # 0: at begin, before reading http response
    # 1: reading header
    # 2: reading body
    local state=0
    local num=0
    local code=0
    while read -r line; do
        num=$((num + 1))
        # check http code
        if [ $state -eq 0 ]; then
            if [ $num -eq 1 ]; then
                if [[ $line =~ ^HTTP/1\.[01][[:space:]]([0-9]{3}).*$ ]]; then
                    code="${BASH_REMATCH[1]}"
                    if [[ "$code" != "200" ]]; then
                        printf "failed to wget '%s', code is not 200 (%s)\\n" "$URL" "$code"
                        exec 3>&-
                        return 1
                    fi
                    state=1
                else
                    printf "invalid http response from '%s'" "$URL"
                    exec 3>&-
                    return 1
                fi
            fi
        elif [ $state -eq 1 ]; then
            if [[ "$line" == $'\r' ]]; then
				# found "\r\n"
				state=2
            fi  
        elif [ $state -eq 2 ]; then
			# redirect body to stdout
			echo "$line"
        fi
    done <&3
    exec 3>&-
}
