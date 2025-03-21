import { defineConfig } from 'vite'
import dotenv from 'dotenv'

dotenv.config()

export default defineConfig({
	root: './web',
	build: {
		outDir: '../dist',
		emptyOutDir: true
	}
})