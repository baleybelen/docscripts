#!/usr/bin/env bash
# Create Markdown-formatted linked list of files in working directory
# For, e.g., mdwiki

index_file="index.md"

# Extension of files to include:
ext="md"

colophon="(Created by $(basename "${0}"))"

echo "${colophon}" > "${index_file}"
echo "" >> "${index_file}"

for file in "$PWD"/*."${ext}"; do
	filename=$(basename $file)
	echo "* ["${filename}"]("${filename}")"	>> "${index_file}"
done