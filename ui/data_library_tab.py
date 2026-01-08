import customtkinter as ctk

class DataLibraryTab(ctk.CTkFrame):
    def __init__(self, master, pokemon_data, moves_data, abilities_data):
        super().__init__(master)
        self.pokemon_data = pokemon_data
        self.moves_data = moves_data
        self.abilities_data = abilities_data
        
        self.tab_view = ctk.CTkTabview(self)
        self.tab_view.pack(fill="both", expand=True, padx=10, pady=10)
        
        self.tab_moves = self.tab_view.add("Moves")
        self.tab_abilities = self.tab_view.add("Abilities")
        self.tab_types = self.tab_view.add("Types")
        
        self.setup_moves()
        self.setup_abilities()
        self.setup_types()

    def setup_moves(self):
        # List of Moves
        scroll = ctk.CTkScrollableFrame(self.tab_moves)
        scroll.pack(fill="both", expand=True)
        
        # Header
        h = ctk.CTkFrame(scroll, height=30)
        h.pack(fill="x")
        ctk.CTkLabel(h, text="Name", width=150, anchor="w").pack(side="left", padx=5)
        ctk.CTkLabel(h, text="Type", width=100, anchor="w").pack(side="left", padx=5)
        ctk.CTkLabel(h, text="Power", width=50, anchor="w").pack(side="left", padx=5)
        ctk.CTkLabel(h, text="Class", width=100, anchor="w").pack(side="left", padx=5)
        
        # Sort moves alphabetically
        sorted_moves = sorted(self.moves_data.items())
        
        for name, data in sorted_moves:
            row = ctk.CTkFrame(scroll)
            row.pack(fill="x", pady=1)
            ctk.CTkLabel(row, text=name, width=150, anchor="w").pack(side="left", padx=5)
            ctk.CTkLabel(row, text=data['type'], width=100, anchor="w", text_color="cyan").pack(side="left", padx=5)
            ctk.CTkLabel(row, text=str(data['power']), width=50, anchor="w").pack(side="left", padx=5)
            ctk.CTkLabel(row, text=data['category'], width=100, anchor="w").pack(side="left", padx=5)

    def setup_abilities(self):
        scroll = ctk.CTkScrollableFrame(self.tab_abilities)
        scroll.pack(fill="both", expand=True)
        
        sorted_abilities = sorted(self.abilities_data.items())
        
        for name, data in sorted_abilities:
            row = ctk.CTkFrame(scroll)
            row.pack(fill="x", pady=2)
            
            ctk.CTkLabel(row, text=name, font=("Arial", 14, "bold")).pack(anchor="w", padx=5)
            ctk.CTkLabel(row, text=data['description'], text_color="gray70", wraplength=600, justify="left").pack(anchor="w", padx=15)

    def setup_types(self):
        # Filter buttons at top, results below
        scroll = ctk.CTkScrollableFrame(self.tab_types)
        scroll.pack(fill="both", expand=True)
        
        self.type_results = ctk.CTkFrame(scroll)
        
        types = ["Normal", "Fire", "Water", "Grass", "Electric", "Ice", "Fighting", "Poison", "Ground", 
                 "Flying", "Psychic", "Bug", "Rock", "Ghost", "Dragon", "Steel", "Dark", "Fairy"] # Gen 9
                 
        btn_frame = ctk.CTkFrame(scroll)
        btn_frame.pack(fill="x", pady=10)
        
        for t in types:
            ctk.CTkButton(btn_frame, text=t, width=60, height=25, 
                          command=lambda x=t: self.filter_type(x)).pack(side="left", padx=2, pady=2)
                          
        self.type_results.pack(fill="both", expand=True, pady=10)
        
    def filter_type(self, type_name):
        for w in self.type_results.winfo_children():
            w.destroy()
            
        ctk.CTkLabel(self.type_results, text=f"Pokemon with Type: {type_name}", font=("Arial", 16, "bold")).pack(pady=10)
        
        count = 0
        for p in self.pokemon_data:
            if type_name in p['types']:
                ctk.CTkLabel(self.type_results, text=f"#{p['id']} {p['name']}").pack(anchor="w", padx=20)
                count += 1
        
        if count == 0:
            ctk.CTkLabel(self.type_results, text="None found.").pack()
