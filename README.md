# Cobblemon Offline Manager (Ultimate Edition)

## Overview
A fully offline Windows Desktop Application for the Minecraft Cobblemon mod.
Features:
- Visual Pokédex
- Competitive Team Builder
- Battle / VS Simulator
- Move & Ability Library

## Setup
1. **Install Dependencies**:
   ```
   pip install -r requirements.txt
   ```

2. **Generate Data**:
   Run the data generator script to fetch Pokemon data from PokeAPI (requires internet *once*).
   ```
   python data_generator.py
   ```
   *Note: Modify `POKEMON_LIMIT` in `data_generator.py` to fetch more or fewer Pokemon (Default set to 50 for demo).*

3. **Run Application**:
   ```
   python main.py
   ```

## Build .exe
To build a standalone executable:
```
pyinstaller --noconfirm --onedir --windowed --add-data "data;data" --add-data "images;images" main.py
```
