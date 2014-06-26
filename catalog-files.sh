#!/usr/bin/env bash
# Description: Catalog files
# Looks for '^(# )?[dD]escription: '

set -o errexit
# set -o nounset
# set -o xtrace

directory="${1}"
grep_exclude="_config.yml"

function display_usage {
    echo "Usage: $(basename "${0}") directory" 1>&2
    echo "(Directory can be a relative path)" 1>&2
    }

if [ $# -lt 1 ]; then
    display_usage
    exit 2
fi

grep -E --recursive --exclude="${grep_exclude}" "^(# )?[dD]escription: " "${directory}" \
| sed -E -e 's/^.*\//* /' -e 's/(# )?[dD]escription: / /' -e 's/: / -- /'