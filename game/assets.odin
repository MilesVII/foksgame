package game

import rl "vendor:raylib"

import "core:fmt"

@(private="file")
ASS_FOPS :: "./assets/foks-sheet.png"

Assets :: struct {
	fops: SpriteSheet,
	bg: []rl.Texture
}

SpriteSheet :: struct {
	texture: rl.Texture2D,
	tileSize: int,
	rowSizes: []int
}

loadAssets :: proc() -> Assets {
	return {
		fops = loadFopsSheet(),
		bg = loadBgSet("./assets/bg/sky/", 9, "png")
	}
}

loadBgSet :: proc(path: string, $count: i32, ext: string) -> []rl.Texture {
	images := make([]rl.Texture, count)
	for i in 0..<count {
		images[i] = rl.LoadTexture(fmt.caprint(path, i, ".", ext, sep = ""))
	}
	return images
}

@(private="file")
loadFopsSheet :: proc() -> SpriteSheet {
	tex := rl.LoadTexture(ASS_FOPS)
	return SpriteSheet { tex, 22, { 5, 14, 8, 11, 1 } }
}

drawFrame :: proc(sheet: SpriteSheet, tile: [2]int, flipX: bool, at: [2]f32, size := [2]f32 { 1, 1 }) {
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
