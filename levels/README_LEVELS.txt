HELL'S DESCENT: LEVELS (Godot 4.7) - one continuous level per floor
Unzip into the project root (folder becomes res://levels/). Tested in Godot 4.7.2 against main: every level loads in under 1 s,
the player starts at the left and lands on the floor in every section, hazards/breakables/bridges work.

  levels/gluttony/rooms/0_gluttony_level.tscn    entry -> banquet hall -> grease pit -> pantry climb -> Hibachi Chef arena
  levels/greed/rooms/0_greed_level.tscn          vault gate -> molten mint -> counting hall -> gold shaft -> Living Statue arena
  levels/violence/rooms/0_violence_level.tscn    blood river -> labyrinth -> bleeding wood -> centaur range -> Labyrinth Butcher arena
  levels/fraud/rooms/0_fraud_level.tscn          bridges -> cracked pit -> hall of lies -> lead cloaks -> Ferry Beast arena
  levels/treachery/rooms/1_satan_arena.tscn      the single Satan room (see README_SATAN.txt)

No room transitions inside a floor: the sections are carved into one tile grid and the walls between them are knocked through,
so the player walks/climbs from the start to the boss without a scene change. Only these keep a doorway:
  every boss arena (its gates), the Labyrinth's two doors (its tiers need them), the Hall of lies' fake wall (the trick needs a wall).

Each level scene:
  Parallax/      backgrounds scroll sideways only (scroll_scale.y = 1), so the editor shows them exactly where they sit in game;
                 every section has its own copy of each layer sitting on its floor
  Tiles          one TileMapLayer for the whole floor (solid = layer 1 "world", tiles 3-5 one-way)
  Illusions      (Fraud) fake floor/wall tiles with collision off
  Chains, Decor, Platforms (one-way tops), Hazards (your hitbox.tscn), Breakables (your hurtbox + health_component,
                 died -> queue_free), Switches (Labyrinth coin targets drop their bridges), Gates (boss arena, start open)
  Exits          Exit_R at the far end = go to the next floor's scene (Exit_L at the start of floors 2-4 = back door, optional)
  Spawns         Spawn_L / Spawn_R markers by the doors
  Player         your player.tscn at the start, Camera2D limits = the whole level
  Foreground     Parallax2D in front of everything

What your code does: Exit_R -> load the next floor (and the Satan room after Fraud); close the arena gates when the boss wakes;
optional charge-only check for the Fraud breakables (ignore hits with damage < 3).
Art + layouts are AI-made (approved by the organizers): list levels/ in CREDITS.md.

UPDATE (jump + breakables pass)
- Every climb step is now <= 36 px (jump peak is ~63 px). Pantry and gold shafts have more shelves, grease-pit pans and
  bleeding-wood beams sit lower, and the 5-tile pits on Greed / Violence are 4 tiles (dash gaps).
- Gluttony is fully clearable without dash. Greed onwards needs dash for the 4-tile pits only.
- Breakables: Breakables/Pot* nodes = small props (crocks, barrels, coin heaps, skulls, mirrors, ...).
  Node2D + Sprite2D + Hurtbox (layer 9 breakables) + health_component (1 HP), died -> queue_free. No collision body,
  so the player walks through them. One slash breaks them. ~21-24 per level, none in boss arenas.
  Breakables/Block* and LeadDoor* (Fraud) are unchanged solid walls (4 and 6 HP).
