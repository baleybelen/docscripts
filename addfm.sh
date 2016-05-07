#!/usr/bin/env bash
#: Description: Add YAML front matter to files
# For, e.g., Jekyll

set -o errexit
# set -o nounset
# set -o xtrace

directory="${1}"
ext="md"
tmpfile="/tmp/tmpfile"

function display_usage {
cat <<EOF
Usage: $(basename "${0}") <directory>
(<directory> can be a relative path)
EOF
    }

test $# -eq 1 -a -d "${directory}" &&

for file in "${directory}"/*."${ext}"; do
	filename=$(basename $file)
    filename=${filename%.${ext}}
    echo "---" > ${tmpfile}
	echo "title: ${filename}" >> ${tmpfile}
    echo "---" >> ${tmpfile}
    echo "" >> ${tmpfile}
    cat ${file} >> ${tmpfile}
    cp ${tmpfile} ${file}
done &&

exit 0 || display_usage && exit 1
