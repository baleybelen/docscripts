#!/usr/bin/env bash

#: description:     Write changelog
#: usage:           changelog.sh <directory>
#: options:
#: author:          Brian Lennon
#: version:         $version$
#: date:            $date$


# OPTIONS

set -o errexit
# set -o nounset    # Interferes with use of unbound variables
# set -o xtrace


# VARIABLES

targetdir="${1}"
git="/usr/bin/git"

# Commit messages to exclude
msg_exclude_regex=(".gitignore|Initial commit|README")


# FUNCTIONS

display_usage()
{
cat <<EOF
Usage: $(basename "${0}") <directory>
(<directory> can be a relative path)
EOF
}

print_underscored()      #@ Make setex-style header
{                        #@ Usage: print_underscored <string> <underscorechar>
  local error="Error: print_underscored() requires <string> <underscorechar>"
  test $# -eq 2 &&
  {
    local string="${1}"; local stringsize="${#1}"; local underscorechar="${2}"
    printf "${string}\n"
    printf "%0.s${underscorechar}" $(seq 1 "${stringsize}")
    return 0
  } || {
    printf "${error}\n" 1>&2; return 1
  }
}


# BODY OF SCRIPT WITH MAIN LOOP

test $# -eq 1 -a -d "${targetdir}" && # Test argument

print_underscored "Changelog" "-"  &&

# If there are no annotated tags, get commit messages from log
if [[ -z $("${git}" -C "${targetdir}" tag -l) ]]; then
  printf "\n\n"
  "${git}" -C "${targetdir}" log --no-merges --format="* %s"                  \
    | sed -E /"${msg_exclude_regex}"/d
else
  # Get list of tags, sort in reverse order, and print tag messages
  "${git}" -C "${targetdir}" tag -l | sort -u -r | while read tag ; do
    printf "\n\n### ${tag} $(${git} -C ${targetdir} show ${tag}               \
      --format=%ad --date=short --no-patch                                    \
      | grep -E '^(19|20)\d\d-(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[01])$')\n\n"
    GIT_PAGER=cat "${git}" -C "${targetdir}" tag --list -n99                  \
      "${tag}"                                                                \
      | sed -e 's/^v[0-9a-zA-Z.-_]* *//'                                      \
            -e 's/^[ \t]*[\*] /* /'                                           \
            -e 's/^[ \t]*-/    -/'
  done
fi &&


# EXIT

exit 0 || display_usage && exit 1
