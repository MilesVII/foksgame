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
key :: proc(oldState: bool, key: string, stateKind: KeyStateKind) -> bool {
	mapping, found := mappings[key]
	if !found do return false
	active := oldState
	for code in mapping {
		if stateKind == .Down {
			if rl.IsKeyPressed(code) do active = true
			if rl.IsKeyReleased(code) do active = false
		} else do active = rl.IsKeyPressed(code)
		if active do return true
	}
	return false
}

updateControls :: proc() {
	controls.left = key(controls.left, "left", .Down)
	controls.rite = key(controls.rite, "rite", .Down)
	controls.jump = key(controls.jump, "jump", .Pressed)
	controls.dash = key(controls.dash, "dash", .Pressed)
}
