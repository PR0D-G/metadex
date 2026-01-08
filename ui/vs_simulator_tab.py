import customtkinter as ctk
import random
from utils.game_logic import calculate_battle_odds

class VSSimulatorTab(ctk.CTkFrame):
    def __init__(self, master, team_builder_instance, pokemon_data):
        super().__init__(master)
        self.team_builder = team_builder_instance
        self.pokemon_data = pokemon_data
        
        self.grid_columnconfigure(0, weight=1)
        self.grid_rowconfigure(2, weight=1) # Log area
        
        # Controls
        ctrl_frame = ctk.CTkFrame(self)
        ctrl_frame.grid(row=0, column=0, pady=10, sticky="ew")
        
        self.mode_var = ctk.StringVar(value="1v1")
        ctk.CTkOptionMenu(ctrl_frame, variable=self.mode_var, values=["1v1", "3v3", "6v6"]).pack(side="left", padx=10)
        
        ctk.CTkButton(ctrl_frame, text="Generate Enemy Team", command=self.gen_enemy).pack(side="left", padx=10)
        ctk.CTkButton(ctrl_frame, text="SIMULATE BATTLE", fg_color="red", command=self.run_sim).pack(side="right", padx=10)
        
        # Status
        self.status_lbl = ctk.CTkLabel(self, text="Ready")
        self.status_lbl.grid(row=1, column=0)
        
        # Log
        self.log_box = ctk.CTkTextbox(self)
        self.log_box.grid(row=2, column=0, sticky="nsew", padx=10, pady=10)
        
        self.enemy_team = []

    def log(self, text):
        self.log_box.insert("end", text + "\n")
        self.log_box.see("end")

    def gen_enemy(self):
        size = 6
        self.enemy_team = []
        for _ in range(size):
            self.enemy_team.append(random.choice(self.pokemon_data))
        self.log("Enemy Team Generated: " + ", ".join([p['name'] for p in self.enemy_team]))

    def run_sim(self):
        self.log_box.delete("0.0", "end")
        my_team = [p for p in self.team_builder.get_team() if p is not None]
        
        if not my_team:
            self.log("Error: Your team is empty!")
            return
            
        if not self.enemy_team:
            self.gen_enemy()
            
        mode_str = self.mode_var.get()
        count = int(mode_str[0])
        
        # Select active pokemon
        if len(my_team) < count:
            self.log(f"Warning: You only have {len(my_team)} pokemon, but mode is {mode_str}.")
            count = len(my_team)
            
        p1_team = my_team[:count]
        p2_team = self.enemy_team[:count]
        
        self.log(f"Starting {mode_str} Battle!")
        
        # Simple Simulation Loop
        # Just random match ups or sequential? Spec says "Pokemon order is randomized"
        random.shuffle(p1_team)
        random.shuffle(p2_team) # Actually enemy is already random, but why not
        
        active_p1 = p1_team.pop(0)
        active_p2 = p2_team.pop(0)
        
        while True:
            self.log(f"--- {active_p1['name']} VS {active_p2['name']} ---")
            
            # Determine winner
            p1_win_prob = calculate_battle_odds(active_p1, active_p2)
            
            if random.random() < p1_win_prob:
                # P1 wins
                self.log(f"{active_p1['name']} defeats {active_p2['name']}! (Odds: {p1_win_prob:.2f})")
                if p2_team:
                    active_p2 = p2_team.pop(0)
                    self.log(f"Opponent sends out {active_p2['name']}.")
                else:
                    self.log("YOU WIN!")
                    break
            else:
                # P2 wins
                self.log(f"{active_p2['name']} defeats {active_p1['name']}! (Odds: {1-p1_win_prob:.2f})")
                if p1_team:
                    active_p1 = p1_team.pop(0)
                    self.log(f"You send out {active_p1['name']}.")
                else:
                    self.log("YOU LOSE!")
                    break
