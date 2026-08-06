// MANAGE SERVER RESPONSES (unified handler — FULL event surface)
// Call it right after gmda_Updatefunction() in the controller's Step event.
// Drains the extension event queue (gmda_pollEvent) and has a case for EVERY
// event the Gamdato_services extension can emit. The demo events (session,
// score, name, saves, achievements) behave like the EXAMPLE 2 project; the
// rest log the payload with gmda_logResponse() — replace those calls with
// your game code.

function gmda_manageResponses(){

var _e = gmda_pollEvent();
while (!is_undefined(_e)) {
	switch (_e.event) {

	// =====================================================================
	//  SESSION / SETUP
	// =====================================================================
	case "session_started": // { player_id, player_name, is_new }
	if (_e.success && _e.is_new){ //Player generated
	show_message_async("Player generated!");
	}
	if (_e.success){
	//The account name only exists from here on
	gamdato_apply_player_name(gmda_getPlayername());
	//In case we were left queued from an earlier session
	gmda_matchmakingStatus();
	}
	gmda_listAchievements(); //refresh unlock state for the catalog
	break;

	case "tables_loaded": // every configured leaderboard is loaded (gmda_status() turns 1)
	gmda_logResponse(_e);
	break;

	case "error": // sessions/start failed (retried automatically with backoff)
	gmda_logResponse(_e);
	break;

	// =====================================================================
	//  LEADERBOARDS & SCORES
	// =====================================================================
	case "submit_completed": // { table, response, best_score }
	switch (_e.response){
	case "record":       show_message_async("New record!"); break;
	case "saved":        show_message_async("Score Submitted!"); break;
	case "not_improved": show_message_async("Submitted score is not higher than the current one..."); break;
	case "error":        show_message_async("Score: "+string(_e.error)); break;
	}
	break;

	case "view_loaded":              // gmda_loadLeaderboardView -> { tag, response.scores, response.player_score }
	case "players_search_completed": // gmda_searchPlayers -> { response.scores }
	gmda_logResponse(_e);
	break;

	// =====================================================================
	//  PLAYERS
	// =====================================================================
	case "newname_completed": // { response, player_name }
	switch (_e.response){
	case "ok":
	show_message_async("The name has been changed to: "+string(_e.player_name));
	gamdato_apply_player_name(_e.player_name);
	break;
	case "taken": show_message_async("The name has already been taken"); break;
	case "error": show_message_async("Name: "+string(_e.error)); break;
	}
	break;

	case "player_info_loaded":   // gmda_loadPlayerInfo -> { response.player }
	case "invitability_loaded":  // gmda_getInvitability -> { response.is_invitable }
	case "invitability_changed": // gmda_setInvitability -> { response }
	gmda_logResponse(_e);
	break;

	// =====================================================================
	//  FRIENDS
	// =====================================================================
	case "invite_sent":           // gmda_sendFriendInvite
	case "invitations_listed":    // gmda_listPendingInvitations (fires twice: incoming + outgoing)
	case "invitation_responded":  // gmda_respondInvitation
	case "invitation_cancelled":  // gmda_cancelInvitation
	case "friends_loaded":        // gmda_listFriends -> { response.friends }
	case "friend_removed":        // gmda_removeFriend
	gmda_logResponse(_e);
	break;

	// =====================================================================
	//  ACHIEVEMENTS
	// =====================================================================
	case "achievement_unlocked": // { response, key }
	switch (_e.response){
	case "unlocked":
	show_message_async("Achievement got successfully");
	var _fx = asset_get_index("obj_achievement_got_effect"); //notification object (if the project has it)
	if (_fx != -1){
	var _object_effect=instance_create_depth(room_width-450,room_height-60,-1,_fx);
	_object_effect.ach_id=_e.key;
	}
	break;
	case "already": show_message_async("Achievement is already unlocked..."); break;
	case "error":   show_message_async("Achievement: "+string(_e.error)); break;
	}
	break;

	case "achievements_loaded": // { response.achievements: [{ achievement_key, name, unlocked, ... }] }
	//The plugin keeps the unlock state: gmda_getAchievementUnlocked(key)
	break;

	case "achievement_info_loaded": // gmda_getAchievementInfo -> { response: { name, points, unlocked, ... } }
	case "achievement_checked":     // gmda_checkAchievement -> { response.unlocked, response.unlocked_at }
	gmda_logResponse(_e);
	break;

	// =====================================================================
	//  CLOUD SAVES
	// =====================================================================
	case "save_loaded": // { response, slot, data }
	switch (_e.response){
	//_e.data is your saved struct, exactly as you sent it. Read each field
	//only if it came in the save: variable_struct_exists(_e.data, "money")
	case "loaded": show_message_async("Data loaded successfully"); break;
	case "empty":  show_message_async("No data received"); break;
	case "error":  show_message_async("Error loading data: "+string(_e.error)); break;
	}
	break;

	case "save_completed": // { tag: slot }
	if (_e.success){ //Data saved successfully
	show_message_async("Data saved successfully");
	}else{
	//e.g. "Cloud saving is not configured for this game" = create the save
	//schema in the panel (game -> Cloud Saves) with the exact fields you send.
	show_message_async("Error saving data: "+string(_e.error));
	}
	break;

	case "saves_listed": // gmda_listSaves -> { response.saves: [{ slot, size_bytes, updated_at }] }
	case "save_deleted": // gmda_deleteSave -> { tag: slot }
	gmda_logResponse(_e);
	break;

	// =====================================================================
	//  MATCHMAKING
	// =====================================================================
	case "matchmaking_joined":
	if (!_e.success){
		//Could not enter the queue: close the search overlay
		if (instance_exists(obj_matchmaking_search)){ with(obj_matchmaking_search){ state = "fade_out"; fade_timer = 0; }}
		show_message_async("Matchmaking: "+string(_e.error));
	}
	break;

	//These three only matter when they really fail. The plugin sets expected
	//when the failure is the normal answer and not a problem
	case "matchmaking_left":
	case "matchmaking_cancelled":
	case "matchmaking_confirmed":
	if (!_e.success && !_e.expected) show_message_async("Matchmaking: "+string(_e.error));
	break;

	case "matchmaking_status":
	if (_e.success){
		//Status updated — queue position, players found, etc.
		//Queued with no overlay up: it reopens itself
		var _mm_st = gmda_matchmakingState();
		if (_mm_st.in_queue && !instance_exists(obj_matchmaking_search)){
		var _mm = instance_create_depth(0, 0, -9999, obj_matchmaking_search);
		_mm.mm_team_size = _mm_st.team_size;
		_mm.mm_auto_accept = _mm_st.auto_accept;
		_mm.joined_ok = true; //the server just confirmed the ticket
		}
	}else if (!_e.expected){
		show_message_async("Matchmaking: "+string(_e.error));
	}
	break;

	case "matchmaking_peer_status":
	//Everyone's connection state, on every heartbeat.
	//gmda_matchmakingState().peer_ms_left gives the worst connected player's ms
	break;

	case "matchmaking_match_closed":
	//The match ends for everyone. The reason matters: it is not always the peer
	if (room == rm_gameplay){
	if (variable_global_exists("online_mode")) global.online_mode = false;
	room_goto(rm_main_menu);
	}
	var _reason = variable_struct_exists(_e, "reason") ? string(_e.reason) : "";
	switch (_reason){
	case "no_server":  show_message_async("Lost connection to the server"); break;
	case "match_gone": show_message_async("The match no longer exists"); break;
	default:           show_message_async("The opponent lost connection"); break;
	}
	break;

	case "matchmaking_match_ended":
	//The server no longer counts the match as live
	break;

	case "matchmaking_found":
	//Opponents are in gmda_matchmakingState().opponents
	//obj_matchmaking_search takes care of connecting
	break;

	// =====================================================================
	//  CURRENCY & STORE
	// =====================================================================
	case "balances_loaded":             // gmda_getBalances -> { response.balances }
	case "inventory_loaded":            // gmda_getInventory -> { response.items }
	case "purchase_completed":          // gmda_purchase -> { response }
	case "topup_started":               // gmda_buyPack -> { response.checkout_url } (open with url_open)
	case "ledger_loaded":               // gmda_getLedger -> { response.entries }
	case "currency_leaderboard_loaded": // gmda_getCurrencyLeaderboard -> { tag: code, response }
	case "grant_completed":             // gmda_grantCurrency -> { response }
	gmda_logResponse(_e);
	break;

	// =====================================================================
	//  REWARDS
	// =====================================================================
	case "rewards_status_loaded": // gmda_getRewardsStatus -> { response.rewards }
	case "reward_claimed":        // gmda_claimReward -> { response }
	gmda_logResponse(_e);
	break;

	// =====================================================================
	//  DOWNLOADABLE CONTENT
	// =====================================================================
	case "bootstrap_loaded": 
		if (_e.success) {
			global.game_bootstrap_data = _e.response;
			show_debug_message("[DLC] Bootstrap cargado OK");
		} else {
			gmda_logResponse(_e);
		}
	break;

	case "content_loaded": 
		if (_e.success) {
			var _key = variable_struct_exists(_e, "tag") ? string(_e.tag) : "";
			var _content = _e.response;
			
			show_debug_message("[DLC] Contenido recibido para la clave: " + _key);

			// Creamos el almacenamiento global si no existe
			if (!variable_global_exists("dlc_content_store")) {
				global.dlc_content_store = {};
			}

			// Guardamos el contenido usando la clave (ej: "dlc" o "gaby_pack")
			if (_key != "") {
				global.dlc_content_store[$ _key] = _content;
			}
		} else {
			// Si falla (por ejemplo error 500 o falta de conexion), se loguea el error
			gmda_logResponse(_e);
			
			// Le avisamos al boton para que no se quede colgado en "DESCARGANDO..."
			if (instance_exists(obj_dlc_character_button)) {
				obj_dlc_character_button.state = "locked";
			}
		}
	break;

	case "content_list_loaded": 
	case "content_sync_complete":
		gmda_logResponse(_e);
	break;

	// =====================================================================
	//  GROUPS / CLANS
	// =====================================================================
	case "group_created":                  // gmda_createGroup
	case "groups_listed":                  // gmda_listGroups -> { response.groups }
	case "group_info_loaded":              // gmda_getGroupInfo -> { response.group }
	case "group_updated":                  // gmda_updateGroup
	case "group_left":                     // gmda_leaveGroup
	case "group_disbanded":                // gmda_disbandGroup (leader only)
	case "group_joined":                   // gmda_joinGroup (open groups)
	case "group_invite_sent":              // gmda_sendGroupInvite
	case "group_invitations_listed":       // gmda_listGroupInvitations
	case "group_invitation_responded":     // gmda_respondGroupInvitation
	case "group_invitation_cancelled":     // gmda_cancelGroupInvitation
	case "group_request_created":          // gmda_createGroupRequest
	case "group_requests_listed":          // gmda_listGroupRequests
	case "group_request_responded":        // gmda_respondGroupRequest
	case "group_request_cancelled":        // gmda_cancelGroupRequest
	case "group_member_kicked":            // gmda_kickGroupMember
	case "group_member_role_assigned":     // gmda_assignGroupRole
	case "group_leadership_transferred":   // gmda_transferGroupLeadership
	gmda_logResponse(_e);
	break;

	default:
	// future/unknown events — logged so nothing is ever silently dropped
	gmda_logResponse(_e);
	break;
	}
	_e = gmda_pollEvent();
}

}


/// gmda_logResponse(event_struct) — default handler: prints the event, its
/// success flag and the payload to the debug output. Replace the calls above
/// with your game code per event.
function gmda_logResponse(_e){
	var _msg = "[gamdato] " + string(_e.event);
	if (variable_struct_exists(_e,"tag")) _msg += " (" + string(_e[$ "tag"]) + ")";
	if (_e.success){
	_msg += " OK";
	if (variable_struct_exists(_e,"response")) _msg += " " + json_stringify(_e[$ "response"]);
	}else{
	_msg += " ERROR";
	if (variable_struct_exists(_e,"error")) _msg += ": " + string(_e[$ "error"]);
	if (variable_struct_exists(_e,"http_status")) _msg += " (" + string(_e[$ "http_status"]) + ")";
	}
	show_debug_message(_msg);
}
