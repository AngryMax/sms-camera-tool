# SMS Camera Tool Beta 2.0.0

SMSCT is a tool used for getting clean, on-a-rail camera shots in Super Mario Sunshine. It's intended use is for making videos or mod trailers, but it's pretty fun to mess around with too! <br/><br/>

SMSCT Beta 2.0.0 has changed a LOT since the last release, Beta 1.0.1! Read the complete changelog [here!](INSERT CHANGELOG LINK HERE!)<br/><br/>

## Installation

Just navigate to the downloads page, and download the latest version. Unzip the contents into a folder, and you should be able to just run it! Tt should be compatible with any NTSC-U version of Sunshine, 
even if it's modded (as long as the mod doesn't do anythign *too* funky with the camera.

## How to use

If you'd prefer to watch a video, [here's a tutorial on how to use SMSCT](https://youtu.be/fE53T9BcNkA) | OLD! New tutorial coming very soon!

## Launch
First, you need to launch your legally obtained copy of Sunshine via Dolphin Emulator. Once you're in the game, you can then run SMS-Camera-Tool.exe. As of current version, it *must* be in this order. *NOTE: your first launching may take a bit of time, since your antivirus will probably want to scan it!*

## Overview
SMSCT works by storing both the Camera's position and the Camera's target together as a single "Keyframe." You can save multiple of these Keyframes so that later you can play Sunshine's camera back over these Keyframes, in order.

## Tour
### General Layout
SMSCT's window is split into four main sections: The 3D View, the Keyframe Editor, the Toolbar, and the Camera Orientation Widget.
<img width="960" height="568" alt="image" src="https://github.com/user-attachments/assets/789b9af0-78ef-4056-9135-5eeb085cef73" />
*Note that the 3D viewport is not highlighted, since it's basically just the whole window!*

### The 3D Viewport
The 3D View offers a visual representation of where your saved Keyframe's Camera Position and Camera Target are. More info about what that means in the [Keyframe Editor section](https://github.com/AngryMax/sms-camera-too#Keyframe-Editor)

Your Keyframe's Camera Position and Target are represented by these little icons, called "**Points**":
<img width="956" height="537" alt="image" src="https://github.com/user-attachments/assets/62b438e5-44af-4486-af16-7e06e7995cc0" />
*Tip! This Keyframe is **unselected**, which usually means that its Camera Target Point is invisible! You can make Camera Target Points that belong to unselected Keyframes always visible by checking "Always Show Targets" in the Toolbar's View menu!*<br/>

However, by defualt, your first Keyframe will be selected, and when a Keyframe is selected, its Points will have these arrow handles. By clicking and dragging these handles, you can move your Points along the handle's axis! Alternatively, by clicking on a Point to select it, upon which it'll turn green, you can drag the Point around to move it horizontally.

INSERT ARROW DRAGGING GIF
INSERT POINT DRAGGING GIF

You may want to move around in the 3D View. To do so, hold right click, then you can fly around with WASD and mouse controls, along with E to move up, or Q/LCtrl to move down.

INSERT GIF OF MOVING WITH INPUT DISPLAY
*Tip! If you get lost: in the Toolbar, go to View, then either click "Reset Camera," or "Go to selected Keyframe."*

### The Keyframe Editor
Editing your singular Keyframe in the 3D View is all well and good, but if you want to actually engage with the intended purpose of SMSCT, then you will need to know how to use the Keyframe editor! At first glance, it may look complex, but it's actually pretty simple! Starting from top to bottom, left to right, here's a brief description of what everything does:

- "Current Keyframe" is your currently selected Keyframe. The number will correspond with the number that appears next to the Keyframe's Points in the 3D View.
- "Add Keyframe" adds a new Keyframe. The newly added Keyframe will always be the last one. Inserting Keyframes inbetween other Keyframes/Keyframe reordering is yet to be added!
- "Duplicate Keyframe" adds a duplicate of your currently selected Keyframe as the last Keyframe. Inserting Keyframes inbetween other Keyframes/Keyframe reordering is yet to be added!
<img width="439" height="80" alt="image" src="https://github.com/user-attachments/assets/af1aa8fb-6937-4712-9660-fcec4141b3ec" /><br/>


- "Position" is your Keyframe's Camera Position, ordered by X, Y, then Z.
<img width="341" height="115" alt="image" src="https://github.com/user-attachments/assets/8be3c41b-3848-4380-aea6-490347a48056" /><br/>


- "Target" is the position of your Keyframe's Camera Target, ordered by X, Y, then Z.
<img width="342" height="114" alt="image" src="https://github.com/user-attachments/assets/1566d70d-a15e-43cd-bde7-7e3614b689f3" /><br/>

- The repeated buttons to the right of each coordinate axis for the Position and Target fields will copy value straight from Sunshine into their respective field. Pressing the target icon will copy from the position Sunshine's camera is targeting, and pressing the blue camera icon will copy from Sunshine's camera position. These buttons are especially handy with something like Better Sunshine Engine's noclip mode.
INSERT GIF OF COPYING VALUES FROM SUNSHINE

- "Copy ALL From Game" will directly copy Sunshine's Camera and Target positions into SMSCT's. You'll probably be using this button a lot!

- "Transition Time" is the time it takes in seconds for this Keyframe to transition to the next one during playback. *This means that the Transition Time for the last Keyframe is meaningless!*

- The dropdown that by defualt reads "No Easing" is your Keyframe's easing. Your options are "No Easing," "Ease In," "Ease Out," and "Ease in and Out." No easing means that the this Keyframe will move to the next Keyframe at a constant rate during playback, while the other options will make it speed up and slow down at different points.

- "Preview Keyframe" will update Sunshine's camera's position and target position to be that of your current Keyframe's. **IMPORTANT NOTE: Since Dolphin Emulator is not expecting and outside program to change Sunshine's code, in Dolphin you have to go to the JIT dropdown, then press "Clear Cache" in order for Sunshine's camera to not fight with SMSCT! As long as you don't load a savestate, restart the game, etc., you should only have to do this once, but only after you're already in SMSCT's Preview Mode!**

- "Delete Keyframe" will delete the current Keyframe.

- "Play Back Keyframes!" will play your Keyframes back, in order, in Super Mario Sunshine. **IMPORTANT NOTE: The same important note about the Preview Keyframe button applies here!** <br/>

### The Toolbar and Camera Orientation Widget
<br/>
- The Toolbar has most of the features you'd expect from a toolbar: saving and opening files, undo and redo, various info, and helpful settings and tools. Your standard keyboard shortcuts are also here, like ctrl + s, ctrl + z, etc.
 - The "Tools" dropdown in the Toolbar has 3 helpful features:
     - "Enable Snapping" makes Points dragged in the 3D View snap onto nearby Points.
     - "Camera Point Follows Editor Cam" continually brings the current Keyframe's Camera Position Point to the 3D Editors Camera
     - "Target Point Follows Editor Cam" continually brings the current Keyframe's Target Position Point to the 3D Editors Camera <br/>
     *Tip! By enabling Preview Keyframe, you can move Sunshine's Camera and/or Target Points around LIVE as you move around the 3D Viewport*
  - The other Toolbar dropdowns are all pretty self-explanitory, or have already been explained in a tip!
- The Camera Orientation Widget not only acts as a sort of 3D compass, but by clicking on the colored cube that corresponds to an axis and direction, you can orient your camera along a specific axis! In the future, this will also change the 3D View's camera to be orthogonal!



## Building
This is a Godot 4.6.2 project. Download the project, then import it through the Godot launcher. You will need to install the [Py4Godot
](https://github.com/niklas2902/py4godot) addon. You should then be able to build it like any normal Godot project, but if that's not the case, please open an issue here on the Github.

## Planned Features
I'd like to work more on this project. If I do, here's what you can expect: <br/>
- !! BCK importing and exporting.
- Cleaned up, easier to read GUI.
- A Keyframe list where you can select and reorder Keyframes.
- Grid snapping.
- Separately toggleable horizontal grid.
- Add FOV to Keyframes.
- Add camera tilt to Keyframes.
- Easing with more customization!
- A corner rounding option for each Keyframe.
- Orthogonal view option.
- Customizable hotkeys.
- Longshot, but perhaps a way to extract the current level's geometry data for the 3D View.
