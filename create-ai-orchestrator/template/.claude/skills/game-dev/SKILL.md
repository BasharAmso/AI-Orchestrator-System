---
id: SKL-0038
name: Game Development
description: |
  Build web-based games across four modes: adventure (narrative + puzzles),
  sandbox (open world + crafting), action (real-time combat + physics), and
  educational (learning objectives + adaptive difficulty). Covers game loop,
  scene management, asset pipeline, input handling, and state persistence.
version: 1.0
owner: builder
triggers:
  - GAME_DEV_REQUESTED
  - GAME_FEATURE_REQUESTED
inputs:
  - docs/GDD.md (Game Design Document)
  - Task description with game mode and feature requirements
  - .claude/project/knowledge/DECISIONS.md
outputs:
  - Game source files (src/game/, src/scenes/, src/entities/)
  - .claude/project/STATE.md (updated)
tags:
  - game
  - interactive
  - canvas
  - webgl
  - phaser
  - adventure
  - sandbox
  - educational
---

# Skill: Game Development

## Metadata

| Field | Value |
|-------|-------|
| Skill ID | SKL-0038 |
| Name | Game Development |
| Version | 1.0 |
| Owner | builder |

## Purpose

Build web-based games using structured procedures adapted to four game modes. Each mode has its own architecture patterns, core systems, and quality checks.

## Procedure

### 1. Determine Game Mode

Read the GDD (docs/GDD.md) or task description. Identify the primary mode:

| Mode | Signals | Core Systems |
|------|---------|-------------|
| **Adventure** | story, narrative, puzzles, point-and-click, dialogue, quests | Scene graph, dialogue engine, inventory, puzzle state, save/load |
| **Sandbox** | open world, crafting, building, exploration, procedural | Chunk/tile system, crafting recipes, entity spawning, world persistence |
| **Action** | combat, physics, real-time, enemies, platformer, shooting | Game loop (60fps), collision detection, entity-component, particle effects |
| **Educational** | learning, quiz, adaptive, curriculum, progress tracking | Question engine, adaptive difficulty, progress analytics, reward system |

If the GDD specifies multiple modes (e.g., adventure + educational), use the primary mode's architecture with secondary mode systems layered on top.

### 2. Select Tech Stack

**Default stack (web-based):**

| Component | Default | Alternative |
|-----------|---------|-------------|
| Engine | Phaser 3 | PixiJS (2D rendering only), Three.js (3D), vanilla Canvas |
| Language | TypeScript | JavaScript |
| Build | Vite | Webpack |
| State | Zustand or built-in scene data | Redux (if React wrapper needed) |
| Audio | Howler.js | Web Audio API directly |
| UI overlay | HTML/CSS overlay | Phaser DOM elements |

If the GDD or task specifies a different engine or approach, follow that instead. Ask the user if unstated.

### 3. Set Up Game Architecture

Create the base structure (skip existing files):

```
src/
  game/
    config.ts          Game configuration (dimensions, physics, debug flags)
    main.ts            Entry point, Phaser.Game instantiation
    scenes/
      BootScene.ts     Asset preloading, splash screen
      MenuScene.ts     Main menu, settings, save slot selection
      GameScene.ts     Primary gameplay scene
      UIScene.ts       HUD overlay (health, score, inventory)
    entities/          Game objects (player, enemies, items, NPCs)
    systems/           Core systems (input, physics, audio, save/load)
    data/              Static data (levels, dialogues, item definitions)
    utils/             Helpers (math, random, collision)
  assets/
    sprites/           Character and object sprites
    tiles/             Tilemap assets
    audio/             Sound effects and music
    ui/                UI elements and fonts
```

### 4. Build Core Systems (All Modes)

These systems are needed regardless of game mode:

**A. Game Loop and Scene Management**
- Phaser scene lifecycle: `preload()`, `create()`, `update()`
- Scene transitions with optional fade/slide effects
- Pause/resume support

**B. Input Handling**
- Keyboard (WASD/arrows + action keys)
- Mouse/touch (click, drag, tap)
- Gamepad support (optional)
- Input mapping configuration (rebindable keys)

**C. Asset Pipeline**
- Preload all assets in BootScene with progress bar
- Sprite sheets with animations (walk, idle, attack, etc.)
- Tilemap loading (Tiled JSON format)
- Audio sprites for sound effects

**D. Save/Load System**
- LocalStorage for web persistence
- Save slots (at least 3)
- Auto-save at checkpoints or intervals
- Save data structure: player state, world state, quest progress, settings

**E. Audio Manager**
- Background music with crossfade between scenes
- Sound effects with volume control
- Mute/unmute toggle
- Respect user audio preferences

### 5. Build Mode-Specific Systems

#### Adventure Mode

1. **Dialogue Engine**
   - Branching dialogue trees (JSON-driven)
   - Character portraits and name plates
   - Choice buttons with consequence tracking
   - Typewriter text effect
   - Format: `{ speaker, text, choices: [{ text, next, effects }] }`

2. **Inventory System**
   - Grid or list inventory UI
   - Item pickup, use, combine, drop
   - Key items vs consumables
   - Item descriptions and icons

3. **Puzzle System**
   - State-based puzzle logic (item + location = solution)
   - Visual feedback on interaction (highlight, animate)
   - Hint system (progressive hints after N failed attempts)
   - Puzzle completion events trigger story progression

4. **Quest/Progress Tracker**
   - Active quests with objectives
   - Quest log UI
   - Quest state: available, active, completed, failed
   - Story flags dictionary (tracks world state decisions)

#### Sandbox Mode

1. **World Grid / Chunk System**
   - Tile-based world (or chunk-based for large worlds)
   - Procedural generation with seed support
   - Biomes or zones with distinct tiles and entities
   - World boundaries or infinite scrolling

2. **Crafting System**
   - Recipe database (JSON-driven)
   - Crafting UI: ingredient slots + output preview
   - Resource gathering from world objects
   - Tool progression (stone -> iron -> diamond)

3. **Building System**
   - Place/remove blocks or objects on grid
   - Rotation and variant selection
   - Blueprint mode (plan before committing resources)
   - Structural rules (optional: gravity, support requirements)

4. **Entity Spawning**
   - Spawn tables per biome/zone
   - Day/night cycle affecting spawns
   - Peaceful vs hostile entity behavior
   - Population limits per chunk

#### Action Mode

1. **Physics and Collision**
   - Arcade physics (Phaser built-in) or Matter.js for complex shapes
   - Collision groups: player, enemies, projectiles, environment
   - Knockback, gravity, friction tuning
   - Platform-specific: one-way platforms, moving platforms

2. **Combat System**
   - Health, damage, invincibility frames
   - Attack patterns (melee range, projectile, area)
   - Enemy AI: patrol, chase, attack states (finite state machine)
   - Hit feedback: screen shake, flash, particles

3. **Particle Effects**
   - Explosions, dust, sparks, magic effects
   - Particle emitter configuration (lifespan, speed, gravity, tint)
   - Pool particles for performance

4. **Level Design Support**
   - Tiled map integration with object layers
   - Spawn points, checkpoints, triggers
   - Camera follow with dead zones
   - Parallax backgrounds (3+ layers)

#### Educational Mode

1. **Question Engine**
   - Multiple question types: multiple choice, drag-and-drop, fill-in, matching
   - Question bank (JSON-driven, tagged by topic and difficulty)
   - Randomized question selection (avoid repeats)
   - Immediate feedback with explanation

2. **Adaptive Difficulty**
   - Track correct/incorrect ratio per topic
   - Increase difficulty after 3 consecutive correct answers
   - Decrease after 2 consecutive wrong answers
   - Difficulty levels: easy, medium, hard (mapped to question tags)

3. **Progress Analytics**
   - Per-topic mastery percentage
   - Session statistics (questions attempted, accuracy, time)
   - Progress visualization (charts, stars, badges)
   - Parent/teacher dashboard view (optional)

4. **Reward System**
   - Points, stars, or XP for correct answers
   - Unlockable content (characters, levels, cosmetics)
   - Streak bonuses (consecutive correct answers)
   - Achievement system with badges

### 6. Polish and Quality

- **Performance:** Target 60fps on mid-range devices. Profile with browser dev tools.
- **Responsive:** Support desktop (1280x720 min) and mobile (portrait + landscape).
- **Accessibility:** Keyboard-navigable menus, colorblind-safe palette options, screen reader support for text-heavy games (adventure/educational).
- **Error handling:** Graceful fallbacks if assets fail to load. Never crash on missing data.
- **Testing:** Manual playthrough of all paths/modes. Edge cases: empty inventory, max score, boundary collisions.

### 7. Definition of Done Checklist

- [ ] Game boots without errors (BootScene -> MenuScene -> GameScene)
- [ ] Core game loop runs at 60fps
- [ ] Player can interact with the game (input handling works)
- [ ] Mode-specific systems functional (per section 5)
- [ ] Save/load works across browser sessions
- [ ] Audio plays correctly (music + SFX)
- [ ] Responsive to at least 2 viewport sizes (desktop + mobile)
- [ ] No console errors during normal gameplay
- [ ] GDD requirements addressed (cross-reference docs/GDD.md)
- [ ] STATE.md updated

## Anti-Patterns

- Never hardcode level data in source files -- use JSON data files
- Never skip the preload phase -- all assets must be loaded before gameplay
- Never use `setInterval` for game timing -- use the engine's update loop
- Never store game state in global variables -- use scene data or a state manager
- Never ignore mobile input -- touch support is required for web games

## Guardrails

- All user-generated content (names, chat) must be sanitized
- No external network calls during gameplay without user consent
- Asset sizes must be reasonable (sprite sheets < 2MB each, total assets < 20MB)
- Frame rate monitoring: warn if consistently below 30fps
