/// @description Signal / code framework.
///
/// A "signal" is a single coloured ping (blue or red) emitted by the hero.
/// Signals have two roles:
///   1. Ambient gameplay effect  — blue pings reveal nearby mines.
///   2. Pattern input            — signals are appended to a buffer and, if
///      the buffer matches a registered multi-signal code, its callback fires.
///
/// All registered codes start with RED so that a single BLUE press is
/// unambiguous (it is the base ping and never leads a code). Among the
/// multi-signal codes, none is a prefix of another — matches resolve the
/// instant the buffer becomes a full code, with no wait needed.
///
/// A safety timeout clears a stale in-progress buffer after `SIGNAL_TIMEOUT`
/// seconds so the player is never stuck mid-sequence.

#macro SIGNAL_PING_RADIUS_DEFAULT  400
#macro SIGNAL_PING_SPEED           800    // px/sec
#macro SIGNAL_RETURN_PING_RADIUS   90     // small echo emitted by pinged mines
#macro SIGNAL_TIMEOUT              1      // seconds of silence before buffer clears
#macro SIGNAL_COOLDOWN             0.05   // minimum seconds between code-pushing signals

enum SIGNAL {
    BLUE,
    RED,
}

function signals_init() {
    global.signals = {
        buffer      : "",
        time_since  : 0,
        cooldown    : 0,
        codes       : [],
    };

    // Index 0 — stop: freeze nearby enemies.
    signal_register_code("RBB", "code_stop", function() {
        if (!instance_exists(obj_hero)) return;
        var _h = instance_find(obj_hero, 0);
        code_stop_enemies(_h.x, _h.y);
    });

    // Index 1 — push: shove nearby crawlers outward.
    signal_register_code("RBRB", "code_push", function() {
        if (!instance_exists(obj_hero)) return;
        var _h = instance_find(obj_hero, 0);
        code_push_enemies(_h.x, _h.y);
    });

    // Index 2 — explode: friendly-fire blasts on threats, detonates mines too.
    signal_register_code("RRBBR", "code_explode", function() {
        if (!instance_exists(obj_hero)) return;
        var _h = instance_find(obj_hero, 0);
        code_explode_threats(_h.x, _h.y);
    });

    // Index 3 — reserved: registered so the pattern is known to the prefix-free
    // recogniser, but does nothing yet.
    signal_register_code("RRRBBR", "code_reserved", function() {});
}

/// @param {String}   _pattern   String of 'B' / 'R' characters.
/// @param {String}   _name      Human-readable label (for debug / UI).
/// @param {Function} _callback  Invoked with no args when the pattern matches.
function signal_register_code(_pattern, _name, _callback) {
    if (!variable_global_exists("signals")) signals_init();
    array_push(global.signals.codes, { pattern: _pattern, name: _name, callback: _callback });
}

/// @desc Emit a ping in the world. Spawns an obj_ping and — unless
///       `_is_code` is false — appends the signal to the player's code buffer.
///       Code-pushing emissions are rate-limited by SIGNAL_COOLDOWN; a
///       cooled-down call returns `noone` and spawns nothing.
/// @param {Real} _x
/// @param {Real} _y
/// @param {Real} _color        SIGNAL.BLUE or SIGNAL.RED.
/// @param {Real} [_radius]     Max radius in px.
/// @param {Bool} [_is_code]    If true, also push to code buffer. Mine echoes should pass false.
function signal_emit(_x, _y, _color, _radius = SIGNAL_PING_RADIUS_DEFAULT, _is_code = true) {
    if (!variable_global_exists("signals")) signals_init();

    if (_is_code && global.signals.cooldown > 0) return noone;

    var _p = instance_create_depth(_x, _y, -100, obj_ping);
    _p.max_radius = _radius;
    _p.ping_color = _color;

    if (_is_code) {
        var _ch = (_color == SIGNAL.BLUE) ? "B" : "R";
        __signal_push(_ch);
        global.signals.cooldown = SIGNAL_COOLDOWN;

        // Player-emitted pings only — mine echoes stay silent (is_code == false).
        var _snd = (_color == SIGNAL.BLUE) ? sfx_ping_blue : sfx_ping_red;
        audio_play_sound(_snd, 1, false, 1, 0, random_range(0.93, 1.07));
    }
    return _p;
}

/// @returns {Bool} True when the player may emit a fresh code-pushing signal.
function signal_ready() {
    if (!variable_global_exists("signals")) signals_init();
    return global.signals.cooldown <= 0;
}

/// @desc Call once per frame (Begin Step of obj_game_controller). Decays the
///       emit cooldown and clears a stale in-progress buffer after
///       SIGNAL_TIMEOUT seconds of silence.
function signal_tick(_dt_seconds) {
    if (!variable_global_exists("signals")) signals_init();
    var _s = global.signals;

    if (_s.cooldown > 0) _s.cooldown = max(0, _s.cooldown - _dt_seconds);

    if (_s.buffer == "") return;
    _s.time_since += _dt_seconds;
    if (_s.time_since >= SIGNAL_TIMEOUT) _s.buffer = "";
}

/// @returns {String} Current in-progress buffer (for debug/HUD).
function signal_buffer() {
    if (!variable_global_exists("signals")) signals_init();
    return global.signals.buffer;
}

// --- internal -----------------------------------------------------------

function __signal_push(_char) {
    var _s = global.signals;
    _s.buffer += _char;
    _s.time_since = 0;
    __signal_try_match();
}

function __signal_try_match() {
    var _s = global.signals;
    var _buf = _s.buffer;

    // Exact match against any registered code? Fire & clear.
    var _n = array_length(_s.codes);
    for (var _i = 0; _i < _n; _i++) {
        var _c = _s.codes[_i];
        if (_buf == _c.pattern) {
            _c.callback();
            _s.buffer = "";
            return;
        }
    }

    // Not a prefix of any code? Discard — the player can't be mid-sequence.
    if (!__signal_is_prefix_of_any(_buf)) _s.buffer = "";
}

function __signal_is_prefix_of_any(_buf) {
    var _s = global.signals;
    var _n = array_length(_s.codes);
    var _len = string_length(_buf);
    for (var _i = 0; _i < _n; _i++) {
        if (string_copy(_s.codes[_i].pattern, 1, _len) == _buf) return true;
    }
    return false;
}

// --- gameplay helpers ---------------------------------------------------

/// @desc Convenience: returns GM color constant for a SIGNAL enum value.
function signal_color(_signal_enum) {
    return (_signal_enum == SIGNAL.BLUE) ? make_color_rgb(80, 170, 255)
                                         : make_color_rgb(255, 80,  80);
}

// --- Totem tuning -------------------------------------------------------
#macro TOTEM_SYMBOL_SHOW   0.34   // seconds each eye is visible
#macro TOTEM_SYMBOL_GAP    0.18   // dark pause between consecutive symbols

/// @desc Called by obj_ping when its leading edge crosses a totem. Starts
///       the code-playback cycle if the totem isn't already busy (subsequent
///       pings during playback are ignored — user-specified).
function totem_trigger(_totem) {
    if (!instance_exists(_totem)) return;
    if (!variable_global_exists("signals")) signals_init();
    var _codes = global.signals.codes;
    with (_totem) {
        if (playback_active) exit;
        var _idx = show_code;
        if (_idx < 0 || _idx >= array_length(_codes)) exit;
        playback_pattern       = _codes[_idx].pattern;
        playback_active        = true;
        playback_t             = 0;
        playback_last_symbol_i = -1;
    }
}

/// @desc Called by obj_ping when its leading edge crosses a mine.
///       Reveals the mine once, then spawns a small non-code, non-activating
///       echo so the player can locate it without chain-triggering neighbours.
function mine_reveal(_mine) {
    if (!instance_exists(_mine)) return;
    with (_mine) {
        if (!revealed) {
            revealed = true;
            var _p = instance_create_depth(x, y, -100, obj_ping);
            _p.max_radius      = SIGNAL_RETURN_PING_RADIUS;
            _p.ping_color      = SIGNAL.BLUE;
            _p.activates_mines = false;
            audio_play_sound(sfx_reveal, 1, false);
        }
    }
}

// --- Combat tuning -------------------------------------------------------
#macro HERO_IFRAME_DURATION    1.0
#macro HERO_KNOCKBACK          12      // px/frame initial velocity
#macro KNOCKBACK_DAMP          0.82    // per-frame velocity multiplier
#macro MINE_SPLASH_RADIUS      110
#macro AI_GRID_CELL            32

/// @desc Damage the hero. `_from_x / _from_y` drive the knockback direction.
///       Returns true if damage actually applied (false while i-framed or
///       with no controller / no hero present).
function hero_damage(_amount, _from_x, _from_y) {
    if (!instance_exists(obj_hero)) return false;
    var _hero = instance_find(obj_hero, 0);
    if (_hero.iframe_ttl > 0) return false;

    // I-frames + knockback away from the damage source.
    _hero.iframe_ttl = HERO_IFRAME_DURATION;
    var _dx = _hero.x - _from_x;
    var _dy = _hero.y - _from_y;
    var _d  = point_distance(0, 0, _dx, _dy);
    if (_d > 0) {
        _hero.knockback_vx = _dx / _d * HERO_KNOCKBACK;
        _hero.knockback_vy = _dy / _d * HERO_KNOCKBACK;
    }

    audio_play_sound(sfx_hurt, 1, false, 1, 0, random_range(0.93, 1.07));

    if (instance_exists(obj_game_controller)) {
        with (obj_game_controller) {
            if (!game_over) {
                hp = max(0, hp - _amount);
                if (hp <= 0) {
                    game_over = true;
                    game_over_time = 0;
                }
            }
        }
    }
    return true;
}

/// @returns {Bool} True when the game controller has declared game over.
///                 Safe to call from any event — no-op if no controller exists.
function game_is_over() {
    if (!instance_exists(obj_game_controller)) return false;
    return obj_game_controller.game_over;
}

/// @desc Canonical entry point for "make this mine go off now". Spawns the
///       big explosion, shakes the camera, and does a splash-damage check
///       against the hero. Safe to call with any mine id (hero contact,
///       crawler contact, future triggers).
function mine_detonate(_mine) {
    if (!instance_exists(_mine)) return;
    with (_mine) {
        instance_create_depth(x, y, -200, obj_explosion);
        audio_play_sound(sfx_explode, 1, false, 1, 0, random_range(0.93, 1.07));

        if (instance_exists(obj_camera)) {
            with (obj_camera) { camera.shake(14); }
        }

        if (instance_exists(obj_hero)) {
            var _hero = instance_find(obj_hero, 0);
            if (point_distance(x, y, _hero.x, _hero.y) < MINE_SPLASH_RADIUS) {
                hero_damage(1, x, y);
            }
        }

        instance_destroy();
    }
}

/// @desc Rebuild the shared AI navigation grid from every live obj_wall
///       (including doors whose mask is currently active). Cheap enough to
///       call on every door state change and every wall destruction.
function ai_grid_refresh() {
    if (!instance_exists(obj_game_controller)) return;
    var _ctrl = instance_find(obj_game_controller, 0);
    if (_ctrl.ai_grid < 0) return;
    mp_grid_clear_all(_ctrl.ai_grid);
    mp_grid_add_instances(_ctrl.ai_grid, obj_wall, false);
}

// --- Scene transition (game-over restart) -------------------------------
#macro TRANSITION_DURATION   0.5        // seconds per fade phase
#macro GAME_OVER_FADE_IN     0.8        // must match obj_game_controller Draw_64
#macro RESTART_INPUT_DELAY   0.9        // block Confirm until overlay is settled

enum GC_TRANSITION {
    NONE,
    FADING_OUT,    // leaving scene — clear → black — then room_restart()
    FADING_IN,     // new scene spawns — black → clear
}

// --- Code effects --------------------------------------------------------
// All three active codes emanate from the hero's position with a single
// range. Mines are "friendly" for the explode code in the sense that only
// their own existing splash (MINE_SPLASH_RADIUS) can hurt the hero — the
// instigator-explosions on crawlers/towers/doors are visual only.

#macro CODE_RANGE             500
#macro CODE_STOP_DURATION     4.0
#macro CODE_PUSH_IMPULSE      18    // ≈ 3× CRAWLER_KNOCKBACK
#macro CODE_PUSH_STUN         0.5

/// @desc Freeze every crawler and tower within CODE_RANGE for
///       CODE_STOP_DURATION seconds. Refresh-on-restack (newer stop wins).
function code_stop_enemies(_cx, _cy) {
    with (obj_enemy_crawler) {
        if (point_distance(x, y, _cx, _cy) <= CODE_RANGE) {
            stop_ttl = max(stop_ttl, CODE_STOP_DURATION);
        }
    }
    with (obj_enemy_tower) {
        if (point_distance(x, y, _cx, _cy) <= CODE_RANGE) {
            stop_ttl = max(stop_ttl, CODE_STOP_DURATION);
        }
    }
}

/// @desc Shove every crawler within CODE_RANGE outward from the caster.
///       Towers are immovable and intentionally skipped. Stun prevents the
///       crawler from immediately re-acquiring and charging back.
function code_push_enemies(_cx, _cy) {
    with (obj_enemy_crawler) {
        if (point_distance(x, y, _cx, _cy) <= CODE_RANGE) {
            var _away = point_direction(_cx, _cy, x, y);
            knockback_vx = lengthdir_x(CODE_PUSH_IMPULSE, _away);
            knockback_vy = lengthdir_y(CODE_PUSH_IMPULSE, _away);
            stun_ttl = max(stun_ttl, CODE_PUSH_STUN);
        }
    }
}

/// @desc Friendly-fire explosion on every crawler / tower / blocked door
///       within CODE_RANGE. Mines in range are also detonated — those use
///       their own (smaller) splash, which CAN hurt the hero if close.
function code_explode_threats(_cx, _cy) {
    with (obj_enemy_crawler) {
        if (point_distance(x, y, _cx, _cy) <= CODE_RANGE) {
            instance_create_depth(x, y, -200, obj_explosion);
            instance_destroy();
        }
    }
    with (obj_enemy_tower) {
        if (point_distance(x, y, _cx, _cy) <= CODE_RANGE) {
            instance_create_depth(x, y, -200, obj_explosion);
            instance_destroy();
        }
    }
    with (obj_door_blocked) {
        if (point_distance(x, y, _cx, _cy) <= CODE_RANGE) {
            instance_create_depth(x, y, -200, obj_explosion);
            // CleanUp on obj_wall fires ai_grid_refresh() so pathing stays current.
            instance_destroy();
        }
    }
    with (obj_mine) {
        if (point_distance(x, y, _cx, _cy) <= CODE_RANGE) {
            mine_detonate(id);
        }
    }
}
