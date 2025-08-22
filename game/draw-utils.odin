package game

import rl "vendor:raylib"
import rlgl "vendor:raylib/rlgl"

import "assets"
import "utils"

import "core:math/linalg"
import "core:fmt"

drawBox :: proc(x: f32, y: f32, color := rl.BLACK , w: f32 = 1, h: f32 = 1) {
	rl.DrawRectangleRec(
		rl.Rectangle { x = x, y = y, width = w, height = h },
		color
	)
}

drawTilemap :: proc(state: ^State, atlasi: []assets.Atlas, tilemap: ^Tilemap) {
	origin := linalg.array_cast(tilemap.offset, f32) + [2]f32 { -.5, -.5 }

	rlgl.Begin(rlgl.TRIANGLES)
	rlgl.Color4ub(255, 255, 255, 255)
	for a, aix in atlasi {
		rlgl.SetTexture(a.texture.id)
	
		for dualTile, ix in tilemap.dualgrid {
			toff := utils.pos2dv(ix, tilemap.size.x + 1)
			if tilemap.rnd[ix] == aix do drawFrameTiled(a, dualTile, origin, toff)
		}
	}
	rlgl.End()
	rlgl.SetTexture(0)
}

drawFrame :: proc(sheet: assets.SpriteSheet, tile: [2]int, flipX: bool, at: [2]f32, size := [2]f32 { 1, 1 }) {
	source := rl.Rectangle {
		x = f32(tile.x * sheet.tileSize.x),
		y = f32(tile.y * sheet.tileSize.y),
		width = f32(sheet.tileSize.x) * (flipX ? -1 : 1),
		height = f32(sheet.tileSize.y)
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

@(private="file")
drawFrameTiled :: proc(atlas: assets.Atlas, tile: [2]int, origin: [2]f32, offset: [2]int, size := [2]f32 { 1, 1 }) {
	origin := origin + linalg.array_cast(offset, f32) * size

	vertesex := [4][2]f32 {
		origin + { 0, 0 } * size,
		origin + { 0, 1 } * size,
		origin + { 1, 1 } * size,
		origin + { 1, 0 } * size
	}
	uvData := atlas.uvs[utils.ix2dv(tile, atlas.tileCount.x)]
	uv := [4][2]f32 {
		({ 0, 0 } * uvData.size + uvData.origin),
		({ 0, 1 } * uvData.size + uvData.origin),
		({ 1, 1 } * uvData.size + uvData.origin),
		({ 1, 0 } * uvData.size + uvData.origin)
	}
	ixes := [6]int {
		1, 2, 0,
		2, 3, 0
	}

	for i in ixes {
		rlgl.TexCoord2f(uv[i].x, uv[i].y)
		rlgl.Vertex2f(vertesex[i].x, vertesex[i].y)
	}
}
