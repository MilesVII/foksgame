package utils

import rl "vendor:raylib"
import "core:unicode/utf8"
import "core:math"
import "core:math/rand"

TAU :: (rl.PI * 2)

BADGE_SIZE :: 16
Badge :: [BADGE_SIZE]rune

stringToBadge :: proc(name: string) -> Badge {
	r : Badge
	runes := utf8.string_to_runes(name)
	for c, i in name {
		if i >= BADGE_SIZE do break
		r[i] = c
	}
	return r
}

badgeToString :: proc(badge: Badge) -> string {
	badge := badge
	return utf8.runes_to_string(badge[:])
}

swap :: proc(a: ^$T, b:^T) {
	c := a^
	a^ = b^
	b^ = c
}

shuffle :: proc(target: []$T) {
	for _, i in target {
		tix := rand.int31_max(i32(len(target)))
		if i == int(tix) do continue
		swap(&target[i], &target[tix])
	}
}

decay :: proc(value: f32, dec: f32, dt: f32) -> f32 {
	return value * math.exp_f32(-dec * dt)
}

decayV :: proc(value: [2]f32, dec: f32, dt: f32) -> [2]f32 {
	r: [2]f32
	for v, i in value do r[i] = decay(v, dec, dt)
	return r
}

signedClamp :: proc(value: $T, limit: T) -> T {
	return clamp(value, -limit, limit)
}
