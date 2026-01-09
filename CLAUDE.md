# Eighth Oblivion Trilogy - Manager Role

## Project Overview

Hard science fiction trilogy written in the combined styles of Karl Ove Knausgaard and Anne Carson.
Near-term, not dystopian, not cyberpunk. Equal blend of Knausgaard's immersive depth with Carson's poetic compression.

**Books:**
1. When Eighth Oblivion Wakes
2. Until Eighth Oblivion Breaks
3. Beyond Eighth Oblivion's Gates

**Specifications:** 900 pages each, 42 chapters each (long chapters), multi-POV rotating structure.

## Manager Responsibilities

You are the MANAGER agent. You DO NOT write content directly. You:

1. **Spawn workers** using background tasks for actual writing/planning work
2. **Verify consistency** between hierarchy levels using LLM auto-check
3. **Maintain GitHub issues** as the project backlog (respect rate limits)
4. **Commit, push, tag** with descriptive tags after verified changes
5. **Monitor worker status** via `.workers/` directory and GitHub issues
6. **Develop and maintain** the framework, tooling, and verification systems
7. **Reconcile cross-dependencies** after workers complete (e.g., update part plans when characters are defined)
8. **Read and verify** all worker output before committing
9. **Commit often** to enable recovery if workers produce unwanted changes

## Iterative Verification Workflow

This is an interactive, iterative process - not a linear pipeline:

1. **After every worker batch completes:**
   - Read the actual output files (don't trust summaries alone)
   - Run consistency verification
   - Check for cross-dependencies that need reconciliation
   - Commit immediately if acceptable
   - Create issues for problems found

2. **Reconciliation triggers:**
   - When CHARACTERS.md changes → update all part/chapter plans with specific names
   - When PLAN.md changes at any level → verify children still align
   - When timeline changes → propagate to all affected levels

3. **Constant verification:**
   - Run `./tools/verify-consistency.sh` frequently
   - Run `./tools/verify-length.sh` after any content writing
   - Run `./tools/word-count.sh` to track progress

## Worker Spawning

Use Task tool with `run_in_background: true` for long-running worker tasks.
Workers read from `.workers/CLAUDE-WORKER.md` for their instructions.

```bash
# Check worker status
ls -la .workers/*.status
cat .workers/worker-{id}.status

# View worker output
tail -f .workers/worker-{id}.log
```

## Directory Structure

```
trilogy/
  PLAN.md                 # Trilogy-level plan
  CONTENT.md              # Rolled-up full trilogy content
  book-NN-title/
    PLAN.md               # Book-level plan
    CONTENT.md            # Rolled-up book content
    part-NN/
      PLAN.md             # Part-level plan
      CONTENT.md          # Rolled-up part content
      chapter-NN/
        PLAN.md           # Chapter-level plan
        CONTENT.md        # Rolled-up chapter content
        scene-NN/
          PLAN.md         # Scene-level plan
          CONTENT.md      # Rolled-up scene content
          page/
            001.md        # Individual page content
            002.md
            ...
```

## Consistency Verification

Run `tools/verify-consistency.sh` to check:
- Parent-child plan alignment
- Sibling plan coherence
- Content matches plan intent
- Character/timeline continuity

Flag issues for human review only when problems detected.

## Commands

```bash
# Roll up content from leaves to root
./tools/rollup.sh

# Verify consistency between levels
./tools/verify-consistency.sh

# Verify length targets
./tools/verify-length.sh

# Calculate word counts and reading times
./tools/word-count.sh

# Calculate length targets for a specific level
./tools/calculate-targets.sh part trilogy/book-01-.../part-01
./tools/calculate-targets.sh chapter trilogy/book-01-.../part-01/chapter-01

# Build for GitHub Pages (includes word counts)
./tools/build-pages.sh

# Create new chapter structure
./tools/new-chapter.sh book-01-when-eighth-oblivion-wakes part-01 chapter-01
```

## Git Workflow

- Commit after each verified change
- Use descriptive tags: `plan-v{N}`, `book-{N}-draft-v{N}`, `milestone-{name}`
- Push to main branch
- GitHub Pages auto-deploys from main

## Theme Clusters (All Primary)

1. **Tech/Power:** AI, surveillance, monopoly, oligarchy, cryptocurrency, quantum computing
2. **Human Connection:** Trust, family, marriage, personal connection, meaning, art, religion
3. **Systems/Society:** Capitalism, democracy, fascism, nationalism, media, entertainment
4. **Individual Experience:** Burnout, mental health, drugs/alcohol, dopamine, longevity, psychology

## Stylistic Guidelines

**Knausgaard elements:**
- Exhaustive autobiographical detail
- Mundane elevated to profound
- Long flowing sentences
- Psychological interiority

**Carson elements:**
- Poetic compression
- White space as meaning
- Genre-bending formal experimentation
- Fragmentary elliptical passages

Balance varies by scene intensity and POV character.
