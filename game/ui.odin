package game

import rl "vendor:raylib"

import "core:fmt"
import "core:strings"
import "core:math"


windowSize := [2]i32 { 640, 480 }
windowSizeF :: proc() -> [2]f32 {
	return [2]f32 { f32(windowSize.x), f32(windowSize.y) }
}

camera := rl.Camera2D {
	offset = windowSizeF() * .32,
	target = rl.Vector2 {0, 0},
	rotation = 0.0,
	zoom = 42.0,
}
pointer: rl.Vector2

@(private)
rt: rl.RenderTexture2D
@(private)
rtLoaded := false

onResize :: proc() {
	windowSize.x = rl.GetScreenWidth()
	windowSize.y = rl.GetScreenHeight()
	if rtLoaded do rl.UnloadRenderTexture(rt)
	rt = rl.LoadRenderTexture(windowSize.x, windowSize.y)
	rtLoaded = true
}

updateUI :: proc() {
	if rl.IsWindowResized() do onResize()
	dt := rl.GetFrameTime()
	pointer = rl.GetScreenToWorld2D(rl.GetMousePosition(), camera)
}

draw :: proc(
	gameState: ^State,
	world: proc(gameState: ^State),
	hud: proc(gameState: ^State),
	pfx: proc(tex: rl.RenderTexture2D),
	background: Maybe(proc()) = nil
) {
	rl.BeginTextureMode(rt)
		rl.ClearBackground(rl.WHITE)
		rl.BeginMode2D(camera)

		back, backSet := background.?
		if backSet do back()

		world(gameState)

		rl.EndMode2D()

		hud(gameState)
	rl.EndTextureMode()

	pfx(rt)

	rl.BeginDrawing()
		rl.DrawTextureRec(
			rt.texture,
			{ 0, 0, f32(rt.texture.width), f32(rt.texture.height) },
			{ 0, 0 }, rl.WHITE
		)
	rl.EndDrawing()
}
