
export const LINK = 'http://localhost:3000'

export interface Vec2 {
	x:number,
	y:number
}

export function generateRandomString(size = 8) {
	let result = ''
	const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
	const charactersLength = characters.length
	for (let i = 0; i < size; i++) {
		result += characters.charAt(Math.floor(Math.random() * charactersLength))
	}
	return result
}

export function DegreesToRadians(degrees:number) {
	return degrees / 180 * Math.PI
}

export function generateRandomVec2(max_x:number, max_y:number): Vec2 {
	return {
		x: Math.floor( Math.random() * max_x ),
		y: Math.floor( Math.random() * max_y )
	}
}