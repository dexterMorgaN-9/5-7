5:7 - Bomb Defusal Game

A tense, retro styled bomb defusal game. Players must memorize five codes within a short window, then enter the correct code on each of four bombs before time runs out.

Gameplay Overview

When the game starts, the player is shown five randomly generated six digit codes for a limited period. Once the timer ends, the codes are shuffled and assigned to four bombs. The player must defuse the bombs one at a time, in order, by entering the correct code on each bomb's before the defusal timer reaches zero. Entering a wrong code resets the input. Successfully entering all six digits checks the code automatically. If all four bombs are defused before time runs out, the player wins. If the timer reaches zero first, the bombs explode and the player loses.

File Structure

project/
├── scenes/
│   ├── MainMenu.tscn
│   ├── Game.tscn
│   └── bomb_panel.tscn
│
├── scripts/
│   ├── MenuController.gd
│   ├── GameController.gd
│   ├── bomb.gd
│   └── audio_manager.gd
│
├── assets/
│   ├── fonts/
│   ├── images/
│   ├── shaders/
│   │   └── Game.gdshader
│   ├── sfx/
│   └── bgm/
│
└── README.md

Controls

Use the on screen numpad or number keys to enter bomb codes
Press the backspace key or the star key on the numpad to delete the last digit
Press the enter key or the hash key on the numpad to submit the entered code

Settings

Players can open the settings panel from the main menu to set a custom name and adjust the master volume using a slider. These preferences are saved locally and reloaded automatically the next time the game starts.

If you enjoy this game while playing consider giving it a star!
