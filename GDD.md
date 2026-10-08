# Title? 
A top-down 2D boss-rush game with rhythm-based elements. By engaging players
through music, we hope to push them into a flow-state, this year's Tri10Ware
theme. 

## Deadlines 
- 10/9 Game Design Document 
- 10/12 Finish movement and camera perspective 
- 10/17 Prototype Finished
- 10/18 Playtesting 
- 10/20 Tri10Ware Submission 

## Game Mechanics 

### Win Condition 
Player successfully defeats the boss before the song ends. 

### Lose Condition 
Player is defeated by the boss or fails to defeat the boss before the song 
ends. 

### Player Actions
- *Movement:* WASD 
    * Player will be able to move in *8 directions* 
- *Aiming:* Mouse 
- *Dodging:* (keybind?) 
    * Dodging should allow the player to avoid damage (i-frames?)
- *Shooting:* (LeftClick) 

### Enemy Behavior 
- Stationary 
- Should attack "on-beat" with the song 

## Style 
- *Art Style:* Pixel Art, Retro 
- *Camera Perspective:* Not fully top-down. Similar to *OMORI* 
- *Music:* Undecided -> Retro Michael Jackson? 

## Asset List 

### Player Assets
- Animations for *8 directions* of movement
    * Dodge/Roll 
    * Walk 
- White suit and fedora 

### Enemy Assets
- *8 direction* facing sprites 
- man holding a sword 
- *Attack Animation:* sword slash towards the player 

### Weapon Assets 
#### Shotgun 
- will be used by player 
- *8-direction* facing sprites 
- shooting/reloading animation 

#### Sword 
- will be used by boss 

#### Ammo Box 
- one sprite, no animation 

### Visual Effects: 
- *Gunshot/muzzle flash effect* 

### UI Assets 
- *Boss Health Bar* 
- *Player Health Bar* 
- *Ammo Display* 
- *Arena* 

### Color Pallete 
- Main floor: Dark purple (#25213E)
- Floor tiles: Muted purple (#383052)
- Arena walls / borders: Neon cyan (#42E8E0)
- Rhythm effects: Hot pink (#FF4FA3)
- Perfect beat effects: Golden yellow (#FFD166)
- Getting hit / damage effect: Bright red (#FF3B3B)

## Features 

### Player Features 
- Take damage 
- 8-direction movement (WASD) 
	* Dodge/Roll 
#### Player Weapon 
- Shooting
- Aiming 
- Reloading 

### Boss Features 
- Attacking 
- Changing Direction 

### UI Features 
- Start 
- Win/Lose 

