#!/usr/bin/env bash
# Spawn a new project directory and files

# Don't use 'set -o errexit': script exits when some queries are answered 'n'?
# set -o errexit

set -o nounset
# set -o xtrace

function display_usage {
    # xargs strips whitespace, so we can indent here
    echo "Usage: $(basename "${0}") \
          project-name \
          [\"quoted project description\"]" | xargs 1>&2
	}

if [ $# -lt 1 ]; then
    display_usage
    exit 2
elif [ $# == 1 ]; then
    project_description="description"
elif [ $# == 2 ]; then
	project_description="${2}"
elif [ $# -gt 2 ]; then
    display_usage
    echo "(Project description must be quoted)"
    exit 2	
fi

function print_underscored_string {
	# String is $1, underscore character is $2
	size="${#1}"
	char="${2}"
	echo "${1}"
	printf "%0.s${2}" $(seq 1 "${size}")
}

destination_dir="/Users/blennon/sync/desk"
project_name="${1}"
project_name_underscored=$(print_underscored_string "${project_name}" "=")
project_path="${destination_dir}"/"${project_name}"
gitignore="${project_path}"/.gitignore
readme="${project_path}"/README.md
sublime_project_file="${project_path}"/"${project_name}".sublime-project

git="/usr/bin/git"
jekyll="/Users/blennon/.rbenv/shims/jekyll"

echo "Do you want a Jekyll site for this project? (y/n) "
read answer
if [ $(echo "${answer}") = 'y' ]; then
	echo "Running 'jekyll new ${project_path}'..."
	"${jekyll}" new "${project_path}"
fi

echo "Creating directory tree in ${destination_dir}..."
mkdir -v -p "${project_path}"/{build,resources/{private,public},snapshot/{archive,milestone,release}}

echo "Making .gitignore..."
cat <<EOF > "${gitignore}"
.DS_Store
*.sublime-workspace

_site/
build/
resources/
snapshot/
EOF

cat "${gitignore}"

echo "Making README.md..."
cat <<EOF > "${readme}"
${project_name_underscored}

${project_description}
EOF

cat "${readme}"

echo "Making Sublime Text project..."
cat <<EOF > "${sublime_project_file}"
{
	"folders":
	[
		{
			"path": "${project_path}"
		}
	]
}
EOF

cat "${sublime_project_file}"

echo "Initalizing Git repository..."
"${git}" -C "${project_path}" init

echo "Adding and committing ${gitignore}, ${readme}, ${sublime_project_file}..."
"${git}" -C "${project_path}" add \
	"${gitignore}" "${readme}" "${sublime_project_file}"
"${git}" -C "${project_path}" commit \
	-m "Create \
$(basename ${gitignore}), \
$(basename ${readme}), \
$(basename ${sublime_project_file})"

echo "Making branch 'develop'..."
"${git}" -C "${project_path}" branch develop

echo "Do you want a 'gh-pages' branch? (y/n) "
read answer
if [ $(echo "${answer}") = 'y' ]; then
	echo "Making branch 'gh-pages'..."
	"${git}" -C "${project_path}" branch gh-pages
fi

echo "Output of 'git -C ${project_path} status':"
"${git}" -C "${project_path}" status

echo "Spawned project files in ${project_path}."
echo "Open project in Sublime Text? (y/n) "
read answer
if [ $(echo "${answer}") = 'y' ]; then
	open "${sublime_project_file}"
	exit 0
else
	exit 0
fi