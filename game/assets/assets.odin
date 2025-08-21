package assets

import rl "vendor:raylib"

import "core:fmt"
import "core:encoding/json"
import "core:os"

@(private="file")
ASS_FOPS :: "./assets/foks-sheet.png"
@(private="file")
ASS_STON :: "./assets/gfx/16x4x4_solid_template.png"

Assets :: struct {
	fops: SpriteSheet,
	ston: SpriteSheet,
	bg: []rl.Texture
}

SpriteSheet :: struct {
	texture: rl.Texture2D,
	tileSize: int,
	rowSizes: []int
}

LevelDataLayer :: struct {
	width: int,
	height: int,
	x: int,
	y: int,
	data: []int,
	name: string,
	id: int
}
LevelData :: struct {
	width: int,
	height: int,
	layers: []LevelDataLayer
}

loadAssets :: proc() -> Assets {
	return {
		fops = loadFopsSheet(),
		ston = loadStoneSheet(),
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

@(private="file")
loadStoneSheet :: proc() -> SpriteSheet {
	tex := rl.LoadTexture(ASS_STON)
	return SpriteSheet { tex, 16, { 4, 4, 4, 4 } }
}

loadLevel :: proc(path: string) -> (ld: LevelData, ok: bool) {
	bytes, fOk := os.read_entire_file(path)
	if !fOk do return ld, false

	e := json.unmarshal(bytes, &ld, .JSON)
	
	if e != nil do return ld, false
	return ld, true
}
