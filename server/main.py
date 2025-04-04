from flask import Flask, send_from_directory, Blueprint
from flask_cors import CORS

from routes.moleculas import moleculaRoute
from routes.atoms import atomRoute

app = Flask(__name__, static_folder='./dist', static_url_path='/static')
CORS(app)

api = Blueprint("/api", __name__, url_prefix="/api")
api.register_blueprint( moleculaRoute )
api.register_blueprint( atomRoute )

app.register_blueprint( api )

if __name__ == '__main__':
    app.run( debug=True, host="0.0.0.0", port=3000 )