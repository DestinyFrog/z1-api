import './MoleculaApp.css'

import { LINK } from '../util'
import { SvgModes } from '../models'
import MixerApp from '../widget/mixerApp'

class MoleculaApp extends MixerApp {
	private uid: string
	private term: string = ""
	private organic = false

	private _mode: SvgModes = SvgModes.STANDARD

	private svg_content: HTMLDivElement
	private standard_button: HTMLButtonElement
	private organic_button: HTMLButtonElement
	private lewis_button: HTMLButtonElement

	constructor(uid: string) {
		super("molecula")
		this.uid = uid

		this.svg_content = document.createElement("div")
		this.svg_content.className = "svg-background"

		this.standard_button = document.createElement("button")
		this.standard_button.textContent = 'Normal'
		this.standard_button.addEventListener('click', () => this.mode = SvgModes.STANDARD)

		this.organic_button = document.createElement("button")
		this.organic_button.textContent = 'Orgânico'
		this.organic_button.addEventListener('click', () => this.mode = SvgModes.ORGANIC)

		this.lewis_button = document.createElement("button")
		this.lewis_button.textContent = 'Lewis'
		this.lewis_button.addEventListener('click', () => this.mode = SvgModes.LEWIS)
	}

	protected Render(): void {
		this.appendToContent(this.svg_content)

		this.appendToFooter(this.standard_button)

		this.getInfo()
		this.loadSvg()
	}

	public set mode(mode: SvgModes) {
		this._mode = mode;
		this.loadSvg()
	}

	public get mode() {
		return this._mode;
	}

	getInfo() {
		fetch(`${LINK}/molecula/${this.uid}`)
			.then(res => res.json())
			.then(({ name, term, organic }: any) => {
				this.title = name
				this.organic = organic
				this.term = term

				if (this.organic)
					this.appendToFooter(this.organic_button)
			})
			.catch(console.error)
	}

	loadSvg() {
		fetch(`${LINK}/molecula/${this.uid}/svg?mode=${this.mode}`)
			.then(res => res.text())
			.then(svg => {
				this.svg_content.innerHTML = svg
				const svg_el: SVGElement = this.svg_content.children[0] as SVGElement
				const { width, height } = (svg_el as any).viewBox.baseVal
				
				if (width > height)
					this.svg_content.style.width = `${width*1.5}px`
			})
			.catch(console.error)
	}

	protected getTerm(): string[] {
		return this.term.split(/([A-Z][a-z]?)/)
	}
}

export default MoleculaApp