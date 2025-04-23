#!/bin/bash

# --- USAGE ---
# ./convert_mol2_to_yaml_json.sh input.mol2

# --- Templates (for user reference) ---
# YAML:
# inchi: InChI=...
# inchikey: ...
# smiles: ...
#
# JSON with descriptors:
# {
#   "0": {
#     "inchi": "...",
#     "inchiKey": "...",
#     "smiles": "..."
#   }
# }
#
# JSON with molId:
# {
#   "0": {
#     "molId": "...",
#     "propertyTypeId": "...",
#     "calculatorref": "...",
#     "isPreComputedProperty": true,
#     "value": -100.0
#   }
# }

# --- Input file parsing ---
input_file="$1"

if [[ -z "$input_file" ]]; then
  echo "Usage: $0 input.mol2"
  exit 1
fi

basename=$(basename "$input_file" .mol2)
yaml_file="${basename}.yaml"
json_file="${basename}.json"
homo_json_file="add_HOMO_${basename}.json"

# --- Extract identifiers using obabel ---
inchi=$(obabel "$input_file" -oinchi --quiet | grep "^InChI=")
inchikey=$(obabel "$input_file" -oinchikey --quiet | awk '{print $1}')
smiles=$(obabel "$input_file" -osmi --quiet | awk '{print $1}')

# --- Check success ---
if [[ -z "$inchi" || -z "$inchikey" || -z "$smiles" ]]; then
  echo "Error: Could not extract identifiers from $input_file"
  exit 2
fi

# --- Write YAML ---
cat > "$yaml_file" <<EOF
inchi: $inchi
inchikey: $inchikey
smiles: $smiles
EOF
echo "YAML written to $yaml_file"

# --- Write JSON with identifiers ---
cat > "$json_file" <<EOF
{
  "0": {
    "inchi": "$inchi",
    "inchiKey": "$inchikey",
    "smiles": "$smiles"
  }
}
EOF
echo "Descriptor JSON written to $json_file"

# --- Write HOMO JSON with molId ---
cat > "$homo_json_file" <<EOF
{
  "0": {
    "molId": "$inchikey",
    "propertyTypeId": "604863ea-2184-46a1-b942-f6f636d74461",
    "calculatorref": "12d12b12-803d-451f-87b4-0f92bfe0c342",
    "isPreComputedProperty": true,
    "value": -100.0
  }
}
EOF
echo "HOMO JSON written to $homo_json_file"
