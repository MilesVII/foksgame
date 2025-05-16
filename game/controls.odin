package game

import rl "vendor:raylib"

import "core:fmt"

Controls :: struct {
	left: bool,
	rite: bool,
	jump: bool,
	dash: bool
}
@(private="file")
KeyMapping :: []rl.KeyboardKey

@(private="file")
mappings := map[string]KeyMapping {
	"left" = { .LEFT, .A },
	"rite" = { .RIGHT, .D },
	"jump" = { .UP, .W, .SPACE }
}

controls: Controls

@(private="file")
KeyStateKind :: enum { Down, Pressed }

@(private="file")
key :: proc(key: string, stateKind: KeyStateKind) -> bool {
	mapping, found := mappings[key]
	if !found do return false
	for code in mapping {
		active := stateKind == .Down ? rl.IsKeyDown(code) : rl.IsKeyPressed(code)
		if active do return true
	}
	return false
}

updateControls :: proc() {
	controls.left = key("left", .Down)
	controls.rite = key("rite", .Down)
	controls.jump = key("jump", .Pressed)
	controls.dash = key("dash", .Pressed)
}
