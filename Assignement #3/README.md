# Assignment 3 — Agent crew for **Dark Touch**

**Game:** *Dark Touch*, a dark-fantasy roguelike built in Unreal Engine 5.8 for the ELVTR capstone. A one-armed half-dragonkin has a spectral magic arm. He raises the enemies he kills into an army, then fights with aimed, WoW-style casting (cast bar, GCD, pushback).

**What the crew produces:** a playable UE 5.8 project, built one week at a time from the GDD. The crew writes C++ gameplay systems, each with an automation test. It also delivers UI mockups and widgets, animation candidates retargeted to the UE5 Mannequin, the production plan, and one review inbox that holds every question for the designer. No agent is allowed to hand over work that does not build, run and pass its tests.

## The crew

The orchestrator is **Claude Code**. The agents are Claude Code subagents: one markdown file per agent, giving its role, its model and its rules. Hooks and scripts enforce the rules around them. The crew does not use CrewAI.

| Agent | Model | Role | Status |
| --- | --- | --- | --- |
| Main session | (session model) | Orchestrator: reads `plan.md`, picks the next task, delegates to subagents | active |
| Producer | Sonnet | Turns the GDD into a 7-week plan: demo cut, weekly milestones, decide-by dates | active, wrote `plan.md` |
| Gameplay Programmer | Opus | All gameplay in C++, with an automation test for every rule that has a number | active |
| UI Designer | inherit | 4 mockups per screen with different design intents, then the UMG widget | active |
| Animation Scraper | Sonnet | Finds animations, gets them validated, retargets them to Manny | active |
| Technical Director | Opus | Checks that the systems fit together and run well | active |
| Game Director | Opus | Reviews work against the GDD | defined, used little so far |
| Review Desk | Sonnet | Collects every question, mockup and validation request into one inbox. Records the designer's answers and routes them | active |
| Machine Coordinator | Haiku | At session start: detects the machine (PC, laptop or phone) and pulls from git. At hand-over: commits and pushes | active since 2026-10-30 |
| AI Director, Level Designer, Game Feel Director, Balance Analyst, Sound Designer, Music Director, Environment Scraper | various | Planned for weeks 2–7 in `plan.md` | defined, not run yet |

That makes 15 agent definitions in total. Eight of them have run on real work, from the orchestrator to the Machine Coordinator. The other seven are written and scheduled.

## How they coordinate (data flow)

See `crew-diagram.mmd` (Mermaid source) and `crew-diagram.png`.

1. **Shared memory.** Every agent reads the same files first:
   - `canon.md`: every validated rule and number;
   - `CLAUDE.md`: how to build (C++ first, the verify loop, the 3-tries rule, git safety);
   - `plan.md`: what to build this week.
2. **Plan → build.** The main session takes the current milestone and delegates it to the builders: Gameplay Programmer, UI Designer, Animation Scraper.
3. **Safety net, so the crew does not crash.** Each time an agent stops, `.claude/hooks/verify.ps1` runs. It does three things:
   - builds any changed C++;
   - reads new crash reports;
   - scans the editor log for new errors.

   On a failure, the agent is sent back to fix it. After 3 failed tries on the same error, it stops and writes the exact error and its best guess to the designer, instead of looping. `test-verify.ps1` checks the gate itself: 11 out of 11 checks pass.
4. **Unreal access.** Agents act on the editor through Epic's MCP plugin (`unreal-mcp`): compiling Blueprints, running PIE and reading the log. They also run the scripts in `.claude/scripts` (`build`, `launch-editor`, `run-tests`).
5. **One human channel.** Every question, choice or "please test this" goes to the Review Desk, which writes it into `review/inbox.js`, shown by `review/index.html`. The designer answers everything on that one page. The Review Desk then records the answer in `review/decisions.md` and routes it to the right agent. Settled facts move into `canon.md`.
6. **Several machines.** A SessionStart hook works out which machine is in use, syncs it from git and warns about uncommitted or diverged work. On the phone (a cloud session, where Unreal cannot run), the agents are told never to claim that their C++ compiles.

## Where the crew code is

The files are copied in `crew-code/` in this folder; in the game repository they live at the paths below.

| File | What it is |
| --- | --- |
| `.claude/agents/*.md` | The agent definitions: role, model, rules |
| `review/review-desk.agent.md` | The Review Desk agent |
| `CLAUDE.md` | Rules shared by every agent |
| `.claude/settings.json` | Hooks: SessionStart (coordinator), Stop / SubagentStop (verify gate) |
| `.claude/hooks/verify.ps1`, `test-verify.ps1` | The gate and its self-test |
| `.claude/hooks/coordinator.sh` | Machine detection and git sync |
| `.claude/scripts/*.ps1` | Build, close or launch the editor, run tests |
| `.mcp.json` | Connection to the Unreal MCP server |
