# Claude Code Boilerplate

By [Songbird Digital](https://github.com/songbirddigital)

A production-ready boilerplate for Claude Code projects featuring domain memory, guardian agents, self-annealing, and context engineering best practices.

Built on principles from Anthropic's research on [Building Effective Agents](https://www.anthropic.com/engineering/building-effective-agents), [Context Engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents), and [Effective Harnesses](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents).

## Design Principles

This boilerplate implements Anthropic's key insights for production AI agents:

### 1. Context Engineering Over Prompt Engineering

> "As models become more capable, the challenge isn't just crafting the perfect prompt—it's thoughtfully curating what information enters the model's limited attention budget at each step."
> — [Anthropic: Context Engineering for AI Agents](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)

**Implementation:**
- **Domain Memory** (`.claude/memory/`) provides persistent state across sessions
- **Session Protocol** loads only relevant context from features.json and progress.log
- **Structured Decision Records** (ADRs) maintain architectural context
- **Agent Protocols** clearly define when and how to invoke specialized agents

### 2. Workflows First, Agents When Needed

> "Start with simple prompts and deterministic workflows, and only add agentic behavior where it's truly valuable."
> — [Anthropic: Building Effective Agents](https://www.anthropic.com/engineering/building-effective-agents)

**Implementation:**
- **IMPLEMENTER** follows a structured workflow: Orient → Plan → Implement → Verify → Update Memory
- **PLANNER** provides guided feature planning with clear deliverables
- **REVIEWER** orchestrates parallel guardians in a deterministic flow
- **Guardians** provide fast, parallel reviews without unnecessary autonomy

### 3. Effective Harnesses for Long-Running Work

> "The magic is in the memory. The magic is in the harness. The magic is not in the personality layer."
> — [Anthropic: Effective Harnesses for Long-Running Agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)

**Implementation:**
- **features.json** tracks project state across sessions (the "harness")
- **progress.log** provides append-only history for context continuity
- **Lifecycle phases** (inception → planning → implementation → testing → review → merged)
- **Handoff context** ensures seamless session transitions

### 4. Self-Improvement with Human Oversight

**Implementation:**
- **Instance-specific feedback** tracked in `.ai/feedback/`
- **Weekly annealing** reviews patterns and proposes improvements
- **Human approval gates** for all changes (never auto-apply)
- **Rollback capability** for any applied improvements

---

## Features

### 🧠 Domain Memory System
- **features.json** — Machine-readable backlog with lifecycle tracking
- **progress.log** — Append-only session history with handoff context
- **decisions.md** — Architectural Decision Records (ADRs)
- **issues.md** — Problem tracking with resolutions
- **Session continuity** across context windows and time

### 🛡️ 9 Guardian Agents
Specialized reviewers that run in parallel during code review:
- **Security** — OWASP top 10, secrets exposure, injection attacks, tenant isolation
- **TypeScript** — Type safety, strict mode compliance, elimination of `any`
- **Architecture** — Design patterns, modularity, SOLID principles, dependency management
- **API** — REST conventions, versioning, error handling, consistent design
- **Database** — Schema optimization, migration safety, query performance
- **Test** — Coverage analysis, test quality, edge case handling
- **Performance** — N+1 queries, bundle size, algorithmic complexity, memory leaks
- **Accessibility** — WCAG compliance, ARIA usage, keyboard navigation
- **Documentation** — Currency, organization, completeness

### 🎯 Agent Protocols
- **INITIALIZER** — Bootstrap new projects with interactive feature planning
- **PLANNER** — Deep feature planning with architectural considerations
- **IMPLEMENTER** — Structured implementation workflow (default)
- **REVIEWER** — Pre-merge review orchestration with guardian synthesis

### 🔄 Self-Annealing System
Continuous improvement based on actual usage:
- **Feedback tracking** by category (guardians, skills, process, directives, memory)
- **Weekly review cycle** analyzes patterns and proposes improvements
- **Human approval** required for all changes
- **Per-instance learning** with cross-project pattern detection
- **Rollback capability** for any applied changes

### 🎓 Apprentice Mode
Educational assistance that explains the "why" not just the "what":
- Analogies and real-world examples
- Industry context and historical perspective
- Jargon definitions
- Trade-off analysis

### 🔍 Research-First Approach
**CRITICAL:** Always search before recommending:
- "best [month year] [topic]" pattern for current best practices
- GitHub pattern searches for battle-tested solutions
- Technology comparison with current data
- Breaking change detection
- Source citations with dates

### ⚡ External Review Integration
Optional async review from alternative perspectives:
- **Codex** integration (~15 min review cycle)
- **Gemini** secondary reviewer support
- Task-based review workflow in `.ai/tasks/review/`

### 🎨 Feature Completion Workflow
Structured process from inception to merge:
1. Inception → 2. Planning → 3. Implementation → 4. Testing → 5. Review → 6. Merged
- Lifecycle tracking in features.json
- Guardian gates before merge
- Memory updates at each phase

---

## Key Things to Watch & Improve

### 🔴 High Priority

**1. Memory File Growth**
- Monitor `.claude/memory/features.json` size
- Archive completed features after 50+ entries
- Rotate progress.log quarterly for large projects

**2. Guardian Accuracy**
- Track false positives in `.ai/feedback/guardians/`
- Review guardian findings during weekly annealing
- Adjust guardian prompts based on feedback

**3. Session Startup Time**
- If session start slows, features.json may be too large
- Consider feature archiving or pagination
- Monitor progress.log tail reads

**4. Context Window Utilization**
- Watch for repeated context loading
- Optimize what goes in memory files
- Use memory feedback to track orientation effectiveness

### 🟡 Medium Priority

**5. External Review Quality**
- Compare Codex/Gemini findings to guardian findings
- Track unique issues found by external reviewers
- Adjust review task templates based on results

**6. Search Pattern Effectiveness**
- Log when searches reveal outdated recommendations
- Track technology suggestions by recency
- Update `.ai/context/current-world-state.md` weekly

**7. Agent Invocation Patterns**
- Track when PLANNER vs IMPLEMENTER is invoked
- Monitor if REVIEWER synthesis is effective
- Adjust agent trigger conditions based on usage

### 🟢 Low Priority

**8. Skill Trigger Accuracy**
- Monitor skill invocation patterns in `.ai/feedback/skills/`
- Adjust skill descriptions for clarity
- Add new skills when patterns emerge

**9. Documentation Drift**
- Keep CLAUDE.md under 200 lines
- Verify README examples still work
- Update version numbers in docs

**10. Boilerplate Sync**
- Check for upstream improvements monthly
- Test `boilerplate-sync` on fresh instances
- Document migration path for breaking changes

## Quick Start

```bash
# Copy to new project
cp -r claude-code-boilerplate/ my-project/
cd my-project/

# Initialize
git init
claude
/setup
```

See [SETUP.md](./SETUP.md) for detailed instructions.

## Structure

```
.claude/                    # Configuration
├── memory/                 # Domain memory (persistent state)
│   ├── features.json       # Machine-readable backlog
│   ├── progress.log        # Session history + handoff
│   ├── decisions.md        # Architectural Decision Records
│   └── issues.md           # Problem tracking
├── agents/                 # Agent protocols
│   ├── INITIALIZER.md      # Bootstrap domain memory
│   ├── PLANNER.md          # Feature planning
│   ├── IMPLEMENTER.md      # Worker protocol
│   ├── REVIEWER.md         # Pre-merge review orchestration
│   └── domains/            # Domain-specific agents
│       ├── security/       # Guardian + Specialist
│       ├── database/       # Guardian + Specialist
│       └── ...             # 9 domains total
├── skills/                 # Workflow orchestration
├── commands/               # Custom slash commands
├── templates/              # Feature spec templates
└── settings.json           # Hooks and guardian config

.ai/                        # Operations
├── feedback/               # Self-annealing observations
│   ├── guardians/
│   ├── skills/
│   ├── memory/             # Domain memory feedback
│   └── ...
├── annealing/              # Weekly review history
├── sessions/               # Session logs
├── context/                # World state
└── tasks/                  # Work assignments

CLAUDE.md                   # Entry point (~170 lines)
AGENTS.md                   # Codex reviewer touchpoint
GEMINI.md                   # Gemini reviewer touchpoint
SETUP.md                    # Setup instructions
```

## Guardian Agents

| Guardian | Model | Focus |
|----------|-------|-------|
| security | sonnet | OWASP, secrets, injection, tenant isolation |
| typescript | haiku | Types, strict mode, no `any` |
| architecture | sonnet | Patterns, modularity, SOLID |
| test | haiku | Coverage, quality, edge cases |
| performance | sonnet | N+1, complexity, memory |
| docs | haiku | Documentation currency |
| accessibility | sonnet | A11y, WCAG, ARIA |
| api | sonnet | REST conventions, versioning |
| database | sonnet | Schema, migrations, queries |

## Skills

| Skill | Description |
|-------|-------------|
| guardian-agents | Orchestrate parallel code review |
| feature-completion | Feature branch → merge workflow |
| full-codebase-review | Develop → main comprehensive review |
| weekly-annealing | Self-improvement cycle |
| apprentice-mode | Detailed teaching mode |
| guardian-builder | Create new guardians with TDD |
| boilerplate-sync | Sync improvements between instances |
| boilerplate-migrate | Add boilerplate to existing projects |

## Commands

| Command | Description |
|---------|-------------|
| /setup | Initialize new project with domain memory |
| /migrate | Add boilerplate to existing project |
| /status | Show current project status |
| /plan | Invoke PLANNER for feature planning |
| /review | Trigger guardian review + external reviewers |
| /complete-feature | Feature completion checklist |
| /feedback | Quick feedback capture |

## Self-Annealing

The boilerplate improves itself:

1. **Observe** — Track guardian accuracy, skill triggers, process friction
2. **Log** — Save to `.ai/feedback/`
3. **Analyze** — Weekly review identifies patterns
4. **Propose** — Suggest improvements with evidence
5. **Approve** — Human approves all changes (never auto-apply)
6. **Apply** — Changes applied with rollback capability

## Customization

### Add/Remove Guardians

Edit `.claude/settings.json`:
```json
"guardians": {
  "enabled": ["security", "typescript", "test"]
}
```

### Adjust Triggers

```json
"triggers": {
  "pre-commit": true,
  "pr-creation": false,
  "manual": true
}
```

### Create Custom Guardian

Use the `guardian-builder` skill with TDD:
1. Create test fixtures in `.ai/fixtures/[name]/`
2. Build guardian to detect issues
3. Test until 100% accuracy

## Research & Citations

This boilerplate is built on research and best practices from Anthropic and the broader AI agent community.

### Anthropic Research (2025)

**Core Agent Design:**
- [Building Effective AI Agents](https://www.anthropic.com/engineering/building-effective-agents) — Workflows vs agents, when to use which, composable patterns
- [Effective Context Engineering for AI Agents](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents) — Sep 2025: Context curation over prompt engineering
- [Effective Harnesses for Long-Running Agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents) — Nov 2025: Memory systems and session continuity

**Implementation Guides:**
- [Writing Tools for Agents](https://www.anthropic.com/engineering/writing-tools-for-agents) — Tool design and optimization
- [Building Agents with the Claude Agent SDK](https://www.anthropic.com/engineering/building-agents-with-the-claude-agent-sdk) — Sep 2025: SDK patterns and best practices
- [Code Execution with MCP](https://www.anthropic.com/engineering/code-execution-with-mcp) — Model Context Protocol integration

**API & Capabilities:**
- [New Agent Capabilities API](https://www.anthropic.com/news/agent-capabilities-api) — May 2025: Code execution, MCP connector, Files API, extended caching
- [Claude 4 Prompt Engineering Best Practices](https://docs.claude.com/en/docs/build-with-claude/prompt-engineering/claude-4-best-practices) — Latest prompting techniques

### Key Takeaways Applied

**From "Building Effective Agents" (Dec 2024):**
> "Augment LLMs with retrieval, tools, and memory. Start with simple prompts and deterministic workflows, and only add agentic behavior where it's truly valuable."

**From "Context Engineering" (Sep 2025):**
> "Modern agent quality depends on curating the entire context stack, not just clever prompt text. If you're still treating 'the prompt' as a single text block, you're missing 70% of what makes agents reliable."

**From "Effective Harnesses" (Nov 2025):**
> "The magic is in the memory. The magic is in the harness. The magic is not in the personality layer."

### Community Research

- **Agentic AI Foundation** — [Dec 2025: MCP donation](http://blog.modelcontextprotocol.io/posts/2025-12-09-mcp-joins-agentic-ai-foundation/) standardizing agent protocols
- **6 Composable Agent Patterns** — [Routing, Parallelization, Orchestrator-Workers, Evaluator-Optimizer](https://research.aimultiple.com/building-ai-agents/)
- **Context Engineering Guide 2025** — [Shift from prompt to context engineering](https://promptbuilder.cc/blog/context-engineering-agents-guide-2025/)

### Project Documentation

- [Design Document: Domain Memory Integration](./docs/plans/2025-12-09-domain-memory-integration-design.md)
- [Original Boilerplate Design](./docs/plans/2025-12-03-claude-code-boilerplate-design.md)
- [Setup Guide](./SETUP.md)
- [Testing Guide](./TESTING.md)
- [Changelog](./CHANGELOG.md)

## Future Enhancements

Tracked for future implementation:

- [ ] SPO (Self-Prompt Optimization) for guardians
- [ ] Promptbreeder-style prompt evolution
- [ ] DSPy integration for automated optimization
- [ ] Automatic trust escalation
- [ ] Cross-project learning

---

## License

GNU General Public License v3.0 - see [LICENSE](./LICENSE)

---

Created by [Songbird Digital](https://github.com/songbirddigital)

Built with research from [VoltAgent](https://github.com/VoltAgent/awesome-claude-code-subagents), [wshobson/agents](https://github.com/wshobson/agents), [claude-flow](https://github.com/ruvnet/claude-flow), [obra/superpowers](https://github.com/obra/superpowers), and contractor-system patterns.
