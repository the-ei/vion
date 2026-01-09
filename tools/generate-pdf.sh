#!/bin/bash
# Generate PDF of the full trilogy
# Requires pandoc with PDF support

set -e

TRILOGY_DIR="${1:-trilogy}"
OUTPUT_DIR="${2:-docs}"
PDF_FILE="$OUTPUT_DIR/the-eighth-oblivion-trilogy.pdf"

echo "Generating PDF..."

# Check if trilogy CONTENT.md exists
if [[ ! -f "$TRILOGY_DIR/CONTENT.md" ]]; then
    echo "Error: $TRILOGY_DIR/CONTENT.md not found. Run rollup.sh first."
    exit 1
fi

# Create temporary file with title page
TEMP_MD=$(mktemp)

cat > "$TEMP_MD" << 'EOF'
---
title: "The Eighth Oblivion Trilogy"
author: ""
documentclass: book
geometry: margin=1in
fontsize: 11pt
linestretch: 1.15
toc: true
toc-depth: 2
---

\newpage

EOF

# Append the trilogy content
cat "$TRILOGY_DIR/CONTENT.md" >> "$TEMP_MD"

# Generate PDF
pandoc "$TEMP_MD" \
    -o "$PDF_FILE" \
    --pdf-engine=pdflatex \
    -V papersize=letter \
    -V mainfont="Times New Roman" \
    --toc \
    --toc-depth=2 \
    2>&1 || {
    echo "PDF generation failed. Trying without LaTeX..."
    # Fallback: try with wkhtmltopdf or basic PDF
    pandoc "$TEMP_MD" \
        -o "$PDF_FILE" \
        --pdf-engine=wkhtmltopdf \
        2>&1 || {
        echo "Warning: Could not generate PDF. Creating HTML instead."
        pandoc "$TEMP_MD" -o "$OUTPUT_DIR/the-eighth-oblivion-trilogy.html" --standalone
    }
}

rm -f "$TEMP_MD"

if [[ -f "$PDF_FILE" ]]; then
    SIZE=$(du -h "$PDF_FILE" | cut -f1)
    echo "PDF generated: $PDF_FILE ($SIZE)"
else
    echo "PDF generation completed with fallback."
fi
