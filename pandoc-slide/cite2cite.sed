#!/usr/bin/env sed -f
# Rewrite citation formats:
# - Jekyll-Scholar to Pandoc
#
# Input:
# {% cite foo_bar_2009 --file bibfile.bib %}
# {%cite foo_bar_2009%}
# {% cite foo_bar_1999 -l 99 %}
# {%cite foo_bar_1999 -l 1-99 --file bibfile.bib%}
#
# Output:
# [@foo_bar_2009]
# [@foo_bar_2009]
# [@foo_bar_1999, 99]
# [@foo_bar_1999, 1-99]

# First pass: cites with Jekyll-Scholar `-l` option:
s/{% *cite \([a-zA-Z0-9_]*\) .*-l \([a-z0-9-]*\) .*%}/[@\1, \2]/

# Second pass: cites without Jekyll-Scholar `-l` option:
s/{% *cite \([a-zA-Z0-9_]*\) *.*%}/[@\1]/