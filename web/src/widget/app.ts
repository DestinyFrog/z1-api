import './app.css'
import { generateRandomString, Vec2 } from "../util"

class App {
	private static windows: (App|null)[] = []

	public readonly tag: string
	protected readonly window_index: number
	public readonly id : string
	private div_app : HTMLDivElement

	protected div_header : HTMLDivElement
	private p_title : HTMLParagraphElement
	private but_close : HTMLButtonElement

	protected div_content : HTMLDivElement
	protected div_footer: HTMLDivElement

	private drag_position: Vec2 = { x: 0, y: 0 }
	private before_drag_position: Vec2 = { x: 0, y: 0 }
	private startPosition : Vec2 = { x: 10, y: 10 }

	private is_dragging = false

	constructor(tag:string, title = "app") {
		this.id = generateRandomString()
		this.tag = tag

		this.div_app = document.createElement("div")
		this.div_app.className = 'app'

		//? HEADER
		this.div_header = document.createElement("div")
		this.div_header.className = 'app-header'
		this.div_app.appendChild(this.div_header)

			this.p_title = document.createElement("p")
			this.p_title.className = 'title'
			this.div_header.appendChild(this.p_title)

			this.but_close = document.createElement("button")
			this.but_close.className = 'button-close'
			this.but_close.addEventListener('click', () => {
				this.Close()
			})
			this.div_header.appendChild(this.but_close)

		//? CONTENT
		this.div_content = document.createElement("div")
		this.div_content.className = 'app-content'
		this.div_app.appendChild(this.div_content)

		//? FOOTER
		this.div_footer = document.createElement("div")
		this.div_footer.className = 'app-footer'
		this.div_app.appendChild(this.div_footer)

		this.position = this.startPosition

		this.title = title
		
		this.window_index = App.windows.push(this) - 1
	}

	protected on_move() {}
	protected on_drop() {}

	public set position(pos:Vec2) {
		this.div_app.style.left = `${pos.x}px`
		this.div_app.style.top = `${pos.y}px`
	}

	public get position() {
		return {
			x: this.div_app.getBoundingClientRect().x,
			y: this.div_app.getBoundingClientRect().y
		}
	}

	public set title(title:string) {
		this.p_title.textContent = title
	}

	public get size() {
		return {
			x: this.div_app.getBoundingClientRect().width,
			y: this.div_app.getBoundingClientRect().height
		}
	}

	public static filter_by_tag(tag:string[]) {
		return this.windows.filter( (app) => {
			if (app) return tag.includes(app.tag)
			return false
		} )
	}

	public Start() {
		this.DragAndDropSystem()

		const app = document.getElementById("app")!
		app.appendChild(this.div_app)

		this.Render()
	}

	public Close() {
		this.Destroy()
		this.div_app.remove()
		App.windows[this.window_index] = null
	}

	protected Render() {}
	protected Destroy() {}

	protected appendToContent(element:HTMLElement) {
		this.div_content.appendChild(element)
	}

	protected appendToFooter(element:HTMLElement) {
		this.div_footer.appendChild(element)
	}

	DragAndDropSystem() {
		this.drag_position = {x:0, y:0} 
		this.before_drag_position = {x:0, y:0}

		this.div_header.addEventListener('mousedown', ev => {
			this.before_drag_position.x = ev.clientX
			this.before_drag_position.y = ev.clientY

			const mouseMove = (ev:MouseEvent) => {
				this.on_move()

				this.is_dragging = true

				// if (ev.clientX > 0 && ev.clientX < document.body.clientWidth) {
					this.drag_position.x = this.before_drag_position.x - ev.clientX
					this.before_drag_position.x = ev.clientX
					this.div_app.style.left = `${this.div_app.offsetLeft - this.drag_position.x}px`	
				// }
				
				// if (ev.clientY > 0 && ev.clientY < document.body.clientHeight) {
					this.drag_position.y = this.before_drag_position.y - ev.clientY
					this.before_drag_position.y = ev.clientY
					this.div_app.style.top = `${this.div_app.offsetTop - this.drag_position.y}px`
				// }
			}

			document.addEventListener('mousemove', mouseMove)
			document.addEventListener('mouseup', _ => {
				if (this.is_dragging) this.on_drop()
				this.is_dragging = false
				document.removeEventListener('mousemove', mouseMove)
			})
		})

		this.div_header.addEventListener('touchstart', ev => {
			this.before_drag_position.x = ev.touches[0].clientX
			this.before_drag_position.y = ev.touches[0].clientY

			const mouseMove = (ev:TouchEvent) => {
				this.on_move()

				this.drag_position.x = this.before_drag_position.x - ev.touches[0].clientX
				this.drag_position.y = this.before_drag_position.y - ev.touches[0].clientY
	
				this.before_drag_position.x = ev.touches.item(0)?.clientX!
				this.before_drag_position.y = ev.touches[0].clientY

				this.div_app.style.top = `${this.div_app.offsetTop - this.drag_position.y}px`
				this.div_app.style.left = `${this.div_app.offsetLeft - this.drag_position.x}px`
			}

			document.addEventListener('touchmove', mouseMove)
			document.addEventListener('touchend', _ => {
				this.on_drop()
				document.removeEventListener('touchmove', mouseMove)
			})
		})
	}
}

export default App