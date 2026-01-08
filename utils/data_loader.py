import json
import os

DATA_DIR = "data"

def load_json(filename):
    path = os.path.join(DATA_DIR, filename)
    if not os.path.exists(path):
        return {}
    with open(path, "r") as f:
        return json.load(f)

def load_data():
    pokemon = load_json("pokedata.json")
    moves = load_json("movedata.json")
    abilities = load_json("abilitydata.json")
    
    # Convert pokemon list to dict for easier lookup by Name or ID if needed, 
    # but strictly it's a list. We can return as is.
    return pokemon, moves, abilities
