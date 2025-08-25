package assets

import rl "vendor:raylib"

import "core:fmt"
import "core:encoding/json"
import "core:os"

@(private="file")
ASS_FOPS :: "./assets/foks-sheet.png"
@(private="file")
ASS_STON :: []cstring {
	"./assets/gfx/16x4x4_solid_template.png",
	"./assets/gfx/16x4x4_solid_template_red.png",
	"./assets/gfx/16x4x4_solid_template_cyan.png"
}

Assets :: struct {
	fops: SpriteSheet,
	ston: []Atlas,
	bg: []rl.Texture
}

SpriteSheetGrid :: struct {
	tileSize: [2]int,
	tileCount: [2]int
}

SpriteSheet :: struct {
	texture: rl.Texture2D,
	tileSize: [2]int,
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
	fops := loadFopsSheet()
	stonAtlasi := make([]Atlas, len(ASS_STON))
	for path, i in ASS_STON do stonAtlasi[i] = atlas(path, { { 16, 16 }, { 4, 4 } })

	return {
		fops = fops,
		ston = stonAtlasi,
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
	return SpriteSheet { tex, { 22, 22 }, { 5, 14, 8, 11, 1 } }
}

loadLevel :: proc(path: string) -> (ld: LevelData, ok: bool) {
	bytes, fOk := os.read_entire_file(path)
	if !fOk do return ld, false

	e := json.unmarshal(bytes, &ld, .JSON)
	
	if e != nil do return ld, false
	return ld, true
}
