#!/usr/bin/env bash
# Description: Catalog files
# Looks for '^(# )?[dD]escription: '

set -o errexit
# set -o nounset
# set -o xtrace

directory="${1}"
grep_exclude="_config.yml"

function display_usage {
cat <<EOF
Usage: $(basename "${0}") <directory>
(<directory> can be a relative path)
EOF
    }

test $# -eq 1 -a -d "${directory}" && \
    grep -E \
        --recursive \
        --exclude="${grep_exclude}" \
        "^(# )?[dD]escription: " "${directory}" \
        | sed -E -e 's/^.*\//* /' \
                 -e 's/(# )?[dD]escription: / /' -e 's/: / -- /' \
    && exit 0 || display_usage && exit 1