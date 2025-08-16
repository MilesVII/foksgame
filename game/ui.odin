package game

import rl "vendor:raylib"

import "utils"

import "core:fmt"
import "core:strings"
import "core:math"

@(private="file")
iv2fv :: proc(v: [2]i32) -> [2]f32 {
	return [2]f32 { f32(v.x), f32(v.y) }
}
windowSize := [2]i32 { 640, 480 }
windowSizeF: [2]f32
worldSpaceWindowSize: [2]f32
TILES_IN_SCREEN :: 16

camera := rl.Camera2D {
	target = rl.Vector2 {0, 0},
	rotation = 0.0,
}
pointer: rl.Vector2

@(private)
rt: rl.RenderTexture2D
@(private)
rtLoaded := false

onResize :: proc() {
	windowSize.x = rl.GetScreenWidth()
	windowSize.y = rl.GetScreenHeight()
	windowSizeF = iv2fv(windowSize)
	camera.zoom = windowSizeF.y / TILES_IN_SCREEN
	worldSpaceWindowSize = rl.GetScreenToWorld2D(windowSizeF, camera) - camera.target
	camera.offset = windowSizeF * .5

	if rtLoaded do rl.UnloadRenderTexture(rt)
	rt = rl.LoadRenderTexture(windowSize.x, windowSize.y)
	rtLoaded = true
}

updateUI :: proc(state: ^State) {
	if rl.IsWindowResized() do onResize()
	dt := rl.GetFrameTime()
	pointer = rl.GetScreenToWorld2D(rl.GetMousePosition(), camera)

	followPosition := state.player.position + .5
	followOffset := worldSpaceWindowSize * { .25, .25 }
	camera.target = utils.vClamp(camera.target, followPosition - followOffset, followPosition + followOffset)
}

draw :: proc(
	gameState: ^State,
	world: proc(gameState: ^State),
	hud: proc(gameState: ^State),
	pfx: proc(gameState: ^State, tex: rl.RenderTexture2D),
	background: proc(gameState: ^State)
) {
	rl.BeginTextureMode(rt)
		rl.ClearBackground(rl.WHITE)

		background(gameState)

		rl.BeginMode2D(camera)

		world(gameState)

		rl.EndMode2D()

		hud(gameState)
	rl.EndTextureMode()

	pfx(gameState, rt)

	rl.BeginDrawing()
		rl.DrawTextureRec(
			rt.texture,
			{ 0, 0, f32(rt.texture.width), f32(-rt.texture.height) },
			{ 0, 0 }, rl.WHITE
		)
	rl.EndDrawing()
}
