# AGENTS.md

**Version:** 1.0
**Date:** 2026-03-15
**Purpose:** Technical reference for Usurper development (methodology in .clio/instructions.md)

---

## Project Overview

**Usurper** is a classic BBS door game - a multi-player fantasy role-playing game originally written in Borland Pascal 7.0 and ported to Free Pascal (FPC). The game runs as a "door" from BBS software, delivering a fast-paced fantasy RPG over serial/telnet connections.

- **Language:** Free Pascal (FPC) 3.2.x - Turbo Pascal (TP) compatibility mode (`-Mtp`)
- **IDE:** Lazarus 2.0.12
- **Architecture:** Two executables - `USURPER.EXE` (game engine) and `EDITOR.EXE` (game editor/configurator)
- **Platforms:** DOS (i386/go32v2), Linux (i386 and x86_64), Windows (i386/win32, x86_64/win64)
- **Build System:** PowerShell script (`build.ps1`) wrapping `fpc.exe`
- **CI/CD:** GitHub Actions (Windows runner, automatic pre-release and tagged release)
- **License:** GPL v2+

---

## Quick Setup

```bash
# Prerequisites: FPC 3.2.x installed via fpcupdeluxe (Windows path: C:\fpcupdeluxe)
# The build script will auto-download fpcupdeluxe if not present

# Build all targets (5 platform combinations)
.\build.ps1

# Build with debug symbols
.\build.ps1 -Debug

# Build output lands in:
# bin\i386-go32v2\     - DOS 32-bit
# bin\i386-linux\      - Linux 32-bit
# bin\i386-win32\      - Windows 32-bit
# bin\x86_64-linux\    - Linux 64-bit
# bin\x86_64-win64\    - Windows 64-bit

# Create release ZIP (done automatically by build.ps1):
# usurper-<cpu>-<os>.zip  (includes RELEASE/ directory + compiled EXEs)
```

**Build targets:** `i386-go32v2`, `i386-linux`, `i386-win32`, `x86_64-linux`, `x86_64-win64`

---

## Architecture

```
USURPER.EXE  (game engine)
    |
    +-- SOURCE/USURPER/USURPER.PAS       (main program)
    +-- SOURCE/USURPER/INIT.PAS          (data structures, type definitions)
    +-- SOURCE/USURPER/FILE_IO.PAS       (file I/O, record locking, data access)
    +-- SOURCE/USURPER/VARIOUS*.PAS      (general game mechanics, 3 files)
    +-- SOURCE/USURPER/ONLINE.PAS        (online/multi-player coordination)
    +-- SOURCE/USURPER/MAIL.PAS          (in-game mail system)
    +-- SOURCE/USURPER/CHILDREN.PAS      (player relationships, children)
    +-- SOURCE/USURPER/GYM.PAS           (training, stats)
    +-- SOURCE/USURPER/CASTLE.PAS        (castle/kingdom mechanics)
    +-- SOURCE/USURPER/ANSICOLR.PAS      (ANSI color codes)
    +-- SOURCE/USURPER/DDPLUS.PAS        (DDPlus BBS I/O library)
    +-- SOURCE/USURPER/ASYNC2.PAS        (async serial comm)
    +-- SOURCE/USURPER/RATING.PAS        (player/hall of fame ratings)
    +-- SOURCE/USURPER/RELATION.PAS      (NPC relationships)
    +-- SOURCE/USURPER/*.PAS             (80+ game feature units)
    |
    +-- SOURCE/COMMON/RPPORT.PAS         (cross-platform portability layer)
    +-- SOURCE/COMMON/TXTSHARE.PAS       (shared text display)
    +-- SOURCE/COMMON/VERSION.PAS        (version constants)
    +-- SOURCE/COMMON/DEFINES.INC        (platform detection macros)
    +-- SOURCE/COMMON/SWAGDATE.PAS       (date handling)

EDITOR.EXE   (game editor/configurator)
    |
    +-- SOURCE/EDITOR/EDITOR.PAS         (main program, TurboVision UI)
    +-- SOURCE/EDITOR/INIT.PAS           (data structures)
    +-- SOURCE/EDITOR/ADDIT.PAS          (add/edit items, 114KB)
    +-- SOURCE/EDITOR/EDWEAP*.PAS        (weapon editing, 3 files)
    +-- SOURCE/EDITOR/EDMONST*.PAS       (monster editing, 2 files)
    +-- SOURCE/EDITOR/EDBODY.PAS         (character body editing)
    +-- SOURCE/EDITOR/*.PAS              (30+ editor units)
    |
    +-- SOURCE/COMMON/ (shared units)
```

**Key runtime dependencies:**

- **DDPlus** - BBS door I/O library (serial, FOSSIL, socket, local)
- **RPPort** - Rick Parrish's cross-platform portability shim (file locking, screen, sleep)
- **TurboVision** - FPC's TurboVision port (used by EDITOR only)

---

## Directory Structure

| Path | Purpose |
|------|---------|
| `SOURCE/USURPER/` | Main game engine source (80+ Pascal units) |
| `SOURCE/EDITOR/` | Game editor source (30+ Pascal units, TurboVision UI) |
| `SOURCE/COMMON/` | Shared units used by both USURPER and EDITOR |
| `SOURCE/EDITOR/OLD/` | Archived/unused editor code |
| `SOURCE/USURPER/OLD/` | Archived DOS-era ASM stubs |
| `RELEASE/` | Distribution files (docs, text art, configs, EXEs go here) |
| `RELEASE/DOCS/` | Player and sysop documentation |
| `RELEASE/TEXT/` | ANSI and ASCII art screens (`.ANS`, `.ASC`) |
| `RELEASE/SAMPLES/` | Sample configuration files |
| `RELEASE/UPGRADES/` | Version upgrade tools |
| `ORIGINAL ARCHIVES/` | Original source ZIP archives (historical reference) |
| `bin/` | Compiled binaries (gitignored) |
| `obj/` | Object files (gitignored) |
| `.github/workflows/` | CI/CD: pre-release (master push) and tagged-release (v* tag) |

**Key files:**

| File | Purpose |
|------|---------|
| `build.ps1` | PowerShell build script - compiles all platforms, creates release ZIPs |
| `SOURCE/USURPER/USURPER.PAS` | Game main program entry point |
| `SOURCE/EDITOR/EDITOR.PAS` | Editor main program entry point |
| `SOURCE/USURPER/INIT.PAS` | Master type definitions and data structures |
| `SOURCE/USURPER/FILE_IO.PAS` | All file I/O, record locking (169KB - largest file) |
| `SOURCE/COMMON/DEFINES.INC` | Platform detection (`{$IFDEF FPC}`, `{$IFDEF WINDOWS}`, etc.) |
| `SOURCE/COMMON/RPPORT.PAS` | Cross-platform portability layer |
| `SOURCE/COMMON/VERSION.PAS` | Version constants (`uver`, `ucomp`) |
| `RELEASE/SAMPLES/USURPER.CFG` | Sample game configuration |
| `RELEASE/DOCS/SYSOP.TXT` | Sysop installation/configuration documentation |
| `RELEASE/DOCS/USURPER.TXT` | Player documentation |
| `RELEASE/DOCS/WHATSNEW.TXT` | Full changelog |

---

## Code Style

**Free Pascal (TP Compatibility Mode) Conventions:**

- **Compiler mode:** `-Mtp` (Turbo Pascal / Borland Pascal 7.0 compatibility)
- **All source files** include `{$I DEFINES.INC}` at top (except on MSDOS target)
- **String types** are short strings by default (`{$H-}`) - use `string[N]` fixed-width types
- **Record alignment** is packed: `{$PACKRECORDS 1}` and `{$packset 1}`
- **No `uses` of modern FPC units** in game code - use RPPort shim for portability
- **ANSI/ASCII art** screens live in `RELEASE/TEXT/` as `.ANS` (color) and `.ASC` (plain) pairs
- **File I/O** uses typed binary files (`file of RecordType`) and explicit record locking
- **Comments** use `{ }` and `(* *)` style - match surrounding code style
- 2-space indentation (existing code convention - match what's around you)

**Platform Macros (use in `{$IFDEF}` blocks):**

| Macro | Meaning |
|-------|---------|
| `FPC` | Compiling with Free Pascal (not Borland) |
| `MSDOS` | DOS target (go32v2) |
| `WINDOWS` | Any Windows target (win32 or win64) |
| `UNIX` | Any Unix/Linux target |
| `GO32V2` | DOS 32-bit protected mode |

**Standard file header pattern:**

```pascal
{$IFNDEF MSDOS}
{$I DEFINES.INC}
{$ENDIF}
{
Copyright 20XX Jakob Dangarden / Usurper Dev Team

 This file is part of Usurper.
 [GPL v2 boilerplate]
}

unit UnitName; {Brief description}

interface

uses
  Init {$IFDEF FPC}, RPPort{$ENDIF};

{ ... }

implementation

{ ... }

end.
```

**String type aliases** (defined in `INIT.PAS`, use these instead of raw `string[N]`):

```pascal
s3, s4, s10, s14, s15, s20, s25, s30, s40, s70, s80, s90, s100, s120
```

**ANSI output** - use `AnsiColr` unit constants (e.g., `aRedOnBlack`, `aHiWhiteOnBlack`) or direct ANSI escape sequences via DDPlus `D()` procedure.

---

## Module Naming Conventions

No strict prefix convention - units are named by function. Key patterns:

| Pattern | Purpose | Examples |
|---------|---------|----------|
| `ED*.PAS` | Editor units for specific item types | EDWEAP, EDMONST, EDBODY, EDHEAD |
| `*C.PAS` | "C" suffix often = "classic" or game location | BRAWLC, PRISONC, GIGOLOC |
| `VARIOUS*.PAS` | General utilities/mechanics overflow | VARIOUS, VARIOUS2, VARIOUS3 |
| `FILE_IO*.PAS` | File I/O split across files | FILE_IO, FILE_IO2 |
| `DDPLUS.PAS` | DDPlus BBS library (serial/FOSSIL/socket I/O) | - |
| `RPPORT.PAS` | Cross-platform portability shim | - |

**Unit declaration format:**

```pascal
unit UnitName; {One-line description}
```

---

## Testing

**There is no automated test suite.** Testing is manual - compile and run.

**Before Committing:**

```bash
# 1. Syntax check (Windows, requires fpc in PATH or fpcupdeluxe installed)
# Run the build script - it will fail fast on compile errors
.\build.ps1 -Debug

# 2. Target-specific build (single platform for faster iteration)
# Example: just x86_64-linux
$null = New-Item -ItemType Directory -Path "bin\x86_64-linux" -Force
$null = New-Item -ItemType Directory -Path "obj\x86_64-linux" -Force
C:\fpcupdeluxe\fpc\bin\x86_64-win64\fpc.exe -B -Tlinux -Px86_64 -Mtp -Scgi -CX -O3 -Xs -XX -FiSOURCE\USURPER -FiSOURCE\COMMON -FUobj\x86_64-linux\ -FEbin\x86_64-linux\ SOURCE\USURPER\USURPER.PAS

# 3. Full release build (all 5 platforms)
.\build.ps1

# 4. Manual functional testing - run the game through a BBS door or direct terminal
```

**CI/CD (GitHub Actions):**

- **Pre-release workflow** (`.github/workflows/pre-release.yml`): Triggers on every push/PR to `master`. Builds all platforms with debug flags, uploads artifacts as "Development Build" pre-release.
- **Tagged release workflow** (`.github/workflows/tagged-release.yml`): Triggers on `v*` tags. Builds release (optimized), creates GitHub Release with ZIPs.

**Build verification checklist:**

1. `build.ps1` runs without errors
2. `bin/<cpu>-<os>/USURPER.EXE` exists and was recently compiled
3. `bin/<cpu>-<os>/EDITOR.EXE` exists and was recently compiled
4. Release ZIPs created: `usurper-<cpu>-<os>.zip`
5. Functional test: run game, exercise changed code paths

---

## Commit Format

Use brief, descriptive commit messages. Existing commit style observed in this repo:

```
Brief imperative description of what changed

Optional: additional context if non-obvious
```

**Examples from this repo:**

```
Fix editor /RESET hanging due to TurboVision finalization
Replace floating-point tab stop test with integer mod
Implement ANSI reverse video (SGR 7) via TextAttr swap
Buffer plain text in D() to reduce serial I/O overhead
Fix ANSI parameter parsing to handle 3+ digit numbers
```

**Rules:**
- Imperative mood ("Fix", "Add", "Replace", not "Fixed", "Added")
- Short subject line (50-72 chars)
- No period at end of subject
- Reference the unit/area being changed when helpful (e.g., "RPPORT.PAS: ...")
- Do not push to origin without asking Andrew

---

## Development Tools

**Common Commands:**

```bash
# Full build (PowerShell, Windows)
.\build.ps1

# Debug build
.\build.ps1 -Debug

# Quick syntax check for a single unit (FPC must be in PATH)
fpc -Mtp -Scgi -FiSOURCE\COMMON -c SOURCE\USURPER\ANSICOLR.PAS

# Search source code
grep -r "pattern" SOURCE/USURPER/
grep -r "pattern" SOURCE/EDITOR/
grep -r "pattern" SOURCE/COMMON/

# Find large units
ls -lh SOURCE/USURPER/*.PAS | sort -k5 -rh | head -20

# Check recent changes
git log --oneline -15
git diff HEAD~1

# View build log from CI
git log --oneline | head  # find recent commit, check GitHub Actions
```

**Lazarus IDE** (optional, for interactive development):
- Open `SOURCE/USURPER.lpi` for the game engine
- Open `SOURCE/EDITOR.lpi` for the editor

---

## Common Patterns

**Cross-platform file locking (RPPort):**

```pascal
{$IFDEF FPC}
uses RPPort;
{$ENDIF}

{ Lock a region of a binary file for exclusive access }
RPLockFile(FileHandle, StartByte, LengthBytes);
{ ... do work ... }
RPUnLockFile(FileHandle, StartByte, LengthBytes);
```

**Platform-conditional code:**

```pascal
{$IFDEF FPC}
  { Free Pascal specific code - modern platforms }
  uses RPPort, BaseUnix;
{$ENDIF}

{$IFDEF MSDOS}
  { DOS-only code }
{$ENDIF}

{$IFDEF WINDOWS}
  { Windows-specific code }
{$ENDIF}

{$IFDEF UNIX}
  { Linux/Unix specific code }
{$ENDIF}
```

**DDPlus BBS output (game I/O):**

```pascal
{ D() - output string to BBS connection (serial/FOSSIL/socket/local) }
D('Hello, world!');

{ Use ANSI color codes from AnsiColr unit }
D(aHiWhiteOnBlack + 'Bold white text' + aDef);

{ Display a text/ANSI file from RELEASE/TEXT/ }
DispFile.DisplayFile('MAINMENU');  { shows MAINMENU.ANS or MAINMENU.ASC }
```

**Record file I/O (typed binary files):**

```pascal
var
  F: file of PlayerRecord;
  Player: PlayerRecord;
begin
  Assign(F, FileName);
  Reset(F);
  RPLockFile(FileRec(F).Handle, RecordIndex * SizeOf(PlayerRecord), SizeOf(PlayerRecord));
  Seek(F, RecordIndex);
  Read(F, Player);
  { ... modify Player ... }
  Seek(F, RecordIndex);
  Write(F, Player);
  RPUnLockFile(FileRec(F).Handle, RecordIndex * SizeOf(PlayerRecord), SizeOf(PlayerRecord));
  Close(F);
end;
```

**Fixed-width string types (always use these, not raw string[N]):**

```pascal
var
  PlayerName: s30;   { string[30] }
  ShortCode:  s4;    { string[4]  }
  Description: s80;  { string[80] }
```

**Compiler directives in source:**

```pascal
{$IFNDEF MSDOS}
{$I DEFINES.INC}       { Always first - platform detection }
{$ENDIF}
```

---

## Documentation

### What Needs Documentation

| Change Type | Required Documentation |
|-------------|------------------------|
| New game feature | Update `RELEASE/DOCS/WHATSNEW.TXT` |
| Configuration change | Update `RELEASE/DOCS/SYSOP.TXT` |
| Gameplay change | Update `RELEASE/DOCS/USURPER.TXT` |
| New AT-codes | Update `RELEASE/DOCS/AT-CODES.TXT` |
| New config option | Update `RELEASE/SAMPLES/USURPER.CFG` |
| Version bump | Update `SOURCE/COMMON/VERSION.PAS` (`uver`, `ucomp`) |

### Documentation Files

| File | Purpose | Audience |
|------|---------|----------|
| `README.md` | Project overview | Contributors |
| `RELEASE/DOCS/USURPER.TXT` | Player guide | Players |
| `RELEASE/DOCS/SYSOP.TXT` | Sysop install/config guide | Sysops |
| `RELEASE/DOCS/WHATSNEW.TXT` | Full changelog | Everyone |
| `RELEASE/DOCS/AT-CODES.TXT` | ANSI AT-code reference | Sysops |
| `RELEASE/DOCS/BETATEAM.TXT` | Beta team credits | Historical |
| `.clio/instructions.md` | Project methodology | AI agents |
| `AGENTS.md` | Technical reference | AI agents |

---

## Anti-Patterns (What NOT To Do)

| Anti-Pattern | Why It's Wrong | What To Do |
|--------------|----------------|------------|
| Use `string` (long strings) | `{$H-}` mode uses short strings; mixing causes bugs | Use `string[N]` or the `sN` type aliases |
| Use `{$H+}` or `{$mode delphi}` | Breaks TP compatibility mode assumptions | Keep `{$H-}` and `-Mtp` |
| Add `uses` of modern FPC units directly | Breaks MSDOS/DOS portability | Use RPPort shim or `{$IFDEF FPC}` guards |
| Use floating-point for integer math | Inconsistent across platforms | Use `div` and `mod` for integer arithmetic |
| Call `halt(0)` from EDITOR | TurboVision finalization hangs | Use `fpExit(0)` from BaseUnix on FPC |
| Skip DEFINES.INC include | Platform macros undefined | Always include `{$I DEFINES.INC}` at top |
| Hardcode screen size | `RPPort` has `RPScreenSizeX/Y` functions | Use RPPort for screen dimensions |
| Raw `D()` calls with ANSI escape sequences | Hard to read, error-prone | Use AnsiColr unit constants |
| Commit `bin/` or `obj/` directories | Build artifacts in repo | These are gitignored, keep it that way |
| Use dynamic arrays or objects | Not available in TP mode | Use static arrays and records |
| Add AI-generated summary docs to root | Clutter | Use `scratch/` (gitignored) for working docs |

---

## Quick Reference

**Build:**
```powershell
# Full build (all platforms)
.\build.ps1

# Debug build
.\build.ps1 -Debug
```

**Search code:**
```bash
grep -r "procedure_or_var_name" SOURCE/
grep -rn "pattern" SOURCE/USURPER/
grep -rn "pattern" SOURCE/COMMON/
```

**Git:**
```bash
git status
git log --oneline -10
git diff
git add -A && git commit -m "Brief description"
# Do NOT push without asking Andrew
```

**Version bump** (when releasing):
```pascal
{ SOURCE/COMMON/VERSION.PAS }
const
  uver  = '0.26';            { update version }
  ucomp = '2026/03/15';      { update compile date }
```

**Release tagging:**
```bash
git tag v0.26
# Then ask Andrew before pushing
```

---

*For project methodology and workflow, see .clio/instructions.md*
