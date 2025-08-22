package assets

import rl "vendor:raylib"
import rlgl "vendor:raylib/rlgl"

import "../utils"

import "core:math/linalg"

@(private="file")
UV :: struct {
	origin: [2]f32,
	size: [2]f32
} 

// Atlas is a spritesheet with boundary around tiles preventing bleeding
Atlas :: struct {
	texture: rl.Texture2D,
	tileCount: [2]int,
	uvs: []UV
}

atlas :: proc(sheet: SpriteSheet) -> Atlas {
	a := Atlas {
		tileCount = { utils.arrMax(sheet.rowSizes), len(sheet.rowSizes) }
	}

	w := int(sheet.texture.width) + a.tileCount.x *  2
	h := int(sheet.texture.height) + a.tileCount.y * 2
	
	original := transmute([^][4]u8)rlgl.ReadTexturePixels(
		sheet.texture.id,
		sheet.texture.width, sheet.texture.height,
		i32(rlgl.PixelFormat.UNCOMPRESSED_R8G8B8A8)
	)
	
	oLen := sheet.texture.width * sheet.texture.height
	bordered := make([][4]u8, w * h)
	borderedTilesize := sheet.tileSize + { 2, 2 }

	for i in 0..<oLen {
		oPos := utils.pos2dv(int(i), int(sheet.texture.width))
		tPos := oPos / sheet.tileSize
		tSpace := oPos - tPos * sheet.tileSize

		target := tPos * borderedTilesize + ({ 1, 1 } + tSpace)
		src := original[i]
		bordered[utils.ix2dv(target, w)] = src

		ix :: proc(at: [2]int, off: [2]int, w: int) -> int {
			return utils.ix2dv(at + off, w)
		}
		if tSpace.x == 0 do bordered[ix(target, { -1, 0 }, w)] = src
		if tSpace.y == 0 do bordered[ix(target, { 0, -1 }, w)] = src
		highBound := sheet.tileSize - { 1, 1 }
		if tSpace.x == highBound.x do bordered[ix(target, { 1, 0 }, w)] = src
		if tSpace.y == highBound.y do bordered[ix(target, { 0, 1 }, w)] = src

		if tSpace.x == 0 && tSpace.y == 0 {
			bordered[ix(target, { -1, -1 }, w)] = src
		}
		if tSpace.x == highBound.x && tSpace.y == 0 {
			bordered[ix(target, { 1, -1 }, w)] = src
		}
		if tSpace.x == 0 && tSpace.y == highBound.y {
			bordered[ix(target, { -1, 1 }, w)] = src
		}
		if tSpace.x == highBound.x && tSpace.y == highBound.y {
			bordered[ix(target, { 1, 1 }, w)] = src
		}
	}

	texId := rlgl.LoadTexture(&(bordered[0][0]), i32(w), i32(h), i32(rlgl.PixelFormat.UNCOMPRESSED_R8G8B8A8), 1)

	a.texture = rl.Texture2D {
		id = texId,
		width =  i32(w),
		height = i32(h),
		format = .UNCOMPRESSED_R8G8B8A8,
		mipmaps = 1
	}

	a.uvs = make([]UV, a.tileCount.x * a.tileCount.y)

	for i in 0..<len(a.uvs) {
		tPos := utils.pos2dv(i, a.tileCount.x)
		sheetSize  := linalg.array_cast( [2]int { w, h }, f32)
		origin     := linalg.array_cast(borderedTilesize * tPos, f32) / sheetSize
		normalGrid := linalg.array_cast(borderedTilesize, f32) / sheetSize
		normalTile := linalg.array_cast(sheet.tileSize,   f32) / sheetSize
		normalBorderOffset := (normalGrid - normalTile) * .5
		a.uvs[i] = UV {
			origin = origin + normalBorderOffset,
			size   = normalTile
		}

	}

	return a
}
