import './PeriodicTableApp.css'

import App from "../widget/app"
import ElementApp from './ElementApp'
import { LINK, CategoryToColor } from '../util'

class PeriodicTableApp extends App {
	private div_periodic_table: HTMLDivElement
	private elements = []

	constructor() {
		super("periodic-table", "Tabela Periódica")

		this.div_periodic_table = document.createElement("div")
		this.div_periodic_table.className = 'periodic-table'
		this.appendToContent(this.div_periodic_table)
	}

	private async loadElements() {
		try {
			const res = await fetch(`${LINK}/element`)
			this.elements = await res.json()
		}
		catch (err) {
			throw err
		}
	}

	protected Render(): void {
		this.loadElements()
		.then( () =>
			this.generatePeriodicTable() )
		.catch(err => {
			console.error(err)
			this.Close()
		})
	}

	private generatePeriodicTable() {
		this.elements?.forEach((element:any) => {
			const element_container = this.generateElementContainer(element)
			this.div_periodic_table.appendChild(element_container)
		})
	}

	private generateElementContainer(element:any) {
		const div_element = document.createElement('div')
		div_element.className = 'element'
		div_element.style.backgroundColor = CategoryToColor(element.category)

		div_element.addEventListener('click', () => {
			const w = new ElementApp(element)
			w.Start()
		})

		div_element.style.gridColumn = element.xpos.toString()
		div_element.style.gridRow = element.ypos.toString()

		const p_symbol = document.createElement('p')
		p_symbol.textContent = element.symbol
		div_element.appendChild(p_symbol)

		return div_element
	}
}

export default PeriodicTableApp