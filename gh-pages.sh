#!/usr/bin/env bash
# Description: Update GitHub Pages site files in branch 'gh-pages'
# Workaround for Jekyll site with plugins (not supported by GitHub Pages)

set -o errexit
set -o nounset
# set -o xtrace

git="/usr/bin/git"
jekyll="/Users/blennon/.rbenv/shims/jekyll"
rsync="/usr/bin/rsync"
# Name of the remote repo to push to:
git_remote="github"

function display_usage {
    echo "Usage: $(basename "${0}") directory" 1>&2
    echo "(Directory can be a relative path)" 1>&2
    }

if [ $# -lt 1 ]; then
    display_usage
    exit 2
fi

my_directory="${1}"
jekyll_site_directory="${my_directory}/_site"
tmp_dir="/tmp/tmp-gh-pages"

if [ -d "${tmp_dir}" ]; then
    echo "Removing last used ${tmp_dir}..."
    rm -r -f "${tmp_dir}"
fi  

rsync_opts="\
-av \
--exclude=.git* \
--exclude-from=${tmp_dir}/.gitignore \
--force \
--delete-after"

echo "Changing to ${my_directory}..."
cd "${my_directory}"

echo "Checking out branch 'master'..."
"${git}" checkout master

echo "Building Jekyll site..."
"${jekyll}" build --source "${my_directory}" --destination "${jekyll_site_directory}"

echo "Copying Jekyll site to ${tmp_dir}..."
cp -av "${jekyll_site_directory}" "${tmp_dir}"

echo ""
echo "Copying .gitignore to ${tmp_dir}..."
cp -av "${my_directory}"/.gitignore "${tmp_dir}"/.gitignore

echo ""
echo "Checking out branch 'gh-pages'..."
"${git}" checkout gh-pages

echo ""
echo "Copying .gitignore to $PWD..."
cp -av "${tmp_dir}"/.gitignore "$PWD"/.gitignore

echo ""
echo "Dry run of rsync..."
# Do not quote ${rsync_opts}, below:
"${rsync}" --dry-run ${rsync_opts} "${tmp_dir}" "$PWD"
echo -n "OK? (y/n) "
read answer
if [ $(echo "${answer}") = 'y' ]; then
    echo "Now sychronizing files..."
    rsync ${rsync_opts} "${tmp_dir}/" "$PWD"

    echo ""
    echo "Output of 'diff -rq ${tmp_dir} $PWD':"
    # Don't know why diff returns exit code other than 0 here, but it does,
    # and `set -o errexit` causes script to exit at that point. Workaround is 
    # appending `|| true`:
    diff -rq "${tmp_dir}" "$PWD" || true

    echo ""
    echo "git status:"
    "${git}" status
    
    echo ""
    echo "Output of 'git add --all --dry-run':"
    "${git}" add --all --dry-run
    echo ""
    echo -n "OK to add? (y/n) "
    read answer
    if [ $(echo "${answer}") = 'y' ]; then
        echo "Adding all..."
        "${git}" add --all
    else
        echo "Exiting"
        exit 1
    fi
    
    echo ""
    echo "Output of 'git commit --dry-run':"
    "${git}" commit --dry-run
    echo -n "OK to commit? (y/n) "
    read answer
    if [ $(echo "${answer}") = 'y' ]; then
        echo "Committing with message 'Site update'..."
        "${git}" commit -m "Site update"
    else
        echo "Exiting"
        exit 1
    fi

    echo ""
    echo "Switching to branch 'master'..."
    "${git}" checkout master

    echo ""
    echo "Output of 'git push --dry-run ${git_remote}':"
    "${git}" push --dry-run "${git_remote}"
    echo -n "OK to push? (y/n) "
    read answer
    if [ $(echo "${answer}") = 'y' ]; then
        echo "Pushing..."
        "${git}" push "${git_remote}"
    else
        echo "Exiting"
        exit 1
    fi

    echo ""
    echo "Output of 'git push --dry-run --tags ${git_remote}':"
    "${git}" push --dry-run --tags "${git_remote}"
    echo -n "OK to push tags? (y/n) "
    read answer
    if [ $(echo "${answer}") = 'y' ]; then
        echo "Pushing tags..."
        "${git}" push --tags "${git_remote}"
    else
        echo "Exiting"
        exit 1
    fi

    echo ""
    echo "Removing ${tmp_dir}..."
    rm -r -f "${tmp_dir}"
    exit 0

else
    echo ""
    echo "Removing ${tmp_dir}..."
    rm -r -f "${tmp_dir}"
    echo "Exiting"
    exit 1
fi