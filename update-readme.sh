#!/usr/bin/env bash
# Description: Update README with file list and changelog
# Uses catalog-files.sh and changelog.sh
# Assumes `head -4 README.md` is static content

set -o errexit
set -o nounset
# set -o xtrace

function display_usage {
    echo "Usage: $(basename "${0}") directory" 1>&2
    echo "(Directory can be a relative path)" 1>&2
    }

if [ $# -lt 1 ]; then
    display_usage
    exit 2
fi

# Directory this script resides in
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

head -4 "${1}"/README.md
echo ""
echo ""
"${script_dir}"/catalog-files.sh "${1}"
echo ""
echo ""
"${script_dir}"/changelog.sh "${1}"