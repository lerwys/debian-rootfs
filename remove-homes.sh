#!/usr/bin/env bash

set -euxo pipefail

SCRIPTPATH="$( cd "$( dirname "${BASH_SOURCE[0]}"  )" && pwd  )"

. ${SCRIPTPATH}/env-vars.sh

rm -rf ${HOMES}
