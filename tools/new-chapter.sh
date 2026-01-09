#!/bin/bash
# Create new chapter structure with template files
# Usage: ./new-chapter.sh book-01-when-eighth-oblivion-wakes part-01 chapter-01

set -e

if [[ $# -lt 3 ]]; then
    echo "Usage: $0 <book-dir> <part-dir> <chapter-dir>"
    echo "Example: $0 book-01-when-eighth-oblivion-wakes part-01 chapter-01"
    exit 1
fi

BOOK="$1"
PART="$2"
CHAPTER="$3"
BASE_PATH="trilogy/$BOOK/$PART/$CHAPTER"

echo "Creating chapter structure at: $BASE_PATH"

# Create chapter directory
mkdir -p "$BASE_PATH"

# Create chapter plan template
cat > "$BASE_PATH/PLAN.md" << EOF
# Chapter Plan: $CHAPTER

## Summary
[Chapter-level summary - 2-3 paragraphs describing the key events and emotional arc]

## Key Elements
- [Major plot point 1]
- [Major plot point 2]
- [Character development moment]
- [Thematic element]

## Characters Present
- [Character 1]: [Role in this chapter]
- [Character 2]: [Role in this chapter]

## Timeline
- Duration: [How much time passes]
- When: [Placement in overall timeline]

## Setting
- Primary location(s):
- Atmosphere/mood:

## Connections
- Parent (Part): [How this chapter serves the part's goals]
- Previous Chapter: [Continuity from previous]
- Next Chapter: [Setup for next]

## Scenes
List the scenes that will comprise this chapter:

1. Scene 01: [Brief description]
2. Scene 02: [Brief description]
3. Scene 03: [Brief description]

## POV
- Primary POV character:
- Style emphasis: [More Knausgaard / More Carson / Balanced]

## Open Questions
- [Decisions that need resolution]
EOF

# Create first scene structure
SCENE_PATH="$BASE_PATH/scene-01"
mkdir -p "$SCENE_PATH/page"

# Create scene plan template
cat > "$SCENE_PATH/PLAN.md" << EOF
# Scene Plan: scene-01

## Summary
[Scene-level summary - 1-2 paragraphs, specific and concrete]

## Key Elements
- [Specific action or dialogue beat]
- [Sensory detail to include]
- [Emotional shift]

## Characters Present
- [Character]: [What they want, what they do]

## Timeline
- Duration: [Minutes/hours within the scene]
- Follows: [What just happened]

## Setting
- Location: [Specific place]
- Time of day:
- Sensory details: [What we see, hear, smell, feel]

## Connections
- Chapter goal served: [Which chapter goal this scene advances]
- Follows scene: [Previous scene reference or "opening"]
- Leads to: [Next scene setup]

## Page Breakdown
Approximate page targets:

- Page 001-002: [Opening/setup]
- Page 003-005: [Development]
- Page 006-008: [Climax/turn]
- Page 009-010: [Resolution/transition]

## Stylistic Notes
- Pacing: [Fast/slow/variable]
- Knausgaard/Carson balance: [Guidance for prose style]
- Key images/metaphors: [Recurring motifs to use]
EOF

# Create first page template
cat > "$SCENE_PATH/page/001.md" << EOF
[Page content goes here. Pure prose, no headers. ~250-300 words.]

[Follow the scene PLAN.md. Maintain the Knausgaard/Carson blend specified.]

[End at a natural pause point.]
EOF

echo "Created:"
echo "  $BASE_PATH/PLAN.md"
echo "  $SCENE_PATH/PLAN.md"
echo "  $SCENE_PATH/page/001.md"
echo ""
echo "To add more scenes, create scene-02/, scene-03/, etc. with similar structure."
