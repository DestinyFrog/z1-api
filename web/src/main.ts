import './style.css'

import PeriodicTableApp from './app/PeriodicTableApp'
import MixerApp from './widget/mixerApp'
import MoleculaApp from './app/MoleculaApp'
import { LINK } from './util'
import BrowserApp from './app/BrowserApp'

const browser = new BrowserApp()
browser.Start()

const periodicTable = new PeriodicTableApp()
periodicTable.Start()

MixerApp.spawn_app = async function(txt:string) {
    const res = await fetch(`${LINK}/molecula/mix/${txt}`)
    const data = await res.json()
    return new MoleculaApp(data.uid)
}