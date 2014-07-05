#!/usr/bin/env bash
# Description: Write changelog

set -o errexit
# set -o nounset # Interferes with use of unbound variables
# set -o xtrace

function display_usage {
cat <<EOF
Usage: $(basename "${0}") <directory>
(<directory> can be a relative path)
EOF
    }

if [ $# -lt 1 ]; then
    display_usage
    exit 2
fi

my_directory="${1}"
git="/usr/bin/git"

# Commit messages to exclude:
message_excludes="Initial commit|.gitignore|README"

function get_tag_date {
    "${git}" -C "${my_directory}" show "${1}" \
    --format=%ad --date=short --no-patch \
    | grep -E '^(19|20)\d\d-(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[01])$'
}

function print_underscored_string {
    # String is $1, underscore character is $2
    size="${#1}"
    char="${2}"
    echo "${1}"
    printf "%0.s${2}" $(seq 1 "${size}")
}

print_underscored_string "Changelog" "-"

# If there are no annotated tags, get commit messages from log
if [[ -z $("${git}" -C "${my_directory}" tag -l) ]]; then
    echo ""
    echo ""
    "${git}" -C "${my_directory}" log --no-merges --format="* %s" \
     | sed -E /"${message_excludes}"/d
else
    # Get list of tags, sort in reverse order, and print tag messages
    "${git}" -C "${my_directory}" tag -l | sort -u -r | while read tag ; do
        echo ""
        echo ""
        echo "### ${tag} ($(get_tag_date ${tag}))"
        echo ""
        GIT_PAGER=cat "${git}" -C "${my_directory}" tag --list -n99 \
            "${tag}" | sed -e 's/^v[0-9a-zA-Z.-_]* *//' -e 's/^[ \t]*//'
    done
fi