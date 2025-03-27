from flask import Blueprint, make_response, request, jsonify
import subprocess
import uuid

from db.conn import get_conn

moleculaRoute = Blueprint('molecula', __name__, url_prefix='/molecula')

fields = "uid, name"

def build_molecula(obj):
    (uid, name) = obj
    return {
        "uid": uid,
        "name": name
    }

@moleculaRoute.route("/", methods=["GET"])
def get_all_molecula():
    conn = get_conn()
    cursor = conn.cursor()
    cursor.execute(f"SELECT {fields} FROM molecula")
    
    moleculas = []
    for obj in cursor.fetchall(): 
        molecula = build_molecula(obj)
        moleculas.append(molecula)

    conn.commit()
    conn.close()
    return jsonify(moleculas)

@moleculaRoute.route("/<uuid:uid>", methods=["GET"])
def get_one_molecula_by_uid(uid):
    conn = get_conn()
    cursor = conn.cursor()
    cursor.execute(f"SELECT {fields} FROM molecula WHERE uid = '{uid}'")

    obj = cursor.fetchone()
    molecula = build_molecula(obj)

    conn.commit()
    conn.close()
    return jsonify(molecula)

@moleculaRoute.route("/search/<string:term>", methods=["GET"])
def search_one_molecula(term:str):
    conn = get_conn()
    cursor = conn.cursor()
    cursor.execute(f"SELECT {fields} FROM molecula WHERE name LIKE ?", [ f"%{term}%" ])
    
    moleculas = []
    for obj in cursor.fetchall(): 
        molecula = build_molecula(obj)
        moleculas.append(molecula)

    conn.commit()
    conn.close()
    return jsonify(moleculas)

@moleculaRoute.route("/<uuid:uid>/svg", methods=["GET"])
def get_svg(uid):
    mode = request.args.get("mode") or "standard"
    result = subprocess.run(["lua", "/home/calisto/cat/me/z1-api/z1/main.lua", mode, str(uid)], capture_output=True, text=True)

    return_code = result.returncode

    if return_code != 0:
        err = result.stderr
        resp = make_response(err)
        return resp

    content = result.stdout
    resp = make_response(content)
    return resp

@moleculaRoute.route("/add", methods=["POST"])
def create_one():
    json = request.get_json()

    uid = uuid.uuid4()
    name = json["name"]
    z1 = json["z1"]

    conn = get_conn()
    cursor = conn.cursor()
    cursor.execute(f"INSERT INTO molecula (uid, name, z1) VALUES (?, ?, ?)", (str(uid), name, z1))

    conn.commit()
    conn.close()
    return jsonify( { "uid": uid } )

@moleculaRoute.route("/edit/<uuid:uid>", methods=["PUT"])
def edit_one(uid):
    json = request.get_json()

    sets = []
    params = []

    fields = ["name", "z1"]
    for field in fields:
        value = json.get(field) or None
        if value:
            sets.append(f"{field} = ?")
            params.append(value)

    conn = get_conn()
    cursor = conn.cursor()

    params.append(str(uid))
    cursor.execute(f"UPDATE molecula SET { ",".join(sets) } WHERE uid = ?", params)

    conn.commit()
    conn.close()
    return jsonify( { "message": "success" } )
