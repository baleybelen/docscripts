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
readme="${1}"/README.md
preview_app="Marked.app"

function build_readme {
    readme_header="${2}"
    echo "${readme_header}"
    echo ""
    "${script_dir}"/catalog-files.sh "${1}"
    echo ""
    echo ""
    "${script_dir}"/changelog.sh "${1}"
}

readme_header=$(head -4 "${readme}")
build_readme "${1}" "${readme_header}"
echo -n "OK? (y/n) "
read answer
if [ $(echo "${answer}") = 'y' ]; then
    rm -i "${readme}"
    build_readme "${1}" "${readme_header}" > "${readme}"
    cat "${readme}"
    echo -n "Preview ${readme}? (y/n) "
    read answer
    if [ $(echo "${answer}") = 'y' ]; then
        open -a "${preview_app}" "${readme}" 
    else
        exit 0
    fi
    exit 0
else
    exit 0
fi