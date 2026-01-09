#!/bin/bash
# Calculate word counts and reading times for all hierarchy levels
# Outputs JSON for programmatic use and Markdown for display

set -e

TRILOGY_DIR="${1:-trilogy}"
OUTPUT_JSON=".workers/word-counts.json"
OUTPUT_MD=".workers/word-counts.md"

# Reading speed (words per minute) - average adult reading speed
READING_WPM=250

# Words per page target
WORDS_PER_PAGE=275

# Initialize JSON
echo "{" > "$OUTPUT_JSON"
echo '  "generated": "'$(date -Iseconds)'",' >> "$OUTPUT_JSON"
echo '  "reading_wpm": '$READING_WPM',' >> "$OUTPUT_JSON"
echo '  "words_per_page": '$WORDS_PER_PAGE',' >> "$OUTPUT_JSON"

# Initialize Markdown
cat > "$OUTPUT_MD" << 'EOF'
# Word Count & Reading Time Report

Generated: DATE_PLACEHOLDER

**Reading speed assumption:** 250 words/minute (average adult)

---

EOF
sed -i '' "s/DATE_PLACEHOLDER/$(date -Iseconds)/" "$OUTPUT_MD" 2>/dev/null || sed -i "s/DATE_PLACEHOLDER/$(date -Iseconds)/" "$OUTPUT_MD"

# Function to count words in a file
count_words() {
    local file="$1"
    if [[ -f "$file" ]]; then
        wc -w < "$file" | tr -d ' '
    else
        echo "0"
    fi
}

# Function to format reading time
format_time() {
    local minutes="$1"
    if [[ $minutes -lt 60 ]]; then
        echo "${minutes}m"
    else
        local hours=$((minutes / 60))
        local mins=$((minutes % 60))
        echo "${hours}h ${mins}m"
    fi
}

# Function to count words in a directory recursively (only .md files in page/ dirs)
count_dir_words() {
    local dir="$1"
    local total=0

    # Count pages directly
    if [[ -d "$dir/page" ]]; then
        for page in "$dir/page"/*.md; do
            if [[ -f "$page" ]]; then
                local words=$(count_words "$page")
                total=$((total + words))
            fi
        done
    fi

    # Recurse into subdirectories
    for subdir in "$dir"/*/; do
        if [[ -d "$subdir" ]] && [[ "$(basename "$subdir")" != "page" ]]; then
            local sub_words=$(count_dir_words "$subdir")
            total=$((total + sub_words))
        fi
    done

    echo "$total"
}

trilogy_total=0

echo '  "books": {' >> "$OUTPUT_JSON"

first_book=true
for book_dir in "$TRILOGY_DIR"/book-*/; do
    if [[ -d "$book_dir" ]]; then
        book_name=$(basename "$book_dir")
        book_words=$(count_dir_words "$book_dir")
        book_pages=$((book_words / WORDS_PER_PAGE))
        book_minutes=$((book_words / READING_WPM))
        book_time=$(format_time $book_minutes)

        trilogy_total=$((trilogy_total + book_words))

        # JSON
        if [[ "$first_book" != "true" ]]; then
            echo "," >> "$OUTPUT_JSON"
        fi
        first_book=false

        echo -n '    "'$book_name'": {"words": '$book_words', "pages": '$book_pages', "minutes": '$book_minutes >> "$OUTPUT_JSON"

        # Markdown
        echo "## $book_name" >> "$OUTPUT_MD"
        echo "" >> "$OUTPUT_MD"
        echo "| Metric | Value |" >> "$OUTPUT_MD"
        echo "|--------|-------|" >> "$OUTPUT_MD"
        echo "| Words | $book_words |" >> "$OUTPUT_MD"
        echo "| Pages | $book_pages |" >> "$OUTPUT_MD"
        echo "| Reading Time | $book_time |" >> "$OUTPUT_MD"
        echo "" >> "$OUTPUT_MD"

        # Parts
        echo ', "parts": {' >> "$OUTPUT_JSON"
        first_part=true

        echo "### Parts" >> "$OUTPUT_MD"
        echo "" >> "$OUTPUT_MD"
        echo "| Part | Words | Pages | Time |" >> "$OUTPUT_MD"
        echo "|------|-------|-------|------|" >> "$OUTPUT_MD"

        for part_dir in "$book_dir"/part-*/; do
            if [[ -d "$part_dir" ]]; then
                part_name=$(basename "$part_dir")
                part_words=$(count_dir_words "$part_dir")
                part_pages=$((part_words / WORDS_PER_PAGE))
                part_minutes=$((part_words / READING_WPM))
                part_time=$(format_time $part_minutes)

                # JSON
                if [[ "$first_part" != "true" ]]; then
                    echo "," >> "$OUTPUT_JSON"
                fi
                first_part=false
                echo -n '        "'$part_name'": {"words": '$part_words', "pages": '$part_pages', "minutes": '$part_minutes'}' >> "$OUTPUT_JSON"

                # Markdown
                echo "| $part_name | $part_words | $part_pages | $part_time |" >> "$OUTPUT_MD"
            fi
        done

        echo "" >> "$OUTPUT_JSON"
        echo '      }}' >> "$OUTPUT_JSON"
        echo "" >> "$OUTPUT_MD"
    fi
done

echo "" >> "$OUTPUT_JSON"
echo "  }," >> "$OUTPUT_JSON"

# Trilogy totals
trilogy_pages=$((trilogy_total / WORDS_PER_PAGE))
trilogy_minutes=$((trilogy_total / READING_WPM))
trilogy_time=$(format_time $trilogy_minutes)

echo '  "trilogy": {' >> "$OUTPUT_JSON"
echo '    "words": '$trilogy_total',' >> "$OUTPUT_JSON"
echo '    "pages": '$trilogy_pages',' >> "$OUTPUT_JSON"
echo '    "minutes": '$trilogy_minutes >> "$OUTPUT_JSON"
echo '  }' >> "$OUTPUT_JSON"
echo "}" >> "$OUTPUT_JSON"

# Markdown totals
echo "---" >> "$OUTPUT_MD"
echo "" >> "$OUTPUT_MD"
echo "## Trilogy Totals" >> "$OUTPUT_MD"
echo "" >> "$OUTPUT_MD"
echo "| Metric | Value | Target |" >> "$OUTPUT_MD"
echo "|--------|-------|--------|" >> "$OUTPUT_MD"
echo "| Words | $trilogy_total | ~742,500 |" >> "$OUTPUT_MD"
echo "| Pages | $trilogy_pages | 2,700 |" >> "$OUTPUT_MD"
echo "| Reading Time | $trilogy_time | ~49h 30m |" >> "$OUTPUT_MD"
echo "" >> "$OUTPUT_MD"

# Progress percentage
if [[ $trilogy_total -gt 0 ]]; then
    target_words=742500
    progress=$((trilogy_total * 100 / target_words))
    echo "**Progress:** ${progress}% of target word count" >> "$OUTPUT_MD"
else
    echo "**Progress:** No content written yet" >> "$OUTPUT_MD"
fi

echo "" >&2
echo "Word count complete:" >&2
echo "  JSON: $OUTPUT_JSON" >&2
echo "  Markdown: $OUTPUT_MD" >&2
echo "  Trilogy: $trilogy_total words ($trilogy_pages pages, $trilogy_time reading time)" >&2
