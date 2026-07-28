// =============================================================================
// GAMDATO SERVICES — GameMaker Extension (full-parity port of the Godot client)
// Backend: gamdato.com public API. Target: GM 2024.x | Tables are 1-based.
//
// Structure (mirrors the legacy gamdata.gml):
//   * #define <fn> blocks (no named params: use argument0 / argument[i] / argument_count)
//   * gmda_*  = public API   |   x_gmda_*  = hidden helpers
//   * Drive it from two events on a persistent controller object:
//       Step           -> gmda_Updatefunction()
//       Async HTTP     -> gmda_HTTPfunction()
//   * Almost every call is asynchronous: you fire it, then read the result from
//     the event queue with gmda_pollEvent() (the GameMaker stand-in for Godot's
//     signals). Synchronous getters (gmda_get*) read the local cache directly.
//
// Auth: session start is signed with the "simple" scheme (sha1, the only hash
// GML ships). The game must be configured with hash_algorithm = "sha1" in the
// panel. After the session opens, every other call uses the session headers.
// =============================================================================


// ===========================================================================
//  INIT  (auto-run by the extension on load)
// ===========================================================================

#define gmda_start_inic
/// Init — called automatically by the extension.

global.GMDA_VERSION = "2.0.0";
global.GMDA_BASE_URL = "https://service.gamdato.com/api/public"; // local dev: http://localhost:8086/api/public
global.GMDA_MAX_TABLES = 10;
global.GMDA_SESSION_LIFETIME_MS = 600000; // 10 min
global.GMDA_SESSION_RENEW_MS = 120000;    // renew with 2 min left
global.GMDA_RETRY_DELAY_MS = 3000;
global.GMDA_SESSION_RETRY_MAX_MS = 60000; // exponential-backoff ceiling for session retries
global.GMDA_PENDING_RETRY_MS = 5000;
global.GMDA_LOG_FILE = "gamdato.dat";

// identity + session
global._gmda_game_id = "";
global._gmda_api_key = "";
global._gmda_player_key = "";
global._gmda_player_name = "";
// Long-lived ownership credential for player_key. Returned ONCE by
// sessions/start (player creation or legacy claim); the server then REQUIRES
// it on every later sessions/start for that player_id — without it renewal
// gets 401 forever. Persisted via the secure save file.
global._gmda_player_secret = "";
global._gmda_session_id = "";
global._gmda_session_secret = "";
global._gmda_session_expires = 0;
global._gmda_session_active = false;
global._gmda_initialized = false;
global._gmda_loading = false;
global._gmda_connected = false;

// tables
global._gmda_tables = array_create(global.GMDA_MAX_TABLES, "");
global._gmda_table_count = 0;
global._gmda_table_data = array_create(global.GMDA_MAX_TABLES, -1); // ds_grid per table
global._gmda_bestscore = array_create(global.GMDA_MAX_TABLES, 0);
global._gmda_globpos = array_create(global.GMDA_MAX_TABLES, 0);
global._gmda_extrainfo = array_create(global.GMDA_MAX_TABLES, "{}"); // player custom_data as JSON, panel keys preserved
// per-table dashboard config, captured from the leaderboard responses
global._gmda_table_sort = array_create(global.GMDA_MAX_TABLES, "desc");
global._gmda_table_periods = array_create(global.GMDA_MAX_TABLES, true);

// phase machine
global._gmda_init_phase = 0; // 0 idle, 1 need session, 3 loading tables, 4 ready
global._gmda_tables_loaded = 0;
global._gmda_new_player = false;
global._gmda_retry_after = 0;
global._gmda_retry_count = 0; // consecutive failed session starts — drives exponential backoff

// pending-score retry queue (offline-safe submit)
global._gmda_pending = ds_map_create(); // table_index(string) -> json {score, meta}
global._gmda_pending_next = 0;
// While now < this, pending-score flushing is paused (server 429 quota_exceeded).
global._gmda_quota_block_until = 0;

// always_download sync bookkeeping (content_sync_complete fires when this drains)
global._gmda_sync_active = false;
global._gmda_sync_left = 0;

// matchmaking state
global._gmda_mm_in_queue = false;
global._gmda_mm_queue_position = 0;
global._gmda_mm_found = false;
global._gmda_mm_opponents = [];          // array of { ip, port, player_id, slot }
global._gmda_mm_opponent_count = 0;     // how many opponents we received
global._gmda_mm_region = "global";
global._gmda_mm_mode = "";              // preferred mode of the current ticket
global._gmda_mm_ticket_id = "";
global._gmda_mm_team_size = 1;          // players per team (1=1v1, 2=2v2, etc.)
global._gmda_mm_players_ready = 0;      // how many players confirmed
global._gmda_mm_players_needed = 0;     // total players needed to start
global._gmda_mm_confirmed = false;      // did WE accept this match
global._gmda_mm_all_ready = false;      // everybody accepted: safe to connect
global._gmda_mm_confirmed_players = []; // player ids that already accepted
global._gmda_mm_confirm_timeout_ms = 30000; // accept window, overwritten by the server
global._gmda_mm_confirm_ms_left = 0;    // server-side countdown, same for everyone
global._gmda_mm_confirm_deadline = 0;   // that countdown as a deadline, so it ticks by itself
global._gmda_mm_auto_accept = false;    // confirm by ourselves as soon as we match
global._gmda_mm_match_cancelled = false;// the match died (timeout or someone left)
// UDP connection, handed out by the server
global._gmda_mm_udp_host = "";
global._gmda_mm_udp_port = 0;
global._gmda_mm_udp_token = "";
global._gmda_mm_slot = 0;
global._gmda_mm_socket = -1;        // lent by the game with gmda_matchmakingSetSocket
global._gmda_mm_local_port = 0;
global._gmda_mm_bind_next = 0;
global._gmda_mm_bind_enabled = true;

// Live match
global._gmda_mm_match_id = "";
global._gmda_mm_in_match = false;
global._gmda_mm_hb_next = 0;
global._gmda_mm_peers = [];          // [{ player_id, player_name, ms_left, gone }]
global._gmda_mm_match_closed = false;
global._gmda_mm_grace_ms = 15000;    // dictated by the server
global._gmda_mm_hb_every_ms = 5000;  // same
global._gmda_mm_peer_deadline = 0;
global._gmda_mm_peer_warn = false;
global._gmda_mm_hb_ok_last = 0;
global._gmda_mm_signal_last = 0;     // last matchmaking reply from the server

// Match watchdog. _watch turns it on; _enforce decides whether it also ends the
// match or just logs what it would have done.
global._gmda_mm_watch   = true;
global._gmda_mm_enforce = false;

// Achievements. Kept by the plugin; read with gmda_getAchievementUnlocked
global._gmda_ach_unlocked = {};
global._gmda_ach_last_key = "";

// http + events
global._gmda_http_queue = ds_map_create(); // request id -> action tag
global._gmda_events = [];                   // queue of result structs (drained by the game)
global._gmda_date = "";
return 0;


// ===========================================================================
//  CONFIGURATION
// ===========================================================================

#define gmda_setController
/// gmda_setController(game_id, api_key) — call once at startup.
global._gmda_game_id = string(argument0);
global._gmda_api_key = string(argument1);
global._gmda_initialized = true;
global._gmda_session_active = false;
global._gmda_init_phase = 1;
global._gmda_tables_loaded = 0;
global._gmda_new_player = false;
global._gmda_retry_count = 0;
global._gmda_retry_after = 0;
gmda_refreshDate();
x_gmda_loadlog();
for (var _i = 0; _i < global._gmda_table_count; _i++) x_gmda_init_table_grid(_i);
return 1;


#define gmda_setLeaderboard
/// gmda_setLeaderboard(key1, [key2], ...) — up to 10, order = 1-based table number.
global._gmda_table_count = min(argument_count, global.GMDA_MAX_TABLES);
for (var _i = 0; _i < global._gmda_table_count; _i++) {
    global._gmda_tables[_i] = string(argument[_i]);
    global._gmda_bestscore[_i] = 0;
    global._gmda_globpos[_i] = 0;
    global._gmda_extrainfo[_i] = "{}";
    global._gmda_table_sort[_i] = "desc";
    global._gmda_table_periods[_i] = true;
    x_gmda_init_table_grid(_i);
}
x_gmda_loadlog();
return 1;


// ===========================================================================
//  STATUS & SYNC GETTERS
// ===========================================================================

#define gmda_status
/// is_ready: session active AND tables loaded. Returns 1/0.
if (global._gmda_session_active && global._gmda_init_phase >= 4) return 1;
return 0;

#define gmda_isSessionActive
/// Session alive (even mid table reload). Returns 1/0.
return global._gmda_session_active ? 1 : 0;

#define gmda_hasConnectivity
/// Last network attempt reached the server. Returns 1/0.
return global._gmda_connected ? 1 : 0;

#define gmda_getPlayername
return global._gmda_player_name;

#define gmda_getPlayerid
return global._gmda_player_key;

#define gmda_getPlayerpos
/// gmda_getPlayerpos(table) — 1-based.
var _t = argument0;
if (_t < 1 || _t > global._gmda_table_count) return 0;
return global._gmda_globpos[_t - 1];

#define gmda_getBestscore
/// gmda_getBestscore(table) — 1-based.
var _t = argument0;
if (_t < 1 || _t > global._gmda_table_count) return 0;
return global._gmda_bestscore[_t - 1];

#define gmda_getExtrainfo
/// gmda_getExtrainfo(table) — 1-based. Returns the custom_data the player
/// submitted with their best score, keyed by the field names defined in the
/// panel (e.g. { level, country }) — same as the Godot client's
/// get_extra_info(). Empty struct {} when the table is invalid or there is no
/// score yet. No network call.
var _t = argument0;
if (_t < 1 || _t > global._gmda_table_count) return {};
var _raw = global._gmda_extrainfo[_t - 1];
if (is_string(_raw) && string_char_at(_raw, 1) == "{") {
    var _cd = -1;
    try { _cd = json_parse(_raw); } catch (_e) { _cd = -1; }
    if (is_struct(_cd)) return _cd;
}
return {};

#define gmda_getTabledata
/// gmda_getTabledata(table) — 1-based, returns a ds_grid (6 cols x 10 rows) or -1.
var _t = argument0;
if (_t < 1 || _t > global._gmda_table_count) return -1;
return global._gmda_table_data[_t - 1];

#define gmda_getTableConfig
/// gmda_getTableConfig(table) — 1-based. Dashboard config captured from the
/// server: { sort_order: "asc"|"desc", periods_enabled: bool }. Defaults
/// (desc/true) until the table has loaded at least once.
var _t = argument0;
var _r = { sort_order: "desc", periods_enabled: true };
if (_t < 1 || _t > global._gmda_table_count) return _r;
_r.sort_order = global._gmda_table_sort[_t - 1];
_r.periods_enabled = global._gmda_table_periods[_t - 1];
return _r;

#define gmda_getDate
return global._gmda_date;

#define gmda_refreshDate
var _dt = date_current_datetime();
global._gmda_date = string(date_get_year(_dt)) + "-" + string(date_get_month(_dt)) + "-" + string(date_get_day(_dt))
    + " " + string(date_get_hour(_dt)) + ":" + string(date_get_minute(_dt)) + ":" + string(date_get_second(_dt));
return global._gmda_date;

#define gmda_pollEvent
/// Returns the next queued result struct { event, success, ... }, or undefined when
/// the queue is empty. Call it in a loop each Step to react to async results.
if (array_length(global._gmda_events) == 0) return undefined;
var _e = global._gmda_events[0];
array_delete(global._gmda_events, 0, 1);
return _e;


// ===========================================================================
//  LEADERBOARDS & SCORES
// ===========================================================================

#define gmda_submit
/// gmda_submit(table, score, [custom_struct]) — 1-based. -> submit_completed
///
/// The event carries response with one of these cases:
///     "record"        the player beat their own best
///     "saved"         the score was stored
///     "not_improved"  their previous best was higher, nothing was stored
///     "error"         could not be sent; the reason is in error
///
/// Plus best_score, their best after this.
/// The table refreshes itself, no need to request it again.
var _t = argument[0];
var _score = argument[1];
var _custom = (argument_count > 2) ? argument[2] : {};
if (!global._gmda_session_active) return 0;
if (_t < 1 || _t > global._gmda_table_count) return 0;
var _idx = _t - 1;
if (!x_gmda_can_improve(_idx, _score)) return 0;
var _b = {};
_b[$ "table_key"] = global._gmda_tables[_idx];
_b[$ "score"] = _score;
_b[$ "custom_data"] = _custom;
return x_gmda_post_session("/scores", _b, "submit|" + string(_idx));

#define gmda_submitWithRetry
/// gmda_submitWithRetry(table, score, [custom_struct]) — queues + retries offline.
var _t = argument[0];
var _score = argument[1];
var _custom = (argument_count > 2) ? argument[2] : {};
if (_t < 1 || _t > global._gmda_table_count) return 0;
var _idx = _t - 1;
if (!x_gmda_can_improve(_idx, _score)) return 0; // historic-only: nothing to gain
var _key = string(_idx);
var _existing = ds_map_exists(global._gmda_pending, _key) ? json_parse(global._gmda_pending[? _key]) : { score: 0, meta: {} };
if (_score <= _existing.score) return 1; // keep the higher queued score
var _entry = {}; _entry[$ "score"] = _score; _entry[$ "meta"] = _custom;
global._gmda_pending[? _key] = json_stringify(_entry);
x_gmda_savelog();
x_gmda_try_flush_pending();
return 1;

#define gmda_getPending
/// gmda_getPending(table) — 1-based, returns { score, meta } or {} if none queued.
var _t = argument0;
if (_t < 1 || _t > global._gmda_table_count) return {};
var _key = string(_t - 1);
if (!ds_map_exists(global._gmda_pending, _key)) return {};
return json_parse(global._gmda_pending[? _key]);

#define gmda_clearPending
/// gmda_clearPending(table) — 1-based, drops the queued score for that table.
var _t = argument0;
if (_t < 1 || _t > global._gmda_table_count) return 0;
var _key = string(_t - 1);
if (ds_map_exists(global._gmda_pending, _key)) { ds_map_delete(global._gmda_pending, _key); x_gmda_savelog(); }
return 1;

#define gmda_reloadinfo
/// Reload every table from the server. -> tables_loaded
if (!global._gmda_session_active) return 0;
global._gmda_tables_loaded = 0;
global._gmda_init_phase = 3;
return 1;

#define gmda_loadLeaderboardView
/// gmda_loadLeaderboardView(table, [period="all"], [options_struct]) -> view_loaded
/// options: { search, friends_only }. period: "all"|"daily"|"weekly"|"monthly".
var _t = argument[0];
var _period = (argument_count > 1) ? string(argument[1]) : "all";
var _opts = (argument_count > 2) ? argument[2] : {};
if (!global._gmda_session_active) return 0;
if (_t < 1 || _t > global._gmda_table_count) return 0;
var _idx = _t - 1;
var _b = {};
_b[$ "table_key"] = global._gmda_tables[_idx];
if (variable_struct_exists(_opts, "search") && string(_opts.search) != "") _b[$ "search"] = string(_opts.search);
var _friends = (variable_struct_exists(_opts, "friends_only") && _opts.friends_only) ? true : false;
if (_friends) _b[$ "friends_only"] = true;
var _suffix = "/leaderboards/scores" + ((_period != "all") ? ("/" + _period) : "");
return x_gmda_post_session(_suffix, _b, "view_loaded|" + string(_idx) + "|" + _period + "|" + (_friends ? "1" : "0"));

#define gmda_searchPlayers
/// gmda_searchPlayers(table, query) -> players_search_completed
var _t = argument[0];
var _q = string(argument[1]);
if (!global._gmda_session_active) return 0;
if (_t < 1 || _t > global._gmda_table_count) return 0;
if (_q == "") return 0;
var _b = {}; _b[$ "table_key"] = global._gmda_tables[_t - 1]; _b[$ "search"] = _q;
return x_gmda_post_session("/leaderboards/scores", _b, "players_search_completed");


// ===========================================================================
//  PLAYERS
// ===========================================================================

#define gmda_loadPlayerInfo
/// gmda_loadPlayerInfo(player_key) -> player_info_loaded
var _b = {}; _b[$ "player_key"] = string(argument0);
return x_gmda_post_session("/players/info", _b, "player_info_loaded");

#define gmda_setNewname
/// gmda_setNewname(new_name) -> newname_completed
var _n = x_gmda_chna(string(argument0), 30);
if (!global._gmda_session_active) return 0;
if (string_length(_n) < 2) return 0;
var _b = {}; _b[$ "player_name"] = _n;
if (!global._gmda_session_active) return 0;
var _h = x_gmda_session_headers();
x_gmda_http_patch(global.GMDA_BASE_URL + "/players/name", json_stringify(_b), _h, "newname|" + _n);
return 1;

#define gmda_getInvitability
/// -> invitability_loaded
return x_gmda_post_session("/players/invitability", {}, "invitability_loaded");

#define gmda_setInvitability
/// gmda_setInvitability(bool) -> invitability_changed
if (!global._gmda_session_active) return 0;
var _b = {}; _b[$ "is_invitable"] = (argument0 ? true : false);
var _h = x_gmda_session_headers();
x_gmda_http_patch(global.GMDA_BASE_URL + "/players/invitability", json_stringify(_b), _h, "invitability_changed");
return 1;


// ===========================================================================
//  FRIENDS
// ===========================================================================

#define gmda_sendFriendInvite
/// gmda_sendFriendInvite(player_key, [message]) -> invite_sent
var _b = {}; _b[$ "player_key"] = string(argument[0]);
if (argument_count > 1 && string(argument[1]) != "") _b[$ "message"] = x_gmda_chna(string(argument[1]), 200);
return x_gmda_post_session("/friends/invite", _b, "invite_sent");

#define gmda_listPendingInvitations
/// -> invitations_listed (fires once per direction: incoming + outgoing)
if (!global._gmda_session_active) return 0;
var _bi = {}; _bi[$ "direction"] = "incoming"; _bi[$ "status"] = "pending"; _bi[$ "limit"] = 50;
x_gmda_post_session("/friends/invitations/list", _bi, "invitations_listed");
var _bo = {}; _bo[$ "direction"] = "outgoing"; _bo[$ "status"] = "pending"; _bo[$ "limit"] = 50;
x_gmda_post_session("/friends/invitations/list", _bo, "invitations_listed");
return 1;

#define gmda_respondInvitation
/// gmda_respondInvitation(invitation_id, accept_bool) -> invitation_responded
var _b = {}; _b[$ "invitation_id"] = string(argument[0]); _b[$ "action"] = (argument[1] ? "accept" : "decline");
return x_gmda_post_session("/friends/invitations/respond", _b, "invitation_responded");

#define gmda_cancelInvitation
/// gmda_cancelInvitation(invitation_id) -> invitation_cancelled
var _b = {}; _b[$ "invitation_id"] = string(argument0);
return x_gmda_post_session("/friends/invitations/cancel", _b, "invitation_cancelled");

#define gmda_listFriends
/// gmda_listFriends([limit=100], [search=""]) -> friends_loaded
var _limit = (argument_count > 0) ? argument[0] : 100;
var _b = {}; _b[$ "limit"] = clamp(_limit, 1, 200);
if (argument_count > 1 && string(argument[1]) != "") _b[$ "search"] = string(argument[1]);
return x_gmda_post_session("/friends/list", _b, "friends_loaded");

#define gmda_removeFriend
/// gmda_removeFriend(player_key) -> friend_removed
var _b = {}; _b[$ "player_key"] = string(argument0);
return x_gmda_post_session("/friends/remove", _b, "friend_removed");


// ===========================================================================
//  ACHIEVEMENTS
// ===========================================================================

#define gmda_listAchievements
/// -> achievements_loaded
return x_gmda_post_session("/achievements/list", {}, "achievements_loaded");

#define gmda_getAchievementInfo
/// gmda_getAchievementInfo(key) -> achievement_info_loaded
var _b = {}; _b[$ "achievement_key"] = string(argument0);
return x_gmda_post_session("/achievements/info", _b, "achievement_info_loaded");

#define gmda_checkAchievement
/// gmda_checkAchievement(key) -> achievement_checked
var _b = {}; _b[$ "achievement_key"] = string(argument0);
return x_gmda_post_session("/achievements/check", _b, "achievement_checked");

#define gmda_unlockAchievement
/// gmda_unlockAchievement(key) -> achievement_unlocked
global._gmda_ach_last_key = string(argument0);
var _b = {}; _b[$ "achievement_key"] = global._gmda_ach_last_key;
return x_gmda_post_session("/achievements/unlock", _b, "achievement_unlocked");

#define gmda_getAchievementUnlocked
/// gmda_getAchievementUnlocked(key) -> true/false
/// Whether the player has that achievement. The plugin keeps it up to date on
/// every gmda_listAchievements and every unlock, with no call to the server.
var _k = string(argument0);
if (!variable_struct_exists(global._gmda_ach_unlocked, _k)) return false;
return global._gmda_ach_unlocked[$ _k] ? true : false;

#define gmda_getLastAchievementKey
/// gmda_getLastAchievementKey() -> string
/// The key of the last gmda_unlockAchievement requested, so you know which one
/// the achievement_unlocked event refers to.
return global._gmda_ach_last_key;


// ===========================================================================
//  CLOUD SAVES
// ===========================================================================

#define gmda_saveGame
/// gmda_saveGame(slot, data_struct) -> save_completed. slot 1..10.
var _slot = argument[0];
var _data = argument[1];
if (!global._gmda_session_active) return 0;
if (_slot < 1 || _slot > 10) return 0;
var _b = {}; _b[$ "slot"] = _slot; _b[$ "data"] = _data;
return x_gmda_post_session("/saves", _b, "save_completed|" + string(_slot));

#define gmda_loadGame
/// gmda_loadGame(slot) -> save_loaded
var _slot = argument0;
if (!global._gmda_session_active) return 0;
if (_slot < 1 || _slot > 10) return 0;
var _b = {}; _b[$ "slot"] = _slot;
return x_gmda_post_session("/saves/load", _b, "save_loaded|" + string(_slot));

#define gmda_listSaves
/// -> saves_listed
return x_gmda_post_session("/saves/list", {}, "saves_listed");

#define gmda_deleteSave
/// gmda_deleteSave(slot) -> save_deleted
var _slot = argument0;
if (!global._gmda_session_active) return 0;
if (_slot < 1 || _slot > 10) return 0;
var _b = {}; _b[$ "slot"] = _slot;
return x_gmda_post_session("/saves/delete", _b, "save_deleted|" + string(_slot));


// ===========================================================================
//  CURRENCY & STORE
// ===========================================================================

#define gmda_getBalances
/// -> balances_loaded
return x_gmda_get_session("/currency/balances", "balances_loaded");

#define gmda_getInventory
/// -> inventory_loaded
return x_gmda_get_session("/currency/inventory", "inventory_loaded");

#define gmda_purchase
/// gmda_purchase(sku, [idempotency_key]) -> purchase_completed
var _b = {}; _b[$ "sku"] = string(argument[0]);
_b[$ "idempotency_key"] = (argument_count > 1 && string(argument[1]) != "") ? string(argument[1]) : x_gmda_idem();
return x_gmda_post_session("/currency/purchase", _b, "purchase_completed");

#define gmda_buyPack
/// gmda_buyPack(pack_sku, [success_url], [cancel_url], [idem]) -> topup_started (opens Stripe URL)
var _b = {};
_b[$ "pack_sku"] = string(argument[0]);
_b[$ "success_url"] = (argument_count > 1 && string(argument[1]) != "") ? string(argument[1]) : "https://gamdato.com/topup/ok";
_b[$ "cancel_url"]  = (argument_count > 2 && string(argument[2]) != "") ? string(argument[2]) : "https://gamdato.com/topup/cancel";
_b[$ "idempotency_key"] = (argument_count > 3 && string(argument[3]) != "") ? string(argument[3]) : x_gmda_idem();
return x_gmda_post_session("/currency/topup/checkout", _b, "topup_started");

#define gmda_getLedger
/// gmda_getLedger([limit=50], [offset=0]) -> ledger_loaded
var _limit = (argument_count > 0) ? clamp(argument[0], 1, 200) : 50;
var _offset = (argument_count > 1) ? max(argument[1], 0) : 0;
return x_gmda_get_session("/currency/ledger?limit=" + string(_limit) + "&offset=" + string(_offset), "ledger_loaded");

#define gmda_getCurrencyLeaderboard
/// gmda_getCurrencyLeaderboard(code, [limit=20]) -> currency_leaderboard_loaded
var _code = string(argument[0]);
var _limit = (argument_count > 1) ? clamp(argument[1], 1, 100) : 20;
return x_gmda_get_session("/currency/leaderboard/" + _code + "?limit=" + string(_limit), "currency_leaderboard_loaded|" + _code);

#define gmda_grantCurrency
/// gmda_grantCurrency(reason_key, [idempotency_key]) -> grant_completed
var _b = {}; _b[$ "reason_key"] = string(argument[0]);
_b[$ "idempotency_key"] = (argument_count > 1 && string(argument[1]) != "") ? string(argument[1]) : x_gmda_idem();
return x_gmda_post_session("/currency/grant", _b, "grant_completed");


// ===========================================================================
//  REWARDS
// ===========================================================================

#define gmda_getRewardsStatus
/// -> rewards_status_loaded
return x_gmda_get_session("/rewards", "rewards_status_loaded");

#define gmda_claimReward
/// gmda_claimReward(key, [idempotency_key]) -> reward_claimed
var _b = {}; _b[$ "key"] = string(argument[0]);
_b[$ "idempotency_key"] = (argument_count > 1 && string(argument[1]) != "") ? string(argument[1]) : x_gmda_idem();
return x_gmda_post_session("/rewards/claim", _b, "reward_claimed");


// ===========================================================================
//  DOWNLOADABLE CONTENT
// ===========================================================================

#define gmda_listGameContent
/// -> content_list_loaded
return x_gmda_get_session("/gamecontent/list", "content_list_loaded");

#define gmda_getGameContent
/// gmda_getGameContent(key) -> content_loaded
var _key = string(argument0);
return x_gmda_get_session("/gamecontent/" + _key, "content_loaded|" + _key);

#define gmda_getBootstrap
/// -> bootstrap_loaded (all always_download content in one envelope)
return x_gmda_get_session("/gamecontent/bootstrap", "bootstrap_loaded");

#define gmda_syncAlwaysDownload
/// Fetches the content list, then each always_download item -> content_loaded, then content_sync_complete.
return x_gmda_get_session("/gamecontent/list", "content_sync_list");

#define gmda_syncContentKeys
/// gmda_syncContentKeys(keys) -> content_loaded per key.
/// keys: comma-separated string ("levels,packs") or an array of keys.
var _keys = argument0;
if (is_string(_keys)) _keys = x_gmda_explode(_keys, ",");
if (!global._gmda_session_active || !is_array(_keys)) return 0;
for (var _i = 0; _i < array_length(_keys); _i++) {
    var _k = string(_keys[_i]);
    if (_k == "") continue;
    x_gmda_get_session("/gamecontent/" + _k, "content_loaded|" + _k);
}
return 1;


// ===========================================================================
//  GROUPS / CLANS
// ===========================================================================

#define gmda_createGroup
/// gmda_createGroup(name, [opts_struct]) -> group_created. opts: tag, description, join_policy, max_members.
var _b = {}; _b[$ "name"] = x_gmda_chna(string(argument[0]), 50);
if (argument_count > 1) {
    var _o = argument[1];
    if (variable_struct_exists(_o, "tag")) _b[$ "tag"] = x_gmda_chna(string(_o.tag), 8);
    if (variable_struct_exists(_o, "description")) _b[$ "description"] = x_gmda_chna(string(_o.description), 500);
    if (variable_struct_exists(_o, "join_policy")) _b[$ "join_policy"] = string(_o.join_policy);
    if (variable_struct_exists(_o, "max_members")) _b[$ "max_members"] = _o.max_members;
}
return x_gmda_post_session("/groups/create", _b, "group_created");

#define gmda_listGroups
/// gmda_listGroups([search=""], [limit=50]) -> groups_listed
var _b = {}; _b[$ "limit"] = (argument_count > 1) ? clamp(argument[1], 1, 100) : 50;
if (argument_count > 0 && string(argument[0]) != "") _b[$ "search"] = string(argument[0]);
return x_gmda_post_session("/groups/list", _b, "groups_listed");

#define gmda_getGroupInfo
/// gmda_getGroupInfo([group_id=""]) -> group_info_loaded (own group when omitted)
var _b = {};
if (argument_count > 0 && string(argument[0]) != "") _b[$ "group_id"] = string(argument[0]);
return x_gmda_post_session("/groups/info", _b, "group_info_loaded");

#define gmda_updateGroup
/// gmda_updateGroup(fields_struct) -> group_updated. fields: name, description, join_policy, max_members.
var _o = argument0;
var _b = {};
if (variable_struct_exists(_o, "name")) _b[$ "name"] = x_gmda_chna(string(_o.name), 50);
if (variable_struct_exists(_o, "description")) _b[$ "description"] = x_gmda_chna(string(_o.description), 500);
if (variable_struct_exists(_o, "join_policy")) _b[$ "join_policy"] = string(_o.join_policy);
if (variable_struct_exists(_o, "max_members")) _b[$ "max_members"] = _o.max_members;
return x_gmda_post_session("/groups/update", _b, "group_updated");

#define gmda_leaveGroup
/// -> group_left
return x_gmda_post_session("/groups/leave", {}, "group_left");

#define gmda_disbandGroup
/// -> group_disbanded (leader only)
return x_gmda_post_session("/groups/disband", {}, "group_disbanded");

#define gmda_joinGroup
/// gmda_joinGroup(group_id) -> group_joined (open groups only)
var _b = {}; _b[$ "group_id"] = string(argument0);
return x_gmda_post_session("/groups/join", _b, "group_joined");

#define gmda_sendGroupInvite
/// gmda_sendGroupInvite(player_key, [message]) -> group_invite_sent
var _b = {}; _b[$ "player_key"] = string(argument[0]);
if (argument_count > 1 && string(argument[1]) != "") _b[$ "message"] = x_gmda_chna(string(argument[1]), 200);
return x_gmda_post_session("/groups/invitations/send", _b, "group_invite_sent");

#define gmda_listGroupInvitations
/// gmda_listGroupInvitations([direction="incoming"], [status="pending"], [limit=50]) -> group_invitations_listed
var _b = {};
_b[$ "direction"] = (argument_count > 0) ? string(argument[0]) : "incoming";
_b[$ "status"] = (argument_count > 1) ? string(argument[1]) : "pending";
_b[$ "limit"] = (argument_count > 2) ? clamp(argument[2], 1, 100) : 50;
return x_gmda_post_session("/groups/invitations/list", _b, "group_invitations_listed");

#define gmda_respondGroupInvitation
/// gmda_respondGroupInvitation(invitation_id, accept_bool) -> group_invitation_responded
var _b = {}; _b[$ "invitation_id"] = string(argument[0]); _b[$ "action"] = (argument[1] ? "accept" : "decline");
return x_gmda_post_session("/groups/invitations/respond", _b, "group_invitation_responded");

#define gmda_cancelGroupInvitation
/// gmda_cancelGroupInvitation(invitation_id) -> group_invitation_cancelled
var _b = {}; _b[$ "invitation_id"] = string(argument0);
return x_gmda_post_session("/groups/invitations/cancel", _b, "group_invitation_cancelled");

#define gmda_createGroupRequest
/// gmda_createGroupRequest(group_id, [message]) -> group_request_created
var _b = {}; _b[$ "group_id"] = string(argument[0]);
if (argument_count > 1 && string(argument[1]) != "") _b[$ "message"] = x_gmda_chna(string(argument[1]), 200);
return x_gmda_post_session("/groups/requests/create", _b, "group_request_created");

#define gmda_listGroupRequests
/// gmda_listGroupRequests([direction="incoming"], [status="pending"], [limit=50]) -> group_requests_listed
var _b = {};
_b[$ "direction"] = (argument_count > 0) ? string(argument[0]) : "incoming";
_b[$ "status"] = (argument_count > 1) ? string(argument[1]) : "pending";
_b[$ "limit"] = (argument_count > 2) ? clamp(argument[2], 1, 100) : 50;
return x_gmda_post_session("/groups/requests/list", _b, "group_requests_listed");

#define gmda_respondGroupRequest
/// gmda_respondGroupRequest(request_id, approve_bool) -> group_request_responded
var _b = {}; _b[$ "request_id"] = string(argument[0]); _b[$ "action"] = (argument[1] ? "approve" : "reject");
return x_gmda_post_session("/groups/requests/respond", _b, "group_request_responded");

#define gmda_cancelGroupRequest
/// gmda_cancelGroupRequest(request_id) -> group_request_cancelled
var _b = {}; _b[$ "request_id"] = string(argument0);
return x_gmda_post_session("/groups/requests/cancel", _b, "group_request_cancelled");

#define gmda_kickGroupMember
/// gmda_kickGroupMember(player_key) -> group_member_kicked
var _b = {}; _b[$ "player_key"] = string(argument0);
return x_gmda_post_session("/groups/members/kick", _b, "group_member_kicked");

#define gmda_assignGroupRole
/// gmda_assignGroupRole(player_key, role) -> group_member_role_assigned. role: admin/member/custom (not "leader").
var _b = {}; _b[$ "player_key"] = string(argument[0]); _b[$ "role"] = string(argument[1]);
return x_gmda_post_session("/groups/members/assign-role", _b, "group_member_role_assigned");

#define gmda_transferGroupLeadership
/// gmda_transferGroupLeadership(player_key) -> group_leadership_transferred
var _b = {}; _b[$ "player_key"] = string(argument0);
return x_gmda_post_session("/groups/members/transfer-leadership", _b, "group_leadership_transferred");


// ===========================================================================
//  MATCHMAKING
// ===========================================================================

#define gmda_matchmakingState
/// gmda_matchmakingState() -> struct with the WHOLE matchmaking state.
///
///   { in_queue, ticket_id, position, team_size, auto_accept,
///     found, opponents, players_ready, players_needed,
///     confirmed, confirmed_players, all_ready, confirm_ms_left,
///     slot, in_match, peer_ms_left, closed, server_ms_ago }
///
///   slot           our seat in the match. 0 is the one everyone connects to
///   confirm_ms_left, peer_ms_left   countdowns, ready to draw
///   server_ms_ago  how long the server has been silent
///
///     var _mm = gmda_matchmakingState();
///     if (_mm.found && !_mm.all_ready) { ...accept screen... }
///     if (_mm.peer_ms_left > 0)        { ...reconnecting notice... }
return {
    in_queue:          global._gmda_mm_in_queue,
    ticket_id:         global._gmda_mm_ticket_id,
    position:          global._gmda_mm_queue_position,
    team_size:         global._gmda_mm_team_size,
    auto_accept:       global._gmda_mm_auto_accept,
    found:             global._gmda_mm_found,
    opponents:         global._gmda_mm_opponents,
    players_ready:     global._gmda_mm_players_ready,
    players_needed:    global._gmda_mm_players_needed,
    confirmed:         global._gmda_mm_confirmed,
    confirmed_players: global._gmda_mm_confirmed_players,
    all_ready:         global._gmda_mm_all_ready,
    confirm_ms_left:   (global._gmda_mm_found && global._gmda_mm_confirm_deadline > 0)
                       ? max(0, global._gmda_mm_confirm_deadline - current_time) : 0,
    slot:              global._gmda_mm_slot,
    in_match:          global._gmda_mm_in_match,
    peer_ms_left:      x_gmda_mm_peer_left(),
    closed:            global._gmda_mm_match_closed,
    server_ms_ago:     (global._gmda_mm_signal_last > 0) ? (current_time - global._gmda_mm_signal_last) : 0
};


#define gmda_matchmakingJoin
/// gmda_matchmakingJoin([options]) -> matchmaking_joined
/// Enters the matchmaking queue.
///
/// options: struct, ALL optional.
///   { team_size:   2               players per team. Default 1 (1v1)
///     version:     "1.4.0"         only match this same version
///     region:      "eu"            filter by region
///     mode:        "ranked"        filter by mode
///     metadata:    { rating: 1500 } your own game data
///     auto_accept: true }          confirm by itself, with no accept screen
///
/// With nothing:  gmda_matchmakingJoin()  -> 1v1 in the global pool.
///
/// region and mode are filters, and must exist in the panel if you use them.
/// version splits queues, so an old build never meets a new one.
///
/// Older forms, still supported:
///   gmda_matchmakingJoin(team_size, options)
///   gmda_matchmakingJoin(team_size, region, [mode], [metadata], [auto_accept])
if (!global._gmda_session_active) return 0;
if (global._gmda_mm_in_queue) return 0;
// Already holding a match: the server would hand the same matched ticket back,
// but the reply is parsed as a fresh queue entry and would wipe the opponents
// we are in the middle of connecting to. Leave or cancel first.
if (global._gmda_mm_found) return 0;
var _team_size = 1;
var _region = "";
var _mode = "";
var _version = global.GMDA_VERSION;
var _meta = {};
var _auto = false;

// Three calling forms, told apart by the type of the first argument. A struct
// is the new form; a number is one of the old ones. Detecting it here keeps
// already-shipped games working.
var _o = undefined;
if (argument_count > 0 && is_struct(argument[0])) {
    _o = argument[0];                       // gmda_matchmakingJoin({ ... })
} else {
    if (argument_count > 0) _team_size = real(argument[0]);
    if (argument_count > 1 && is_struct(argument[1])) {
        _o = argument[1];                   // gmda_matchmakingJoin(n, { ... })
    } else {                                // forma posicional original
        if (argument_count > 1) _region = string(argument[1]);
        if (argument_count > 2) _mode = string(argument[2]);
        if (argument_count > 3 && is_struct(argument[3])) _meta = argument[3];
        if (argument_count > 4) _auto = argument[4] ? true : false;
    }
}
if (is_struct(_o)) {
    if (variable_struct_exists(_o, "team_size")) _team_size = real(_o[$ "team_size"]);
    if (variable_struct_exists(_o, "region")) _region = string(_o[$ "region"]);
    if (variable_struct_exists(_o, "mode")) _mode = string(_o[$ "mode"]);
    if (variable_struct_exists(_o, "metadata") && is_struct(_o[$ "metadata"])) _meta = _o[$ "metadata"];
    if (variable_struct_exists(_o, "auto_accept")) _auto = _o[$ "auto_accept"] ? true : false;
    if (variable_struct_exists(_o, "version") && string(_o[$ "version"]) != "") _version = string(_o[$ "version"]);
}
_team_size = clamp(_team_size, 1, 8);
global._gmda_mm_auto_accept = _auto;
global._gmda_mm_bind_enabled = true;
global._gmda_mm_match_cancelled = false;
// A fresh search starts the silence count from now, not from whatever the last
// one left behind
global._gmda_mm_signal_last = current_time;
var _b = {};
_b[$ "team_size"] = _team_size;
// Region and mode are only sent when asked for. Empty = global pool.
if (_region != "") _b[$ "region"] = _region;
_b[$ "version"] = _version;
_b[$ "player_id"] = global._gmda_player_key;
_b[$ "player_name"] = global._gmda_player_name;
if (_mode != "") _b[$ "preferred_mode"] = _mode;
if (!is_struct(_meta)) _meta = {};
if (!variable_struct_exists(_meta, "udp_port") && global._gmda_mm_local_port > 0) {
    _meta[$ "udp_port"] = global._gmda_mm_local_port;
}
if (variable_struct_names_count(_meta) > 0) _b[$ "metadata"] = _meta;
global._gmda_mm_region = _region;
global._gmda_mm_mode = _mode;
global._gmda_mm_team_size = _team_size;
global._gmda_mm_players_needed = _team_size * 2;
return x_gmda_post_session("/matchmaking/join", _b, "mm_join");


#define x_gmda_mm_leave
/// Internal: releases the queue ticket without cancelling the match.
if (!global._gmda_session_active) return 0;
if (!global._gmda_mm_in_queue && global._gmda_mm_ticket_id == "") return 0;
var _b = {};
_b[$ "ticket_id"] = global._gmda_mm_ticket_id;
_b[$ "player_id"] = global._gmda_player_key;
return x_gmda_post_session("/matchmaking/leave", _b, "mm_leave");


#define gmda_matchmakingCancel
/// gmda_matchmakingCancel()
/// Leaves the queue, or declines a match already found. It covers both: which
/// one applies is decided by the plugin.
if (!global._gmda_session_active) return 0;
if (!global._gmda_mm_in_queue && !global._gmda_mm_found && global._gmda_mm_ticket_id == "") return 0;
var _b = {};
_b[$ "ticket_id"] = global._gmda_mm_ticket_id;
_b[$ "player_id"] = global._gmda_player_key;
if (global._gmda_mm_found) return x_gmda_post_session("/matchmaking/cancel", _b, "mm_cancel");
return x_gmda_post_session("/matchmaking/leave", _b, "mm_leave");


#define gmda_matchmakingStatus
/// gmda_matchmakingStatus() -> matchmaking_status
/// Polls current queue status (position, estimated wait, players found so far).
/// Callable even when this client does not think it is queued: with an empty
/// ticket_id the server looks the player up, which is how a client that just
/// restarted finds out it still has a live ticket.
if (!global._gmda_session_active) return 0;
var _b = {};
_b[$ "ticket_id"] = global._gmda_mm_ticket_id;
_b[$ "player_id"] = global._gmda_player_key;
return x_gmda_post_session("/matchmaking/status", _b, "mm_status");


#define gmda_matchmakingConfirm
/// gmda_matchmakingConfirm() -> matchmaking_confirmed
/// Confirms the match after receiving matchmaking_found.
/// All players must confirm before the window expires.
if (!global._gmda_session_active) return 0;
if (!global._gmda_mm_found) return 0;
var _b = {};
_b[$ "ticket_id"] = global._gmda_mm_ticket_id;
_b[$ "player_id"] = global._gmda_player_key;
return x_gmda_post_session("/matchmaking/confirm", _b, "mm_confirm");


#define gmda_matchmakingGetEndpoint
/// gmda_matchmakingGetEndpoint([index]) -> { host, port }
/// Where to send that opponent's packets. index defaults to 0.
/// host "" and port 0 when there is no address yet.
///
/// How the opponent is reached is the plugin's business; the game just sends
/// wherever this says.
var _idx = (argument_count > 0) ? real(argument[0]) : 0;

if (global._gmda_mm_udp_host != "" && global._gmda_mm_udp_port > 0) {
    return { host: global._gmda_mm_udp_host, port: global._gmda_mm_udp_port };
}

var _o = gmda_matchmakingGetOpponent(_idx);
if (!is_struct(_o)) return { host: "", port: 0 };
return { host: string(_o[$ "ip"]), port: real(_o[$ "port"]) };


#define gmda_matchmakingGetOpponent
/// gmda_matchmakingGetOpponent(index) -> { ip, port, player_id, slot }
/// Returns opponent data at index (0-based), or -1 if out of range.
if (!global._gmda_mm_found) return -1;
var _idx = (argument_count > 0) ? real(argument[0]) : 0;
if (_idx < 0 || _idx >= global._gmda_mm_opponent_count) return -1;
return global._gmda_mm_opponents[_idx];


#define gmda_matchmakingMatchStarted
/// gmda_matchmakingMatchStarted()
/// Tells the plugin the fight started. From here on it watches everyone's
/// connection and emits matchmaking_match_closed if somebody drops.
x_gmda_mm_leave();
global._gmda_mm_in_queue = false;
global._gmda_mm_found = false;
global._gmda_mm_all_ready = false;
global._gmda_mm_ticket_id = "";
global._gmda_mm_match_closed = false;
global._gmda_mm_peers = [];

global._gmda_mm_in_match = true;
global._gmda_mm_hb_next = 0;
global._gmda_mm_peer_warn = false;
global._gmda_mm_peer_deadline = 0;
global._gmda_mm_hb_ok_last = current_time;

global._gmda_mm_bind_next = 0;
x_gmda_p2p_bind();
global._gmda_mm_bind_enabled = false;
return 1;


#define gmda_matchmakingMatchEnded
/// gmda_matchmakingMatchEnded()
/// The fight ended, or the player left. Stops the heartbeat and tells the
/// server so the match stops counting as live.
if (!global._gmda_mm_in_match) return 0;
var _id = global._gmda_mm_match_id;
global._gmda_mm_in_match = false;
global._gmda_mm_match_id = "";
global._gmda_mm_peers = [];
global._gmda_mm_match_closed = false;
if (_id != "" && global._gmda_session_active) {
    var _b = {};
    _b[$ "match_id"] = _id;
    x_gmda_post_session("/matchmaking/end", _b, "mm_end");
}
return 1;


#define x_gmda_mm_peer_left
/// Milliseconds left for the WORST connected player before the match closes on
/// a disconnect.
///
/// Returns 0 while everything is fine, so this is enough:
///     var _left = gmda_matchmakingState().peer_ms_left;
///     if (_left > 0) { ...show a notice and a countdown... }
if (!global._gmda_mm_in_match) return 0;
if (!global._gmda_mm_peer_warn) return 0;
if (global._gmda_mm_peer_deadline <= 0) return 0;
return max(0, global._gmda_mm_peer_deadline - current_time);


#define x_gmda_mm_close
/// x_gmda_mm_close(reason)
/// Closes the live match, once, and tells the game. Every path by which a match
/// dies goes through here.
var _motivo = argument0;
if (!global._gmda_mm_watch) return 0;

// Without _enforce it only logs to the console what would have happened
if (!global._gmda_mm_enforce) {
    var _pms = 0;
    for (var _i = 0; _i < array_length(global._gmda_mm_peers); _i++) {
        var _p = global._gmda_mm_peers[_i];
        if (string(_p[$ "player_id"]) == global._gmda_player_key) continue;
        _pms = real(_p[$ "ms_left"]);
    }
    show_debug_message("[mm] CERRARIA la partida: motivo=" + string(_motivo)
        + " match=" + string(global._gmda_mm_match_id)
        + " ms_rival=" + string(_pms)
        + " desde_ultimo_latido_ok=" + string(current_time - global._gmda_mm_hb_ok_last)
        + " gracia=" + string(global._gmda_mm_grace_ms));
    return 0;
}

if (!global._gmda_mm_in_match && global._gmda_mm_match_closed) return 0;

global._gmda_mm_match_closed = true;
global._gmda_mm_in_match = false;
global._gmda_mm_peer_warn = false;
global._gmda_mm_peer_deadline = 0;

var _id = global._gmda_mm_match_id;
global._gmda_mm_match_id = "";

x_gmda_emit("matchmaking_match_closed", {
    success: true,
    match_id: _id,
    players: global._gmda_mm_peers,
    reason: _motivo
});
return 1;


#define x_gmda_mm_heartbeat
/// Heartbeat for the live match. Self-throttled; a no-op outside a fight.
if (!global._gmda_mm_watch) return 0;
if (!global._gmda_mm_in_match) return 0;

var _now = current_time;
if (_now < global._gmda_mm_hb_next) return 0;
global._gmda_mm_hb_next = _now + global._gmda_mm_hb_every_ms;

// If the server stops answering for the whole grace window the match closes
// anyway: word that the other player dropped travels IN the heartbeat reply,
// and with no reply it can never arrive.
if (global._gmda_mm_hb_ok_last > 0
    && (_now - global._gmda_mm_hb_ok_last) > global._gmda_mm_grace_ms) {
    x_gmda_mm_close("no_server");
    if (global._gmda_mm_enforce) return 0;
}

if (!global._gmda_session_active) return 0;
// We beat even without knowing the id: the server knows which match we are in
var _b = {};
_b[$ "match_id"] = global._gmda_mm_match_id;
return x_gmda_post_session("/matchmaking/heartbeat", _b, "mm_heartbeat");


#define gmda_matchmakingSetSocket
/// gmda_matchmakingSetSocket(socket, [port])
/// Lends the extension the UDP socket your netcode already uses. Call it once,
/// after your socket exists and before joining a queue.
///
/// Skip it and matchmaking still works, but the players may not reach each
/// other across networks.
global._gmda_mm_socket = (argument_count > 0) ? argument[0] : -1;
global._gmda_mm_local_port = (argument_count > 1) ? real(argument[1]) : global._gmda_mm_local_port;
global._gmda_mm_bind_next = 0;
return 1;


#define x_gmda_p2p_bind
/// Internal: tells the server which address our router maps us to.
/// Self-throttled; expects no reply.
if (!global._gmda_mm_bind_enabled) return 0;
if (global._gmda_mm_socket == -1) return 0;
if (global._gmda_mm_udp_host == "" || global._gmda_mm_udp_port <= 0) return 0;
if (global._gmda_mm_udp_token == "") return 0;
var _now = current_time;
if (_now < global._gmda_mm_bind_next) return 0;
global._gmda_mm_bind_next = _now + 5000;
var _tok = global._gmda_mm_udp_token;
var _b = buffer_create(1 + string_byte_length(_tok), buffer_fixed, 1);
buffer_write(_b, buffer_u8, 0x01);
buffer_write(_b, buffer_text, _tok); // buffer_text: no terminating null
network_send_udp_raw(global._gmda_mm_socket, global._gmda_mm_udp_host, global._gmda_mm_udp_port, _b, buffer_get_size(_b));
buffer_delete(_b);
return 1;


#define x_gmda_read_udp
/// Internal: picks up the connection block the server attaches to join and
/// status replies.
var _r = argument0;
if (!is_struct(_r) || !variable_struct_exists(_r, "udp")) return 0;
var _u = _r[$ "udp"];
if (!is_struct(_u)) return 0;
if (variable_struct_exists(_u, "host")) global._gmda_mm_udp_host = string(_u[$ "host"]);
if (variable_struct_exists(_u, "port")) global._gmda_mm_udp_port = real(_u[$ "port"]);
// A new token forces an announce right away, without waiting for the interval:
// until it announces with it, the opponent has nowhere to send anything
if (variable_struct_exists(_u, "token")) {
    var _tok_nuevo = string(_u[$ "token"]);
    if (_tok_nuevo != global._gmda_mm_udp_token) {
        global._gmda_mm_udp_token = _tok_nuevo;
        global._gmda_mm_bind_next = 0;
    }
}
if (variable_struct_exists(_u, "slot")) global._gmda_mm_slot = real(_u[$ "slot"]);
return 1;


#define gmda_matchmakingTakeCancelled
/// Returns 1 once if the match died under us — the accept window closed, or
/// another player cancelled — and clears the flag, so exactly one reader sees
/// each cancellation. Returns 0 otherwise.
if (!global._gmda_mm_match_cancelled) return 0;
global._gmda_mm_match_cancelled = false;
global._gmda_mm_udp_host = "";
global._gmda_mm_udp_port = 0;
global._gmda_mm_udp_token = "";
global._gmda_mm_slot = 0;
return 1;


#define gmda_matchmakingClear
/// Forgets the local search: no ticket, not queued, no match, no opponents.
/// Call it once the match is under way, or when the server stopped answering
/// and the leftover state would otherwise lock the player out of searching
/// again. It does NOT talk to the server — pair it with gmda_matchmakingCancel
/// to release the ticket too.
global._gmda_mm_in_queue = false;
global._gmda_mm_found = false;
global._gmda_mm_all_ready = false;
global._gmda_mm_confirmed = false;
global._gmda_mm_ticket_id = "";
global._gmda_mm_queue_position = 0;
global._gmda_mm_opponents = [];
global._gmda_mm_opponent_count = 0;
global._gmda_mm_confirmed_players = [];
global._gmda_mm_confirm_deadline = 0;
global._gmda_mm_match_cancelled = false;
return 1;


// ===========================================================================
//  UPDATE LOOP — call from the Step event
// ===========================================================================

#define gmda_Updatefunction
if (!global._gmda_initialized) return 0;
var _now = real(x_gmda_get_timestamp());

// Phase 1: need a session
// The retry wait gates this block and nothing else: the rest of the update has
// to keep running even when the server does not answer
if (global._gmda_init_phase == 1 && !global._gmda_loading && _now >= global._gmda_retry_after) {
    global._gmda_loading = true;
    var _b = {};
    if (global._gmda_player_key != "") {
        _b[$ "player_id"] = global._gmda_player_key;
        // Send player_secret only when we have one. Legacy players (created
        // before the secret rollout) hit this branch with an empty secret;
        // the server claims-on-first-use and returns the secret once.
        if (global._gmda_player_secret != "") _b[$ "player_secret"] = global._gmda_player_secret;
    }
    var _json = json_stringify(_b);
    var _h = x_gmda_game_auth_headers(_json);
    x_gmda_http_post(global.GMDA_BASE_URL + "/sessions/start", _json, _h, "session_start");
}

// Phase 3: load tables one at a time
if (global._gmda_init_phase == 3 && !global._gmda_loading) {
    if (global._gmda_tables_loaded < global._gmda_table_count) {
        global._gmda_loading = true;
        var _tk = global._gmda_tables[global._gmda_tables_loaded];
        var _tb = {}; _tb[$ "table_key"] = _tk;
        var _th = x_gmda_session_headers();
        x_gmda_http_post(global.GMDA_BASE_URL + "/leaderboards/scores", json_stringify(_tb), _th, "load_table|" + string(global._gmda_tables_loaded));
    } else {
        global._gmda_init_phase = 4;
        x_gmda_savelog();
        x_gmda_emit("tables_loaded", { success: true });
        x_gmda_try_flush_pending();
    }
}

// Session renewal
// The current credentials keep working until the new ones arrive; only a 401
// throws the session away
if (global._gmda_session_active && global._gmda_init_phase >= 4) {
    if (_now > global._gmda_session_expires - global.GMDA_SESSION_RENEW_MS) {
        global._gmda_init_phase = 1;
        global._gmda_loading = false;
    }
}

// Pending-score retry
if (global._gmda_pending_next != 0 && _now >= global._gmda_pending_next) {
    x_gmda_try_flush_pending();
}

x_gmda_p2p_bind();
x_gmda_mm_heartbeat();

// Status polling. It keeps running after a match is found: the accept step is
// watched through here. Once everybody accepted there is nothing left to ask.
var _mm_waiting_accept = global._gmda_mm_found && !global._gmda_mm_all_ready;
if ((global._gmda_mm_in_queue || _mm_waiting_accept) && !global._gmda_loading) {
    if (!variable_global_exists("_gmda_mm_poll_next")) global._gmda_mm_poll_next = 0;
    if (_now >= global._gmda_mm_poll_next) {
        // Faster during the accept window, so "the other one accepted" does not
        // sit stale
        global._gmda_mm_poll_next = _now + (_mm_waiting_accept ? 2000 : 3000);
        gmda_matchmakingStatus();
    }
}
return 1;


// ===========================================================================
//  ASYNC HTTP HANDLER — call from the Async HTTP event
// ===========================================================================

#define gmda_HTTPfunction
var _req_id = async_load[? "id"];
if (!ds_map_exists(global._gmda_http_queue, _req_id)) return 0;

var _status = async_load[? "status"];
// status 1 = still downloading (progress event for large bodies, e.g. 10MB
// saves) — keep the tag queued and wait for the final event.
if (_status == 1) return 0;

var _action = global._gmda_http_queue[? _req_id];
ds_map_delete(global._gmda_http_queue, _req_id);

var _http_status = async_load[? "http_status"];
var _parts = x_gmda_explode(_action, "|");
var _cmd = _parts[0];

// session_start + load_table own the loading flag (they drive the phase machine).
if (_cmd == "session_start" || _cmd == "load_table") global._gmda_loading = false;

// Any matchmaking reply proves the server is still there. The search UI needs
// that to give up when it goes quiet, and working it out from the outside meant
// the game tracking a timestamp of its own on every matchmaking event.
if (string_copy(_cmd, 1, 3) == "mm_") global._gmda_mm_signal_last = current_time;

var _result_str = async_load[? "result"];
var _response = -1;
if (is_string(_result_str) && string_length(_result_str) > 0) {
    try { _response = json_parse(_result_str); } catch (_e) { _response = -1; }
}

// Connectivity: any HTTP reply means the server was reachable.
global._gmda_connected = (_status >= 0);

// Errors
if (_status < 0 || _http_status < 200 || _http_status >= 300) {
    x_gmda_handle_error(_cmd, _parts, _response, _http_status);
    return 0;
}

// A successful response means we're under quota again — resume pending retries.
global._gmda_quota_block_until = 0;

// Sliding session lifetime
if (global._gmda_session_active) global._gmda_session_expires = real(x_gmda_get_timestamp()) + global.GMDA_SESSION_LIFETIME_MS;

switch (_cmd) {
    case "session_start":
        global._gmda_session_id = _response[$ "session_id"];
        global._gmda_session_secret = _response[$ "session_secret"];
        global._gmda_session_expires = real(x_gmda_get_timestamp()) + global.GMDA_SESSION_LIFETIME_MS;
        global._gmda_session_active = true;
        global._gmda_retry_count = 0; // success resets the backoff curve
        var _old = global._gmda_player_key;
        global._gmda_player_key = _response[$ "player_id"];
        global._gmda_player_name = _response[$ "player_name"];
        // Capture player_secret if the server returned one (player creation or
        // legacy claim — delivered ONLY once). On later session starts the
        // server returns null; never overwrite a stored secret with empty.
        if (variable_struct_exists(_response, "player_secret")) {
            var _psec = _response[$ "player_secret"];
            if (is_string(_psec) && _psec != "") global._gmda_player_secret = _psec;
        }
        global._gmda_new_player = (_old == "");
        x_gmda_savelog();
        global._gmda_init_phase = 3;
        global._gmda_tables_loaded = 0;
        x_gmda_emit("session_started", { success: true, player_id: global._gmda_player_key, player_name: global._gmda_player_name, is_new: global._gmda_new_player });
        break;

    case "load_table":
        x_gmda_apply_table(real(_parts[1]), _response);
        global._gmda_tables_loaded++;
        break;

    case "submit":
        var _sidx = real(_parts[1]);
        if (is_struct(_response) && variable_struct_exists(_response, "score") && is_struct(_response[$ "score"])) {
            global._gmda_bestscore[_sidx] = _response[$ "score"][$ "score"];
        }
        // a queued retry for this table succeeded -> drop it
        var _pk = string(_sidx);
        if (ds_map_exists(global._gmda_pending, _pk)) ds_map_delete(global._gmda_pending, _pk);
        x_gmda_savelog();
        // The server tells writing the historic best apart from only improving
        // the periods. That is leaderboard bookkeeping: the game just needs one
        // case. With no field -or an older server- it counts as saved, which is
        // the safe assumption: nobody is told they did not improve because of a
        // missing field.
        var _fx = (is_struct(_response) && variable_struct_exists(_response, "effect")) ? string(_response[$ "effect"]) : "";
        var _res = "saved";
        if (_fx == "updated") _res = "record";
        else if (_fx == "not_improved") _res = "not_improved";
        x_gmda_emit("submit_completed", {
            success: true,
            table: _sidx + 1,
            response: _res,
            best_score: global._gmda_bestscore[_sidx]
        });
        // refresh just this table
        var _rb = {}; _rb[$ "table_key"] = global._gmda_tables[_sidx];
        x_gmda_post_session("/leaderboards/scores", _rb, "refresh_table|" + string(_sidx));
        break;

    case "refresh_table":
        x_gmda_apply_table(real(_parts[1]), _response);
        break;

    case "newname":
        global._gmda_player_name = _response[$ "player_name"];
        x_gmda_savelog();
        x_gmda_emit("newname_completed", { success: true, response: "ok", player_name: global._gmda_player_name });
        break;

    case "content_sync_list":
        // emit the list, then fetch each always_download item;
        // content_sync_complete fires once every per-key fetch resolves.
        x_gmda_emit("content_list_loaded", { success: true, response: _response });
        var _fetches = 0;
        if (is_struct(_response) && variable_struct_exists(_response, "items") && is_array(_response[$ "items"])) {
            var _items = _response[$ "items"];
            for (var _i = 0; _i < array_length(_items); _i++) {
                var _it = _items[_i];
                if (is_struct(_it) && variable_struct_exists(_it, "category") && _it[$ "category"] == "always_download") {
                    if (x_gmda_get_session("/gamecontent/" + string(_it[$ "key"]), "content_loaded|" + string(_it[$ "key"]))) _fetches++;
                }
            }
        }
        if (_fetches > 0) {
            global._gmda_sync_active = true;
            global._gmda_sync_left = _fetches;
        } else {
            x_gmda_emit("content_sync_complete", { success: true });
        }
        break;

    case "mm_join":
        if (is_struct(_response) && variable_struct_exists(_response, "ticket_id")) {
            global._gmda_mm_in_queue = true;
            global._gmda_mm_ticket_id = string(_response[$ "ticket_id"]);
            global._gmda_mm_queue_position = variable_struct_exists(_response, "position") ? real(_response[$ "position"]) : 1;
            global._gmda_mm_found = false;
            global._gmda_mm_opponents = [];
            global._gmda_mm_opponent_count = 0;
            global._gmda_mm_players_ready = 0;
            global._gmda_mm_confirmed = false;
            global._gmda_mm_all_ready = false;
            global._gmda_mm_confirmed_players = [];
            global._gmda_mm_match_cancelled = false;
            x_gmda_read_udp(_response);
            if (variable_struct_exists(_response, "team_size")) global._gmda_mm_team_size = real(_response[$ "team_size"]);
            if (variable_struct_exists(_response, "players_needed")) global._gmda_mm_players_needed = real(_response[$ "players_needed"]);
            // The server may answer that this ticket already has a match, when
            // resuming a search that was left halfway
            if (variable_struct_exists(_response, "match_id") && string(_response[$ "match_id"]) != "") {
                global._gmda_mm_match_id = string(_response[$ "match_id"]);
            }
            if (variable_struct_exists(_response, "found") && _response[$ "found"]) {
                global._gmda_mm_in_queue = false;
                global._gmda_mm_found = true;
            }
            x_gmda_emit("matchmaking_joined", {
                success: true,
                ticket_id: global._gmda_mm_ticket_id,
                position: global._gmda_mm_queue_position,
                team_size: global._gmda_mm_team_size,
                players_needed: global._gmda_mm_players_needed
            });
        } else {
            global._gmda_mm_in_queue = false;
            x_gmda_emit("matchmaking_joined", { success: false, expected: false, error: "Invalid server response" });
        }
        break;

    case "mm_leave":
        global._gmda_mm_in_queue = false;
        global._gmda_mm_ticket_id = "";
        global._gmda_mm_queue_position = 0;
        global._gmda_mm_found = false;
        global._gmda_mm_opponents = [];
        global._gmda_mm_opponent_count = 0;
        global._gmda_mm_players_ready = 0;
        global._gmda_mm_confirmed = false;
        global._gmda_mm_all_ready = false;
        global._gmda_mm_confirmed_players = [];
        x_gmda_emit("matchmaking_left", { success: true });
        break;

    case "mm_cancel":
        global._gmda_mm_in_queue = false;
        global._gmda_mm_ticket_id = "";
        global._gmda_mm_queue_position = 0;
        global._gmda_mm_found = false;
        global._gmda_mm_opponents = [];
        global._gmda_mm_opponent_count = 0;
        global._gmda_mm_players_ready = 0;
        global._gmda_mm_confirmed = false;
        global._gmda_mm_all_ready = false;
        global._gmda_mm_confirmed_players = [];
        x_gmda_emit("matchmaking_cancelled", { success: true });
        break;

    case "mm_status":
        if (is_struct(_response)) {
            // The reply carries the ticket, so a client that asked without one
            // (fresh boot with a live ticket) adopts the search from here.
            if (variable_struct_exists(_response, "ticket_id")) {
                global._gmda_mm_ticket_id = string(_response[$ "ticket_id"]);
                global._gmda_mm_in_queue = true;
            }
            if (variable_struct_exists(_response, "team_size")) {
                global._gmda_mm_team_size = real(_response[$ "team_size"]);
                global._gmda_mm_players_needed = global._gmda_mm_team_size * 2;
            }
            // Region/mode of the ticket the server matched us to: a client that
            // restarted only learns them here, and needs them to requeue.
            if (variable_struct_exists(_response, "region")) global._gmda_mm_region = string(_response[$ "region"]);
            if (variable_struct_exists(_response, "mode")) global._gmda_mm_mode = string(_response[$ "mode"]);
            x_gmda_read_udp(_response);
            global._gmda_mm_queue_position = variable_struct_exists(_response, "position") ? real(_response[$ "position"]) : 0;
            if (variable_struct_exists(_response, "players_found")) global._gmda_mm_opponent_count = real(_response[$ "players_found"]);
            if (variable_struct_exists(_response, "players_ready")) global._gmda_mm_players_ready = real(_response[$ "players_ready"]);
            // Server can push a "found" status via status poll
            if (variable_struct_exists(_response, "status") && _response[$ "status"] == "found") {
                global._gmda_mm_in_queue = false;
                global._gmda_mm_found = true;
                // Accept step: who has said yes so far. all_ready is the green
                // light to start the P2P handshake. The countdown comes from the
                // server so every player sees the same number.
                if (variable_struct_exists(_response, "match_id") && string(_response[$ "match_id"]) != "") global._gmda_mm_match_id = string(_response[$ "match_id"]);
                if (variable_struct_exists(_response, "players_needed")) global._gmda_mm_players_needed = real(_response[$ "players_needed"]);
                if (variable_struct_exists(_response, "confirmed")) global._gmda_mm_confirmed = _response[$ "confirmed"] ? true : false;
                if (variable_struct_exists(_response, "all_ready")) global._gmda_mm_all_ready = _response[$ "all_ready"] ? true : false;
                if (variable_struct_exists(_response, "confirm_timeout_ms")) global._gmda_mm_confirm_timeout_ms = real(_response[$ "confirm_timeout_ms"]);
                // No confirm_ms_left means an older server: fall back to the whole
                // window, or the accept prompt would be born already expired.
                global._gmda_mm_confirm_ms_left = variable_struct_exists(_response, "confirm_ms_left")
                    ? real(_response[$ "confirm_ms_left"])
                    : global._gmda_mm_confirm_timeout_ms;
                // Kept as a deadline too: the status poll only lands every few
                // seconds, so the raw value goes stale between calls and the
                // game would have to smooth it out on its own
                global._gmda_mm_confirm_deadline = current_time + global._gmda_mm_confirm_ms_left;
                if (variable_struct_exists(_response, "confirmed_players") && is_array(_response[$ "confirmed_players"])) {
                    global._gmda_mm_confirmed_players = _response[$ "confirmed_players"];
                }
                // Parse opponents array
                global._gmda_mm_opponents = [];
                if (variable_struct_exists(_response, "opponents") && is_array(_response[$ "opponents"])) {
                    var _opps = _response[$ "opponents"];
                    for (var _oi = 0; _oi < array_length(_opps); _oi++) {
                        var _opp = _opps[_oi];
                        array_push(global._gmda_mm_opponents, {
                            ip: string(_opp[$ "ip"]),
                            port: real(_opp[$ "port"]),
                            player_id: variable_struct_exists(_opp, "player_id") ? string(_opp[$ "player_id"]) : "",
                            player_name: variable_struct_exists(_opp, "player_name") ? string(_opp[$ "player_name"]) : "",
                            slot: variable_struct_exists(_opp, "slot") ? real(_opp[$ "slot"]) : _oi
                        });
                    }
                    global._gmda_mm_opponent_count = array_length(global._gmda_mm_opponents);
                }
                // auto_accept: say yes without asking the player. Done here and
                // not in the game code so it works with no UI at all.
                if (global._gmda_mm_auto_accept && !global._gmda_mm_confirmed) {
                    gmda_matchmakingConfirm();
                }
                x_gmda_emit("matchmaking_found", {
                    success: true,
                    opponents: global._gmda_mm_opponents,
                    opponent_count: global._gmda_mm_opponent_count,
                    ticket_id: global._gmda_mm_ticket_id,
                    players_ready: global._gmda_mm_players_ready,
                    players_needed: global._gmda_mm_players_needed,
                    confirmed_players: global._gmda_mm_confirmed_players,
                    confirmed: global._gmda_mm_confirmed,
                    all_ready: global._gmda_mm_all_ready,
                    auto_accept: global._gmda_mm_auto_accept,
                    confirm_timeout_ms: global._gmda_mm_confirm_timeout_ms,
                    confirm_ms_left: global._gmda_mm_confirm_ms_left
                });
            } else {
                x_gmda_emit("matchmaking_status", {
                    success: true,
                    position: global._gmda_mm_queue_position,
                    in_queue: global._gmda_mm_in_queue,
                    players_found: global._gmda_mm_opponent_count,
                    players_ready: global._gmda_mm_players_ready
                });
            }
        }
        break;

    case "mm_heartbeat":
        if (is_struct(_response)) {
            global._gmda_mm_hb_ok_last = current_time;
            if (variable_struct_exists(_response, "match_id") && string(_response[$ "match_id"]) != "") {
                global._gmda_mm_match_id = string(_response[$ "match_id"]);
            }
            if (variable_struct_exists(_response, "grace_ms")) global._gmda_mm_grace_ms = real(_response[$ "grace_ms"]);
            if (variable_struct_exists(_response, "beat_every_s")) global._gmda_mm_hb_every_ms = real(_response[$ "beat_every_s"]) * 1000;
            if (variable_struct_exists(_response, "players") && is_array(_response[$ "players"])) {
                global._gmda_mm_peers = _response[$ "players"];
            }
            var _closed = variable_struct_exists(_response, "closed") && _response[$ "closed"];
            if (_closed) x_gmda_mm_close("peer_disconnected");
            if (!_closed) {
                // Stored as a deadline, so the game reads a countdown that ticks
                // down by itself between heartbeats
                var _worst = -1;
                for (var _pi = 0; _pi < array_length(global._gmda_mm_peers); _pi++) {
                    var _pp = global._gmda_mm_peers[_pi];
                    if (string(_pp[$ "player_id"]) == global._gmda_player_key) continue;
                    var _pms = real(_pp[$ "ms_left"]);
                    if (_worst < 0 || _pms < _worst) _worst = _pms;
                }
                global._gmda_mm_peer_deadline = current_time + ((_worst < 0) ? global._gmda_mm_grace_ms : _worst);
                // A healthy opponent never reaches the whole grace: one interval
                // has always gone by. Below that, a heartbeat went missing
                var _piso = global._gmda_mm_grace_ms - global._gmda_mm_hb_every_ms - 2000;
                global._gmda_mm_peer_warn = (_worst >= 0 && _worst < _piso);

                x_gmda_emit("matchmaking_peer_status", {
                    success: true,
                    match_id: global._gmda_mm_match_id,
                    players: global._gmda_mm_peers,
                    ms_left: x_gmda_mm_peer_left()
                });
            }
        }
        break;

    case "mm_end":
        x_gmda_emit("matchmaking_match_ended", { success: true });
        break;

    case "mm_confirm":
        if (is_struct(_response) && variable_struct_exists(_response, "confirmed") && _response[$ "confirmed"]) {
            if (variable_struct_exists(_response, "players_ready")) global._gmda_mm_players_ready = real(_response[$ "players_ready"]);
            if (variable_struct_exists(_response, "players_needed")) global._gmda_mm_players_needed = real(_response[$ "players_needed"]);
            if (variable_struct_exists(_response, "confirmed_players") && is_array(_response[$ "confirmed_players"])) {
                global._gmda_mm_confirmed_players = _response[$ "confirmed_players"];
            }
            global._gmda_mm_confirmed = true;
            if (variable_struct_exists(_response, "match_id") && string(_response[$ "match_id"]) != "") {
                global._gmda_mm_match_id = string(_response[$ "match_id"]);
            }
            // The last player to accept learns it here; the others through the
            // status poll
            if (variable_struct_exists(_response, "match_ready") && _response[$ "match_ready"]) global._gmda_mm_all_ready = true;
            x_gmda_emit("matchmaking_confirmed", {
                success: true,
                ticket_id: global._gmda_mm_ticket_id,
                players_ready: global._gmda_mm_players_ready,
                players_needed: global._gmda_mm_players_needed,
                confirmed_players: global._gmda_mm_confirmed_players,
                all_ready: global._gmda_mm_all_ready
            });
        } else {
            x_gmda_emit("matchmaking_confirmed", { success: false, expected: false, error: "Confirmation failed or expired" });
        }
        break;

    case "mm_found":
        // Push event from server — multiple opponents found
        global._gmda_mm_in_queue = false;
        global._gmda_mm_found = true;
        global._gmda_mm_opponents = [];
        if (variable_struct_exists(_response, "opponents") && is_array(_response[$ "opponents"])) {
            var _opps2 = _response[$ "opponents"];
            for (var _oj = 0; _oj < array_length(_opps2); _oj++) {
                var _op = _opps2[_oj];
                array_push(global._gmda_mm_opponents, {
                    ip: string(_op[$ "ip"]),
                    port: real(_op[$ "port"]),
                    player_id: variable_struct_exists(_op, "player_id") ? string(_op[$ "player_id"]) : "",
                    slot: variable_struct_exists(_op, "slot") ? real(_op[$ "slot"]) : _oj
                });
            }
            global._gmda_mm_opponent_count = array_length(global._gmda_mm_opponents);
        }
        // Fallback: legacy single-opponent format
        if (global._gmda_mm_opponent_count == 0 && variable_struct_exists(_response, "opponent_ip")) {
            array_push(global._gmda_mm_opponents, {
                ip: string(_response[$ "opponent_ip"]),
                port: real(_response[$ "opponent_port"]),
                player_id: "",
                slot: 0
            });
            global._gmda_mm_opponent_count = 1;
        }
        x_gmda_emit("matchmaking_found", {
            success: true,
            opponents: global._gmda_mm_opponents,
            opponent_count: global._gmda_mm_opponent_count,
            ticket_id: global._gmda_mm_ticket_id,
            confirm_timeout_ms: variable_struct_exists(_response, "confirm_timeout_ms") ? real(_response[$ "confirm_timeout_ms"]) : 10000
        });
        break;

    case "achievements_loaded":
        if (is_struct(_response) && variable_struct_exists(_response, "achievements")) {
            var _lista = _response[$ "achievements"];
            if (is_array(_lista)) {
                for (var _ai = 0; _ai < array_length(_lista); _ai++) {
                    var _a = _lista[_ai];
                    global._gmda_ach_unlocked[$ string(_a[$ "achievement_key"])] = (_a[$ "unlocked"] ? true : false);
                }
            }
        }
        x_gmda_emit(_cmd, { success: true, response: _response });
        break;

    case "achievement_unlocked":
        if (global._gmda_ach_last_key != "") {
            global._gmda_ach_unlocked[$ global._gmda_ach_last_key] = true;
        }
        var _ya = (is_struct(_response) && variable_struct_exists(_response, "already_unlocked")
                   && _response[$ "already_unlocked"]);
        x_gmda_emit(_cmd, {
            success: true,
            response: (_ya ? "already" : "unlocked"),
            key: global._gmda_ach_last_key
        });
        break;

    case "save_loaded":
        // The saved game comes out already unwrapped. Digging through
        // response.save.data was the plugin's job, not the game's.
        var _slot_c = (array_length(_parts) > 1) ? real(_parts[1]) : 0;
        var _dato = undefined;
        if (is_struct(_response) && variable_struct_exists(_response, "save")
            && is_struct(_response[$ "save"])) {
            _dato = _response[$ "save"][$ "data"];
        }
        x_gmda_emit(_cmd, {
            success: true,
            response: (is_struct(_dato) ? "loaded" : "empty"),
            slot: _slot_c,
            data: _dato
        });
        break;

    default:
        // Generic: the action tag IS the event name; deliver the raw parsed response.
        var _ev = { success: true, response: _response };
        if (array_length(_parts) > 1) _ev[$ "tag"] = _parts[1];
        x_gmda_emit(_cmd, _ev);
        // Per-key fetch of an active sync resolved — fire complete when drained.
        if (_cmd == "content_loaded" && global._gmda_sync_active) {
            global._gmda_sync_left -= 1;
            if (global._gmda_sync_left <= 0) {
                global._gmda_sync_active = false;
                x_gmda_emit("content_sync_complete", { success: true });
            }
        }
        break;
}
return 1;


// ===========================================================================
//  INTERNAL HELPERS  (x_gmda_*)
// ===========================================================================

#define x_gmda_emit
/// x_gmda_emit(event_name, payload_struct) — queues a result for gmda_pollEvent().
var _payload = argument1;
_payload[$ "event"] = argument0;
array_push(global._gmda_events, _payload);
return 0;

#define x_gmda_post_session
/// x_gmda_post_session(url_suffix, body_struct, action_tag) — session-auth POST.
if (!global._gmda_session_active) return 0;
var _h = x_gmda_session_headers();
x_gmda_http_post(global.GMDA_BASE_URL + argument0, json_stringify(argument1), _h, argument2);
return 1;

#define x_gmda_get_session
/// x_gmda_get_session(url_suffix, action_tag) — session-auth GET.
if (!global._gmda_session_active) return 0;
var _h = x_gmda_session_headers();
x_gmda_http_get(global.GMDA_BASE_URL + argument0, _h, argument1);
return 1;

#define x_gmda_try_flush_pending
/// Sends any queued submit_with_retry scores when ready.
global._gmda_pending_next = 0;
// Paused while the monthly quota is exhausted — don't retry until it resets.
if (real(x_gmda_get_timestamp()) < global._gmda_quota_block_until) {
    if (!ds_map_empty(global._gmda_pending)) global._gmda_pending_next = global._gmda_quota_block_until;
    return 0;
}
if (!global._gmda_session_active || global._gmda_init_phase < 4) {
    if (!ds_map_empty(global._gmda_pending)) global._gmda_pending_next = real(x_gmda_get_timestamp()) + global.GMDA_PENDING_RETRY_MS;
    return 0;
}
var _key = ds_map_find_first(global._gmda_pending);
while (!is_undefined(_key)) {
    var _idx = real(_key);
    var _entry = json_parse(global._gmda_pending[? _key]);
    var _next = ds_map_find_next(global._gmda_pending, _key);
    if (!x_gmda_can_improve(_idx, _entry.score)) {
        // historic-only table and the queued score can no longer beat the
        // best — the server would store nothing, so drop it.
        ds_map_delete(global._gmda_pending, _key);
        x_gmda_savelog();
    } else {
        var _b = {};
        _b[$ "table_key"] = global._gmda_tables[_idx];
        _b[$ "score"] = _entry.score;
        _b[$ "custom_data"] = _entry.meta;
        x_gmda_post_session("/scores", _b, "submit|" + string(_idx));
    }
    _key = _next;
}
if (!ds_map_empty(global._gmda_pending)) global._gmda_pending_next = real(x_gmda_get_timestamp()) + global.GMDA_PENDING_RETRY_MS;
return 1;

#define x_gmda_apply_table
/// x_gmda_apply_table(internal_idx, response) — fills the table grid + own score,
/// and captures the table's dashboard config (sort_order / periods_enabled).
var _idx = argument0;
var _response = argument1;
if (_idx < 0 || _idx >= global._gmda_table_count) return 0;
var _cfg = is_struct(_response) ? _response[$ "leaderboard"] : undefined;
if (is_struct(_cfg)) {
    if (variable_struct_exists(_cfg, "sort_order")) global._gmda_table_sort[_idx] = string(_cfg[$ "sort_order"]);
    if (variable_struct_exists(_cfg, "periods_enabled")) global._gmda_table_periods[_idx] = (_cfg[$ "periods_enabled"] ? true : false);
}
x_gmda_init_table_grid(_idx);
var _grid = global._gmda_table_data[_idx];
var _scores = is_struct(_response) ? _response[$ "scores"] : -1;
if (is_array(_scores)) {
    var _count = min(array_length(_scores), 10);
    for (var _i = 0; _i < _count; _i++) {
        var _e = _scores[_i];
        ds_grid_set(_grid, 0, _i, _e[$ "rank"]);
        ds_grid_set(_grid, 1, _i, _e[$ "player_name"]);
        ds_grid_set(_grid, 2, _i, _e[$ "score"]);
        var _cd = _e[$ "custom_data"];
        if (is_struct(_cd)) {
            var _keys = variable_struct_get_names(_cd);
            for (var _k = 0; _k < array_length(_keys) && _k < 3; _k++) ds_grid_set(_grid, 3 + _k, _i, _cd[$ _keys[_k]]);
        }
    }
}
var _ps = is_struct(_response) ? _response[$ "player_score"] : -1;
if (is_struct(_ps)) {
    global._gmda_globpos[_idx] = _ps[$ "rank"];
    global._gmda_bestscore[_idx] = _ps[$ "score"];
    var _pcd = _ps[$ "custom_data"];
    if (is_struct(_pcd)) {
        // store the custom_data verbatim (JSON) so gmda_getExtrainfo can expose
        // the panel-defined field names, not just positional values
        global._gmda_extrainfo[_idx] = json_stringify(_pcd);
    }
}
return 1;

#define x_gmda_can_improve
/// x_gmda_can_improve(internal_idx, score) — false only for historic-only
/// tables (periods disabled in the dashboard) when the score cannot beat the
/// cached best. With temporal scores on, any submit can still improve a
/// daily/weekly/monthly bucket, so it always goes through.
var _idx = argument0;
var _score = argument1;
if (global._gmda_table_periods[_idx]) return 1;
if (global._gmda_globpos[_idx] <= 0) return 1; // no known score yet
if (global._gmda_table_sort[_idx] == "asc") return (_score < global._gmda_bestscore[_idx]) ? 1 : 0;
return (_score > global._gmda_bestscore[_idx]) ? 1 : 0;

#define x_gmda_generate_nonce
randomize();
var _chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
var _s = "";
repeat (16) _s += string_char_at(_chars, irandom(string_length(_chars) - 1) + 1);
return _s;

#define x_gmda_idem
/// 24-char idempotency key (a-zA-Z0-9).
randomize();
var _chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
var _s = "";
repeat (24) _s += string_char_at(_chars, irandom(string_length(_chars) - 1) + 1);
return _s;

#define x_gmda_get_timestamp
/// Unix milliseconds (string). MUST be UTC: the server rejects timestamps
/// outside ±2 min, and date_current_datetime() honours the current timezone
/// setting (local by default) — local time would be off by the UTC offset.
var _tz = date_get_timezone();
date_set_timezone(timezone_utc);
var _gm = date_current_datetime();
date_set_timezone(_tz);
var _unix_seconds = floor((_gm - 25569) * 86400);
// string_format, not string(): string() formats reals per target, and on HTML5
// a 13-digit number can come out with decimals or an exponent. The server reads
// this header as a plain integer and rejects anything else, which is why the
// same build authenticates on Windows and fails once exported to web.
return string_format(_unix_seconds * 1000, 1, 0);

#define x_gmda_game_auth_headers
/// x_gmda_game_auth_headers(body_json) -> ds_map. Simple signed auth (sha1).
var _body_json = argument0;
var _ts = x_gmda_get_timestamp();
var _nonce = x_gmda_generate_nonce();
var _body_hash = sha1_string_utf8(_body_json);
var _payload = global._gmda_api_key + "|" + global._gmda_game_id + "|" + _ts + "|" + _nonce + "|" + _body_hash;
var _signature = sha1_string_utf8(_payload);
var _h = ds_map_create();
ds_map_add(_h, "Content-Type", "application/json");
ds_map_add(_h, "x-game-id", global._gmda_game_id);
ds_map_add(_h, "x-timestamp", _ts);
ds_map_add(_h, "x-nonce", _nonce);
ds_map_add(_h, "x-signature", _signature);
ds_map_add(_h, "x-auth-mode", "simple");
return _h;

#define x_gmda_session_headers
var _ts = x_gmda_get_timestamp();
var _h = ds_map_create();
ds_map_add(_h, "Content-Type", "application/json");
ds_map_add(_h, "x-session-id", global._gmda_session_id);
ds_map_add(_h, "x-session-secret", global._gmda_session_secret);
ds_map_add(_h, "x-timestamp", _ts);
return _h;

#define x_gmda_http_post
var _req = http_request(argument0, "POST", argument2, argument1);
ds_map_add(global._gmda_http_queue, _req, argument3);
ds_map_destroy(argument2);
return _req;

#define x_gmda_http_patch
var _req = http_request(argument0, "PATCH", argument2, argument1);
ds_map_add(global._gmda_http_queue, _req, argument3);
ds_map_destroy(argument2);
return _req;

#define x_gmda_http_get
var _req = http_request(argument0, "GET", argument1, "");
ds_map_add(global._gmda_http_queue, _req, argument2);
ds_map_destroy(argument1);
return _req;

#define x_gmda_savelog
var _m = ds_map_create();
ds_map_add(_m, "player_key", global._gmda_player_key);
ds_map_add(_m, "player_name", global._gmda_player_name);
// Stored inside the secure save (device-bound). Required to re-open sessions.
ds_map_add(_m, "player_secret", global._gmda_player_secret);
ds_map_add(_m, "table_count", string(global._gmda_table_count));
for (var _i = 0; _i < global._gmda_table_count; _i++) {
    var _p = "t" + string(_i) + "_";
    ds_map_add(_m, _p + "globpos", string(global._gmda_globpos[_i]));
    ds_map_add(_m, _p + "bestscore", string(global._gmda_bestscore[_i]));
    ds_map_add(_m, _p + "extrainfo", global._gmda_extrainfo[_i]);
}
// pending-score queue
var _pk = ds_map_find_first(global._gmda_pending);
var _pending_keys = "";
while (!is_undefined(_pk)) {
    ds_map_add(_m, "pending_" + _pk, global._gmda_pending[? _pk]);
    _pending_keys += (_pending_keys == "" ? "" : ",") + _pk;
    _pk = ds_map_find_next(global._gmda_pending, _pk);
}
ds_map_add(_m, "pending_keys", _pending_keys);
ds_map_secure_save(_m, global.GMDA_LOG_FILE);
ds_map_destroy(_m);
return 1;

#define x_gmda_loadlog
if (!file_exists(global.GMDA_LOG_FILE)) return 0;
var _m = ds_map_secure_load(global.GMDA_LOG_FILE);
if (!ds_exists(_m, ds_type_map)) return 0;
var _v;
_v = ds_map_find_value(_m, "player_key"); if (!is_undefined(_v)) global._gmda_player_key = _v;
_v = ds_map_find_value(_m, "player_name"); if (!is_undefined(_v)) global._gmda_player_name = _v;
_v = ds_map_find_value(_m, "player_secret"); if (!is_undefined(_v)) global._gmda_player_secret = _v;
for (var _i = 0; _i < global._gmda_table_count; _i++) {
    var _p = "t" + string(_i) + "_";
    _v = ds_map_find_value(_m, _p + "globpos"); if (!is_undefined(_v)) global._gmda_globpos[_i] = real(_v);
    _v = ds_map_find_value(_m, _p + "bestscore"); if (!is_undefined(_v)) global._gmda_bestscore[_i] = real(_v);
    _v = ds_map_find_value(_m, _p + "extrainfo"); if (!is_undefined(_v)) global._gmda_extrainfo[_i] = _v;
}
var _pks = ds_map_find_value(_m, "pending_keys");
if (!is_undefined(_pks) && _pks != "") {
    var _arr = x_gmda_explode(_pks, ",");
    for (var _k = 0; _k < array_length(_arr); _k++) {
        var _pv = ds_map_find_value(_m, "pending_" + _arr[_k]);
        if (!is_undefined(_pv)) global._gmda_pending[? _arr[_k]] = _pv;
    }
}
ds_map_destroy(_m);
return 1;

#define x_gmda_explode
var _str = argument0;
var _del = argument1;
var _arr = [];
var _pos = string_pos(_del, _str);
while (_pos > 0) {
    array_push(_arr, string_copy(_str, 1, _pos - 1));
    _str = string_delete(_str, 1, _pos);
    _pos = string_pos(_del, _str);
}
array_push(_arr, _str);
return _arr;

#define x_gmda_chna
/// x_gmda_chna(str, maxlen) — strip control chars + truncate.
var _str = argument0;
var _maxlen = argument1;
_str = string_replace_all(_str, "|", "");
_str = string_replace_all(_str, chr(13), "");
_str = string_replace_all(_str, chr(10), "");
_str = string_replace_all(_str, chr(34), "");
_str = string_replace_all(_str, "\\", "");
if (string_length(_str) > _maxlen) _str = string_copy(_str, 1, _maxlen);
return _str;

#define x_gmda_init_table_grid
/// x_gmda_init_table_grid(internal_idx) — (re)creates a 6x10 ds_grid.
var _i = argument0;
if (global._gmda_table_data[_i] != -1 && ds_exists(global._gmda_table_data[_i], ds_type_grid)) ds_grid_destroy(global._gmda_table_data[_i]);
global._gmda_table_data[_i] = ds_grid_create(6, 10);
ds_grid_clear(global._gmda_table_data[_i], "");
return 0;

#define x_gmda_handle_error
/// x_gmda_handle_error(cmd, parts, response, http_status)
var _cmd = argument0;
var _parts = argument1;
var _response = argument2;
var _http_status = argument3;
var _msg = (is_struct(_response) && variable_struct_exists(_response, "error")) ? string(_response[$ "error"]) : "";
// Every failure carries a readable reason. Without this, every place that shows
// the error has to check whether it exists and whether it is empty first.
if (_msg == "") {
    if (_http_status <= 0) _msg = "No connection";
    else _msg = "Server error (" + string(_http_status) + ")";
}

// Releases the "request in flight" lock, same as the success path does
if (_cmd == "session_start" || _cmd == "load_table") global._gmda_loading = false;

// Monthly consumption quota exhausted — pause pending-score retries (1h)
// instead of hammering the backend every 5 s.
if (_http_status == 429 && _msg == "quota_exceeded") {
    global._gmda_quota_block_until = real(x_gmda_get_timestamp()) + 3600000;
}

// A 401 from any session-authed call means the server no longer knows our
// session (TTL hit, server restart, eviction). Retrying the same dead
// credentials loops forever, so drop the session and let gmda_Updatefunction
// mint a fresh one. Queued scores stay pending and flush once it's back.
// session_start is excluded: its 401 means bad player_secret (handled below).
if (_http_status == 401 && _cmd != "session_start" && global._gmda_session_active) {
    global._gmda_session_active = false;
    global._gmda_session_id = "";
    global._gmda_session_secret = "";
    global._gmda_init_phase = 1;
    global._gmda_retry_after = 0; // re-login immediately
}

if (_cmd == "session_start") {
    // 401 = bad/missing player_secret. Retrying the same payload loops
    // forever, so wipe ALL local player state (id, secret, cached scores,
    // pending queue) and let the next attempt create a fresh player.
    if (_http_status == 401) {
        global._gmda_player_key = "";
        global._gmda_player_secret = "";
        global._gmda_player_name = "";
        global._gmda_session_id = "";
        global._gmda_session_secret = "";
        ds_map_clear(global._gmda_pending);
        for (var _i = 0; _i < global._gmda_table_count; _i++) {
            global._gmda_bestscore[_i] = 0;
            global._gmda_globpos[_i] = 0;
            global._gmda_extrainfo[_i] = "{}";
            x_gmda_init_table_grid(_i);
        }
        x_gmda_savelog();
    }
    global._gmda_init_phase = 1;
    // Exponential backoff: RETRY_DELAY_MS * 2^(n-1), capped, ±12% jitter.
    global._gmda_retry_count += 1;
    var _shift = min(max(global._gmda_retry_count - 1, 0), 16);
    var _delay = min(global.GMDA_RETRY_DELAY_MS * power(2, _shift), global.GMDA_SESSION_RETRY_MAX_MS);
    _delay = _delay * random_range(0.88, 1.12);
    global._gmda_retry_after = real(x_gmda_get_timestamp()) + _delay;
    x_gmda_emit("error", { success: false, event_for: "session_start", error: _msg, http_status: _http_status });
    return 0;
}
if (_cmd == "load_table") { global._gmda_tables_loaded++; return 0; }
if (_cmd == "newname") {
    var _tomado = (_msg == "Name is already taken");
    x_gmda_emit("newname_completed", {
        success: false, response: (_tomado ? "taken" : "error"), error: _msg
    });
    return 0;
}
if (_cmd == "submit") {
    var _sidx = (array_length(_parts) > 1) ? real(_parts[1]) : -1;
    // Permanent client error (validation, bad table_key, inactive board…) —
    // retrying the SAME payload never succeeds: drop the queued score.
    // Transient ones (401 session, 429, 5xx, network) keep it for retry.
    var _permanent = (_http_status >= 400 && _http_status < 500 && _http_status != 401 && _http_status != 429);
    var _pk = string(_sidx);
    if (_permanent && ds_map_exists(global._gmda_pending, _pk)) {
        ds_map_delete(global._gmda_pending, _pk);
        x_gmda_savelog();
    }
    // One more case of the same switch: the game does not have to check success
    x_gmda_emit("submit_completed", {
        success: false, table: _sidx + 1, response: "error",
        error: _msg, http_status: _http_status
    });
    return 0;
}
// Events that resolve their outcome in response carry it on failure too, so the
// game can handle them with a single switch
if (_cmd == "achievement_unlocked") {
    x_gmda_emit(_cmd, {
        success: false, response: "error", key: global._gmda_ach_last_key,
        error: _msg, http_status: _http_status
    });
    return 0;
}
if (_cmd == "save_loaded") {
    x_gmda_emit(_cmd, {
        success: false, response: "error",
        slot: (array_length(_parts) > 1) ? real(_parts[1]) : 0, data: undefined,
        error: _msg, http_status: _http_status
    });
    return 0;
}

// Matchmaking errors — reset queue state on failure
if (_cmd == "mm_join") {
    global._gmda_mm_in_queue = false;
    global._gmda_mm_ticket_id = "";
    x_gmda_emit("matchmaking_joined", { success: false, expected: false, error: _msg, http_status: _http_status });
    return 0;
}
if (_cmd == "mm_leave") {
    global._gmda_mm_in_queue = false;
    global._gmda_mm_ticket_id = "";
    global._gmda_mm_queue_position = 0;
    x_gmda_emit("matchmaking_left", { success: false, expected: false, error: _msg, http_status: _http_status });
    return 0;
}
if (_cmd == "mm_cancel") {
    x_gmda_emit("matchmaking_cancelled", { success: false, expected: false, error: _msg, http_status: _http_status });
    return 0;
}
if (_cmd == "mm_heartbeat") {
    // 4xx = the match no longer exists. A 5xx or a network drop is transient
    // and gets retried on the next heartbeat
    if (_http_status >= 400 && _http_status < 500 && _http_status != 401 && _http_status != 429) {
        x_gmda_mm_close("match_gone");
    }
    return 0;
}
if (_cmd == "mm_end") return 0;
if (_cmd == "mm_status" || _cmd == "mm_confirm") {
    // Some failures are the normal answer and not a problem: asking about a
    // ticket we do not have replies 400, and a 429 clears itself on the next
    // poll. Deciding it here spares the game from reading HTTP codes.
    var _normal = (global._gmda_mm_ticket_id == "") || (_http_status == 429);

    // 4xx = the ticket is gone: the accept window closed, or somebody cancelled
    if (_http_status >= 400 && _http_status < 500 && _http_status != 401 && _http_status != 429) {
        // Only counts as a cancellation if we believed we had a live search
        if (global._gmda_mm_found || global._gmda_mm_in_queue) global._gmda_mm_match_cancelled = true;
        global._gmda_mm_in_queue = false;
        global._gmda_mm_found = false;
        global._gmda_mm_ticket_id = "";
        global._gmda_mm_all_ready = false;
    }
    x_gmda_emit(_cmd == "mm_status" ? "matchmaking_status" : "matchmaking_confirmed",
        { success: false, expected: _normal, error: _msg, http_status: _http_status });
    return 0;
}
// Per-key fetch of an active always_download sync failed — still drains the counter.
if (_cmd == "content_loaded" && global._gmda_sync_active) {
    global._gmda_sync_left -= 1;
    if (global._gmda_sync_left <= 0) {
        global._gmda_sync_active = false;
        x_gmda_emit("content_sync_complete", { success: true });
    }
}
// generic failure for any other action: emit the command's event with success=false
var _eev = { success: false, error: _msg, http_status: _http_status };
if (array_length(_parts) > 1) _eev[$ "tag"] = _parts[1];
x_gmda_emit(_cmd, _eev);
return 0;
