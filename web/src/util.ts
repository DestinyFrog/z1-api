
export const LINK = 'http://localhost:3000/api'

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

export function CategoryToColor(category:string) {
	switch (category) {
		case "hidrogênio":
			return "#8c0250";
		case "metal alcalino":
			return "#e5b80b";
		case "metal alcalino terroso":
			return "#ff6600";
		case "ametal":
			return "#008000";
		case "metal de transição":
			return "#970700";
		case "semimetal":
			return "#aa007a";
		case "gás nobre":
			return "#9400d3";
		case "outros metais":
			return "#ff007f";
		case "metaloide":
			return "#ff22ee";
		case "halogênio":
			return "#304ee6";
		case "lantanídeo":
			return "#054f77";
		case "actinídeo":
			return "#4169e1";
		case "desconhecido":
		default:
			return "#333333";
	}
}