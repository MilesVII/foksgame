package game

import rl "vendor:raylib"

import "core:fmt"
import "core:math"
import "core:math/linalg"

import "utils"

@(private="file")
GRAV_FORS    := f32(.06) / 32
@(private="file")
JUMP_FORS    := f32(1.1) / 32
@(private="file")
MOVE_FORS    := f32(.17) / 32
@(private="file")
BOUNCE_COEF  := f32(.3) / 32
@(private="file")
BOUNCE_EPS   := f32(.00001)
@(private="file")
SLIDE_EPS    := f32(.00001)
@(private="file")
FRICTION_GND := f32(.03)
@(private="file")
FRICTION_AIR := f32(.03)

@(private)
updateKinetics :: proc(state: ^State) {
	dt := rl.GetFrameTime() * 1000

	// create deltaV from input
	fors: [2]f32
	if controls.left do fors.x -= MOVE_FORS * dt
	if controls.rite do fors.x += MOVE_FORS * dt

	// kill gravity if gripping
	gripped := false
	if fors.x != 0 {
		gripADX := allowedDisplacement(state.player.position, fors, state.tiles, true)
		gripped = gripADX.distance == 0
	}
	standADY := allowedDisplacement(state.player.position, { 0, -1 }, state.tiles, false)
	standing := standADY.distance == 0

	// apply gravity in free fall
	if !gripped && !standing do fors.y -= GRAV_FORS * dt

	// friction dampening
	friction := (standing ? FRICTION_GND : FRICTION_AIR) * dt
	if abs(state.player.velocity.x) < SLIDE_EPS do state.player.velocity.x = 0
	fors.x += state.player.velocity.x * friction * -1

	// modify velocity on jump
	if controls.jump {
		state.player.velocity.y = 0
		if gripped {
			fors += {
				JUMP_FORS * 1.7 * math.sign(fors.x) * -1,
				JUMP_FORS * .8
			}
		} else do fors.y += JUMP_FORS * dt
	}

	intendedDisplacement := state.player.velocity + fors

	adx := allowedDisplacement(state.player.position, intendedDisplacement, state.tiles, true)
	fdx := utils.signedClamp(intendedDisplacement.x, adx.distance)

	ady := allowedDisplacement(state.player.position, intendedDisplacement, state.tiles, false)
	fdy := utils.signedClamp(intendedDisplacement.y, ady.distance)

	vBounce := ady.distance == abs(fdy)
	if vBounce {
		if ady.distance > BOUNCE_EPS {
			state.player.velocity.y *= -BOUNCE_COEF
		} else {
			state.player.velocity.y = 0
			fors.y = 0
		}
	}

	state.player.velocity += fors
	state.player.position += { fdx, fdy }
}

CastResult :: struct {
	nearest: Tile,
	tileFound: bool,
	distance: f32
}
allowedDisplacement :: proc(origin: [2]f32, direction: [2]f32, tileset: []Tile, isXAxis: bool) -> CastResult {
	bumper: f32
	originProjection: [2]f32
	maxDisplacement := math.INF_F32
	nearestTile: Tile
	tileFound := false

	if isXAxis {
		bumper = math.sign(direction.x) > 0 ? origin.x + 1 : origin.x
		originProjection = { origin.y, origin.y + 1 }
	} else {
		bumper = math.sign(direction.y) > 0 ? origin.y + 1 : origin.y
		originProjection = { origin.x, origin.x + 1 }
	}

	for tile in tileset {
		tileOrigin := linalg.array_cast(tile.position, f32)
		tileProjection: [2]f32
		onCourse: bool

		if isXAxis {
			tileProjection = { tileOrigin.y, tileOrigin.y + 1}
			onCourse = math.sign(direction.x) == math.sign(tileOrigin.x - origin.x)
		} else {
			tileProjection = { tileOrigin.x,  tileOrigin.x + 1}
			onCourse = math.sign(direction.y) == math.sign(tileOrigin.y - origin.y)
		}


		if (rangeOverlap(originProjection, tileProjection) && onCourse){
			tileBumper: f32
			if isXAxis {
				tileBumper = math.sign(direction.x) > 0 ? tileOrigin.x : tileOrigin.x + 1
			} else {
				tileBumper = math.sign(direction.y) > 0 ? tileOrigin.y : tileOrigin.y + 1
			}
			distance := abs(tileBumper - bumper)
			if distance < maxDisplacement {
				maxDisplacement = distance
				nearestTile = tile
				tileFound = true
			}
		}
	}

	return {
		nearest = nearestTile,
		distance = maxDisplacement,
		tileFound = tileFound
	}
}

rangeOverlap :: proc(r0: [2]f32, r1: [2]f32) -> bool {
	return r0[1] > r1[0] && r0[0] < r1[1]
}
