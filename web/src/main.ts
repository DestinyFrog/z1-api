import './style.css'

import BrowserApp from "./app/BrowserApp"
import PeriodicTableApp from './app/PeriodicTableApp'

const browser = new BrowserApp()
browser.Start()

const periodicTable = new PeriodicTableApp()
periodicTable.Start()