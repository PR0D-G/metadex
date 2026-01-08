import customtkinter as ctk
from PIL import Image
import os
import json
from utils.game_logic import get_weaknesses

class PokedexTab(ctk.CTkFrame):
    def __init__(self, master, pokemon_data, moves_data, abilities_data):
        super().__init__(master)
        self.pokemon_data = pokemon_data
        self.moves_data = moves_data
        self.abilities_data = abilities_data
        
        self.favorites = self.load_favorites()
        
        self.filtered_data = pokemon_data
        self.page = 1
        self.items_per_page = 50
        self.total_pages = 1
        
        # Grid Configuration
        self.grid_columnconfigure(0, weight=1)
        self.grid_rowconfigure(2, weight=1) # Scroll frame is now row 2
        
        # --- Top Bar (Search & Quick Filters) ---
        self.top_bar = ctk.CTkFrame(self)
        self.top_bar.grid(row=0, column=0, sticky="ew", padx=10, pady=(10, 5))
        
        self.search_var = ctk.StringVar()
        self.search_entry = ctk.CTkEntry(self.top_bar, textvariable=self.search_var, placeholder_text="Search Pokemon...")
        self.search_entry.pack(side="left", padx=10, fill="x", expand=True)
        self.search_entry.bind("<KeyRelease>", self.update_list)
        
        self.fav_filter_var = ctk.BooleanVar(value=False)
        self.chk_fav = ctk.CTkCheckBox(self.top_bar, text="Favorites Only", variable=self.fav_filter_var, command=self.update_list)
        self.chk_fav.pack(side="right", padx=10)
        
        # --- Advanced Filter Bar ---
        self.filter_bar = ctk.CTkFrame(self)
        self.filter_bar.grid(row=1, column=0, sticky="ew", padx=10, pady=(0, 10))
        
        # Sort
        ctk.CTkLabel(self.filter_bar, text="Sort:").pack(side="left", padx=5)
        self.sort_var = ctk.StringVar(value="ID")
        self.sort_opt = ctk.CTkOptionMenu(self.filter_bar, variable=self.sort_var, 
                                          values=["ID", "Name", "Total Stats", "Speed", "Attack", "Defense"],
                                          command=self.update_list, width=100)
        self.sort_opt.pack(side="left", padx=5)
        
        # Type Filter
        ctk.CTkLabel(self.filter_bar, text="Type:").pack(side="left", padx=5)
        self.type_var = ctk.StringVar(value="All")
        types = ["All", "Normal", "Fire", "Water", "Grass", "Electric", "Ice", "Fighting", "Poison", "Ground", 
                 "Flying", "Psychic", "Bug", "Rock", "Ghost", "Dragon", "Steel", "Dark", "Fairy"]
        self.type_opt = ctk.CTkOptionMenu(self.filter_bar, variable=self.type_var, values=types, command=self.update_list, width=100)
        self.type_opt.pack(side="left", padx=5)
        
        # Gen Filter
        ctk.CTkLabel(self.filter_bar, text="Gen:").pack(side="left", padx=5)
        self.gen_var = ctk.StringVar(value="All")
        self.gen_opt = ctk.CTkOptionMenu(self.filter_bar, variable=self.gen_var, 
                                         values=["All", "1", "2", "3", "4", "5", "6", "7", "8", "9"],
                                         command=self.update_list, width=70)
        self.gen_opt.pack(side="left", padx=5)

        # Scrollable Frame for Grid
        self.scroll_frame = ctk.CTkScrollableFrame(self)
        self.scroll_frame.grid(row=2, column=0, sticky="nsew", padx=10, pady=(0, 10))
        self.scroll_frame.grid_columnconfigure(0, weight=1)
        
        # Pagination Controls
        self.footer = ctk.CTkFrame(self, height=40)
        self.footer.grid(row=3, column=0, sticky="ew", padx=10, pady=5)
        
        self.btn_prev = ctk.CTkButton(self.footer, text="<< Prev", width=100, command=self.prev_page)
        self.btn_prev.pack(side="left", padx=10, pady=5)
        
        self.lbl_page = ctk.CTkLabel(self.footer, text="Page 1 of 1")
        self.lbl_page.pack(side="left", expand=True)
        
        self.btn_next = ctk.CTkButton(self.footer, text="Next >>", width=100, command=self.next_page)
        self.btn_next.pack(side="right", padx=10, pady=5)
        
        self.detail_frame = None
        
        # Initial Sort/Filter
        self.update_list()

    def prev_page(self):
        if self.page > 1:
            self.page -= 1
            self.populate_grid(self.filtered_data)

    def next_page(self):
        if self.page < self.total_pages:
            self.page += 1
            self.populate_grid(self.filtered_data)

    def load_favorites(self):
        try:
            if os.path.exists("favorites.json"):
                with open("favorites.json", "r") as f:
                    return set(json.load(f))
        except:
            pass
        return set()

    def save_favorites(self):
        with open("favorites.json", "w") as f:
            json.dump(list(self.favorites), f)

    def toggle_favorite(self, pid):
        if pid in self.favorites:
            self.favorites.remove(pid)
        else:
            self.favorites.add(pid)
        self.save_favorites()
        # Refresh if in detail view or grid
        self.update_list()
        # If detail view is open, refresh it? simpler to just close or let user see. 
        # But if we toggle in detail view, we want to update the star button there.


    def populate_grid(self, data):
        # Clear existing
        for widget in self.scroll_frame.winfo_children():
            widget.destroy()
            
        # Pagination Logic
        total_items = len(data)
        self.total_pages = (total_items + self.items_per_page - 1) // self.items_per_page
        if self.total_pages < 1: self.total_pages = 1
        
        if self.page > self.total_pages: self.page = self.total_pages
        if self.page < 1: self.page = 1
        
        start_idx = (self.page - 1) * self.items_per_page
        end_idx = start_idx + self.items_per_page
        
        display_data = data[start_idx:end_idx]
        
        # Update Footer
        self.lbl_page.configure(text=f"Page {self.page} of {self.total_pages} ({total_items} Pokemon)")
        self.btn_prev.configure(state="normal" if self.page > 1 else "disabled")
        self.btn_next.configure(state="normal" if self.page < self.total_pages else "disabled")
        
        columns = 4
        for i, p in enumerate(display_data):
            row = i // columns
            col = i % columns
            
            card = self.create_pokemon_card(p)
            card.grid(row=row, column=col, padx=10, pady=10, sticky="nsew")
        
        # Configure columns
        for i in range(columns):
            self.scroll_frame.grid_columnconfigure(i, weight=1)

    def create_pokemon_card(self, pokemon):
        frame = ctk.CTkFrame(self.scroll_frame, cursor="hand2")
        frame.bind("<Button-1>", lambda e, p=pokemon: self.show_details(p))
        
        # Image
        img_path = pokemon.get("image_path")
        try:
            if img_path and os.path.exists(img_path):
                img = ctk.CTkImage(Image.open(img_path), size=(100, 100))
                lbl_img = ctk.CTkLabel(frame, image=img, text="")
            else:
                lbl_img = ctk.CTkLabel(frame, text="[No Image]", width=100, height=100)
        except Exception:
             lbl_img = ctk.CTkLabel(frame, text="[Error]", width=100, height=100)

        lbl_img.pack(pady=5)
        lbl_img.bind("<Button-1>", lambda e, p=pokemon: self.show_details(p))
        
        # Name
        lbl_name = ctk.CTkLabel(frame, text=pokemon["name"], font=("Arial", 14, "bold"))
        lbl_name.pack()
        lbl_name.bind("<Button-1>", lambda e, p=pokemon: self.show_details(p))
        
        # ID
        lbl_id = ctk.CTkLabel(frame, text=f"#{pokemon['id']}", text_color="gray")
        lbl_id.pack()
        lbl_id.bind("<Button-1>", lambda e, p=pokemon: self.show_details(p))
        # Favorite Indicator
        if pokemon['id'] in self.favorites:
            lbl_fav = ctk.CTkLabel(frame, text="⭐", font=("Arial", 16))
            lbl_fav.place(relx=0.85, rely=0.05, anchor="ne")

        return frame

    def update_list(self, event=None):
        query = self.search_var.get().lower()
        fav_only = self.fav_filter_var.get()
        sort_by = self.sort_var.get()
        type_filter = self.type_var.get()
        gen_filter = self.gen_var.get()
        
        
        print(f"DEBUG: update_list called. Query='{query}', Fav={fav_only}, Type={type_filter}, Gen={gen_filter}")
        
        # Filter
        res = []
        for p in self.pokemon_data:
            # Text Search
            if query and query not in p["name"].lower():
                continue
            
            # Favorite Filter
            if fav_only and p['id'] not in self.favorites:
                continue
                
            # Type Filter
            if type_filter != "All" and type_filter not in p["types"]:
                continue
            
            # Gen Filter
            if gen_filter != "All":
                try:
                    pid = int(p['id'])
                    gen = 0
                    if pid <= 151: gen = 1
                    elif pid <= 251: gen = 2
                    elif pid <= 386: gen = 3
                    elif pid <= 493: gen = 4
                    elif pid <= 649: gen = 5
                    elif pid <= 721: gen = 6
                    elif pid <= 809: gen = 7
                    elif pid <= 905: gen = 8
                    else: gen = 9
                    
                    if str(gen) != gen_filter:
                        continue
                except Exception as e:
                    print(f"DEBUG: Error in Gen Check for {p['name']}: {e}")
            
            res.append(p)
            
        print(f"DEBUG: Filtered result count: {len(res)}")
        
        # Sort
        if sort_by == "ID":
            res.sort(key=lambda x: x['id'])
        elif sort_by == "Name":
            res.sort(key=lambda x: x['name'])
        elif sort_by == "Total Stats":
            res.sort(key=lambda x: sum(x['stats'].values()), reverse=True)
        elif sort_by == "Speed":
            res.sort(key=lambda x: x['stats']['speed'], reverse=True)
        elif sort_by == "Attack":
            res.sort(key=lambda x: x['stats']['attack'], reverse=True)
        elif sort_by == "Defense":
            res.sort(key=lambda x: x['stats']['defense'], reverse=True)
            
        if sort_by == "Defense":
            res.sort(key=lambda x: x['stats']['defense'], reverse=True)
            
        self.filtered_data = res
        self.page = 1 # Reset to page 1 on filter change
        self.populate_grid(self.filtered_data)

    def show_details(self, pokemon):
        # Overlay
        if self.detail_frame:
            self.detail_frame.destroy()
            
        self.detail_frame = ctk.CTkFrame(self, fg_color=("gray90", "gray20")) # darker popup
        self.detail_frame.place(relx=0.5, rely=0.5, anchor="center", relwidth=0.8, relheight=0.8)
        
        # Close Button
        btn_close = ctk.CTkButton(self.detail_frame, text="X", width=30, command=self.detail_frame.destroy, fg_color="red")
        btn_close.pack(anchor="ne", padx=10, pady=10)
        
        # Content
        content = ctk.CTkScrollableFrame(self.detail_frame)
        content.pack(fill="both", expand=True, padx=20, pady=20)
        
        # Header
        header = ctk.CTkFrame(content, fg_color="transparent")
        header.pack(fill="x")
        
        # Top Actions
        actions = ctk.CTkFrame(header, fg_color="transparent")
        actions.pack(side="right", padx=10, anchor="n")
        
        # Favorite Button in Detail
        is_fav = pokemon['id'] in self.favorites
        fav_text = "★ Unpin" if is_fav else "☆ Pin"
        fav_color = "orange" if is_fav else "gray"
        btn_fav = ctk.CTkButton(actions, text=fav_text, width=80, fg_color=fav_color,
                                command=lambda: [self.toggle_favorite(pokemon['id']), self.show_details(pokemon)]) # Refresh to show change
        btn_fav.pack(pady=5)

        # Big Image
        img_path = pokemon.get("image_path")
        if img_path and os.path.exists(img_path):
             img = ctk.CTkImage(Image.open(img_path), size=(200, 200))
             ctk.CTkLabel(header, image=img, text="").pack(side="left", padx=20)
        
        info = ctk.CTkFrame(header, fg_color="transparent")
        info.pack(side="left", padx=20)
        
        ctk.CTkLabel(info, text=f"#{pokemon['id']} {pokemon['name']}", font=("Arial", 24, "bold")).pack(anchor="w")
        ctk.CTkLabel(info, text=f"Types: {', '.join(pokemon['types'])}", font=("Arial", 16)).pack(anchor="w")
        ctk.CTkLabel(info, text=f"Chain: {pokemon['evolution']}", font=("Arial", 12)).pack(anchor="w")
        
        # BST & Role
        total_stats = sum(pokemon['stats'].values())
        bst_color = "gray"
        if total_stats < 450: bst_color = "orange"
        elif total_stats < 500: bst_color = "yellow"
        elif total_stats < 600: bst_color = "green"
        else: bst_color = "cyan"
        
        # Basic Role Logic
        stats = pokemon['stats']
        role = "Balanced"
        if stats['speed'] > 100:
            if stats['attack'] > stats['special-attack']: role = "Physical Sweeper"
            else: role = "Special Sweeper"
        elif stats['defense'] > 100 or stats['special-defense'] > 100:
            role = "Tank/Wall"
        elif stats['attack'] > 110: role = "Physical Attacker"
        elif stats['special-attack'] > 110: role = "Special Attacker"
            
        ctk.CTkLabel(info, text=f"BST: {total_stats} ({role})", text_color=bst_color, font=("Arial", 14, "bold")).pack(anchor="w", pady=5)
        
        # Stats
        stats_frame = ctk.CTkFrame(content)
        stats_frame.pack(fill="x", pady=10)
        ctk.CTkLabel(stats_frame, text="Base Stats", font=("Arial", 16, "bold")).pack(anchor="w", padx=10, pady=5)
        
        for k, v in pokemon["stats"].items():
            row = ctk.CTkFrame(stats_frame, fg_color="transparent")
            row.pack(fill="x", padx=10, pady=2)
            ctk.CTkLabel(row, text=k.upper(), width=100, anchor="w").pack(side="left")
            
            # Bar
            color = "#ff8800"
            if v >= 110: 
                color = "#00ff00"
            elif v >= 80:
                color = "#aaff00" # yellow-green
            elif v > 140:
                color = "#00ffff"
            
            # Simple progress bar using frame width
            bar_container = ctk.CTkFrame(row, height=20, width=200, fg_color="gray30")
            bar_container.pack(side="left")
            bar_fill = ctk.CTkFrame(bar_container, height=20, width=int(v * 1.5), fg_color=color) # Scale factor
            bar_fill.pack(side="left")
            
            ctk.CTkLabel(row, text=str(v)).pack(side="left", padx=10)

        # Weakness Summary
        weak_frame = ctk.CTkFrame(content)
        weak_frame.pack(fill="x", pady=10)
        ctk.CTkLabel(weak_frame, text="Type Defenses", font=("Arial", 16, "bold")).pack(anchor="w", padx=10, pady=5)
        
        weaknesses = get_weaknesses(pokemon['types'])
        weak_grid = ctk.CTkFrame(weak_frame, fg_color="transparent")
        weak_grid.pack(fill="x", padx=10)
        
        # Sort by multiplier for clarity (4x, 2x, 0.5x, 0.25x, 0x)
        sorted_weak = sorted(weaknesses.items(), key=lambda x: x[1], reverse=True)
        
        # Basic flow layout
        r, c = 0, 0
        for t, m in sorted_weak:
            bg = "gray"
            if m > 1: bg = "#ff5555" # red
            if m < 1: bg = "#55aa55" # green
            if m == 0: bg = "#555555" # dark gray
            
            w_badge = ctk.CTkLabel(weak_grid, text=f"{t} x{m:g}", fg_color=bg, corner_radius=5, width=80)
            w_badge.grid(row=r, column=c, padx=2, pady=2)
            c += 1
            if c > 5:
                c = 0
                r += 1

        # Abilities & Moves (Simple list)
        am_frame = ctk.CTkFrame(content)
        am_frame.pack(fill="x", pady=10)
        
        # Interactive Abilities
        ctk.CTkLabel(am_frame, text="Abilities (Hover for info):", font=("Arial", 14, "bold")).pack(anchor="w", padx=10, pady=5)
        ab_row = ctk.CTkFrame(am_frame, fg_color="transparent")
        ab_row.pack(fill="x", padx=10)
        
        for ab in pokemon["abilities"]:
            # Check description from data if available
            desc = "No description."
            if ab in self.abilities_data:
                desc = self.abilities_data[ab]['description']
            
            # Button that shows info on click (easier than hover in pure ctk without tooltip lib)
            btn = ctk.CTkButton(ab_row, text=ab, width=100, fg_color="teal", 
                                command=lambda d=desc, n=ab: self.show_ability_info(n, d))
            btn.pack(side="left", padx=5)

        # Move Preview (Top Strongest)
        mv_frame = ctk.CTkFrame(content)
        mv_frame.pack(fill="x", pady=10)
        ctk.CTkLabel(mv_frame, text="Key Moves (by Power):", font=("Arial", 14, "bold")).pack(anchor="w", padx=10, pady=5)
        
        # Collect move data
        move_list = []
        for m_name in pokemon['moves']:
             if m_name in self.moves_data:
                 m_data = self.moves_data[m_name]
                 if m_data['power']: # Filter out status moves (power 0 or None)
                     move_list.append((m_name, m_data['type'], m_data['power'], m_data['category']))
        
        # Sort by power desc
        move_list.sort(key=lambda x: x[2], reverse=True)
        
        # Show top 10
        mv_grid = ctk.CTkFrame(mv_frame, fg_color="transparent")
        mv_grid.pack(fill="x", padx=10)
        
        headers = ["Name", "Type", "Power", "Cat"]
        for c, h in enumerate(headers):
            ctk.CTkLabel(mv_grid, text=h, font=("Arial", 12, "bold")).grid(row=0, column=c, padx=5, sticky="w")
            
        for i, (name, mtype, power, cat) in enumerate(move_list[:10]):
            r = i + 1
            ctk.CTkLabel(mv_grid, text=name).grid(row=r, column=0, padx=5, sticky="w")
            ctk.CTkLabel(mv_grid, text=mtype, text_color="cyan").grid(row=r, column=1, padx=5, sticky="w")
            ctk.CTkLabel(mv_grid, text=str(power)).grid(row=r, column=2, padx=5, sticky="w")
            ctk.CTkLabel(mv_grid, text=cat).grid(row=r, column=3, padx=5, sticky="w")

    def show_ability_info(self, name, desc):
        # Create a "tooltip" style overlay at mouse position or center
        # Since we don't have mouse pos easily passed here without current event, center it.
        
        # Check if already showing a tooltip
        if hasattr(self, 'tooltip_frame') and self.tooltip_frame:
            self.tooltip_frame.destroy()
            
        self.tooltip_frame = ctk.CTkFrame(self, fg_color="#333333", border_width=2, border_color="white")
        # Place relative to center/bottom of the detail frame or main frame
        self.tooltip_frame.place(relx=0.5, rely=0.8, anchor="center", relwidth=0.6)
        
        lbl_name = ctk.CTkLabel(self.tooltip_frame, text=name, font=("Arial", 14, "bold"), text_color="cyan")
        lbl_name.pack(pady=(10, 5))
        
        lbl_desc = ctk.CTkLabel(self.tooltip_frame, text=desc, wraplength=400)
        lbl_desc.pack(pady=(0, 10), padx=10)
        
        # Auto-close button or click to close
        btn = ctk.CTkButton(self.tooltip_frame, text="Close", width=60, height=20, fg_color="red", command=self.tooltip_frame.destroy)
        btn.pack(pady=5)
        
        # Self-destroy after 5 seconds? Or just let user close. User asked for tooltip.
        # "Hover or click". We used click.
        # Let's add an explicit close.
