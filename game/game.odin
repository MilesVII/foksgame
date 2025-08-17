package game

import rl "vendor:raylib"

import "assets"

import "core:fmt"
import "core:net"
import "core:math"
import "core:math/rand"
import "core:math/linalg"

Tile :: struct {
	color: rl.Color,
	position: [2]int
}

Player :: struct {
	position: [2]f32,
	velocity: [2]f32,
	motion: MotionState,
	animation: AnimationState
}

State :: struct {
	tiles: [dynamic]Tile,
	player: Player,
	assets: assets.Assets
}

game :: proc() {
	gameState: State
	
	rl.SetTraceLogLevel(.WARNING)
	rl.SetConfigFlags({ .WINDOW_RESIZABLE })
	rl.InitWindow(windowSize.x, windowSize.y, "fops")
	defer rl.CloseWindow()

	rl.SetExitKey(.KEY_NULL)
	rl.SetTargetFPS(120)

	onResize()
	// rl.InitAudioDevice()

	gameState.assets = assets.loadAssets()
	loadLevel(&gameState, 0)

	for !rl.WindowShouldClose() {
		updateUI(&gameState)

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
			drawPostFx,
			drawBack
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
drawPostFx :: proc(state: ^State, rt: rl.RenderTexture2D) {
}

@(private)
drawBack :: proc(state: ^State) {
	slide := camera.target.x / windowSizeF.x * -10
	slideStep := f32(1) / f32(len(state.assets.bg))
	for t, i in state.assets.bg do drawPaxFrame(t, slide * slideStep * f32(i))
}

@(private)
drawPaxFrame :: proc(t: rl.Texture, offset: f32) {
	offset := offset - math.trunc(offset)

	tSize := [2]f32 { f32(t.width), f32(t.height) }
	scale := max(windowSizeF.x / tSize.x, windowSizeF.y / tSize.y)
	scaledW := tSize.x * scale
	centering := (tSize * scale - windowSizeF) * .5
	slide := [2]f32 { scaledW * offset, 0 }

	rl.DrawTextureEx(t, slide - centering + { scaledW * -1, 0 }, 0, scale, rl.WHITE)
	rl.DrawTextureEx(t, slide - centering + { scaledW *  0, 0 }, 0, scale, rl.WHITE)
	rl.DrawTextureEx(t, slide - centering + { scaledW *  1, 0 }, 0, scale, rl.WHITE)
}

@(private)
update :: proc(state: ^State) {
	updateControls()
	state.player.motion = updateKinetics(state)
	updateAnimation(&state.player.animation, &state.player.motion)
}
