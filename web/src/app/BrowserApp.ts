import './BrowserApp.css'

import MoleculaApp from './MoleculaApp'
import App from "../widget/app"
import { LINK } from '../util'
import { MoleculaModel } from '../models'

class BrowserApp extends App {
	private search_bar: HTMLInputElement
	private ol_recomendation: HTMLUListElement

	constructor() {
		super("browser")

		this.search_bar = document.createElement('input')
		this.search_bar.type = 'text'
		this.search_bar.className = 'browser-input'
		this.search_bar.addEventListener('keydown', () => this.search())

		this.ol_recomendation = document.createElement('ol')
	}

	protected Render(): void {
		this.appendToContent(this.search_bar)
		this.appendToContent(this.ol_recomendation)
	}

	private search() {
		const term = this.search_bar.value
		if (term == "") return

		const link = `${LINK}/search/${term}`

		fetch(link)
			.then(res => res.json())
			.then((recomendations:MoleculaModel[]) => {
				this.ol_recomendation.innerHTML = ''
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