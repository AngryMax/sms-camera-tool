extends FileDialog
class_name FileDialogCustom

@export var okButton: Button

var _invalidFilePopup: PopupPanel

func _ready() -> void:
	_makeCustomConfirm()


func _makeCustomConfirm() -> void:
	# https://forum.godotengine.org/t/how-to-prevent-filedialog-confirm-under-certain-conditions/53180
	var origCallable: Callable = confirmed.get_connections()[0].get('callable')
	confirmed.disconnect(origCallable)
	
	var validFileMode := false
	match file_mode:
		FileDialog.FILE_MODE_SAVE_FILE:
			confirmed.connect(_on_save_confirm.bind(origCallable))
			validFileMode = true
			
	assert(validFileMode, "The only File Mode supported for FileDialogCustom is Save!")


### Signal Receive Funcs ###

func _on_save_confirm(origCallable: Callable):
	
	assert(okButton, "FileDialogCustom using FileDialogCustom Save needs to be assigned a button in the Inspector!")
	
	for child in get_children():
		if child.name == "InvalidFilePopup":
			_invalidFilePopup = child
	
	assert(_invalidFilePopup, "FileDialogCustom using FileDialogCustom Save needs to have a PopupPanel child!")
	
	okButton.connect("pressed", _on_invalid_ok_pressed)
	
	var file := current_file
	
	var invalidChars: String = "<>:\"/\\|?*"
	
	for i in invalidChars.length():
		var character = invalidChars[i]
		if file.contains(character):
			_invalidFilePopup.show()
			return
	
	origCallable.call()


func _on_invalid_ok_pressed():
	_invalidFilePopup.visible = false
