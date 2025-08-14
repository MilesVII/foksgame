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
Mapping :: struct {
	name: string,
	keys: []rl.KeyboardKey
}
@(private="file")
mappings := []Mapping {
	{ "left", { .LEFT, .A } },
	{ "rite", { .RIGHT, .D } },
	{ "jump", { .UP, .W, .SPACE } },
	{ "dash", { } }
}

controls: Controls

@(private="file")
KeyStateKind :: enum { Down, Pressed }

@(private="file")
key :: proc(oldState: bool, key: string, stateKind: KeyStateKind) -> bool {
	found := false
	mapping: Mapping
	for m in mappings {
		if m.name == key {
			found = true
			mapping = m
		}
	}
	if !found do return false

	active := oldState
	for code in mapping.keys {
		if stateKind == .Down {
			down := rl.IsKeyPressed(code)
			up   := rl.IsKeyReleased(code)
			if down || up do return down
		} else {
			if rl.IsKeyPressed(code) do return true
		}
	}
	if stateKind == .Down do return oldState
	else do return false
}

updateControls :: proc() {
	controls.left = key(controls.left, "left", .Down)
	controls.rite = key(controls.rite, "rite", .Down)
	controls.jump = key(controls.jump, "jump", .Pressed)
	controls.dash = key(controls.dash, "dash", .Pressed)
}
