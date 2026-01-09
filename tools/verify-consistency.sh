#!/bin/bash
# Verify consistency between hierarchy levels
# Uses LLM to check parent-child and sibling alignment

set -e

TRILOGY_DIR="${1:-trilogy}"
ISSUES_FILE=".workers/consistency-issues.md"

echo "# Consistency Check Report" > "$ISSUES_FILE"
echo "Generated: $(date -Iseconds)" >> "$ISSUES_FILE"
echo "" >> "$ISSUES_FILE"

issues_found=0

# Function to check parent-child consistency
check_parent_child() {
    local parent_plan="$1"
    local child_plan="$2"

    if [[ ! -f "$parent_plan" ]] || [[ ! -f "$child_plan" ]]; then
        return
    fi

    echo "Checking: $child_plan against $parent_plan"

    # Create verification prompt
    local prompt="Compare these two planning documents for consistency.

PARENT PLAN ($parent_plan):
$(cat "$parent_plan")

CHILD PLAN ($child_plan):
$(cat "$child_plan")

Does the child plan align with and serve the parent plan?
Report any inconsistencies in: themes, timeline, characters, events, tone.
If consistent, respond with just: CONSISTENT
If issues found, list them briefly."

    # Store prompt for LLM verification (to be processed by manager)
    echo "## Check: $child_plan" >> "$ISSUES_FILE"
    echo "Parent: $parent_plan" >> "$ISSUES_FILE"
    echo "Status: PENDING_VERIFICATION" >> "$ISSUES_FILE"
    echo "" >> "$ISSUES_FILE"
}

# Function to check sibling consistency
check_siblings() {
    local dir="$1"
    local plans=()

    for plan in "$dir"/*/PLAN.md; do
        if [[ -f "$plan" ]]; then
            plans+=("$plan")
        fi
    done

    if [[ ${#plans[@]} -lt 2 ]]; then
        return
    fi

    echo "Checking siblings in: $dir"
    echo "## Sibling Check: $dir" >> "$ISSUES_FILE"
    echo "Plans: ${plans[*]}" >> "$ISSUES_FILE"
    echo "Status: PENDING_VERIFICATION" >> "$ISSUES_FILE"
    echo "" >> "$ISSUES_FILE"
}

# Recursive function to traverse hierarchy
traverse_hierarchy() {
    local dir="$1"
    local parent_plan="$dir/PLAN.md"

    # Check each child against parent
    for child_dir in "$dir"/*/; do
        if [[ -d "$child_dir" ]]; then
            local child_plan="$child_dir/PLAN.md"
            check_parent_child "$parent_plan" "$child_plan"
            traverse_hierarchy "$child_dir"
        fi
    done

    # Check siblings at this level
    check_siblings "$dir"
}

# Start traversal
traverse_hierarchy "$TRILOGY_DIR"

echo ""
echo "Verification prompts written to: $ISSUES_FILE"
echo "Manager should process these with LLM and flag issues for human review."
