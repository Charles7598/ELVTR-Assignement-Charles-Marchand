# Dark Touch — project rules

Every agent working in this repository (main session and subagents) follows these rules.
The game designer has the final word.

## Where things are
- `Agentic Documentation/canon.md`: read it first, the source of truth for every rule
  and number. `open-questions.md` next to it lists what is not decided yet (never
  invent an answer); `art-direction.md` the visual rules; the full GDD is `GDD-full.md`.
- `UE5 Project/`: the Unreal project (`DarkTouch.uproject`). Every code and content path
  below (`Source/`, `Plugins/`, `/Game/`) is inside it.
- `.claude/agents/`: the agents (13 + the Review Desk). `.claude/scripts/`: build, editor and test scripts.
  Claude Code runs from this repository root.

## Talking to the designer: one inbox
- Everything that needs the designer (a question, a choice, mockups, a proposal, a
  feature to test, a request for feedback) goes into the review inbox through the
  `review-desk` agent: review/inbox.js, shown by review/index.html. Never leave a
  question only in the chat or only inside a mockup page.
- When the designer pastes a block starting with "RÉPONSES REVIEW", hand it to the
  review-desk agent first; it records the answers and says which agent does what next.
- End every step with the inbox count: "Inbox : N en attente — ouvre review/index.html".

## How we build: whole first, then polish
- A feature is added complete in a first version, on every layer at once: C++ and tests,
  UI, feel and VFX, animation (or a placeholder pose), audio, and its place in the level.
  The designer must always be able to play the whole game as it stands.
- First versions use 1 asset candidate; the 3-candidate choices and quality passes come
  with polish. Never polish one layer of a feature while another layer is still missing.

## How the game is built: C++ first
- **All gameplay code is C++, written by the agents.** The designer does not build
  anything by hand. Blueprints are thin subclasses that only assign assets (meshes,
  animations, sounds, effects, UI layout); no game rule lives in a Blueprint graph.
- Every number lives in a data table or data asset, never in code.
- Expose to the editor what the designer may want to tweak: `UPROPERTY(EditAnywhere)`
  for values, `BlueprintAssignable` delegates for events. Say in your hand-over which
  variables he can change.
- Generic, reusable systems: the plugin `Plugins/GameSystems/` (one runtime module per
  system, e.g. `Casting`, `Army`, `StatGrades`, `Encounters`), each with a README.md.
  The plugin never includes or references the game module.
- Dark Touch-specific code: the game module `Source/DarkTouch/`. Content: `/Game/DarkTouch/`.
- Unreal-style C++: UE naming (A, U, F, I, E prefixes), `UCLASS`/`UPROPERTY`/`UFUNCTION`,
  `TObjectPtr` and `UPROPERTY` on every UObject pointer, no raw new/delete, check every
  pointer before use. A null pointer crashes the editor.
- Each rule with a number gets an automation test (path `GameSystems.<System>.<Rule>`
  or `DarkTouch.<Feature>.<Rule>`), e.g. "a hit pushes the cast back 1.5 s".

## Tools
- **Unreal MCP** (`unreal-mcp` in `/mcp`): Epic's ModelContextProtocol plugin (UE 5.8). Works
  only while the editor is open. Use it to create Blueprint subclasses and data assets,
  set properties, compile and save Blueprints (`compile_blueprint`, then
  `AssetTools.save_assets`), read the log (`LogsToolset.GetLogEntries`), start and stop
  PIE (`EditorAppToolset.StartPIE`). If a tool name differs, list the server's tools.
- **Scripts** (run with `powershell -NoProfile -ExecutionPolicy Bypass -File <script>`):

| Script | Does |
| --- | --- |
| `.claude\scripts\build.ps1` | Builds the C++ (editor closed). Prints errors, then warnings in project files |
| `.claude\scripts\close-editor.ps1` | Closes the editor normally. Save everything first |
| `.claude\scripts\launch-editor.ps1` | Builds if needed, opens the editor, waits for the MCP. Reports a crash on load |
| `.claude\scripts\run-tests.ps1 [-Filter X]` | Runs the automation tests headless, even with the editor open |

## The verify loop: nothing is handed over until it builds, runs and passes
The designer must never be the first to see an error. After every change:

1. **C++ changed** →
   - Save everything through the MCP, then `close-editor.ps1`.
   - `build.ps1`. Fix every error, and every warning in a file you touched. Rebuild
     until clean.
   - `launch-editor.ps1`. If the editor crashes on load, it prints the crash: fix it.
   - Small edit inside a `.cpp` function body only, editor open: Live Coding is allowed
     instead (console command `LiveCoding.Compile`, if the MCP can run console
     commands). Then check the log for `Live coding succeeded`. Any change to a header,
     a `UPROPERTY`/`UFUNCTION`, a new class or a `Build.cs` always takes the full loop.
2. **Tests** → `run-tests.ps1 -Filter GameSystems.<System>` (or `DarkTouch.<Feature>`)
   for what you changed. All must pass. Before a hand-over, run the whole suite.
3. **Blueprint subclass or data asset changed** → compile and save it through the MCP.
4. **Gameplay changed** → PIE smoke test: start PIE, let it run about 10 seconds (or
   play the scenario through the MCP), stop PIE.
5. **Read the log** → `LogsToolset.GetLogEntries`, pattern
   `Error|Warning|Accessed None|Ensure|Assertion`, since your change. Fix every error,
   and every warning you caused.

## When something fails
- Read the full error, find the cause, fix it, then run the same check again.
- **Never hide an error to make it pass**: do not delete the failing code or test,
  comment it out, skip it with an early return or an IsValid that silently drops the
  feature, disable a plugin or lower a log verbosity. Fixing the symptom is not fixing
  the bug.
- **3 tries maximum** on the same error. Then stop and write to the designer: the exact
  error, the file and line (or asset), what you tried, and your best guess of the
  cause. This is the only case where the designer sees an error first.
- **The gate:** a check runs automatically when you finish (`.claude\hooks\verify.ps1`).
  It builds changed C++, looks for new crash reports and reads new errors in the editor
  log. If it sends you back, it is a real problem: fix it and finish again.

## Machines: pc-fixe, pc-portable, telephone
- The designer works on three machines; git is the only link. At every session start the
  coordinator hook (`.claude/hooks/coordinator.sh`) says which machine this is, pulls the
  other machine's work and lists what this machine can do. Read its report first and
  follow it (unknown machine: ask; C++ pulled: build before using the editor).
- When the report asks for it, or when the designer says he switches machine or leaves,
  hand over to the `machine-coordinator` agent: it commits and pushes.
- Every commit message ends with the trailer `Machine: <pc-fixe|pc-portable|telephone>`.
- On telephone (cloud session) there is no Unreal and no build: never claim C++ compiles
  there; mark it "not compiled yet".

## Safety
- Commit to git before any large change (new system, refactor, mass rename, asset
  reorganisation), so a broken state can be rolled back. Small commits, clear messages.
- Never kill the editor: close it with `close-editor.ps1`. Never save during PIE.
- Never mass-move or rename assets, or delete files, without the designer's go.
- After the editor restarts, the MCP session may be stale. If MCP tools fail, ask the
  designer to reconnect it with `/mcp`.
