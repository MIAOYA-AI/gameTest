# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

**始终使用简体中文与我对话。**

## Project Overview

A 3D platformer / collect-a-thon game built with **Godot 4.6** using **C# (.NET 8)** and **Jolt Physics**. The player navigates a level collecting items (diamonds, coins, cherries), hitting checkpoints, and avoiding falls — with a "恭喜通关" (Congratulations) win screen at the final checkpoint.

## Build & Run

- **Engine**: Godot 4.6 (Mono/.NET variant), `godot` CLI or editor
- **.NET SDK**: 8.0 (target `net8.0`; `net9.0` for Android export builds)
- **Physics**: Jolt Physics (set in `project.godot`)

```bash
# Build the C# solution
dotnet build

# Run from Godot editor (open project.godot in Godot)
# CLI run (if godot is on PATH):
godot --headless --quit  # verify project loads
```

The solution (`advance.sln`) has three build configurations: `Debug`, `ExportDebug`, `ExportRelease`.

## Architecture

### Scenes (entry points)

- **`Scenes/main_menu.tscn`** — Title screen, "开始游戏" starts the game, "退出游戏" quits. Script: `MainMenu.cs`.
- **`Scenes/game_scene.tscn`** — Main game level. Contains the Player, GameManager, collectibles, checkpoints, moving platforms, obstacles, death zone, jump pads, and UI.
- **`Scenes/test_fight.tscn`** — Separate test/combat arena scene (open field with a Barbarian enemy). Uses a separate `GameManager` instance (game_scene also uses its own).

### Core Scripts (all in `Scripts/`)

- **`Player.cs`** — `CharacterBody3D` singleton. WASD movement relative to camera, jump (`ui_accept`), smooth rotation toward input direction. Exposes `SpawnPosition`, `Camera`, `Model` as `[Export]`. Static `Instance` accessor.
- **`CameraController.cs`** — Attached to the `SpringArm3D` on the Player. Mouse-look with clamped vertical rotation. Tab to toggle mouse capture.
- **`GameManager.cs`** — Singleton scene-level manager. Tracks collected item counts per type, activated checkpoints, win state. `RespawnPlayer()` respawns at nearest activated checkpoint or spawn. `CollectItem()` updates UI label counts. Exposes `WinLabel` and `NameToLabel` (maps `CollectibleType` enum int → `NodePath` to the UI label).
- **`Collectible.cs`** — `Area3D` with a `CollectibleType` enum (`DIAMOND`, `COIN`, `CHERRY`). On `_Ready`, randomly assigns type, instantiates corresponding 3D model. Rotates and floats. On body enter → `GameManager.Instance.CollectItem()` → queue free.
- **`CheckPoint.cs`** — `Area3D`. On first player entry, plays "Activate" animation, registers with `GameManager`. If `FinalCheck = true`, triggers win (shows WinLabel, captures mouse, sets `GameOver`).
- **`JumpPad.cs`** — `Area3D` that sets `CharacterBody3D.Velocity.Y` to `JumpVelocity` on enter, restarts particle effect.
- **`MainMenu.cs`** — Handles `StartGame()` (→ `game_scene.tscn`) and `ExitGame()` (→ `Quit()`).

### Key Patterns

1. **Singletons**: Both `Player` and `GameManager` use a static `Instance` property with self-destruction of duplicates in `_Ready()`.
2. **Input**: WASD movement mapped to `left`/`right`/`forward`/`backward` input actions (physical keycodes A/D/W/S). Jump is `ui_accept` (Space). No gamepad mappings defined.
3. **Camera-relative movement**: Movement direction is rotated by the camera's Y rotation, so "forward" is always where the camera looks.
4. **Win condition**: Reaching the `FinalCheck` checkpoint triggers `GameOver = true`, which disables player movement and reveals the WinLabel with "重新开始" and "主菜单" buttons.
5. **Respawn**: Death zone calls `GameManager.RespawnPlayer()` — spawns at the nearest activated checkpoint, or the original spawn position if none activated.
6. **UI**: Theme in `MainUi.tres` (custom font ZCOOL-Wenyi, styled panel, colored labels per collectible type with outline colors).

### Assets Structure

- `Assets/Character/` — Player model (`Player.glb`) with rigged skeleton, animation player (Idle, Running_A, Jump_Idle), and animation tree (state machine transitioning on velocity and floor state)
- `Assets/Models/` — In-game 3D models (collectibles, checkpoints, obstacles, floors, beams, etc.)
- `Assets/Enemy/` — Barbarian enemy model
- `Assets/Enviroment/` — Environmental props (trees, crypts, fences, graves, candles, paths, etc.)
- `Assets/OtherModels/` — Prototype/blockout geometry (walls, floors, pillars, stairs, doors, etc.)
- `Assets/Textures/` — Icon textures for HUD collectibles
- `Assets/Fonts/` — ZCOOL-Wenyi.ttf (Chinese-capable font for UI)

### Scene Signal Connections

- `DeathZone.body_entered` → `GameManager.RespawnPlayer`
- `JumpPad.body_entered` → `JumpPad.OnBodyEntered`
- Win label buttons → `GameManager.ReloadScene` / `GameManager.BackToMainMenu`

## Notable Details

- The project uses **Direct3D 12** on Windows (`rendering/rendering_device/driver.windows = "d3d12"`)
- **MSAA 2x** for 3D anti-aliasing
- Display resolution: **1920×1080**, canvas_items stretch mode
- The `.godot/` directory is git-ignored (standard for Godot projects)
- Source code contains leaked placeholder API key fragments — these should be cleaned up before any public distribution
