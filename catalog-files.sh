#!/usr/bin/env bash
# Description: Catalog files
# Looks for '^(# )?Description: '

set -o errexit
# set -o nounset
# set -o xtrace

directory="${1}"

function display_usage {
    echo "Usage: $(basename "${0}") directory" 1>&2
    echo "(Directory can be a relative path)" 1>&2
    }

if [ $# -lt 1 ]; then
    display_usage
    exit 2
fi

grep -E --recursive "^(# )?[dD]escription: " "${directory}" \
| sed -e 's/^.*\//* /' -e 's/# Description: / /' -e 's/: / -- /'