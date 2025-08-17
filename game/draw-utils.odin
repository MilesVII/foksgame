package game

import "assets"
import rl "vendor:raylib"

drawBox :: proc(x: f32, y: f32, color := rl.BLACK , w: f32 = 1, h: f32 = 1) {
	rl.DrawRectangleRec(
		rl.Rectangle { x = x, y = y, width = w, height = h },
		color
	)
}

drawFrame :: proc(sheet: assets.SpriteSheet, tile: [2]int, flipX: bool, at: [2]f32, size := [2]f32 { 1, 1 }) {
	source := rl.Rectangle {
		x = f32(tile.x * sheet.tileSize),
		y = f32(tile.y * sheet.tileSize),
		width = f32(sheet.tileSize) * (flipX ? -1 : 1),
		height = f32(sheet.tileSize)
	}
	destination := rl.Rectangle {
		x = at.x,
		y = at.y,
		width = size.x,
		height = size.y,
	}
	rl.DrawTexturePro(
		sheet.texture,
		source, destination,
		{ 0, 0 },
		0, rl.WHITE
	)
}
