This is our repo for the jam, read this before you start please, it's quick.

Godot version
Everyone use Godot 4.7.2, exact same version. Don't update mid jam unless we all do it together, otherwise scenes get rewritten and we get weird conflicts.

Getting it running
Clone it: git clone https://github.com/Jadelaawar42027/inferno-game-jam.git
Then open Godot, hit Import, pick the project.godot file and press F5 to see it runs. If you hate the terminal just use GitHub Desktop, it's fine.

Folders
I've already made all the folders so you don't have to guess where stuff goes.
assets/art - sprites, tilesets etc.
assets/audio/music, assets/audio/sfx, assets/audio/voice - pretty obvious
assets/fonts
assets/shaders
scenes/ and scripts/ both have player, enemies, bosses, levels, ui. Scene goes in scenes/x, its script goes in scripts/x with the same name.
resources/abilities - for the ability resources

There's a .gitkeep file in every folder. It's empty, it's only there so Git actually pushes the empty folders. Don't worry about it, delete it once your folder has real stuff in it or just leave it, whatever.

Display settings
Base resolution is 640x360, the window opens at 1280x720 so it's not tiny on your screen.
Stretch mode viewport, aspect keep, scale mode integer so pixel art scales clean.
Default texture filter is Nearest so pixel art stays sharp and not blurry. If your sprite looks blurry it's probably overridden on the node, check the texture filter on it.

Input map
move_left (A / left arrow)
move_right (D / right arrow)
move_up (W / up arrow)
move_down (S / down arrow) - up and down are for aiming attacks up/down
jump (Space)
attack (J / left click)
dash (Shift)
throw (K)
interact (E)
pause (Esc)
Use these action names in code, never check raw keys.

Physics layers
Already named them so the checkboxes show names, not numbers.
1 world - floors, walls, platforms
2 player
3 enemies
4 player_hitbox - player attacks
5 enemy_hitbox - enemy attacks
6 pickups
If you're not sure what layer/mask something needs just ask.

Audio buses
Master with Music, SFX and Voice going into it. Put every audio player on the right bus or volume settings won't work later. It's saved in default_bus_layout.tres, commit that.

Git stuff
.gitignore ignores the .godot folder and .DS_Store (Mac junk), don't commit either.
.gitattributes forces LF line endings so Windows and Mac don't fight over every file, leave it.

How we work
We all push straight to main, we're each working on separate stuff so it should be fine.
Tasks are on Trello. Pick one, put your name on it, move it to Doing.
Always git pull before you start working and again before you push.
Use git pull --rebase so we don't get "merge branch main" commits everywhere.
Commit small and push often, not a whole day of work at once.
Run the game before every push, if main is broken it's broken for everyone.
If git pull gives you a conflict and you're not sure what to do, stop and ping me, don't just pick a side.

Few rules that'll save us
- Say in Discord which scene you're editing, 2 people on the same scene = merge hell
- Don't touch Project Settings (input map, layers, autoloads etc.), tell me and I'll do it. project.godot conflicts the most
- Move/rename files inside Godot, not Finder/Explorer, or references break
- Commit the .uid and .import files, they look useless but they're not
- Never git push --force, it can wipe other people's work
- No AI generated anything, art, music, code, dialogue. Jam rules, we get DQ'd
- Any asset you download goes in CREDITS.md with the link and license when you add it, not on the last day

That's it for now, I'll update this as I add stuff. Ping me if anything doesn't work.
