#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

ROOT=$(unset CDPATH && cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$ROOT"

function check_shellheck() {
    if ! test -x ./shellcheck; then
        return 1
    fi
    local version
    version=$(./shellcheck --version | awk '/version:/ {print $2}')
    [[ "$version" == "0.5.0" ]]
}

function install_shellcheck() {
    curl -s https://shellcheck.storage.googleapis.com/shellcheck-v0.5.0.linux.x86_64.tar.xz | tar --strip-components 1 -xJf - shellcheck-v0.5.0/shellcheck
}

if ! check_shellheck; then
    install_shellcheck
fi

./shellcheck -x hack/*.sh || true
./shellcheck -x ./*.sh || true

echo "Passed all shellcheck checks."
