#!/bin/bash

# --- USAGE ---
# ./convert_mol2_to_yaml_json.sh input.mol2 [output.yaml] [output.json]

# --- TEMPLATES (user-visible examples) ---
# YAML template:
# inchi: InChI=...
# inchikey: ...
# smiles: ...

# JSON template:
# {
#   "0": {
#     "molId": "REAL_INCHIKEY",
#     "propertyTypeId": "604863ea-2184-46a1-b942-f6f636d74461",
#     "calculatorref": "12d12b12-803d-451f-87b4-0f92bfe0c342",
#     "isPreComputedProperty": true,
#     "value": -100.0
#   }
# }

# --- Argument parsing ---
input_file="$1"
yaml_file="${2:-output.yaml}"
json_file="${3:-output.json}"

if [[ -z "$input_file" ]]; then
  echo "Usage: $0 input.mol2 [output.yaml] [output.json]"
  exit 1
fi

# --- Extract identifiers using obabel ---
inchi=$(obabel "$input_file" -oinchi --quiet | grep InChI=)
inchikey=$(obabel "$input_file" -oinchikey --quiet)
smiles=$(obabel "$input_file" -osmi --quiet)

# --- Check for success ---
if [[ -z "$inchi" || -z "$inchikey" || -z "$smiles" ]]; then
  echo "Error: Could not extract identifiers from $input_file"
  exit 2
fi

# --- Write YAML file ---
cat > "$yaml_file" <<EOF
inchi: $inchi
inchikey: $inchikey
smiles: $smiles
EOF

echo "YAML written to $yaml_file"

# --- Write JSON file ---
cat > "$json_file" <<EOF
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

echo "JSON written to $json_file"
