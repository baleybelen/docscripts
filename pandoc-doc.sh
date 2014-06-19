#!/usr/bin/env bash
# Description: Process Pandoc Markdown into document formats
#
# Sample output filename:
# blennon-proglang-v1.0.0-0-g9ebab6a-introduction+201406040231.pdf

set -o errexit
set -o nounset
# set -o xtrace

pandoc="/usr/local/bin/pandoc"

function display_usage {
    echo "Usage: $(basename "${0}") -t [pdf-article | pdf-book | html | odt | docx] -c [0-5] -f file" 1>&2
    echo "       -t   to format" 1>&2
    echo "       -c   table of contents depth (0 = no table of contents)" 1>&2
    echo "       -f   file to process (can be a relative path)" 1>&2
    }

if [ $# -lt 6 ]; then
    display_usage
    exit 2
fi

function get_absolute_filename {
  if [ ! -d "$(dirname "${1}")" ]; then
    echo "Cannot locate file ${1}" 1>&2
    exit 2
  else
    echo "$(cd "$(dirname "${1}")" && pwd)/$(basename "${1}")"
  fi
}

function get_fileinfo {
    username=$(whoami)
    filename=$(basename "${1}")
    extensionless="${filename%%.*}"

    dir_name=$(dirname "${1}")
    build_dir="${dir_name}/build"
    dir="${dir_name##*/}"

    buildtag=$(date +%Y%m%d%H%M%S)

    # Workaround: we don't want "." as an element of "${build_name}".
    # If file that the script is invoked on is in current working dir,
    # then reassign "${dir}":
    if [ "${dir}" = "." ]; then
        dir=$(basename "$PWD")
    fi

    git_last_commit_date=$(git -C ${dir_name} log HEAD --pretty=format:%ad --date=short -1 | sed 's/-//g')
    git_describe_string="git -C ${dir_name} describe HEAD --tags --long"
    # Catch Git errors when there are no tags to describe:
    git_describe=$(${git_describe_string}) && out="${?}" || out="${?}"
    if [ ! "${out}" -eq 0 ]; then
       echo "^Git error; perhaps there are no tags to describe?" 1>&2
       exit 2
    fi

    build_name="${username}"-"${dir}"-"${git_describe}"-"${git_last_commit_date}"-"${filename}"+"${buildtag}"
    }

function set_global_opts {
    opts="\
--smart \
--filter=pandoc-citeproc \
"
    pdf_article_opts="\
--latex-engine=xelatex \
--template=$HOME/sync/config/pandoc/templates/default.latex \
--variable=documentclass:memoir \
--variable=classoption:oneside \
--variable=classoption:article \
--variable=fontsize:12pt \
--variable=mainfont:Cardo \
--output=${build_dir}/${build_name}.pdf\
"

    pdf_book_opts="\
--latex-engine=xelatex \
--template=$HOME/sync/config/pandoc/templates/default.latex \
--variable=documentclass:memoir \
--variable=classoption:oneside \
--variable=include-before:\setcounter{chapter}{-1} \
--variable=include-before:\settocdepth{chapter} \
--variable=include-before:\chapterstyle{wilsondob} \
--variable=include-before:\pagestyle{plain} \
--variable=include-before:\renewcommand\contentsname{} \
--variable=fontsize:12pt \
--variable=mainfont:Cardo \
--variable=linkcolor:black \
--output=${build_dir}/${build_name}.pdf\
"

    # Don't use `--standalone`; it's implied by `--template`
    # (so adding it turns it off?):
    html_opts="\
--to=html \
--self-contained \
--template=$HOME/sync/config/pandoc/templates/default.html \
--css=$HOME/sync/lib/css/kultiad-serif.css \
--metadata=user-name:$username \
--metadata=project-name:$dir \
--metadata=filename:$filename \
--metadata=extensionless:$extensionless \
--metadata=versiondate:$git_last_commit_date \
--metadata=build-tag:$buildtag \
--output=${build_dir}/${build_name}.html\
"
    odt_opts="\
--to=odt \
--output=${build_dir}/${build_name}.odt\
"
    docx_opts="\
--to=docx \
--output=${build_dir}/${build_name}.docx\
"
    }

function set_toc_opts {
    case "${1}" in
        "0") toc_opts="";;
        "1") toc_opts="--table-of-contents --toc-depth=1";;
        "2") toc_opts="--table-of-contents --toc-depth=2";;
        "3") toc_opts="--table-of-contents --toc-depth=3";;
        "4") toc_opts="--table-of-contents --toc-depth=4";;
        "5") toc_opts="--table-of-contents --toc-depth=5";;
    esac
    }

function assign_format_opts {
    case "${1}" in
        "pdf-article" ) add_opts="${pdf_article_opts}";;
        "pdf-book" ) add_opts="${pdf_book_opts}";;
        "html") add_opts="${html_opts}";;
        "odt" ) add_opts="${odt_opts}";;
        "docx") add_opts="${docx_opts}";;
    esac
    }

function build_file {
    # Create dir 'build' if it doesn't exist
    if [ ! -d "${build_dir}" ]; then
      echo "Running 'mkdir ${dir_name}/build'..."
      mkdir "${dir_name}"/build
    fi
    echo "Running 'pandoc ${1} ${opts} ${toc_opts} ${add_opts}'..."
    # ${opts} ${toc_opts} ${add_opts} must *not* be quoted, below:
    "${pandoc}" "${1}" ${opts} ${add_opts} ${toc_opts}
    }

while getopts ":t:c:f:" opt; do
  case "${opt}" in
    "t" ) format="${OPTARG}"
        case "${format}" in
            "pdf-article" ) ;;
            "pdf-book" ) ;;
            "html") ;;
            "odt" ) ;;
            "docx") ;;
            *) echo "Invalid format parameter: ${format}" 1>&2
               exit 1;;
        esac
        ;;
    "c" ) toc="${OPTARG}"
        case "${toc}" in
            "0") ;;
            "1") ;;
            "2") ;;
            "3") ;;
            "4") ;;
            "5") ;;
            *) echo "Invalid TOC depth: ${toc}" 1>&2
               exit 1;;
        esac
        ;;
    "f" ) file=$(get_absolute_filename "${OPTARG}")
        if [ ! -f "${file}" ]; then
           echo "Cannot locate file '${file}'" 1>&2
           exit 2
        fi
        get_fileinfo "${file}"
        set_global_opts
        set_toc_opts "${toc}"
        assign_format_opts "${format}"
        build_file "${file}"
        exit 0
        ;;
    \?) echo "Invalid option: -${OPTARG}" 1>&2
       exit 1;;
    : ) echo "Option -${OPTARG} requires an argument." 1>&2
       exit 1;;
  esac
done
