import customtkinter as ctk
import os
from PIL import Image

class TeamBuilderTab(ctk.CTkFrame):
    def __init__(self, master, pokemon_data, moves_data, abilities_data):
        super().__init__(master)
        self.pokemon_data = pokemon_data
        self.moves_data = moves_data
        self.abilities_data = abilities_data
        
        self.team = [None] * 6 # List of dicts or None
        
        self.grid_columnconfigure(0, weight=1)
        self.grid_rowconfigure(1, weight=1)
        
        # Analysis Panel
        self.analysis_frame = ctk.CTkFrame(self, height=100)
        self.analysis_frame.grid(row=0, column=0, sticky="ew", padx=10, pady=10)
        ctk.CTkLabel(self.analysis_frame, text="Team Analysis (WIP)", font=("Arial", 16, "bold")).pack(pady=10)
        
        # Team Slots Area
        self.slots_frame = ctk.CTkScrollableFrame(self, orientation="horizontal")
        self.slots_frame.grid(row=1, column=0, sticky="nsew", padx=10, pady=10)
        
        self.slot_widgets = []
        for i in range(6):
            slot = TeamSlot(self.slots_frame, i, self.pokemon_data, self.update_team)
            slot.pack(side="left", padx=10, fill="y")
            self.slot_widgets.append(slot)
            
    def update_team(self, index, pokemon_entry):
        self.team[index] = pokemon_entry
        # Update Analysis here if implemented
        print(f"Team updated at slot {index}")

    def get_team(self):
        return [s.get_data() for s in self.slot_widgets]

class TeamSlot(ctk.CTkFrame):
    def __init__(self, master, index, pokemon_list, update_callback):
        super().__init__(master, width=250, height=400)
        self.index = index
        self.pokemon_list = pokemon_list
        self.update_callback = update_callback
        self.current_pokemon = None
        
        self.pack_propagate(False)
        
        self.lbl_title = ctk.CTkLabel(self, text=f"Slot {index+1}", font=("Arial", 14, "bold"))
        self.lbl_title.pack(pady=5)
        
        self.img_label = ctk.CTkLabel(self, text="[Empty]", width=100, height=100, fg_color="gray30")
        self.img_label.pack(pady=10)
        
        self.lbl_name = ctk.CTkLabel(self, text="---")
        self.lbl_name.pack()
        
        # Change Button
        self.btn_change = ctk.CTkButton(self, text="Change", command=self.open_selection)
        self.btn_change.pack(pady=5)
        
        # Move Selectors (Placeholder)
        self.moves_frame = ctk.CTkFrame(self, fg_color="transparent")
        self.moves_frame.pack(fill="x", padx=5)
        
    def open_selection(self):
        # Use an overlay frame on the main window instead of Toplevel
        # Find the main window
        root = self.winfo_toplevel()
        
        # Overlay Background (Modal effect)
        overlay = ctk.CTkFrame(root, fg_color="#2b2b2b", border_width=2, border_color="white")
        overlay.place(relx=0.5, rely=0.5, anchor="center", relwidth=0.5, relheight=0.7)
        
        # Enforce modality
        overlay.grab_set()
        overlay.focus_set()
        
        # Header
        h = ctk.CTkFrame(overlay, fg_color="transparent")
        h.pack(fill="x", padx=10, pady=10)
        ctk.CTkLabel(h, text="Select Pokemon", font=("Arial", 16, "bold")).pack(side="left")
        
        btn_close = ctk.CTkButton(h, text="X", width=30, fg_color="red", command=overlay.destroy)
        btn_close.pack(side="right")
        
        search_var = ctk.StringVar()
        entry = ctk.CTkEntry(overlay, textvariable=search_var, placeholder_text="Search...")
        entry.pack(fill="x", padx=10, pady=10)
        
        scroll = ctk.CTkScrollableFrame(overlay)
        scroll.pack(fill="both", expand=True, padx=10, pady=10)
        
        def select(p):
            self.set_pokemon(p)
            overlay.destroy()
            
        def update_list(*args):
            # Clear
            for w in scroll.winfo_children():
                w.destroy()
                
            query = search_var.get().lower()
            filtered = [p for p in self.pokemon_list if query in p['name'].lower()]
            
            # Limit render for speed
            for p in filtered[:50]: 
                b = ctk.CTkButton(scroll, text=p['name'], command=lambda x=p: select(x))
                b.pack(fill="x", pady=2)
                
        entry.bind("<KeyRelease>", update_list)
        update_list()
        
    def set_pokemon(self, pokemon):
        self.current_pokemon = pokemon
        self.lbl_name.configure(text=pokemon['name'])
        
        # Image
        img_path = pokemon.get("image_path")
        if img_path and os.path.exists(img_path):
             img = ctk.CTkImage(Image.open(img_path), size=(100, 100))
             self.img_label.configure(image=img, text="")
        else:
             self.img_label.configure(image=None, text="[No Image]")
        
        # Callback
        self.update_callback(self.index, pokemon)

    def get_data(self):
        return self.current_pokemon
