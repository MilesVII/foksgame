package game

import rl "vendor:raylib"

import "assets"

LEVEL_PATHS := []string {
	"./assets/levels/tutorial.json",
	"./assets/levels/shaft.json",
	"./assets/levels/jump.json",
	"./assets/levels/final.json"
}

TILE_TYPE :: enum int {
	EMPTY = 0,
	SOLID = 1,
	SPAWN = 2,
	FINISH = 3,
	TRIGGER = 4
}

loadLevel :: proc(state: ^State, id: i32) {
	levelData, ok := assets.loadLevel(LEVEL_PATHS[id])
	if !ok do return

	clear(&state.tiles)
	w := levelData.width
	for layer in levelData.layers {
		for t, i in layer.data {
			x := i % layer.width + layer.x
			y := i / layer.width + layer.y

			#partial switch TILE_TYPE(t) {
				case .EMPTY:
				case .SOLID: {
					append(&state.tiles, Tile {
						color = rl.BLACK,
						position = { x, y }
					})
				}
				case .FINISH: {
					append(&state.tiles, Tile {
						color = rl.RED,
						position = { x, y }
					})
				}
				case .SPAWN: {
					state.player.position = { f32(x), f32(y - 1) }
				}
			}
		}
	}
}
