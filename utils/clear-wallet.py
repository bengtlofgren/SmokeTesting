#!/usr/bin/env python3

import sys
import toml

def delete_entries_with_prefix(toml_path, prefix):
    # Load the TOML file
    with open(toml_path, "r") as file:
        data = toml.load(file)

    # Filter and delete entries with the specified prefix
    data = {section: {key: value for key, value in values.items() if not key.startswith(prefix)}
            for section, values in data.items()}

    # Write the modified TOML back to the file
    with open(toml_path, "w") as file:
        toml.dump(data, file)

wallet_toml_path = sys.argv[1]
toml_path = wallet_toml_path
prefix_to_delete = "smoketesting-"
delete_entries_with_prefix(toml_path, prefix_to_delete)