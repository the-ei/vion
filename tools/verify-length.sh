#!/bin/bash
# Verify content length at all hierarchy levels
# Checks that pages, scenes, chapters meet targets with natural variation

set -e

TRILOGY_DIR="${1:-trilogy}"
OUTPUT_FILE=".workers/length-report.md"

# Target specifications (words)
PAGE_TARGET_MIN=200
PAGE_TARGET_MAX=350
PAGE_TARGET_AVG=275

SCENE_TARGET_PAGES_MIN=5
SCENE_TARGET_PAGES_MAX=15

CHAPTER_TARGET_PAGES_MIN=18
CHAPTER_TARGET_PAGES_MAX=25
CHAPTER_TARGET_AVG=21  # ~21 pages = 900/42 chapters

BOOK_TARGET_PAGES=900
BOOK_VARIANCE_PERCENT=10

# Initialize report
cat > "$OUTPUT_FILE" << EOF
# Length Verification Report
Generated: $(date -Iseconds)

## Target Specifications

### Page Level
- Target: ${PAGE_TARGET_MIN}-${PAGE_TARGET_MAX} words per page
- Average target: ~${PAGE_TARGET_AVG} words

### Scene Level
- Target: ${SCENE_TARGET_PAGES_MIN}-${SCENE_TARGET_PAGES_MAX} pages per scene

### Chapter Level
- Target: ${CHAPTER_TARGET_PAGES_MIN}-${CHAPTER_TARGET_PAGES_MAX} pages per chapter
- Average target: ~${CHAPTER_TARGET_AVG} pages

### Book Level
- Target: ~${BOOK_TARGET_PAGES} pages
- Acceptable variance: ±${BOOK_VARIANCE_PERCENT}%

---

## Analysis

EOF

total_issues=0

# Function to count words in a file
count_words() {
    local file="$1"
    if [[ -f "$file" ]]; then
        wc -w < "$file" | tr -d ' '
    else
        echo "0"
    fi
}

# Function to analyze a page
analyze_page() {
    local page_file="$1"
    local words=$(count_words "$page_file")
    local status="OK"

    if [[ $words -lt $PAGE_TARGET_MIN ]]; then
        status="SHORT"
        ((total_issues++))
    elif [[ $words -gt $PAGE_TARGET_MAX ]]; then
        status="LONG"
        ((total_issues++))
    fi

    echo "$words|$status"
}

# Function to analyze a scene
analyze_scene() {
    local scene_dir="$1"
    local page_count=0
    local total_words=0
    local issues=""

    if [[ -d "$scene_dir/page" ]]; then
        for page in "$scene_dir/page"/*.md; do
            if [[ -f "$page" ]]; then
                ((page_count++))
                local result=$(analyze_page "$page")
                local words=$(echo "$result" | cut -d'|' -f1)
                local status=$(echo "$result" | cut -d'|' -f2)
                total_words=$((total_words + words))
                if [[ "$status" != "OK" ]]; then
                    issues="$issues $(basename $page):$status"
                fi
            fi
        done
    fi

    local scene_status="OK"
    if [[ $page_count -lt $SCENE_TARGET_PAGES_MIN ]] && [[ $page_count -gt 0 ]]; then
        scene_status="SHORT"
    elif [[ $page_count -gt $SCENE_TARGET_PAGES_MAX ]]; then
        scene_status="LONG"
    fi

    echo "$page_count|$total_words|$scene_status|$issues"
}

echo "Scanning content..." >&2

# Traverse and analyze
for book_dir in "$TRILOGY_DIR"/book-*/; do
    if [[ -d "$book_dir" ]]; then
        book_name=$(basename "$book_dir")
        book_total_pages=0
        book_total_words=0
        book_issues=""

        echo "" >> "$OUTPUT_FILE"
        echo "### $book_name" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"

        for part_dir in "$book_dir"/part-*/; do
            if [[ -d "$part_dir" ]]; then
                part_name=$(basename "$part_dir")
                part_pages=0
                part_words=0

                for chapter_dir in "$part_dir"/chapter-*/; do
                    if [[ -d "$chapter_dir" ]]; then
                        chapter_name=$(basename "$chapter_dir")
                        chapter_pages=0
                        chapter_words=0
                        chapter_issues=""

                        for scene_dir in "$chapter_dir"/scene-*/; do
                            if [[ -d "$scene_dir" ]]; then
                                result=$(analyze_scene "$scene_dir")
                                scene_pages=$(echo "$result" | cut -d'|' -f1)
                                scene_words=$(echo "$result" | cut -d'|' -f2)
                                scene_status=$(echo "$result" | cut -d'|' -f3)
                                scene_issues=$(echo "$result" | cut -d'|' -f4)

                                chapter_pages=$((chapter_pages + scene_pages))
                                chapter_words=$((chapter_words + scene_words))

                                if [[ -n "$scene_issues" ]]; then
                                    chapter_issues="$chapter_issues$scene_issues"
                                fi
                            fi
                        done

                        if [[ $chapter_pages -gt 0 ]]; then
                            local chapter_status="OK"
                            if [[ $chapter_pages -lt $CHAPTER_TARGET_PAGES_MIN ]]; then
                                chapter_status="SHORT ($chapter_pages pages)"
                                ((total_issues++))
                            elif [[ $chapter_pages -gt $CHAPTER_TARGET_PAGES_MAX ]]; then
                                chapter_status="LONG ($chapter_pages pages)"
                                ((total_issues++))
                            fi

                            if [[ "$chapter_status" != "OK" ]] || [[ -n "$chapter_issues" ]]; then
                                echo "- **$part_name/$chapter_name**: $chapter_status" >> "$OUTPUT_FILE"
                                if [[ -n "$chapter_issues" ]]; then
                                    echo "  - Page issues:$chapter_issues" >> "$OUTPUT_FILE"
                                fi
                            fi
                        fi

                        part_pages=$((part_pages + chapter_pages))
                        part_words=$((part_words + chapter_words))
                    fi
                done

                book_total_pages=$((book_total_pages + part_pages))
                book_total_words=$((book_total_words + part_words))
            fi
        done

        if [[ $book_total_pages -gt 0 ]]; then
            echo "" >> "$OUTPUT_FILE"
            echo "**Book totals:** $book_total_pages pages, $book_total_words words" >> "$OUTPUT_FILE"

            # Check book target
            local target_min=$((BOOK_TARGET_PAGES * (100 - BOOK_VARIANCE_PERCENT) / 100))
            local target_max=$((BOOK_TARGET_PAGES * (100 + BOOK_VARIANCE_PERCENT) / 100))

            if [[ $book_total_pages -lt $target_min ]]; then
                echo "**STATUS: UNDER TARGET** (need $((target_min - book_total_pages)) more pages)" >> "$OUTPUT_FILE"
            elif [[ $book_total_pages -gt $target_max ]]; then
                echo "**STATUS: OVER TARGET** (by $((book_total_pages - target_max)) pages)" >> "$OUTPUT_FILE"
            else
                echo "**STATUS: ON TARGET**" >> "$OUTPUT_FILE"
            fi
        else
            echo "(No content yet)" >> "$OUTPUT_FILE"
        fi
    fi
done

echo "" >> "$OUTPUT_FILE"
echo "---" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "## Summary" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "Total issues flagged: $total_issues" >> "$OUTPUT_FILE"

echo "Report written to: $OUTPUT_FILE" >&2
echo "Total issues: $total_issues" >&2
