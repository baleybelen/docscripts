#!/usr/bin/env bash
# Description: For tagging releases
# Retrieves commits since the last annotated tag 
# or all commits, if no annotated tags exist

set -o errexit
# set -o nounset # This interferes with using unbound variables
# set -o xtrace

function display_usage {
    echo "Usage: $(basename "${0}") directory tag" 1>&2
    echo "(Directory can be a relative path)" 1>&2
    }

if [ $# -lt 2 ]; then
    display_usage
    exit 2
fi

my_directory="${1}"
new_tag="${2}"
git="/usr/bin/git"
tempfile="/tmp/tag-release"

# If there are no annotated tags:
if [[ -z $("${git}" -C "${my_directory}" tag -l) ]]; then
    "${git}" -C "${my_directory}" log --no-merges --format="* %s%n%-b"  \
    > "${tempfile}"
else
    # Get commits since the last tag:
    last_tag=$("${git}" -C "${my_directory}" tag -l | tail -1)
    "${git}" -C "${my_directory}" log "${last_tag}"..HEAD \
        --no-merges \
        --format="* %s%n%-b" \
        > "${tempfile}"
fi

nano "${tempfile}"
# Get nano's process ID (assuming there's only one) and wait for it to finish
wait $(pgrep nano)

"${git}" tag -a "${new_tag}" --file="${tempfile}"

echo "Showing last tag..."
newest_tag=$("${git}" -C "${my_directory}" tag -l | tail -1)
"${git}" show "${newest_tag}" \
    --no-patch \
    --format="%nCommits with this tag:%n* %s%n%-b"

rm "${tempfile}"
exit 0