extends PopupPanel

var _origStr: String
var _websiteStr = "[you_REALLY_shouldnt_see_this]"

func _ready() -> void:
	_origStr = %PromptText.text

func setWebsiteString(website: String) -> void:
	_websiteStr = website
	website = "[b]" + website + "[/b]"
	%PromptText.text = _origStr.replace("[you_shouldnt_see_this]", website)
	%PromptText.push_bold()


func _on_yes_button_pressed() -> void:
	OS.shell_open(_websiteStr)
	hide()


func _on_no_button_pressed() -> void:
	hide()
