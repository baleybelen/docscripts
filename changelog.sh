#!/usr/bin/env bash
# Description: Write changelog

set -o errexit
# set -o nounset # Interferes with use of unbound variables
# set -o xtrace

my_directory="${1}"
git="/usr/bin/git"

# Commit messages to exclude:
message_excludes="Initial commit|.gitignore|README"

display_usage() {
cat <<EOF
Usage: $(basename "${0}") <directory>
(<directory> can be a relative path)
EOF
    }

print_underscored_string() {
    # String is $1, underscore character is $2
    size="${#1}"
    char="${2}"
    printf "${1}\n"
    printf "%0.s${2}" $(seq 1 "${size}")
    }

test $# -eq 1 -a -d "${my_directory}" &&

print_underscored_string "Changelog" "-" &&

# If there are no annotated tags, get commit messages from log
if [[ -z $("${git}" -C "${my_directory}" tag -l) ]]; then
    printf "\n\n"
    "${git}" -C "${my_directory}" log --no-merges --format="* %s" \
     | sed -E /"${message_excludes}"/d
else
    # Get list of tags, sort in reverse order, and print tag messages
    "${git}" -C "${my_directory}" tag -l | sort -u -r | while read tag ; do
        printf "\n\n### ${tag} $(${git} -C ${my_directory} show ${tag} \
                                  --format=%ad --date=short --no-patch \
            | grep -E '^(19|20)\d\d-(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[01])$')\n\n"
        GIT_PAGER=cat "${git}" -C "${my_directory}" tag --list -n99 \
            "${tag}" \
            | sed -e 's/^v[0-9a-zA-Z.-_]* *//' \
                  -e 's/^[ \t]*[\*] /* /' \
                  -e 's/^[ \t]*-/    -/'

    done
fi &&

exit 0 || display_usage && exit 1