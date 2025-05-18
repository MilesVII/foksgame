package game

import rl "vendor:raylib"

import "core:fmt"
import "core:math"
import "core:math/rand"

AnimationPose :: enum {
	IDLE, LOOK, WALK, FALL, LAND, GRIP
}

AnimationState :: struct {
	ms: f32,
	pose: AnimationPose,
	next: AnimationPose
}

@(private)
updateAnimation :: proc(state: ^AnimationState, motion: ^MotionState) {
	poseByMotion :: proc(state: ^AnimationState, motion: ^MotionState) {
		if motion.pose == .RUN {
			state.pose = .WALK
			state.next = .WALK
		}
		if motion.pose == .FALL {
			state.pose = .FALL
			state.next = .FALL
		}
		if motion.pose == .GRIP {
			state.pose = .GRIP
			state.next = .GRIP
		}
		if motion.pose == .STAND {
			state.pose = .IDLE
			state.next = .IDLE
		}
		if motion.landed {
			state.pose = .LAND
			state.next = .IDLE
		}
	}

	if motion.poseChanged {
		state.ms = 0
		poseByMotion(state, motion)
	}

	state.ms += rl.GetFrameTime() * 1000
	loop := animationLoop(state.pose)
	for state.ms >= loop {
		state.ms -= loop
		if state.pose == .IDLE && rand.int31_max(10) == 0 {
			state.next = .LOOK
		}
		if state.pose == .LOOK do state.next = .IDLE
		if state.pose == .LAND do poseByMotion(state, motion)
		state.pose = state.next
	}

}

@(private="file")
animationLoop :: proc(pose: AnimationPose) -> f32 {
	msPerFrame := f32(100)
	if pose == .LAND do msPerFrame *= .6
	return msPerFrame * f32(animationFrameCount(pose))
}

// TODO use to retrieve frame count from sheet
@(private="file")
animationRow :: proc(pose: AnimationPose) -> int {
	switch pose {
		case .IDLE: return 0 // refers to spritesheet framecount
		case .LOOK: return 1
		case .WALK: return 2
		case .FALL: return 3
		case .LAND: return 3
		case .GRIP: return 4
	}
	return 0
}
@(private="file")
animationFrameCount :: proc(pose: AnimationPose) -> int {
	switch pose {
		case .IDLE: return 5 // refers to spritesheet framecount
		case .LOOK: return 14
		case .WALK: return 8
		case .FALL: return 1
		case .LAND: return 5
		case .GRIP: return 1
	}
	return 0
}

@(private)
animationFrame :: proc(state: ^AnimationState) -> [2]int {
	if state.pose == .FALL do return { 5, 3 }
	loop := animationLoop(state.pose)
	frame := int(math.floor(state.ms / loop * f32(animationFrameCount(state.pose))))

	if state.pose == .LAND do frame += 6
	return { frame, animationRow(state.pose) }
}
