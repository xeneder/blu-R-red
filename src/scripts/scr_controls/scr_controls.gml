/// @description Simple arcade-style controls framework.
/// Gamepad left stick + D-pad + keyboard. Digital actions accept the
/// analog stick as a fallback when it crosses the deadzone.
///
/// Usage:
///   - Call ctrl_update() once per frame (Begin Step of a controller object).
///   - Read continuous input via ctrl_axis_h() / ctrl_axis_v()    (-1..1)
///   - Read digital   input via ctrl_check / ctrl_pressed / ctrl_released
///     passing a CTRL.* enum value.

#macro CTRL_DEADZONE      0.25
#macro CTRL_GAMEPAD_SLOT  0

enum CTRL {
    UP, DOWN, LEFT, RIGHT,
    ACTION_1, ACTION_2,
    START, CONFIRM, CANCEL,
    __COUNT
}

function ctrl_init() {
    global.ctrl = {
        gamepad_slot : -1,
        deadzone     : CTRL_DEADZONE,
        axis_h       : 0,
        axis_v       : 0,
        state        : array_create(CTRL.__COUNT, false),
        prev         : array_create(CTRL.__COUNT, false),
    };
    gamepad_set_axis_deadzone(CTRL_GAMEPAD_SLOT, CTRL_DEADZONE);
}

function ctrl_update() {
    if (!variable_global_exists("ctrl")) ctrl_init();
    var _c = global.ctrl;

    _c.gamepad_slot = gamepad_is_connected(CTRL_GAMEPAD_SLOT) ? CTRL_GAMEPAD_SLOT : -1;

    // --- Digital directional sources ---
    var _gp_u = __ctrl_gp(gp_padu), _gp_d = __ctrl_gp(gp_padd);
    var _gp_l = __ctrl_gp(gp_padl), _gp_r = __ctrl_gp(gp_padr);

    var _key_u = keyboard_check(vk_up)    || keyboard_check(ord("W"));
    var _key_d = keyboard_check(vk_down)  || keyboard_check(ord("S"));
    var _key_l = keyboard_check(vk_left)  || keyboard_check(ord("A"));
    var _key_r = keyboard_check(vk_right) || keyboard_check(ord("D"));

    var _dh = ((_key_r || _gp_r) ? 1 : 0) - ((_key_l || _gp_l) ? 1 : 0);
    var _dv = ((_key_d || _gp_d) ? 1 : 0) - ((_key_u || _gp_u) ? 1 : 0);

    // --- Analog stick (gamepad left) ---
    var _ah = 0, _av = 0;
    if (_c.gamepad_slot >= 0) {
        _ah = gamepad_axis_value(_c.gamepad_slot, gp_axislh);
        _av = gamepad_axis_value(_c.gamepad_slot, gp_axislv);
        if (abs(_ah) < _c.deadzone) _ah = 0;
        if (abs(_av) < _c.deadzone) _av = 0;
    }

    // Digital overrides analog when the user is actively pressing a direction.
    _c.axis_h = (_dh != 0) ? _dh : _ah;
    _c.axis_v = (_dv != 0) ? _dv : _av;

    // Keep previous digital state for edge detection.
    array_copy(_c.prev, 0, _c.state, 0, CTRL.__COUNT);

    // Directional digital = any direct digital source, OR analog past deadzone.
    _c.state[CTRL.UP]    = _key_u || _gp_u || _av < -_c.deadzone;
    _c.state[CTRL.DOWN]  = _key_d || _gp_d || _av >  _c.deadzone;
    _c.state[CTRL.LEFT]  = _key_l || _gp_l || _ah < -_c.deadzone;
    _c.state[CTRL.RIGHT] = _key_r || _gp_r || _ah >  _c.deadzone;

    _c.state[CTRL.ACTION_1] = __ctrl_gp(gp_face1) || keyboard_check(ord("Z")) || keyboard_check(vk_space);
    _c.state[CTRL.ACTION_2] = __ctrl_gp(gp_face2) || keyboard_check(ord("X"));
    _c.state[CTRL.START]    = __ctrl_gp(gp_start) || keyboard_check(vk_enter);

    // Confirm / cancel alias over the action buttons plus the usual menu keys.
    _c.state[CTRL.CONFIRM]  = _c.state[CTRL.ACTION_1] || keyboard_check(vk_enter);
    _c.state[CTRL.CANCEL]   = _c.state[CTRL.ACTION_2] || keyboard_check(vk_escape);
}

function __ctrl_gp(_btn) {
    var _slot = global.ctrl.gamepad_slot;
    return (_slot >= 0) && gamepad_button_check(_slot, _btn);
}

function ctrl_axis_h() {
    if (!variable_global_exists("ctrl")) ctrl_init();
    return global.ctrl.axis_h;
}

function ctrl_axis_v() {
    if (!variable_global_exists("ctrl")) ctrl_init();
    return global.ctrl.axis_v;
}

function ctrl_check(_action) {
    if (!variable_global_exists("ctrl")) ctrl_init();
    return global.ctrl.state[_action];
}

function ctrl_pressed(_action) {
    if (!variable_global_exists("ctrl")) ctrl_init();
    return global.ctrl.state[_action] && !global.ctrl.prev[_action];
}

function ctrl_released(_action) {
    if (!variable_global_exists("ctrl")) ctrl_init();
    return !global.ctrl.state[_action] && global.ctrl.prev[_action];
}
