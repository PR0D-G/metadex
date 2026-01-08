TYPE_CHART = {
    "Normal": {"Rock": 0.5, "Ghost": 0, "Steel": 0.5},
    "Fire": {"Fire": 0.5, "Water": 0.5, "Grass": 2, "Ice": 2, "Bug": 2, "Rock": 0.5, "Dragon": 0.5, "Steel": 2},
    "Water": {"Fire": 2, "Water": 0.5, "Grass": 0.5, "Ground": 2, "Rock": 2, "Dragon": 0.5},
    "Electric": {"Water": 2, "Electric": 0.5, "Grass": 0.5, "Ground": 0, "Flying": 2, "Dragon": 0.5},
    "Grass": {"Fire": 0.5, "Water": 2, "Grass": 0.5, "Poison": 0.5, "Ground": 2, "Flying": 0.5, "Bug": 0.5, "Rock": 2, "Dragon": 0.5, "Steel": 0.5},
    "Ice": {"Fire": 0.5, "Water": 0.5, "Grass": 2, "Ice": 0.5, "Ground": 2, "Flying": 2, "Dragon": 2, "Steel": 0.5},
    "Fighting": {"Normal": 2, "Ice": 2, "Poison": 0.5, "Flying": 0.5, "Psychic": 0.5, "Bug": 0.5, "Rock": 2, "Ghost": 0, "Dark": 2, "Steel": 2, "Fairy": 0.5},
    "Poison": {"Grass": 2, "Poison": 0.5, "Ground": 0.5, "Rock": 0.5, "Ghost": 0.5, "Steel": 0, "Fairy": 2},
    "Ground": {"Fire": 2, "Electric": 2, "Grass": 0.5, "Poison": 2, "Flying": 0, "Bug": 0.5, "Rock": 2, "Steel": 2},
    "Flying": {"Electric": 0.5, "Grass": 2, "Fighting": 2, "Bug": 2, "Rock": 0.5, "Steel": 0.5},
    "Psychic": {"Fighting": 2, "Poison": 2, "Psychic": 0.5, "Dark": 0, "Steel": 0.5},
    "Bug": {"Fire": 0.5, "Grass": 2, "Fighting": 0.5, "Poison": 0.5, "Flying": 0.5, "Psychic": 2, "Ghost": 0.5, "Dark": 2, "Steel": 0.5, "Fairy": 0.5},
    "Rock": {"Fire": 2, "Ice": 2, "Fighting": 0.5, "Ground": 0.5, "Flying": 2, "Bug": 2, "Steel": 0.5},
    "Ghost": {"Normal": 0, "Psychic": 2, "Ghost": 2, "Dark": 0.5},
    "Dragon": {"Dragon": 2, "Steel": 0.5, "Fairy": 0},
    "Steel": {"Fire": 0.5, "Water": 0.5, "Electric": 0.5, "Ice": 2, "Rock": 2, "Steel": 0.5, "Fairy": 2},
    "Dark": {"Fighting": 0.5, "Psychic": 2, "Ghost": 2, "Dark": 0.5, "Fairy": 0.5},
    "Fairy": {"Fire": 0.5, "Fighting": 2, "Poison": 0.5, "Dragon": 2, "Dark": 2, "Steel": 0.5}
}

def get_effectiveness(attack_type, defend_types):
    multiplier = 1.0
    # Normalize types
    att = attack_type.capitalize()
    
    for dt in defend_types:
        dt = dt.capitalize()
        if att in TYPE_CHART:
            val = TYPE_CHART[att].get(dt, 1.0)
            multiplier *= val
    return multiplier

def get_weaknesses(defend_types):
    # Returns specific weaknesses/resistances for a pokemon
    results = {}
    all_types = TYPE_CHART.keys()
    
    for att in all_types:
        eff = get_effectiveness(att, defend_types)
        if eff != 1.0:
            results[att] = eff
            
    return results

def calculate_battle_odds(p1, p2):
    # p1 and p2 are dicts with 'name', 'types', 'stats'
    if not p1 or not p2:
        return 0.5
    
    # Simple logic as per spec: Total Stats x Type Effectiveness
    stats1 = sum(p1['stats'].values())
    stats2 = sum(p2['stats'].values())
    
    eff1 = 1.0
    for t in p1['types']:
        eff1 = max(eff1, get_effectiveness(t, p2['types']))
        
    eff2 = 1.0
    for t in p2['types']:
        eff2 = max(eff2, get_effectiveness(t, p1['types']))
        
    # Avoid zero division
    score1 = stats1 * eff1
    score2 = stats2 * eff2
    
    if score1 + score2 == 0:
        return 0.5
        
    return score1 / (score1 + score2)
