import './ElementApp.css'

import { CategoryToColor } from '../util'
import MixerApp from '../widget/mixerApp'

class ElementApp extends MixerApp {
	public element

	private main_content: HTMLDivElement
	private p_atomic_number: HTMLParagraphElement
	private p_symbol: HTMLParagraphElement
	private p_name: HTMLParagraphElement
	private p_atomic_mass: HTMLParagraphElement
	private ul_layer: HTMLUListElement

	constructor(element:any) {
		super(element.oficial_name)
		this.element = element

		this.div_content.style.display = 'flex'

		this.main_content = document.createElement('div')
		this.main_content.className = 'main-content'
		this.appendToContent(this.main_content)

		this.p_atomic_number = document.createElement('p')
		this.p_atomic_number.className = 'atomic-number'
		this.main_content.appendChild(this.p_atomic_number)

		this.p_symbol = document.createElement('p')
		this.p_symbol.className = 'symbol'
		this.main_content.appendChild(this.p_symbol)

		this.p_name = document.createElement('p')
		this.p_name.className = 'name'
		this.main_content.appendChild(this.p_name)

		this.p_atomic_mass = document.createElement('p')
		this.p_atomic_mass.className = 'atomic-mass'
		this.main_content.appendChild(this.p_atomic_mass)

		this.ul_layer = document.createElement('ul')
		this.ul_layer.className = 'layer'
		this.appendToContent(this.ul_layer)

		this.title = this.element.oficial_name
	}

	protected Render(): void {
		this.div_content.style.backgroundColor = CategoryToColor(this.element.category)

		this.p_atomic_number.textContent = this.element.atomic_number.toString()
		this.p_symbol.textContent = this.element.symbol
		this.p_name.textContent = this.element.oficial_name
		this.p_atomic_mass.textContent = (this.element.atomic_mass?.toString() || "desconhecido")

		this.element.layers.forEach((layer:any) => {
			const li_layer = document.createElement("li")
			li_layer.textContent = layer.toString()
			this.ul_layer.appendChild(li_layer)
		})
	}

	protected getTerm(): string[] {
		return [ this.element.symbol ]
	}
}

export default ElementApp