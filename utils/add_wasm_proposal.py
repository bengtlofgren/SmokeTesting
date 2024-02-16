import json

import argparse

# The first argument is the path to the proposal file, the second is the path to the wasm file
parser = argparse.ArgumentParser()
parser.add_argument("proposal_path", help="Path to the proposal file")
parser.add_argument("wasm_path", help="Path to the wasm file")

args = parser.parse_args()

# Read file to wasm_bytes
wasm_path = args.wasm_path
with open(wasm_path, "rb") as f:
    wasm_bytes = list(f.read())
# Copy wasm_bytes to clipboard

proposal_path = args.proposal_path.strip().replace(" ", "")

print("proposal path is:", proposal_path)
# Load the proposal file
with open(proposal_path, "r") as f:
    proposal = json.load(f)

proposal["data"] = wasm_bytes

with open(proposal_path, "w") as f:
    json.dump(proposal, f)

print(f"Added wasm to {proposal_path}")