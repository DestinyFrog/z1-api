from flask import Flask, send_from_directory, Blueprint
from flask_cors import CORS

from routes.moleculas import moleculaRoute
from routes.atoms import atomRoute

app = Flask(__name__)
CORS(app)

api = Blueprint("api", __name__, url_prefix="/api")

api.register_blueprint( moleculaRoute )
api.register_blueprint( atomRoute )

app.register_blueprint( api )

@app.route("/<path:path>")
def serve_pages(path:str):
    return send_from_directory('./dist', path)

if __name__ == '__main__':
    app.run( debug=True, host="0.0.0.0", port=3000 )