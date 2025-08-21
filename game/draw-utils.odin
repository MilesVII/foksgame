package game

import rl "vendor:raylib"

import "assets"
import "utils"

import "core:math/linalg"

drawBox :: proc(x: f32, y: f32, color := rl.BLACK , w: f32 = 1, h: f32 = 1) {
	rl.DrawRectangleRec(
		rl.Rectangle { x = x, y = y, width = w, height = h },
		color
	)
}

drawTilemap :: proc(state: ^State, tilemap: ^Tilemap) {
	origin := linalg.array_cast(tilemap.offset, f32)

	for dualTile, ix in tilemap.dualgrid {
		x, y := utils.pos2d(ix, tilemap.size.x + 1)
		drawFrame(state.assets.ston, dualTile, false, origin + { f32(x) - .5, f32(y) - .5 })
	}
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
