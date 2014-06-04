#!/usr/bin/env python
# Parse JSON-format issue tracker data

import json
import os
import re
import sys

input_file = sys.argv[1]

get_json = open(input_file)
json_data = json.load(get_json)

def is_number(s):
    """Test to see if a string can be represented as a number."""
    try:
        float(s)
        return True
    except ValueError:
        return False

def get_kvpairs(data, dict, sortkey, *keys):
    """Returns a list of lists of concatenated key-value pairs 
    for each of `*keys` in each of subdictionaries in dictionary `dict`.

    Omits key of `sortkey` so value can be used as sort key.
    """
    list = []
    for item in data[dict]:
        values = []                 # reset
        for key in keys:            # for each of the arbitrary # of keys
            value = item[key]       # ...get value of that key
            if value is not None:   # viz., as long as there exists a value
                if type(value) == int:
                    value = str(item[key])
                else:
                    value = item[key].encode('utf-8')

                # handle multiline strings:
                #   remove blank lines
                value = os.linesep.join([s for s in value.splitlines() if s])
                #   ...create a list from the remaining lines
                value = value.splitlines()
                #   ...join that list with a delimiter
                value = ': '.join(value)

                # omit key of `sortkey`, so value can be used as sort key
                if key == sortkey:
                    values.append(value)
                else:
                    values.append("[" + key + ":] " + value)
        list.append(values)
    return list

def build_list(data, *keylists):
    """Returns a single unified and sorted list.

    Each of `*keylists` has the format: [data, dict, sortkey, *keys].
    """ 
    output = []
    for keylist in keylists:
        restofkeys = keylist[1:len(keylist)]
        listoflists = get_kvpairs(data, keylist[0], keylist[1], *restofkeys)
        for item in listoflists:
            output.append(item)
    # if sortkey is representable as a number, convert to integer before sorting
    if is_number(output[0][0]):
        output = sorted(output, key=lambda item: float(item[0]))
    else:
        output = sorted(output, key=lambda item: item[0])
    return output

def format_list(data, itemtitle, *keylists, **changes):
    """Formats the list.

    `itemtitle` will appear at the first word of each entry.
    `**changes` designates transformations when the list is formatted.
    """
    list = build_list(data, *keylists)
    output = ""
    changemes = changes.keys()   # get key values from `**changes`
    for item in list:
        item = ' '.join(item)
        # swap specified alternates for key values in `**changes`
        for changeme in changemes:
            match = re.search(changeme, item)
            if match:
                item = item.replace("[" + changeme + ":]", changes[changeme])
        # concatenate output string
        output += "* " + itemtitle + " " + item + "\n\n"
    print output

if '__main__' == __name__:
    format_list(json_data, \
        "Issue",                            # item title \
        ["issues", "id", "title"],          # dict, then keys in subdicts of dict \ 
        ["comments", "issue", "content"],   # ...dict, keys in subdicts of dict \
        title="\n  Task:",                  # 'title' --> '\n Task:' \
        content="\n  Response:"             # ...etc. \
        )
