package game

import rl "vendor:raylib"

import "core:fmt"
import "core:net"
import "core:math/rand"
import "core:math/linalg"

Tile :: struct {
	color: rl.Color,
	position: [2]int
}

testiles := []Tile {
	// { rl.BLACK, [2]int { 0, -1 } },
	// { rl.RED,   [2]int { 1, 1 } },
	// { rl.BLACK, [2]int { 2, 3 } },
	// { rl.BLACK, [2]int { 3, 3 } },
	// { rl.BLACK, [2]int { 5, 1 } },
	// { rl.BLACK, [2]int { 6, 1 } },
	// { rl.BLACK, [2]int { 6, 2 } },
	// { rl.BLACK, [2]int { 9, 5 } },
	// { rl.BLACK, [2]int { 10, 5 } },
	// { rl.BLACK, [2]int { 11, 5 } },
	// { rl.BLACK, [2]int { 12, 5 } },
	// { rl.BLACK, [2]int { 12, 7 } },
	// { rl.BLACK, [2]int { 12, 8 } },
	// { rl.BLACK, [2]int { 12, 9 } },
	// { rl.BLACK, [2]int { 12, 10 } },
	// { rl.BLACK, [2]int { 12, 11 } },
	// { rl.BLACK, [2]int { 12, 12 } },
	// { rl.BLACK, [2]int { 12, 13 } }
	{ rl.BLACK, [2]int { -1, 1 } },
	{ rl.BLACK, [2]int { -1, 0 } },
	{ rl.BLACK, [2]int { -1, -1 } },
	{ rl.BLACK, [2]int { 0, -1 } },
	{ rl.BLACK, [2]int { 1, -1 } },
	{ rl.BLACK, [2]int { 2, -1 } },
	{ rl.BLACK, [2]int { 3, -1 } },
	{ rl.BLACK, [2]int { 4, -1 } },
	{ rl.BLACK, [2]int { 5, -1 } },
	{ rl.BLACK, [2]int { 6, -1 } },
	{ rl.BLACK, [2]int { 7, -1 } },
	{ rl.BLACK, [2]int { 8, -1 } },
	{ rl.BLACK, [2]int { 9, -1 } },
	{ rl.BLACK, [2]int { 10, -1 } },
	{ rl.BLACK, [2]int { 11, -1 } },
	{ rl.BLACK, [2]int { 12, -1 } },
	{ rl.BLACK, [2]int { 12, 0 } },
	{ rl.BLACK, [2]int { 12, 1 } },
	{ rl.BLACK, [2]int { 12, 2 } },
	{ rl.BLACK, [2]int { 12, 3 } },
	{ rl.BLACK, [2]int { 12, 4 } },
	{ rl.BLACK, [2]int { 12, 5 } },
	{ rl.BLACK, [2]int { 12, 6 } },
	{ rl.BLACK, [2]int { 12, 7 } },
	{ rl.BLACK, [2]int { 12, 8 } },
	{ rl.BLACK, [2]int { 12, 9 } },
}

Player :: struct {
	position: [2]f32,
	velocity: [2]f32,
	motion: MotionState,
	animation: AnimationState
}

State :: struct {
	tiles: []Tile,
	player: Player,
	assets: struct {
		fops: SpriteSheet
	}
}

game :: proc() {
	gameState := State {
		tiles = testiles
	}
	
	rl.SetTraceLogLevel(.WARNING)
	rl.SetConfigFlags({ .WINDOW_RESIZABLE })
	rl.InitWindow(1900, 900, "SWGRedux")
	defer rl.CloseWindow()

	rl.SetExitKey(.KEY_NULL)
	rl.SetTargetFPS(120)

	onResize()
	// rl.InitAudioDevice()

	gameState.assets.fops = loadFopsSheet()

	for !rl.WindowShouldClose() {
		updateUI()
		if rl.IsKeyPressed(.R) {
			gameState.player = {
				position = { 0, 0 },
				velocity = { 0, 0 }
			}
		}
		update(&gameState)
		draw(
			&gameState,
			drawWorld,
			drawHUD,
			drawPostFx
		)
	}
}

@(private)
drawWorld :: proc(state: ^State) {
	for tile in state.tiles {
		drawBox(f32(tile.position.x), f32(tile.position.y), tile.color)
	}
	// drawBox(state.player.position.x, state.player.position.y, rl.GREEN)
	drawFrame(
		state.assets.fops,
		animationFrame(&state.player.animation),
		state.player.motion.direction == .LEFT,
		state.player.position
	)
}

@(private)
drawHUD :: proc(state: ^State) {
	rl.DrawFPS(10, 10)
	// screenspace hud

	rl.BeginMode2D(camera)

	// projection
	rl.EndMode2D()
}

@(private)
drawPostFx :: proc(rt: rl.RenderTexture2D) {
}

@(private)
update :: proc(state: ^State) {
	updateControls()
	state.player.motion = updateKinetics(state)
	updateAnimation(&state.player.animation, &state.player.motion)
}
