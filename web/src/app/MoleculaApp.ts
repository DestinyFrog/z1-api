import './MoleculaApp.css'

import App from "../widget/app"
import { LINK } from '../util'
import { MoleculaModel, SvgModes } from '../models'

class MoleculaApp extends App {
	private uid: string
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
		this.appendToFooter(this.organic_button)
		this.appendToFooter(this.lewis_button)

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
		fetch(`${LINK}/${this.uid}`)
			.then(res => res.json())
			.then(({ name }: MoleculaModel) => this.title = name)
			.catch(console.error)
	}

	loadSvg() {
		fetch(`${LINK}/${this.uid}/svg?mode=${this.mode}`)
			.then(res => res.text())
			.then(svg => {
				this.svg_content.innerHTML = svg

				const svg_el: SVGElement = this.svg_content.children[0] as SVGElement
				const { x, y, width, height } = (svg_el as any).viewBox.baseVal
				const mut = 1.2
				
				if (width > height) {
					svg_el.style.width = (width * mut).toString() + 'px'
				}
				else {
					svg_el.style.height = (height * mut).toString() + 'px'
				}

			})
			.catch(console.error)
	}
}

export default MoleculaApp