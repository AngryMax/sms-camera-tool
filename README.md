# SMS Camera Tool

SMSCT is a tool used for getting clean, on-a-rail camera shots in Super Mario Sunshine. It's intended use is for making videos or mod trailers, but it's pretty fun to mess around with too!

## Installation

Just navigate to the downloads page, and download the latest version. Unzip the contents into a folder, and you should be able to just run it! Tt should be compatible with any NTSC-U version of Sunshine, 
even if it's modded (as long as the mod doesn't do anythign *too* funky with the camera.

## How to use

If you'd prefer to watch a video, here's a tutorial on how to use SMSCT: (insert link here)

## Launch
First, you need to launch your legally obtained copy of Sunshine via Dolphin Emulator. Once you're in the game, you can then run SMS-Camera-Tool.exe. As of current version, it *must* be in this order.

## Overview
SMSCT works by storing both the Camera's position and the Camera's target together as a single "Point." You can save multiple of these Points so that later you can "replay" these points, which means
the in-game camera will move from point to point in order.

## GUI Tour
In this section, I will add a description for what each button/input field does.

### Current Point, Add Point, Duplicate Point, and Delete Point
<img width="463" height="48" alt="image" src="https://github.com/user-attachments/assets/58747f59-6eb9-4d31-bc9e-434e19669d7d" />
Current Point is the Point you're currently working with. You will only start with one. You can add a point by pressing "Add Point," or "Duplicate Point."
Add Point will make a new Point filled with zeros, Duplicate Point will make a new Point copied from your current Point. Use the arrow on the Current Point filed to navigate your Points.<br/>
<br/>
<img width="150" height="44" alt="image" src="https://github.com/user-attachments/assets/1a2d393d-0f5a-4835-8536-d247db1cebe6" />
Further down and purposely out of the way is the "Delete Point" button, which will delete your current Point.

### Position, Target and the Copy Buttons
<img width="507" height="271" alt="image" src="https://github.com/user-attachments/assets/634a12d3-8b8a-46f3-aefc-b6e7f7da0b48" />
The three fields following "Position:" are the X, Y, and Z coordinates for the Camera's position. The Three fields folling "Target:" are the X, Y, and Z coordinates for the Camera's *Target* position.
During normal gameplay, the target position is Mario's position (technically I think it's a bit above Mario but that's not important). <br/> <br/>

Below those fields is the "Copy ALL From Game" button. Pressing this button will copy the Camera's position and target position directly into the relative fields. If you want more specificity, you can
use the buttons to the *right* of each individual coordinate field to copy from the specific axis of either the in-game Camera's target position (the target icon), or the in-game Camera's position (the 
blue camera icon). <br/> <br/>

The broken chain-link icon all the way to the right currently does nothing functional, so don't worry about it.

### Transition Time and Easing
<img width="461" height="46" alt="image" src="https://github.com/user-attachments/assets/fe7100f3-f286-4103-ae5f-e0dbda2a97f3" />
"Transition Time:" is the time in seconds it takes the Current Point to transition to the next Point. This means that the Transition Time for the final point is more or less irrelevant! <br/> <br/>

The dropdown menu to the right that has "Linear" selected in the screenshot sets the easing type for the transition from the Current Point to the next Point. This feature is still WIP, so Linear
is the only option that works fully as intended at the moment. Selecting Cubic can still make nice looking camera sweeps, it's just not working fully as intended, yet!

## Preview Point
<img width="173" height="45" alt="image" src="https://github.com/user-attachments/assets/a6678ad1-049a-48c4-923c-205f3038a1ee" />
Enabling this switch will set Sunshine's Camera to your Current Point. This is useful for editing and tweaking your Point to look exactly how you'd like it to!

### Replay Points
<img width="468" height="63" alt="image" src="https://github.com/user-attachments/assets/7aaf0be7-abbf-4211-8b32-bbded17e1049" />
Finally, we have the "Replay Points!" button. This button will begin the process of moving Sunshine's camera to your defined Points! <br/> <br/>
**IMPORTANT 1**: Sunshine's camera will fight with SMSCT, which makes everthing look jittery and bad! SMSCT automatically "blocks" the code in Sunshine responsible for doing this, however, since
Dolphin doesn't expect an outside program to change Sunshine's code, it may not react! In order to fix this, you must click [ Dolphin -> JIT -> Clear Cache ] _after_ you've either already started
a Point reply, or after you've enabled "Preview Point." You should only have to do this once, unless you click the "Restore Camera" button, more on that below. <br/> <br/>
**IMPORTANT 2**: Currently, the SMS-Camera-Tool window will hang
while it's replaying back your points due to being hastily coded. It'll return to being usable once it's done playing your Points back. 

### Restore Camera
<img width="459" height="49" alt="image" src="https://github.com/user-attachments/assets/0257ab64-bd2f-430f-b2fc-f242f72bf036" />
The "Restore Camera" button will restore vanilla functionality to Sunshine's camera. Just like with getting the camera to work with the "Replay Points!" button, you have to clear the JIT cache
to get this button to work.

### Misc
Up top, there's a standard toolbar with saving and loading functionality, as well as other self explanitory buttons.


## Building
This is a Godot 4.6.2 project. Download the project, then import it through the Godot launcher. You will need to install the [https://github.com/niklas2902/py4godot
](Py4Godot) addon. You should then be able to build it like any normal Godot project, but if that's not the case, please open an issue here on the Github.
