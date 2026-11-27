
function gmda_manageResponses(){

var _e = gmda_pollEvent();
while (!is_undefined(_e)) {
	switch (_e.event) {

	case "session_started":
	if (_e.success && _e.is_new){
	show_message_async("Player generated!");
	}
	if (_e.success){
	gamdato_apply_player_name(gmda_getPlayername());
	gmda_matchmakingStatus();
	}
	gmda_listAchievements();
	break;

	case "tables_loaded":
	gmda_logResponse(_e);
	break;

	case "error":
	gmda_logResponse(_e);
	break;

	case "submit_completed":
	if (_e.table == SURVIVAL_LB_TABLE && !is_undefined(global.survival))
		{
		global.survival.sub = _e.response;
		global.survival.sub_t = global.survival.t;
		break;
		}
	switch (_e.response){
	case "record":       show_message_async("New record!"); break;
	case "saved":        show_message_async("Score Submitted!"); break;
	case "not_improved": show_message_async("Submitted score is not higher than the current one..."); break;
	case "error":        show_message_async("Score: "+string(_e.error)); break;
	}
	break;

	case "view_loaded":
	lb_on_view(_e);
	break;
	case "players_search_completed":
	gmda_logResponse(_e);
	break;

	case "newname_completed":
	switch (_e.response){
	case "ok":
	show_message_async("The name has been changed to: "+string(_e.player_name));
	gamdato_apply_player_name(_e.player_name);
	break;
	case "taken": show_message_async("The name has already been taken"); break;
	case "error": show_message_async("Name: "+string(_e.error)); break;
	}
	break;

	case "player_info_loaded":
	case "invitability_loaded":
	case "invitability_changed":
	gmda_logResponse(_e);
	break;

	case "invite_sent":
	case "invitations_listed":
	case "invitation_responded":
	case "invitation_cancelled":
	case "friends_loaded":
	case "friend_removed":
	gmda_logResponse(_e);
	break;

	case "achievement_unlocked":
	switch (_e.response){
	case "unlocked":
	show_message_async("Achievement got successfully");
	var _fx = asset_get_index("obj_achievement_got_effect");
	if (_fx != -1){
	var _object_effect=instance_create_depth(room_width-450,room_height-60,-1,_fx);
	_object_effect.ach_id=_e.key;
	}
	break;
	case "already": show_message_async("Achievement is already unlocked..."); break;
	case "error":   show_message_async("Achievement: "+string(_e.error)); break;
	}
	break;

	case "achievements_loaded":
	break;

	case "achievement_info_loaded":
	case "achievement_checked":
	gmda_logResponse(_e);
	break;

	case "save_loaded":
	switch (_e.response){
	case "loaded": show_message_async("Data loaded successfully"); break;
	case "empty":  show_message_async("No data received"); break;
	case "error":  show_message_async("Error loading data: "+string(_e.error)); break;
	}
	break;

	case "save_completed":
	if (_e.success){
	show_message_async("Data saved successfully");
	}else{
	show_message_async("Error saving data: "+string(_e.error));
	}
	break;

	case "saves_listed":
	case "save_deleted":
	gmda_logResponse(_e);
	break;

	case "matchmaking_joined":
	if (!_e.success){
		if (instance_exists(obj_matchmaking_search)){ with(obj_matchmaking_search){ state = "fade_out"; fade_timer = 0; }}
		game_show_notice("Matchmaking: "+string(_e.error));
	}
	break;

	case "matchmaking_left":
	case "matchmaking_cancelled":
	case "matchmaking_confirmed":
	if (!_e.success && !_e.expected) game_show_notice("Matchmaking: "+string(_e.error));
	break;

	case "matchmaking_status":
	if (_e.success){
		var _mm_st = gmda_matchmakingState();
		if (_mm_st.in_queue && !instance_exists(obj_matchmaking_search)){
		var _mm = instance_create_depth(0, 0, -9999, obj_matchmaking_search);
		_mm.mm_team_size = _mm_st.team_size;
		_mm.mm_auto_accept = _mm_st.auto_accept;
		_mm.joined_ok = true;
		}
	}else if (!_e.expected){
		game_show_notice("Matchmaking: "+string(_e.error));
	}
	break;

	case "matchmaking_peer_status":
	break;

   case "matchmaking_match_closed":
	if (room == rm_gameplay){
	if (variable_global_exists("online_mode")) global.online_mode = false;
	room_goto(rm_main_menu);
	}
	var _reason = variable_struct_exists(_e, "reason") ? string(_e.reason) : "";
	switch (_reason){
	case "no_server":  game_show_critical_overlay("CONNECTION LOST", "Lost connection to the server"); break;
	case "match_gone": game_show_critical_overlay("MATCH ENDED", "The match no longer exists"); break;
	default:           game_show_critical_overlay("CONNECTION LOST", "The opponent lost connection"); break;
	}
   break;

	case "matchmaking_match_ended":
	break;

	case "matchmaking_found":
	break;

	case "balances_loaded":
	case "inventory_loaded":
	case "purchase_completed":
	case "topup_started":
	case "ledger_loaded":
	case "currency_leaderboard_loaded":
	case "grant_completed":
	gmda_logResponse(_e);
	break;

	case "rewards_status_loaded":
	case "reward_claimed":
	gmda_logResponse(_e);
	break;

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

			if (!variable_global_exists("dlc_content_store")) {
				global.dlc_content_store = {};
			}

			if (_key != "") {
				global.dlc_content_store[$ _key] = _content;
			}
		} else {
			gmda_logResponse(_e);
			
			if (instance_exists(obj_dlc_character_button)) {
				obj_dlc_character_button.state = "locked";
			}
		}
	break;

	case "content_list_loaded": 
	case "content_sync_complete":
		gmda_logResponse(_e);
	break;

	case "group_created":
	case "groups_listed":
	case "group_info_loaded":
	case "group_updated":
	case "group_left":
	case "group_disbanded":
	case "group_joined":
	case "group_invite_sent":
	case "group_invitations_listed":
	case "group_invitation_responded":
	case "group_invitation_cancelled":
	case "group_request_created":
	case "group_requests_listed":
	case "group_request_responded":
	case "group_request_cancelled":
	case "group_member_kicked":
	case "group_member_role_assigned":
	case "group_leadership_transferred":
	gmda_logResponse(_e);
	break;

	default:
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
