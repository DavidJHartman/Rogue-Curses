extends Control

@export var sync_lost_label : Label
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sync_lost_label.visible = false
	SyncManager.sync_lost.connect(_on_SyncManager_sync_lost)
	SyncManager.sync_regained.connect(_on_SyncManager_sync_regained)
	SyncManager.sync_error.connect(_sync_lost)

func _on_SyncManager_sync_lost() -> void:
	sync_lost_label.visible = true

func _on_SyncManager_sync_regained() -> void:
	sync_lost_label.visible = false

func _sync_lost() -> void:
	sync_lost_label.visible = false
