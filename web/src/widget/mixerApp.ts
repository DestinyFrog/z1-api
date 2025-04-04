import App from "./app";

abstract class MixerApp extends App {
    static mixed_apps: MixerApp[] = []
    static spawn_app: ((txt: string) => Promise<App>) | undefined = undefined

    constructor(tag: string, title: string = "") {
        super(tag, title)
        MixerApp.mixed_apps.push(this)
    }

    private mix() {
        const collidedApp = MixerApp.mixed_apps.reduce(
            (acc, current: MixerApp): MixerApp[] => {
                if (current.id == this.id) return acc

                if (
                    this.position.x + this.size.x > current.position.x &&
                    this.position.x < current.position.x + current.size.x &&
                    this.position.y + this.size.y > current.position.y &&
                    this.position.y < current.position.y + current.size.y
                ) return [...acc, current]

                return acc
            }
            , [])

        if (collidedApp.length == 0) return

        collidedApp.push(this)

        const txt = collidedApp.reduce(
            (acc: string[], app: MixerApp) =>
                [...acc, ...app.getTerm()]
            , [])
            .sort()
            .join("")

        if (MixerApp.spawn_app)
            MixerApp.spawn_app(txt)
                .then((app:App) => {
                    app.position = this.position
                    app.Start()
                    collidedApp.forEach(app => app.Close())
                })
                .catch(() => { })
    }

    protected abstract getTerm(): string[]

    protected on_drop(): void {
        this.mix()
        super.on_drop()
    }
}

export default MixerApp