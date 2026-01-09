#!/bin/bash
# Build content for GitHub Pages
# Copies and organizes content into docs/ directory

set -e

TRILOGY_DIR="${1:-trilogy}"
DOCS_DIR="docs"

echo "Building GitHub Pages content..."

# Clean and recreate docs directory
rm -rf "$DOCS_DIR"
mkdir -p "$DOCS_DIR"

# Create index page
cat > "$DOCS_DIR/index.md" << 'EOF'
# The Eighth Oblivion Trilogy

A hard science fiction trilogy written in the combined styles of Karl Ove Knausgaard and Anne Carson.

## Books

1. [When Eighth Oblivion Wakes](book-01-when-eighth-oblivion-wakes/)
2. [Until Eighth Oblivion Breaks](book-02-until-eighth-oblivion-breaks/)
3. [Beyond Eighth Oblivion's Gates](book-03-beyond-eighth-oblivions-gates/)

## Project Status

- [Planning Documents](planning/)
- [Full Trilogy Content](trilogy-content.md)

---

*Near-term hard science fiction. Not dystopian, not cyberpunk.*
EOF

# Create planning directory
mkdir -p "$DOCS_DIR/planning"

# Copy trilogy-level plan
if [[ -f "$TRILOGY_DIR/PLAN.md" ]]; then
    cp "$TRILOGY_DIR/PLAN.md" "$DOCS_DIR/planning/trilogy-plan.md"
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
            # Create placeholder
            echo "# ${book_name}" > "$DOCS_DIR/$book_name/index.md"
            echo "" >> "$DOCS_DIR/$book_name/index.md"
            echo "*Content in development*" >> "$DOCS_DIR/$book_name/index.md"
        fi

        # Copy part plans to planning directory
        for part_dir in "$book_dir"/part-*/; do
            if [[ -d "$part_dir" ]] && [[ -f "$part_dir/PLAN.md" ]]; then
                part_name=$(basename "$part_dir")
                cp "$part_dir/PLAN.md" "$DOCS_DIR/planning/$book_name-$part_name-plan.md"
            fi
        done
    fi
done

# Create planning index
cat > "$DOCS_DIR/planning/index.md" << 'EOF'
# Planning Documents

## Trilogy Level
- [Trilogy Plan](trilogy-plan.md)

## Book Level
EOF

for plan in "$DOCS_DIR/planning"/book-*-plan.md; do
    if [[ -f "$plan" ]]; then
        name=$(basename "$plan" .md)
        echo "- [$name]($name.md)" >> "$DOCS_DIR/planning/index.md"
    fi
done

echo "" >> "$DOCS_DIR/planning/index.md"
echo "## Part Level" >> "$DOCS_DIR/planning/index.md"

for plan in "$DOCS_DIR/planning"/book-*-part-*-plan.md; do
    if [[ -f "$plan" ]]; then
        name=$(basename "$plan" .md)
        echo "- [$name]($name.md)" >> "$DOCS_DIR/planning/index.md"
    fi
done

# Create _config.yml for Jekyll
cat > "$DOCS_DIR/_config.yml" << 'EOF'
title: The Eighth Oblivion Trilogy
description: Hard science fiction in the styles of Knausgaard and Carson
theme: jekyll-theme-minimal
markdown: kramdown
EOF

echo "GitHub Pages content built in: $DOCS_DIR/"
echo "Files created:"
find "$DOCS_DIR" -type f -name "*.md" | head -20
