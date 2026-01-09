#!/bin/bash
# Prepare verification tasks for manager to process with LLM
# Outputs JSON-formatted verification requests

set -e

TRILOGY_DIR="${1:-trilogy}"
OUTPUT_DIR=".workers/verification"

mkdir -p "$OUTPUT_DIR"

# Clear previous verification requests
rm -f "$OUTPUT_DIR"/*.json

request_id=0

# Function to create parent-child verification request
create_parent_child_request() {
    local parent_plan="$1"
    local child_plan="$2"

    if [[ ! -f "$parent_plan" ]] || [[ ! -f "$child_plan" ]]; then
        return
    fi

    request_id=$((request_id + 1))
    local output_file="$OUTPUT_DIR/verify-$request_id.json"

    cat > "$output_file" << EOF
{
    "type": "parent_child",
    "id": $request_id,
    "parent_path": "$parent_plan",
    "child_path": "$child_plan",
    "status": "pending"
}
EOF
    echo "Created: $output_file"
}

# Function to create sibling verification request
create_sibling_request() {
    local dir="$1"
    local plans=()

    for plan in "$dir"/*/PLAN.md; do
        if [[ -f "$plan" ]]; then
            plans+=("\"$plan\"")
        fi
    done

    if [[ ${#plans[@]} -lt 2 ]]; then
        return
    fi

    request_id=$((request_id + 1))
    local output_file="$OUTPUT_DIR/verify-$request_id.json"
    local plans_json=$(IFS=,; echo "${plans[*]}")

    cat > "$output_file" << EOF
{
    "type": "sibling",
    "id": $request_id,
    "directory": "$dir",
    "plans": [$plans_json],
    "status": "pending"
}
EOF
    echo "Created: $output_file"
}

# Recursive traversal
traverse() {
    local dir="$1"
    local parent_plan="$dir/PLAN.md"

    for child_dir in "$dir"/*/; do
        if [[ -d "$child_dir" ]]; then
            local child_plan="$child_dir/PLAN.md"
            create_parent_child_request "$parent_plan" "$child_plan"
            traverse "$child_dir"
        fi
    done

    create_sibling_request "$dir"
}

echo "Preparing verification requests..."
traverse "$TRILOGY_DIR"
echo ""
echo "Verification requests created in: $OUTPUT_DIR/"
echo "Total requests: $request_id"
echo ""
echo "Manager should process each request with LLM verification."
