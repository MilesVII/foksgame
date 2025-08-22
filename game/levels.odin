package game

import rl "vendor:raylib"

import "assets"
import "utils"

import "core:math/rand"

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

	for tm in state.tiles do delete(tm.tiles)
	clear(&state.tiles)

	w := levelData.width
	for layer in levelData.layers {
		tm := Tilemap {
			size = { layer.width, layer.height },
			offset = { f32(layer.x), f32(layer.y) },
			tiles = make([]u8, layer.width * layer.height),
			dualgrid = make([][2]int, 2 * (layer.width + 1) * (layer.height + 1)),
			rnd = make([]int, 2 * (layer.width + 1) * (layer.height + 1))
		}
		assert(len(tm.tiles) == len(layer.data))

		for t, i in layer.data {
			x := i % layer.width + layer.x
			y := i / layer.width + layer.y

			#partial switch TILE_TYPE(t) {
				case .EMPTY:
				case .SOLID: {
					tm.tiles[i] = 1
				}
				case .FINISH:
				case .SPAWN: {
					state.player.position = { f32(x), f32(y - 1) }
				}
			}
		}

		inBounds :: proc(at: [2]int, size: [2]int) -> bool {
			return at.x >= 0 && at.y >= 0 && at.x < size.x && at.y < size.y
		}

		for y in 0..<layer.height + 1 do for x in 0..<layer.width + 1 {
			w := layer.width
			picks := [4][2]int {
				({ x, y } + {  0, -1 }),
				({ x, y } + { -1, -1 }),
				({ x, y } + { -1,  0 }),
				({ x, y } + {  0,  0 })
			}
			ne := inBounds(picks[0], tm.size) ? tm.tiles[utils.ix2dv(picks[0], w)] == 1 : false
			nw := inBounds(picks[1], tm.size) ? tm.tiles[utils.ix2dv(picks[1], w)] == 1 : false
			sw := inBounds(picks[2], tm.size) ? tm.tiles[utils.ix2dv(picks[2], w)] == 1 : false
			se := inBounds(picks[3], tm.size) ? tm.tiles[utils.ix2dv(picks[3], w)] == 1 : false

			stix := (
				(ne ? 0b0001 : 0) +
				(nw ? 0b0010 : 0) +
				(sw ? 0b0100 : 0) +
				(se ? 0b1000 : 0)
			)
			ix := utils.ix2d(x, y, layer.width + 1)
			tm.dualgrid[ix] = utils.pos2dv(int(stix), 4)
			tm.rnd[ix] = rand.int_max(2)
		}

		append(&state.tiles, tm)
	}
}

@(private="file")
setTileTypes :: proc() {

}