#!/bin/bash
# Calculate target lengths for worker instructions
# Computes page counts from hierarchy position

set -e

# Book-level targets
BOOK_PAGES=900
BOOK_CHAPTERS=42
PARTS_PER_BOOK=5

# Calculate derived targets
PAGES_PER_CHAPTER=$((BOOK_PAGES / BOOK_CHAPTERS))  # ~21 pages

# Chapter distribution by part (from PLAN.md files)
# Parts have varying chapter counts:
# Part 1: 8 chapters, Part 2: 9 chapters, Part 3: 9 chapters, Part 4: 9 chapters, Part 5: 7 chapters

usage() {
    echo "Usage: $0 <level> <path>"
    echo ""
    echo "Levels:"
    echo "  part    - Calculate chapter and page targets for a part"
    echo "  chapter - Calculate scene and page targets for a chapter"
    echo "  scene   - Calculate page targets for a scene"
    echo ""
    echo "Examples:"
    echo "  $0 part trilogy/book-01-.../part-01"
    echo "  $0 chapter trilogy/book-01-.../part-01/chapter-01"
    echo "  $0 scene trilogy/book-01-.../part-01/chapter-01/scene-01"
}

calculate_part_targets() {
    local part_path="$1"
    local part_name=$(basename "$part_path")

    # Determine chapter count based on part number
    local part_num=${part_name#part-}
    part_num=$((10#$part_num))  # Remove leading zeros

    local chapter_count
    local page_target
    case $part_num in
        1) chapter_count=8; page_target=168 ;;   # 8 * 21
        2) chapter_count=9; page_target=189 ;;   # 9 * 21
        3) chapter_count=9; page_target=189 ;;   # 9 * 21
        4) chapter_count=9; page_target=189 ;;   # 9 * 21
        5) chapter_count=7; page_target=147 ;;   # 7 * 21
        *) chapter_count=8; page_target=168 ;;   # default
    esac

    cat << EOF
## Part Targets: $part_name

- **Chapters in part:** $chapter_count
- **Total pages target:** ~$page_target pages
- **Average pages per chapter:** $PAGES_PER_CHAPTER pages

### Chapter Page Distribution (with natural variation)

| Chapter | Target Pages | Words (approx) |
|---------|-------------|----------------|
EOF

    # Generate chapter targets with variation
    local variation_range=4  # +/- 2 pages
    for i in $(seq 1 $chapter_count); do
        # Add some variation (-2 to +2 pages)
        local var=$(( (RANDOM % 5) - 2 ))
        local pages=$((PAGES_PER_CHAPTER + var))
        local words=$((pages * 275))
        printf "| Chapter %02d | %d pages | %d words |\n" $i $pages $words
    done

    echo ""
    echo "### Worker Instructions Template"
    echo ""
    echo '```'
    echo "Target: $page_target pages for this part ($chapter_count chapters)"
    echo "Average: $PAGES_PER_CHAPTER pages per chapter (18-25 acceptable)"
    echo "Pages: 275 words each (200-350 acceptable)"
    echo "Natural variation expected and encouraged."
    echo '```'
}

calculate_chapter_targets() {
    local chapter_path="$1"
    local chapter_name=$(basename "$chapter_path")

    # Default to 21 pages, estimate 3-5 scenes
    local page_target=$PAGES_PER_CHAPTER
    local min_scenes=3
    local max_scenes=5
    local avg_pages_per_scene=$((page_target / 4))  # ~5 pages per scene

    cat << EOF
## Chapter Targets: $chapter_name

- **Total pages target:** $page_target pages
- **Words target:** ~$((page_target * 275)) words
- **Expected scenes:** $min_scenes-$max_scenes scenes
- **Average pages per scene:** $avg_pages_per_scene pages

### Scene Distribution Template

| Scene | Target Pages | Notes |
|-------|-------------|-------|
| Scene 01 | 4-6 pages | Opening/establishment |
| Scene 02 | 5-7 pages | Development |
| Scene 03 | 4-6 pages | Complication/turn |
| Scene 04 | 5-8 pages | Climax/resolution |

### Worker Instructions Template

\`\`\`
Target: $page_target pages for this chapter
Scenes: $min_scenes-$max_scenes scenes
Pages per scene: 4-8 pages (vary naturally)
Words per page: 275 (200-350 acceptable)
Total words: ~$((page_target * 275))
\`\`\`
EOF
}

calculate_scene_targets() {
    local scene_path="$1"
    local scene_name=$(basename "$scene_path")

    # Default scene is ~5-6 pages
    local min_pages=4
    local max_pages=8
    local avg_pages=6

    cat << EOF
## Scene Targets: $scene_name

- **Target pages:** $min_pages-$max_pages pages
- **Words target:** ~$((avg_pages * 275)) words ($((min_pages * 275))-$((max_pages * 275)))

### Page Distribution Template

| Page | Words Target | Notes |
|------|-------------|-------|
| 001.md | 250-300 | Scene opening |
| 002.md | 275-325 | Development |
| 003.md | 250-300 | Building tension |
| 004.md | 275-325 | Peak moment |
| 005.md | 250-300 | Scene close |

### Worker Instructions Template

\`\`\`
Target: $min_pages-$max_pages pages for this scene
Words per page: 275 (200-350 acceptable)
Total words: $((min_pages * 275))-$((max_pages * 275))

Page guidance:
- End each page at natural pause (sentence/paragraph break)
- Vary page lengths naturally (not all 275 words exactly)
- Shorter pages for high intensity moments (Carson mode)
- Longer pages for reflective passages (Knausgaard mode)
\`\`\`
EOF
}

# Main
if [[ $# -lt 2 ]]; then
    usage
    exit 1
fi

level="$1"
path="$2"

case "$level" in
    part)
        calculate_part_targets "$path"
        ;;
    chapter)
        calculate_chapter_targets "$path"
        ;;
    scene)
        calculate_scene_targets "$path"
        ;;
    *)
        echo "Unknown level: $level"
        usage
        exit 1
        ;;
esac
