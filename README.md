# MILLSTONE ROLEPLAY

A lightweight SA-MP/OMP gamemode built for serious roleplay servers. Started development in January 2026 with one goal in mind: keep it clean, keep it fast, keep it stable.

No unnecessary features. No bloated systems. Just solid fundamentals that work right out of the box.

## Features

### Account System
- MySQL database with bcrypt password encryption
- Automatic registration and login dialogs
- Position and stats persistence
- Auto-save on disconnect

### Player Systems
- Proximity chat (20 unit range)
- Automatic level progression (hourly)
- Money and skin saving
- Interior and virtual world support

### Admin Tools
- Six-tier admin hierarchy (Level 1-6)
- Map click teleportation
- Vehicle spawning system
- Player stat management

## Commands

### Admin Commands

| Command | Description | Required Level |
|---------|-------------|----------------|
| `/a [text]` | Admin chat | Level 1+ |
| `/setadmin [player] [level]` | Set admin level | Level 6 |
| `/veh [modelid] [color1] [color2]` | Spawn vehicle | Level 3+ |
| `/setskin [player] [skinid]` | Change player skin | Level 2+ |
| `/sethp [player] [amount]` | Set player health | Level 2+ |
| `/setarmor [player] [amount]` | Set player armor | Level 2+ |

## Installation

1. Clone this repository
2. Import `database.sql` to your MySQL server
3. Configure database credentials in the script
4. Compile with your preferred Pawn compiler
5. Run the server

## Requirements

- open.mp or SA-MP 0.3.7+
- MySQL R41
- Required plugins and includes (see credits)

## Credits

**Development:** YourName

**Libraries & Plugins:**
- [open.mp team](https://open.mp) - Core platform
- [BlueG](https://github.com/pBlueG/SA-MP-MySQL) - MySQL plugin (a_mysql)
- [Y_Less](https://github.com/pawn-lang/YSI-Includes) - YSI framework
- [lc_mencent](https://github.com/lc_mencent/samp-bcrypt) - bcrypt encryption (samp_bcrypt)
- [urShadow](https://github.com/urShadow/Pawn.CMD) - Command processor (Pawn.CMD)
- [maddinat0r](https://github.com/maddinat0r/sscanf) - String parser (sscanf2)

## License

Free to use. Free to modify. Just keep the credits intact.

---
