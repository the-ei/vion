#!/bin/bash
# Build content for GitHub Pages
# Copies and organizes content into docs/ directory
# Includes word counts and reading times

set -e

TRILOGY_DIR="${1:-trilogy}"
DOCS_DIR="docs"

echo "Building GitHub Pages content..."

# First, generate word counts
./tools/word-count.sh "$TRILOGY_DIR"

# Clean and recreate docs directory
rm -rf "$DOCS_DIR"
mkdir -p "$DOCS_DIR"

# Read word count data
WORD_COUNT_MD=".workers/word-counts.md"

# Create index page with stats
cat > "$DOCS_DIR/index.md" << 'EOF'
# The Eighth Oblivion Trilogy

A hard science fiction trilogy written in the combined styles of Karl Ove Knausgaard and Anne Carson.

## Books

1. [When Eighth Oblivion Wakes](book-01-when-eighth-oblivion-wakes/)
2. [Until Eighth Oblivion Breaks](book-02-until-eighth-oblivion-breaks/)
3. [Beyond Eighth Oblivion's Gates](book-03-beyond-eighth-oblivions-gates/)

## Project Status

- [Planning Documents](planning/)
- [Word Counts & Reading Times](stats.md)
- [Full Trilogy Content](trilogy-content.md)

EOF

# Add stats summary to index
if [[ -f ".workers/word-counts.json" ]]; then
    # Extract trilogy stats using grep/sed (portable)
    total_words=$(grep '"words":' .workers/word-counts.json | tail -1 | sed 's/[^0-9]//g')
    total_pages=$(grep '"pages":' .workers/word-counts.json | tail -1 | sed 's/[^0-9]//g')

    if [[ -n "$total_words" ]] && [[ "$total_words" -gt 0 ]]; then
        target_words=742500
        progress=$((total_words * 100 / target_words))
        echo "### Current Progress" >> "$DOCS_DIR/index.md"
        echo "" >> "$DOCS_DIR/index.md"
        echo "- **Words written:** $total_words" >> "$DOCS_DIR/index.md"
        echo "- **Pages:** $total_pages / 2,700" >> "$DOCS_DIR/index.md"
        echo "- **Progress:** ${progress}%" >> "$DOCS_DIR/index.md"
        echo "" >> "$DOCS_DIR/index.md"
    fi
fi

cat >> "$DOCS_DIR/index.md" << 'EOF'

---

*Near-term hard science fiction. Not dystopian, not cyberpunk.*
EOF

# Copy word counts report
if [[ -f "$WORD_COUNT_MD" ]]; then
    cp "$WORD_COUNT_MD" "$DOCS_DIR/stats.md"
fi

# Create planning directory
mkdir -p "$DOCS_DIR/planning"

# Copy trilogy-level plan
if [[ -f "$TRILOGY_DIR/PLAN.md" ]]; then
    cp "$TRILOGY_DIR/PLAN.md" "$DOCS_DIR/planning/trilogy-plan.md"
fi

# Copy characters
if [[ -f "$TRILOGY_DIR/CHARACTERS.md" ]]; then
    cp "$TRILOGY_DIR/CHARACTERS.md" "$DOCS_DIR/planning/characters.md"
fi

# Copy full trilogy content if exists
if [[ -f "$TRILOGY_DIR/CONTENT.md" ]]; then
    cp "$TRILOGY_DIR/CONTENT.md" "$DOCS_DIR/trilogy-content.md"
fi

# Process each book
for book_dir in "$TRILOGY_DIR"/book-*/; do
    if [[ -d "$book_dir" ]]; then
        book_name=$(basename "$book_dir")
        mkdir -p "$DOCS_DIR/$book_name"

        # Copy book plan
        if [[ -f "$book_dir/PLAN.md" ]]; then
            cp "$book_dir/PLAN.md" "$DOCS_DIR/planning/$book_name-plan.md"
        fi

        # Copy book content
        if [[ -f "$book_dir/CONTENT.md" ]]; then
            cp "$book_dir/CONTENT.md" "$DOCS_DIR/$book_name/index.md"
        else
            # Create placeholder with stats
            echo "# ${book_name}" > "$DOCS_DIR/$book_name/index.md"
            echo "" >> "$DOCS_DIR/$book_name/index.md"
            echo "*Content in development*" >> "$DOCS_DIR/$book_name/index.md"
            echo "" >> "$DOCS_DIR/$book_name/index.md"
            echo "[View Planning Documents](../planning/)" >> "$DOCS_DIR/$book_name/index.md"
        fi

        # Copy part plans to planning directory
        for part_dir in "$book_dir"/part-*/; do
            if [[ -d "$part_dir" ]] && [[ -f "$part_dir/PLAN.md" ]]; then
                part_name=$(basename "$part_dir")
                cp "$part_dir/PLAN.md" "$DOCS_DIR/planning/$book_name-$part_name-plan.md"
            fi
        done

        # Copy chapter plans if they exist
        for part_dir in "$book_dir"/part-*/; do
            if [[ -d "$part_dir" ]]; then
                part_name=$(basename "$part_dir")
                for chapter_dir in "$part_dir"/chapter-*/; do
                    if [[ -d "$chapter_dir" ]] && [[ -f "$chapter_dir/PLAN.md" ]]; then
                        chapter_name=$(basename "$chapter_dir")
                        cp "$chapter_dir/PLAN.md" "$DOCS_DIR/planning/$book_name-$part_name-$chapter_name-plan.md"
                    fi
                done
            fi
        done
    fi
done

# Create planning index
cat > "$DOCS_DIR/planning/index.md" << 'EOF'
# Planning Documents

## Overview
- [Trilogy Plan](trilogy-plan.md)
- [Characters](characters.md)

## Book Level
EOF

for plan in "$DOCS_DIR/planning"/book-*-plan.md; do
    if [[ -f "$plan" ]] && [[ ! "$plan" =~ part ]]; then
        name=$(basename "$plan" .md)
        echo "- [$name]($name.md)" >> "$DOCS_DIR/planning/index.md"
    fi
done

echo "" >> "$DOCS_DIR/planning/index.md"
echo "## Part Level" >> "$DOCS_DIR/planning/index.md"

for plan in "$DOCS_DIR/planning"/book-*-part-*-plan.md; do
    if [[ -f "$plan" ]] && [[ ! "$plan" =~ chapter ]]; then
        name=$(basename "$plan" .md)
        echo "- [$name]($name.md)" >> "$DOCS_DIR/planning/index.md"
    fi
done

# Add chapter level if any exist
chapter_plans=$(ls "$DOCS_DIR/planning"/book-*-part-*-chapter-*-plan.md 2>/dev/null || true)
if [[ -n "$chapter_plans" ]]; then
    echo "" >> "$DOCS_DIR/planning/index.md"
    echo "## Chapter Level" >> "$DOCS_DIR/planning/index.md"

    for plan in "$DOCS_DIR/planning"/book-*-part-*-chapter-*-plan.md; do
        if [[ -f "$plan" ]]; then
            name=$(basename "$plan" .md)
            echo "- [$name]($name.md)" >> "$DOCS_DIR/planning/index.md"
        fi
    done
fi

# Create _config.yml for Jekyll
cat > "$DOCS_DIR/_config.yml" << 'EOF'
title: The Eighth Oblivion Trilogy
description: Hard science fiction in the styles of Knausgaard and Carson
theme: jekyll-theme-minimal
markdown: kramdown
EOF

echo "GitHub Pages content built in: $DOCS_DIR/"
echo "Files created:"
find "$DOCS_DIR" -type f -name "*.md" | head -30
