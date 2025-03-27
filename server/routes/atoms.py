from flask import Blueprint, jsonify
import json

from db.conn import get_conn

atomRoute = Blueprint('atoms', __name__, url_prefix='/element')

fields = "atomic_number, oficial_name, atomic_radius, category, atomic_mass, eletronegativity, period, family, symbol, fase, xpos, ypos, layers, electronic_configuration, oxidation_state, discovery_year, discovery, another_names"

def build_atom(obj):
    (atomic_number, oficial_name, atomic_radius, category, atomic_mass, eletronegativity, period, family, symbol, fase, xpos, ypos, layers, electronic_configuration, oxidation_state, discovery_year, discovery, another_names) = obj
    return {
        "atomic_number": atomic_number,
        "oficial_name": oficial_name,
        "atomic_radius": atomic_radius,
        "category": category,
        "atomic_mass": atomic_mass,
        "eletronegativity": eletronegativity,
        "period": period,
        "family": family,
        "symbol": symbol,
        "fase": fase,
        "xpos": xpos,
        "ypos": ypos,
        "layers": json.loads(layers),
        "electronic_configuration": electronic_configuration,
        "oxidation_state": oxidation_state

    }

@atomRoute.route("/", methods=["GET"])
def get_all_molecula():
    conn = get_conn()
    cursor = conn.cursor()
    cursor.execute(f"SELECT {fields} FROM element")
    
    moleculas = []
    for obj in cursor.fetchall(): 
        molecula = build_atom(obj)
        moleculas.append(molecula)

    conn.commit()
    conn.close()
    return jsonify(moleculas)
