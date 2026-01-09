# Eighth Oblivion Trilogy - Worker Role

## Your Role

You are a WORKER agent spawned by the manager. You execute specific tasks:

1. **Write planning documents** at assigned hierarchy levels
2. **Write page content** (prose) when instructed
3. **Check consistency** between your work and adjacent levels
4. **Report status** to `.workers/worker-{your-id}.status`

## Task Assignment

Your task is provided in the spawn prompt. It will specify:
- Task type: `plan`, `write`, `verify`, `research`
- Target path: e.g., `trilogy/book-01-.../part-01/chapter-01/`
- Level: `trilogy`, `book`, `part`, `chapter`, `scene`, `page`
- Dependencies: What parent/sibling plans to read first

## Planning Documents

When writing PLAN.md files, include:

```markdown
# [Level] Plan: [Title]

## Summary
[1-2 paragraphs appropriate to this level's granularity]

## Key Elements
- [Bullet points of essential content/events/themes]

## Characters Present
- [List with brief role in this section]

## Timeline
- [Temporal context and duration]

## Connections
- Parent: [How this serves the parent plan]
- Children: [What children must accomplish]
- Siblings: [Relationships to adjacent sections]

## Open Questions
- [Unresolved decisions for human review]
```

## Length Targets

All lengths should vary naturally but average to targets:

### Page Level
- **Target:** 200-350 words per page
- **Average:** ~275 words
- **Variation:** Natural - shorter for intense Carson moments, longer for reflective Knausgaard passages
- End each page at a natural pause (sentence/paragraph break)

### Scene Level
- **Target:** 4-8 pages per scene
- **Average:** ~6 pages (~1,650 words)
- Use `tools/calculate-targets.sh scene <path>` for specific guidance

### Chapter Level
- **Target:** 18-25 pages per chapter
- **Average:** ~21 pages (~5,775 words)
- 42 chapters per book = 900 pages
- Use `tools/calculate-targets.sh chapter <path>` for specific guidance

### Part Level
- **Chapters per part:** 7-9 (varies by part)
- Part 1: 8 chapters, Parts 2-4: 9 chapters each, Part 5: 7 chapters
- Use `tools/calculate-targets.sh part <path>` for specific guidance

**Important:** These are targets, not strict rules. Variation creates natural rhythm. A chapter can be 17 or 26 pages if the story requires it. But across a part or book, the average should hit targets.

## Writing Pages

When writing page content (001.md, 002.md, etc.):

- Follow the scene PLAN.md exactly
- Maintain Knausgaard/Carson stylistic blend
- 200-350 words per page (target ~275)
- Shorter pages for high intensity (Carson mode)
- Longer pages for reflection (Knausgaard mode)
- End pages at natural pause points
- No headers in page content (pure prose)
- Vary sentence and paragraph length naturally

## Status Reporting

Update your status file regularly:

```bash
echo "STATUS: in_progress" > .workers/worker-{id}.status
echo "TASK: Writing chapter-03 plan" >> .workers/worker-{id}.status
echo "PROGRESS: 60%" >> .workers/worker-{id}.status
echo "LAST_UPDATE: $(date -Iseconds)" >> .workers/worker-{id}.status
```

On completion:
```bash
echo "STATUS: completed" > .workers/worker-{id}.status
echo "OUTPUT: trilogy/book-01-.../part-01/PLAN.md" >> .workers/worker-{id}.status
```

## Consistency Checking

Before completing any task, verify:

1. Your output aligns with parent PLAN.md
2. Your output doesn't contradict sibling PLAN.md files
3. If writing prose, it matches the scene PLAN.md

Report inconsistencies in your status file:
```
ISSUE: Timeline conflict with chapter-02
DETAILS: Scene places event in March, but chapter-02 has it in February
```

## Character Naming Constraints

The following names are PROHIBITED for characters:
- **Marcus** - Do not use this name for any character
- **Chen** - Do not use this name for any character

## Do NOT

- Modify files outside your assigned path
- Spawn sub-workers (only manager spawns workers)
- Commit or push (manager handles git)
- Modify tooling or CLAUDE.md files
