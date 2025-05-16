package game

import rl "vendor:raylib"

drawBox :: proc(x: f32, y: f32, color := rl.BLACK , w: f32 = 1, h: f32 = 1) {
	rl.DrawRectangleRec(
		rl.Rectangle { x = x, y = y, width = w, height = h },
		color
	)
}
