package game

import rl "vendor:raylib"

import "core:fmt"
import "core:math"
import "core:math/linalg"

import "utils"

@(private="file")
Config :: struct {
	GRAV_FORS   : f32,
	JUMP_IMP    : f32,
	UNGRIP_IMP  : [2]f32,
	WALK_FORS   : f32,
	FLY_FORS    : f32,
	BOUNCE_EPS  : f32,
	SLIDE_EPS   : f32,
	FRICTION_GND: f32,
	FRICTION_AIR: f32,
	FRICTION_GRP: f32,
	FORCE_UNGRIP: bool
}
@(private="file")
CFG :: Config {
	GRAV_FORS    = .4375,
	JUMP_IMP     = -.1002,
	UNGRIP_IMP   = { -.0788, -.1302 },
	WALK_FORS    = .42,
	FLY_FORS     = .28,
	BOUNCE_EPS   = .01,
	SLIDE_EPS    = .001,
	FRICTION_GND = 7.9,
	FRICTION_AIR = 6.9,
	FRICTION_GRP = 30,
	FORCE_UNGRIP = false
}

MotionStatePose :: enum {
	STAND, FALL, GRIP, RUN
}
MotionStateDirection :: enum {
	LEFT, RITE
}
MotionState :: struct {
	pose: MotionStatePose,
	direction: MotionStateDirection,
	landed: bool,
	poseChanged: bool,
	doubleJump: bool
}


@(private)
updateKinetics :: proc(state: ^State) -> MotionState {
	dt := rl.GetFrameTime()

	fors: [2]f32

	standADY := allowedDisplacement(state.player.position, { 0, math.sign(CFG.GRAV_FORS) }, state.tiles[:], false)
	standing := standADY.distance == 0
	
	controlFors := standing ? CFG.WALK_FORS : CFG.FLY_FORS
	if controls.left do fors.x -= controlFors * dt
	if controls.rite do fors.x += controlFors * dt
	
	gripped := false
	if fors.x != 0 && !standing {
		gripADX := allowedDisplacement(state.player.position, fors, state.tiles[:], true)
		gripped = state.player.velocity.y * math.sign(CFG.GRAV_FORS) > 0 && gripADX.distance == 0
	}

	if standing || gripped do state.player.motion.doubleJump = true

	// apply gravity in free fall
	if !standing do fors.y += CFG.GRAV_FORS * dt
	if gripped do fors.y -= state.player.velocity.y * CFG.FRICTION_GRP * dt

	// friction dampening
	friction := (standing ? CFG.FRICTION_GND : CFG.FRICTION_AIR) * dt
	if abs(state.player.velocity.x) < CFG.SLIDE_EPS do state.player.velocity.x = 0
	fors.x += state.player.velocity.x * friction * -1

	// modify velocity on jump
	if controls.jump && state.player.motion.doubleJump {
		if !standing && !gripped do state.player.motion.doubleJump = false
		state.player.velocity.y = 0
		if gripped {
			rite := math.sign(fors.x)
			if CFG.FORCE_UNGRIP {
				if rite > 0 do controls.rite = false
				if rite < 0 do controls.left = false
			}
			fors += CFG.UNGRIP_IMP * { rite, 1 }
		} else do fors.y += CFG.JUMP_IMP
	}

	intendedDisplacement := state.player.velocity + fors

	adx := allowedDisplacement(state.player.position, intendedDisplacement, state.tiles[:], true)
	fdx := utils.signedClamp(intendedDisplacement.x, adx.distance)

	ady := allowedDisplacement(state.player.position, intendedDisplacement, state.tiles[:], false)
	fdy := utils.signedClamp(intendedDisplacement.y, ady.distance)

	vBounce := ady.distance == abs(fdy)
	if vBounce {
		if ady.distance < CFG.BOUNCE_EPS {
			state.player.velocity.y = 0
			fors.y = 0
		}
	}

	state.player.velocity += fors
	state.player.position += { fdx, fdy }

	if (intendedDisplacement.x != 0 && adx.distance == 0) {
		state.player.velocity.x = 0
		fors.x = 0
	}

	motionState := state.player.motion
	if state.player.velocity.x != 0 {
		motionState.direction = state.player.velocity.x > 0 ? .RITE : .LEFT
	}

	motionState.pose = .FALL
	if gripped do motionState.pose = .GRIP
	else if standing do motionState.pose = state.player.velocity.x != 0 ? .RUN : .STAND

	motionState.landed = state.player.motion.pose == .FALL && standing
	motionState.poseChanged = motionState.pose != state.player.motion.pose

	return motionState
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
	boxSize := f32(2)
	tileSize := f32(1)

	if isXAxis {
		bumper = direction.x > 0 ? origin.x + boxSize : origin.x
		originProjection = { origin.y, origin.y + boxSize }
	} else {
		bumper = direction.y > 0 ? origin.y + boxSize : origin.y
		originProjection = { origin.x, origin.x + boxSize }
	}

	for tile in tileset {
		tileOrigin := linalg.array_cast(tile.position, f32)
		tileProjection: [2]f32
		onCourse: bool

		if isXAxis {
			tileProjection = { tileOrigin.y, tileOrigin.y + tileSize}
			onCourse = math.sign(direction.x) == math.sign(tileOrigin.x - origin.x)
		} else {
			tileProjection = { tileOrigin.x,  tileOrigin.x + tileSize}
			onCourse = math.sign(direction.y) == math.sign(tileOrigin.y - origin.y)
		}

		if (rangeOverlap(originProjection, tileProjection) && onCourse){
			tileBumper: f32
			if isXAxis {
				tileBumper = direction.x > 0 ? tileOrigin.x : tileOrigin.x + tileSize
			} else {
				tileBumper = direction.y > 0 ? tileOrigin.y : tileOrigin.y + tileSize
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
