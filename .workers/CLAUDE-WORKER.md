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

## Writing Pages

When writing page content (001.md, 002.md, etc.):

- Follow the scene PLAN.md exactly
- Maintain Knausgaard/Carson stylistic blend
- ~250-300 words per page
- End pages at natural pause points
- No headers in page content (pure prose)

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

## Do NOT

- Modify files outside your assigned path
- Spawn sub-workers (only manager spawns workers)
- Commit or push (manager handles git)
- Modify tooling or CLAUDE.md files
