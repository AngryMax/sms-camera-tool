##### Previous Beta release: Beta 1.0.1 (b1.0.1)
# SMS Camera Tool Beta 2.0.0 (b2.0.0) Changelog

- General changes:
  - Renamed "Points" to "Keyframes".
  - "Point" now refers to Camera Position and Target Position.
  - Removed the "Fix Camera" button. SMSCT will now automatically do that once Preview Mode is disabled, or a Playback has finished. The camera will still not immediately fix itself because of JIT caching.
  - The GUI got a bit of reorganization, but nothing drastic.
  - ***Due to savefile changes, b1.0.1 saves will not be compatabile with b2.0.0 saves!***

- Added a 3D View where you can see you can visually see each Keyframe's Points.
  - Points can be moved in the 3D view by dragging them or the colord arrows attached to them.
  - Hold right click to enable moving around in the 3D View with WASD + E to move up, and Q/LCtrl to move down.
  - In the bottom left corner of the screen is a 3D compass that shows you your camera's orientation. It can be clicked to face the camera towards specific +/- axes.

- Implemented an actual easing system, with the selection options "No Easing," "Ease In," "Ease Out," and "Ease in and Out."
  - Easing, like Transition Time, belongs to Keyframe A (when transitioning from Keyframe A to B). This means that the final Keyframe's Easing value is meaningless!

- Added tons of toolbar settings!
  - ***File***:
      - **Save**: saves to your last Saved As or Opened file. No more having to select a file every time you want to save! Yippee!
  - ***Edit***:
      - **Undo**: works as any undo feature you'd expect! You can undo Point transforms, general Keyframe edits, and the deletion/addition of Keyframes!
      - **Redo**: the Yang to Undo's Yin.
      - **Settings**: opens a settings menu. Currently only has one option, which disables the advanced shaders that are used for the Camera Target and Position representations during playback (more on that later)
  - ***Tools***:
    - **Enable Snapping: when enabled, dragged Points in the 3D View will snap to other, nearby Points
    - **Camera Point Follows Editor Cam: when enabeled, the Camera Position belonging to the currently selected Keyframe will copy from the 3D View's camera position. Handy when used with Preview Keyframe.
    - **Target Point Follows Editor Cam**: when enabled, the Target Position belonging to the currently selected Keyframe will copy from the 3D View's camera position. Handy when used with Preview Keyframe.
  - ***View***
    - **Show Grid**: when disabled, makes the grid shown in the 3D View invisible.
    - **Show Axes**: when disabled, makes the X, Y, and Z axes lines in the 3D View invisible.
    - **Always Show Targets**: when enabled, makes Target Points for unselected Keyframes visible (only the Target Point for the current selected Keyframe is visible by default)
    - **Reset Camera**: resets the 3D View's camera back to its original position on startup.
    - **Go to selected Keyframe**: brings the 3D View's camera to the Camera Position Point of the currently selected Keyframe.

- Added keyboard shortcuts!
  - ***Toolbar shortcuts***:
    - **Ctrl + S** - Save (or Save As if no file is currently open).
    - **Ctrl + Shift + S** - Save As.
    - **Ctrl + Z** - Undo.
    - **Ctrl + Shift + Z** or **Ctrl + Y** - Redo.
    - **Ctrl + N** - Open a new file.
    - **Ctrl + O** - Open a saved file.
  - ***Keyframe Editor shortcuts**:
    - **N** - Add Keyframe.
    - **Delete** or **Backspace** - Delete the current Keyframe.
    - **Arrow Key Right** or **L** - Select the next Keyframe (wraps around).
    - **Arrow Key Left** or **J** - Select the previous Keyframe (wraps around).
    - **Shift + Arrow Key Right** or **Shift + L** - Select the last Keyframe.
    - **Shift + Arrow Key Left** or **Shift + J** - Select the first Keyframe.

- Fixed the "size 2 fish" bug
