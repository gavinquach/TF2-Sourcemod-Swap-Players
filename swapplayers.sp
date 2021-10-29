// Force semicolon
#pragma semicolon 1

// Includes
#include <sourcemod>
#include <tf2>					// TF enums and TF2_ functions
#include <tf2_stocks>			// more TF2_ functions

// Plugin info
#define PLUGIN_NAME			"Swap players"
#define PLUGIN_AUTHOR		"DeDstar"
#define PLUGIN_DESCRIPTION 	"Swap 2 players' team"
#define PLUGIN_VERSION		"1.0.2"
#define PLUGIN_URL			""

// Force new-style declarations (Sourcepawn 1.7 and newer)
#pragma newdecls required

public Plugin myinfo =
{
	name		= PLUGIN_NAME,
	author		= PLUGIN_AUTHOR,
	description	= PLUGIN_DESCRIPTION,
	version		= PLUGIN_VERSION,
	url			= PLUGIN_URL
};

public void OnPluginStart() {
	RegAdminCmd("sm_swap", CommandSwap, ADMFLAG_SLAY, "Swap 2 players' team. Usage: sm_swap target1 target2");
}

public Action CommandSwap(int client, int args) {
	if (GetCmdArgs() > 2) {
		ReplyToCommand(client, "\x03[SM] \x01Too many arguments! Command format: sm_swap player1_name player2_name");
		return Plugin_Handled;
	}
	else if (GetCmdArgs() < 2) {
		ReplyToCommand(client, "\x03[SM] \x01Missing arguments! Command format: sm_swap player1_name player2_name");
		return Plugin_Handled;
	}
	else if (GetCmdArgs() < 1) {
		ReplyToCommand(client, "\x03[SM] \x01Missing arguments! Command format: sm_swap player1_name player2_name");
		return Plugin_Handled;
	}
	
	char arg1[MAX_NAME_LENGTH];
	char arg2[MAX_NAME_LENGTH];
	GetCmdArg(1, arg1, sizeof(arg1));
	GetCmdArg(2, arg2, sizeof(arg2));
	int target1 = FindTarget(client, arg1);
	int target2 = FindTarget(client, arg2);
	
	if (!IsValidClient(target1)) {
		ReplyToCommand(client, "\x03[SM] \x01%N is not valid", target1);
		return Plugin_Handled;
	}
	if (!IsValidClient(target2)) {
		ReplyToCommand(client, "\x03[SM] \x01%N is not valid", target2);
		return Plugin_Handled;
	}
	
	PerformSwap(client, target1, target2);
	return Plugin_Handled;
}

void PerformSwap(int client, int client1, int client2) {
	TFTeam target1Team = TF2_GetClientTeam(client1);
	TFTeam target2Team = TF2_GetClientTeam(client2);
	
	if (target1Team == target2Team) {
		ReplyToCommand(client, "\x03[SM] \x01%N and %N are in the same team!", client1, client2);
	} else {
		LogAction(client, -1, "\"%L\" has swapped \"%L\" and \"%L\"", client, client1, client2);
		TF2_ChangeClientTeam(client1, target2Team);
		TF2_ChangeClientTeam(client2, target1Team);
	
		PrintToChatAll("\x03[SM] \x01%N has swapped %N and %N.", client, client1, client2);
	}
}

bool IsValidClient(int client) {
	if (client <= 0 || client > MaxClients || !IsClientInGame(client) || IsFakeClient(client) || IsClientSourceTV(client) || IsClientReplay(client))
		return false;
	return true;
}