import './BrowserApp.css'

import MoleculaApp from './MoleculaApp'
import App from "../widget/app"
import { LINK } from '../util'
import { MoleculaModel } from '../models'

class BrowserApp extends App {
	private header: HTMLHeadElement
		private search_bar: HTMLInputElement
	
	private ol_recomendation: HTMLUListElement

	constructor() {
		super("browser", "Navegador")

		this.header = document.createElement('header')
		this.header.className = 'browser-header'

			this.search_bar = document.createElement('input')
			this.search_bar.type = 'text'
			this.search_bar.className = 'browser-input'
			this.search_bar.addEventListener('keydown', () => this.search())
			this.header.appendChild(this.search_bar)

		this.ol_recomendation = document.createElement('ol')
		this.ol_recomendation.className = 'recomendation'
	}

	protected Render(): void {
		this.appendToContent(this.header)
		this.appendToContent(this.ol_recomendation)
	}

	private search() {
		const term = this.search_bar.value
		if (term == "") return

		this.ol_recomendation.innerHTML = ''

		fetch(`${LINK}/search/${term}`)
			.then(res => res.json())
			.then((recomendations:MoleculaModel[]) => {
				this.ol_recomendation.innerHTML = ''

				this.ol_recomendation.innerText = (recomendations.length == 0) ? 'Nenhum resultado encontrado' : ''

				recomendations.forEach(({name, uid}) => {
					const li = document.createElement('li')
					li.textContent = name
					li.addEventListener('click', () => this.openAppMolecula(uid))
					this.ol_recomendation.appendChild(li)
				})
			})
			.catch(console.error)
	}

	private openAppMolecula(uid:string) {
		const moleculaApp = new MoleculaApp(uid)
		moleculaApp.Start()
	}
}

export default BrowserApp