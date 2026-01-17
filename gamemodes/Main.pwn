/*
	Millstone Roleplay by Qoyf

	Description:

	  Millstone Roleplay started as a personal project in January 2026. Built it
      from scratch with open.mp in mind. Kept things simple and efficient.

      The goal was straightforward. Create a solid foundation without all the
      unnecessary features that slow servers down. No bloat, just what you need
      to run a clean roleplay server.

      This isn't some half-finished project. It's tested, stable, and ready to go.
      You can run it as is or build whatever you want on top of it. The foundation
      won't let you down.

      Free to use. Free to modify. Just keep it clean.

	Credits:

 	* Qoyf (scripter)

	Copyright(c) 2025-2026 Qoyf (All rights reserved).
*/

#include <open.mp>
#include <a_mysql>
#include <YSI_Coding\y_timers>
#include <samp_bcrypt>
#include <Pawn.CMD>
#include <sscanf2>

// MySQL
new MySQL:g_SQL;

// Dialogs
#define DIALOG_REGISTER 1
#define DIALOG_LOGIN 2

// Server Settings
#define LEVEL_UP_TIME 3600

// Default Spawn
#define DEFAULT_SPAWN_X 1685.3188
#define DEFAULT_SPAWN_Y -2331.0569
#define DEFAULT_SPAWN_Z 13.5469
#define DEFAULT_SPAWN_A 0.9578

// Colors
#define COLOR_CLIENT      (0xAAC4E5FF)
#define COLOR_WHITE       (0xFFFFFFFF)
#define COLOR_RED         (0xFF0000FF)
#define COLOR_CYAN        (0x33CCFFFF)
#define COLOR_LIGHTRED    (0xFF6347FF)
#define COLOR_LIGHTGREEN  (0x9ACD32FF)
#define COLOR_YELLOW      (0xFFFF00FF)
#define COLOR_GREY        (0xAFAFAFFF)
#define COLOR_PINK    (0xFF8282FF)
#define COLOR_PURPLE      (0xD0AEEBFF)
#define COLOR_LIGHTYELLOW (0xF5DEB3FF)
#define COLOR_DARKBLUE    (0x1394BFFF)
#define COLOR_ORANGE      (0xFFA500FF)
#define COLOR_LIME        (0x00FF00FF)
#define COLOR_GREEN       (0x33CC33FF)
#define COLOR_BLUE        (0x2641FEFF)
#define COLOR_RADIO       (0x8D8DFFFF)
#define COLOR_LIGHTBLUE   (0x007FFFFF)
#define COLOR_SERVER      (0xFFFF90FF)
#define COLOR_ADMINCHAT   (0x33EE33FF)
#define DEFAULT_COLOR     (0xFFFFFFFF)

// Message Macros
#define SendServerMessage(%0,%1) \
	SendClientMessageEx(%0, COLOR_SERVER, "SERVER:{FFFFFF} "%1)

#define SendSyntaxMessage(%0,%1) \
	SendClientMessageEx(%0, COLOR_GREY, "SYNTAX:{FFFFFF} "%1)

#define SendErrorMessage(%0,%1) \
	SendClientMessageEx(%0, COLOR_LIGHTRED, "ERROR:{FFFFFF} "%1)

#define SendAdminAction(%0,%1) \
	SendClientMessageEx(%0, COLOR_CLIENT, "ADMIN:{FFFFFF} "%1)

// Player Data
enum E_PLAYER_DATA 
{
    pID,
    pName[MAX_PLAYER_NAME],
    pPassword[61],
    pAdmin,
    pLevel,
    pMoney,
    pSkin,
    pDeaths,
    pPlayTime,
    Float:pPosX,
    Float:pPosY,
    Float:pPosZ,
    Float:pPosA,
    pInterior,
    pVirtualWorld,
    bool:pLogged
}
new pData[MAX_PLAYERS][E_PLAYER_DATA];

stock SendClientMessageEx(playerid, color, const text[], {Float, _}:...)
{
	static args, str[144];

	if((args = numargs()) == 3)
	{
	    SendClientMessage(playerid, color, text);
	}
	else
	{
		while(--args >= 3)
		{
			#emit LCTRL 5
			#emit LOAD.alt args
			#emit SHL.C.alt 2
			#emit ADD.C 12
			#emit ADD
			#emit LOAD.I
			#emit PUSH.pri
		}
		#emit PUSH.S text
		#emit PUSH.C 144
		#emit PUSH.C str
		#emit PUSH.S 8
		#emit SYSREQ.C format
		#emit LCTRL 5
		#emit SCTRL 4

		SendClientMessage(playerid, color, str);

		#emit RETN
	}
	return 1;
}

main() 
{
    print("\n");
    print("___  ________ _      _      _____ _____ _____ _   _  _____ ");
    print("|  \\/  |_   _| |    | |    /  ___|_   _|  _  | \\ | ||  ___|");
    print("| .  . | | | | |    | |    \\ `--.  | | | | | |  \\| || |__  ");
    print("| |\\/| | | | | |    | |     `--. \\ | | | | | | . ` ||  __| ");
    print("| |  | |_| |_| |____| |____/\\__/ / | | \\ \\_/ / |\\  || |___ ");
    print("\\_|  |_/\\___/\\_____/\\_____/\\____/  \\_/  \\___/\\_| \\_/\\____/");
    print("\n");
    print("===============================================================");
    print("   Millstone Roleplay v1.0");
    print("   Developed by: Qoyf");
    print("===============================================================");
    print("\n");
    print("   Credits:");
    print("   - open.mp team (https://open.mp)");
    print("   - BlueG (a_mysql plugin)");
    print("   - Y_Less (YSI libraries)");
    print("   - lc_mencent (samp_bcrypt)");
    print("   - urShadow (Pawn.CMD)");
    print("   - maddinat0r (sscanf2)");
    print("\n");
}

public OnGameModeInit() 
{
    new MySQLOpt:options = mysql_init_options();
    mysql_set_option(options, AUTO_RECONNECT, true);
    
    g_SQL = mysql_connect("localhost", "root", "", "paradise", options);
    
    if(g_SQL == MYSQL_INVALID_HANDLE || mysql_errno(g_SQL) != 0) 
    {
        print("[MySQL] Connection failed!");
        SendRconCommand("exit");
        return 1;
    }
    
    print("[MySQL] Connection established successfully!");
    
    SetGameModeText("Millstone RP v1.0");
    ShowPlayerMarkers(PLAYER_MARKERS_MODE_OFF);
    DisableInteriorEnterExits();
    EnableStuntBonusForAll(false);
    
    return 1;
}

public OnGameModeExit() 
{
    mysql_close(g_SQL);
    return 1;
}

public OnPlayerConnect(playerid) 
{
    GetPlayerName(playerid, pData[playerid][pName], MAX_PLAYER_NAME);
    ResetPlayerData(playerid);
    CheckPlayerAccount(playerid);
    
    TogglePlayerSpectating(playerid, true);
    return 1;
}

public OnPlayerDisconnect(playerid, reason) 
{
    if(pData[playerid][pLogged]) 
    {
        SavePlayerData(playerid);
    }
    ResetPlayerData(playerid);
    return 1;
}

public OnPlayerText(playerid, text[])
{
    if(!pData[playerid][pLogged]) return 0;
    
    new string[144];
    format(string, sizeof(string), "%s says: %s", pData[playerid][pName], text);
    
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    
    foreach(new i : Player)
    {
        if(GetPlayerVirtualWorld(i) == GetPlayerVirtualWorld(playerid))
        {
            if(IsPlayerInRangeOfPoint(i, 20.0, x, y, z))
            {
                SendClientMessage(i, COLOR_WHITE, string);
            }
        }
    }
    return 0;
}

public OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ)
{
    if(pData[playerid][pAdmin] < 1)
    {
        SendErrorMessage(playerid, "You don't have permission to use this feature!");
        return 1;
    }

    SetPlayerPosFindZ(playerid, fX, fY, fZ);
    SendServerMessage(playerid, "You've been teleported to your map marker.");
    return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) 
{
    switch(dialogid) 
    {
        case DIALOG_REGISTER: 
        {
            if(!response) return Kick(playerid);
            
            if(strlen(inputtext) < 6 || strlen(inputtext) > 32) 
            {
                ShowRegisterDialog(playerid, "Password must be between 6 and 32 characters!");
                return 1;
            }
            
            bcrypt_hash(playerid, "OnPasswordHashed", inputtext, 12);
            return 1;
        }
        
        case DIALOG_LOGIN: 
        {
            if(!response) return Kick(playerid);
            
            if(strlen(inputtext) < 1) 
            {
                ShowLoginDialog(playerid, "Enter your password!");
                return 1;
            }
            
            bcrypt_verify(playerid, "OnPasswordVerified", inputtext, pData[playerid][pPassword]);
            return 1;
        }
    }
    return 1;
}

ptask PlayerTime[1000](playerid)
{
    if(!pData[playerid][pLogged]) return 0;
    
    pData[playerid][pPlayTime]++;
    
    if(pData[playerid][pPlayTime] % LEVEL_UP_TIME == 0)
    {
        pData[playerid][pLevel]++;
        SetPlayerScore(playerid, pData[playerid][pLevel]);
        SendServerMessage(playerid, "Congrats! You've leveled up to level %d.", pData[playerid][pLevel]);
    }
    return 1;
}

stock ResetPlayerData(playerid) 
{
    pData[playerid][pID] = 0;
    pData[playerid][pPassword][0] = EOS;
    pData[playerid][pAdmin] = 0;
    pData[playerid][pLevel] = 1;
    pData[playerid][pMoney] = 0;
    pData[playerid][pSkin] = 0;
    pData[playerid][pDeaths] = 0;
    pData[playerid][pPlayTime] = 0;
    pData[playerid][pPosX] = 0.0;
    pData[playerid][pPosY] = 0.0;
    pData[playerid][pPosZ] = 0.0;
    pData[playerid][pPosA] = 0.0;
    pData[playerid][pInterior] = 0;
    pData[playerid][pVirtualWorld] = 0;
    pData[playerid][pLogged] = false;
}

stock SetPlayerSpawn(playerid) 
{
    SetSpawnInfo(playerid, 0, pData[playerid][pSkin], pData[playerid][pPosX], pData[playerid][pPosY], pData[playerid][pPosZ], pData[playerid][pPosA], WEAPON:0, 0, WEAPON:0, 0, WEAPON:0, 0);
    TogglePlayerSpectating(playerid, false);
    
    SetPlayerInterior(playerid, pData[playerid][pInterior]);
    SetPlayerVirtualWorld(playerid, pData[playerid][pVirtualWorld]);
    SetPlayerScore(playerid, pData[playerid][pLevel]);
    SetPlayerSkin(playerid, pData[playerid][pSkin]);
    GivePlayerMoney(playerid, pData[playerid][pMoney]);
}

stock ShowRegisterDialog(playerid, const error[] = "") 
{
    new string[256];
    format(string, sizeof(string), "%s{FFFFFF}What's up, {FFFF00}%s{FFFFFF}!\n\nYour account ain't registered yet.\nGo ahead and create a password.\n\n{FF0000}%s", error[0] ? "{FF0000}" : "", pData[playerid][pName], error);
    ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "Register", string, "Sign Up", "Quit");
}

stock ShowLoginDialog(playerid, const error[] = "") 
{
    new string[256];
    format(string, sizeof(string), "%s{FFFFFF}Welcome back, {FFFF00}%s{FFFFFF}!\n\nYour account's already registered.\nDrop your password below.\n\n{FF0000}%s", error[0] ? "{FF0000}" : "", pData[playerid][pName], error);
    ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Login", string, "Log In", "Quit");
}

stock CheckPlayerAccount(playerid) 
{
    new query[128];
    mysql_format(g_SQL, query, sizeof(query), "SELECT `password` FROM `players` WHERE `name` = '%e' LIMIT 1", pData[playerid][pName]);
    mysql_tquery(g_SQL, query, "OnPlayerAccountCheck", "d", playerid);
}

forward OnPlayerAccountCheck(playerid);
public OnPlayerAccountCheck(playerid) 
{
    if(!IsPlayerConnected(playerid)) return 0;
    
    if(cache_num_rows() > 0) 
    {
        cache_get_value_name(0, "password", pData[playerid][pPassword], 61);
        ShowLoginDialog(playerid);
    } 
    else 
    {
        ShowRegisterDialog(playerid);
    }
    return 1;
}

stock SavePlayerData(playerid) 
{
    if(!pData[playerid][pLogged]) return 0;
    
    GetPlayerPos(playerid, pData[playerid][pPosX], pData[playerid][pPosY], pData[playerid][pPosZ]);
    GetPlayerFacingAngle(playerid, pData[playerid][pPosA]);
    pData[playerid][pInterior] = GetPlayerInterior(playerid);
    pData[playerid][pVirtualWorld] = GetPlayerVirtualWorld(playerid);
    pData[playerid][pLevel] = GetPlayerScore(playerid);
    pData[playerid][pMoney] = GetPlayerMoney(playerid);
    pData[playerid][pSkin] = GetPlayerSkin(playerid);
    
    new query[512];
    mysql_format(g_SQL, query, sizeof(query), "UPDATE `players` SET `admin` = %d, `level` = %d, `money` = %d, `skin` = %d, `deaths` = %d, `playtime` = %d, `pos_x` = %f, `pos_y` = %f, `pos_z` = %f, `pos_a` = %f, `interior` = %d, `virtualworld` = %d WHERE `id` = %d", pData[playerid][pAdmin], pData[playerid][pLevel], pData[playerid][pMoney], pData[playerid][pSkin], pData[playerid][pDeaths], pData[playerid][pPlayTime], pData[playerid][pPosX], pData[playerid][pPosY], pData[playerid][pPosZ], pData[playerid][pPosA], pData[playerid][pInterior], pData[playerid][pVirtualWorld], pData[playerid][pID]);
    mysql_tquery(g_SQL, query);
    return 1;
}

stock LoadPlayerData(playerid) 
{
    cache_get_value_name_int(0, "id", pData[playerid][pID]);
    cache_get_value_name_int(0, "admin", pData[playerid][pAdmin]);
    cache_get_value_name_int(0, "level", pData[playerid][pLevel]);
    cache_get_value_name_int(0, "money", pData[playerid][pMoney]);
    cache_get_value_name_int(0, "skin", pData[playerid][pSkin]);
    cache_get_value_name_int(0, "deaths", pData[playerid][pDeaths]);
    cache_get_value_name_int(0, "playtime", pData[playerid][pPlayTime]);
    cache_get_value_name_float(0, "pos_x", pData[playerid][pPosX]);
    cache_get_value_name_float(0, "pos_y", pData[playerid][pPosY]);
    cache_get_value_name_float(0, "pos_z", pData[playerid][pPosZ]);
    cache_get_value_name_float(0, "pos_a", pData[playerid][pPosA]);
    cache_get_value_name_int(0, "interior", pData[playerid][pInterior]);
    cache_get_value_name_int(0, "virtualworld", pData[playerid][pVirtualWorld]);
    
    pData[playerid][pLogged] = true;
    
    if(pData[playerid][pPosX] == 0.0 && pData[playerid][pPosY] == 0.0) 
    {
        pData[playerid][pPosX] = DEFAULT_SPAWN_X;
        pData[playerid][pPosY] = DEFAULT_SPAWN_Y;
        pData[playerid][pPosZ] = DEFAULT_SPAWN_Z;
        pData[playerid][pPosA] = DEFAULT_SPAWN_A;
    }
    
    SetPlayerSpawn(playerid);
    SendServerMessage(playerid, "Welcome back, %s!", pData[playerid][pName]);
}

forward OnPasswordHashed(playerid);
public OnPasswordHashed(playerid) 
{
    if(!IsPlayerConnected(playerid)) return 0;
    
    new hash[61];
    bcrypt_get_hash(hash);
    
    new query[256];
    mysql_format(g_SQL, query, sizeof(query), "INSERT INTO `players` (`name`, `password`) VALUES ('%e', '%s')", pData[playerid][pName], hash);
    mysql_tquery(g_SQL, query, "OnPlayerRegister", "d", playerid);
    return 1;
}

forward OnPlayerRegister(playerid);
public OnPlayerRegister(playerid) 
{
    if(!IsPlayerConnected(playerid)) return 0;
    
    pData[playerid][pID] = cache_insert_id();
    pData[playerid][pLogged] = true;
    pData[playerid][pMoney] = 1500;
    pData[playerid][pLevel] = 1;
    pData[playerid][pSkin] = 137;
    pData[playerid][pPosX] = DEFAULT_SPAWN_X;
    pData[playerid][pPosY] = DEFAULT_SPAWN_Y;
    pData[playerid][pPosZ] = DEFAULT_SPAWN_Z;
    pData[playerid][pPosA] = DEFAULT_SPAWN_A;
    
    SetPlayerSpawn(playerid);
    SendServerMessage(playerid, "Registration complete! Welcome to Millstone Roleplay!");
    return 1;
}

forward OnPasswordVerified(playerid, bool:success);
public OnPasswordVerified(playerid, bool:success) 
{
    if(!IsPlayerConnected(playerid)) return 0;
    
    if(!success) 
    {
        ShowLoginDialog(playerid, "Wrong password! Try again.");
        return 1;
    }
    
    new query[256];
    mysql_format(g_SQL, query, sizeof(query), "SELECT * FROM `players` WHERE `name` = '%e' LIMIT 1", pData[playerid][pName]);
    mysql_tquery(g_SQL, query, "OnPlayerLogin", "d", playerid);
    return 1;
}

forward OnPlayerLogin(playerid);
public OnPlayerLogin(playerid) 
{
    if(!IsPlayerConnected(playerid)) return 0;
    
    if(cache_num_rows() > 0) 
    {
        LoadPlayerData(playerid);
    }
    return 1;
}

CMD:veh(playerid, params[])
{
    if(pData[playerid][pAdmin] < 3)
    {
        SendErrorMessage(playerid, "You don't have permission to use this command!");
        return 1;
    }

    new vehid, color1, color2;
    if(sscanf(params, "iii", vehid, color1, color2))
    {
        SendSyntaxMessage(playerid, "/veh [modelid] [color1] [color2]");
        return 1;
    }
    
    if(vehid < 400 || vehid > 611)
    {
        SendErrorMessage(playerid, "Invalid vehicle model ID! (400-611)");
        return 1;
    }

    new Float:x, Float:y, Float:z, Float:a;
    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, a);

    new vehicleid = CreateVehicle(vehid, x + 2.0, y, z, a, color1, color2, -1);
    PutPlayerInVehicle(playerid, vehicleid, 0);

    SendServerMessage(playerid, "Vehicle created. (Model: %d)", vehid);
    return 1;
}

CMD:setadmin(playerid, params[])
{
    if(pData[playerid][pAdmin] < 6)
    {
        SendErrorMessage(playerid, "You don't have permission to use this command!");
        return 1;
    }

    new targetid, level;
    if(sscanf(params, "ui", targetid, level))
    {
        SendSyntaxMessage(playerid, "/setadmin [playerid/name] [level]");
        return 1;
    }
    
    if(!IsPlayerConnected(targetid))
    {
        SendErrorMessage(playerid, "Player is not online!");
        return 1;
    }

    if(level < 0 || level > 6)
    {
        SendErrorMessage(playerid, "Admin level must be between 0-6!");
        return 1;
    }

    pData[targetid][pAdmin] = level;
    SavePlayerData(targetid);
    
    SendAdminAction(playerid, "You've set %s's admin level to %d.", pData[targetid][pName], level);
    SendAdminAction(targetid, "Your admin level has been changed to %d by %s.", level, pData[playerid][pName]);
    return 1;
}

CMD:setskin(playerid, params[])
{
    if(pData[playerid][pAdmin] < 2)
    {
        SendErrorMessage(playerid, "You don't have permission to use this command!");
        return 1;
    }

    new targetid, skinid;
    if(sscanf(params, "ui", targetid, skinid))
    {
        SendSyntaxMessage(playerid, "/setskin [playerid/name] [skinid]");
        return 1;
    }

    if(!IsPlayerConnected(targetid))
    {
        SendErrorMessage(playerid, "Player is not online!");
        return 1;
    }

    if(skinid < 0 || skinid > 311)
    {
        SendErrorMessage(playerid, "Invalid skin ID! (0-311)");
        return 1;
    }

    SetPlayerSkin(targetid, skinid);
    pData[targetid][pSkin] = skinid;

    SendAdminAction(playerid, "You've set %s's skin to ID %d.", pData[targetid][pName], skinid);
    SendServerMessage(targetid, "Your skin has been changed to ID %d by admin %s.", skinid, pData[playerid][pName]);
    return 1;
}

CMD:sethp(playerid, params[])
{
    if(pData[playerid][pAdmin] < 2)
    {
        SendErrorMessage(playerid, "You don't have permission to use this command!");
        return 1;
    }

    new targetid, Float:health;
    if(sscanf(params, "uf", targetid, health))
    {
        SendSyntaxMessage(playerid, "/sethp [playerid/name] [amount]");
        return 1;
    }

    if(!IsPlayerConnected(targetid))
    {
        SendErrorMessage(playerid, "Player is not online!");
        return 1;
    }

    if(health < 0.0 || health > 100.0)
    {
        SendErrorMessage(playerid, "Health amount must be between 0-100!");
        return 1;
    }

    SetPlayerHealth(targetid, health);

    SendAdminAction(playerid, "You've set %s's health to %.1f.", pData[targetid][pName], health);
    SendServerMessage(targetid, "Your health has been set to %.1f by admin %s.", health, pData[playerid][pName]);
    return 1;
}

CMD:setarmor(playerid, params[])
{
    if(pData[playerid][pAdmin] < 2)
    {
        SendErrorMessage(playerid, "You don't have permission to use this command!");
        return 1;
    }

    new targetid, Float:armor;
    if(sscanf(params, "uf", targetid, armor))
    {
        SendSyntaxMessage(playerid, "/setarmor [playerid/name] [amount]");
        return 1;
    }

    if(!IsPlayerConnected(targetid))
    {
        SendErrorMessage(playerid, "Player is not online!");
        return 1;
    }

    if(armor < 0.0 || armor > 100.0)
    {
        SendErrorMessage(playerid, "Armor amount must be between 0-100!");
        return 1;
    }

    SetPlayerArmour(targetid, armor);

    SendAdminAction(playerid, "You've set %s's armor to %.1f.", pData[targetid][pName], armor);
    SendServerMessage(targetid, "Your armor has been set to %.1f by admin %s.", armor, pData[playerid][pName]);
    return 1;
}

CMD:a(playerid, params[])
{
    if(pData[playerid][pAdmin] < 1)
    {
        SendErrorMessage(playerid, "You don't have permission to use this command!");
        return 1;
    }

    new text[128];
    if(sscanf(params, "s[128]", text))
    {
        SendSyntaxMessage(playerid, "/a [text]");
        return 1;
    }

    new string[144];
    format(string, sizeof(string), "Admin %s (Level %d): %s", pData[playerid][pName], pData[playerid][pAdmin], text);

    foreach(new i : Player)
    {
        if(pData[i][pAdmin] >= 1)
        {
            SendClientMessage(i, COLOR_ADMINCHAT, string);
        }
    }
    return 1;
}