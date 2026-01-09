#!/bin/bash
# Roll up content from leaf pages to higher levels
# Creates CONTENT.md at each level by concatenating children

set -e

TRILOGY_DIR="${1:-trilogy}"

# Extract title from PLAN.md if it exists
get_plan_title() {
    local dir="$1"
    local plan_file="$dir/PLAN.md"
    if [[ -f "$plan_file" ]]; then
        # Extract title after "# ... Plan: " on first line
        local title=$(head -1 "$plan_file" | sed 's/^# .*Plan: //')
        if [[ -n "$title" && "$title" != "$(head -1 "$plan_file")" ]]; then
            echo "$title"
            return 0
        fi
    fi
    return 1
}

# Convert directory names to proper titles
format_title() {
    local name="$1"
    local dir="$2"  # Optional: directory path to check for PLAN.md
    local num
    local plan_title

    case "$name" in
        "book-01-when-eighth-oblivion-wakes") echo "When Eighth Oblivion Wakes" ;;
        "book-02-until-eighth-oblivion-breaks") echo "Until Eighth Oblivion Breaks" ;;
        "book-03-beyond-eighth-oblivions-gates") echo "Beyond Eighth Oblivion's Gates" ;;
        part-*)
            num=$((10#${name#part-}))
            if [[ -n "$dir" ]] && plan_title=$(get_plan_title "$dir"); then
                echo "Part $num: $plan_title"
            else
                echo "Part $num"
            fi
            ;;
        chapter-*)
            num=$((10#${name#chapter-}))
            if [[ -n "$dir" ]] && plan_title=$(get_plan_title "$dir"); then
                echo "Chapter $num: $plan_title"
            else
                echo "Chapter $num"
            fi
            ;;
        scene-*)
            echo "__SCENE_BREAK__"  # Marker for scene break (processed separately)
            ;;
        *) echo "$name" ;;
    esac
}

echo "Rolling up content from leaves to root..."

# Function to roll up a directory
rollup_dir() {
    local dir="$1"
    local content_file="$dir/CONTENT.md"
    local has_content=false

    # First, recursively roll up all subdirectories
    for subdir in "$dir"/*/; do
        if [[ -d "$subdir" ]]; then
            rollup_dir "$subdir"
        fi
    done

    # Now collect content for this level
    local temp_content=$(mktemp)

    # Check for page directory with .md files (leaf level)
    if [[ -d "$dir/page" ]]; then
        for page in "$dir/page"/*.md; do
            if [[ -f "$page" ]]; then
                cat "$page" >> "$temp_content"
                echo -e "\n\n" >> "$temp_content"
                has_content=true
            fi
        done
    fi

    # Check for child CONTENT.md files
    local first_child=true
    for child_content in "$dir"/*/CONTENT.md; do
        if [[ -f "$child_content" ]]; then
            # Extract directory name for section header
            child_dir=$(dirname "$child_content")
            child_name=$(basename "$child_dir")
            child_title=$(format_title "$child_name" "$child_dir")

            # Handle scene breaks specially - only divider between scenes, not header
            if [[ "$child_title" == "__SCENE_BREAK__" ]]; then
                if [[ "$first_child" != "true" ]]; then
                    # Add scene break divider (horizontal rule)
                    echo -e "\n---\n" >> "$temp_content"
                fi
            else
                echo -e "# $child_title\n" >> "$temp_content"
            fi

            cat "$child_content" >> "$temp_content"
            echo -e "\n\n" >> "$temp_content"
            has_content=true
            first_child=false
        fi
    done

    if [[ "$has_content" == "true" ]]; then
        mv "$temp_content" "$content_file"
        echo "Created: $content_file"
    else
        rm -f "$temp_content"
    fi
}

# Start rollup from trilogy directory
rollup_dir "$TRILOGY_DIR"

echo "Rollup complete."
