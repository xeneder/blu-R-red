/// @description Knockback physics, stun gate, chase / pathfind AI, anim phase.

// Sort by depth
event_inherited()

if (game_is_over()) exit;

var _dt = delta_time / 1000000;

// --- Knockback always integrates (lets stunned crawlers still get shoved) ---
if (knockback_vx != 0 || knockback_vy != 0) {
    move_and_collide(knockback_vx, knockback_vy, obj_wall);
    knockback_vx *= KNOCKBACK_DAMP;
    knockback_vy *= KNOCKBACK_DAMP;
    if (abs(knockback_vx) < 0.1) knockback_vx = 0;
    if (abs(knockback_vy) < 0.1) knockback_vy = 0;
}

// --- Stun gate: suppress AI, keep animating (idle bob) --------------------
is_moving = false;
var _ai_active = (stun_ttl <= 0);
if (!_ai_active) {
    stun_ttl = max(0, stun_ttl - _dt);
} else if (instance_exists(obj_hero)) {
    var _hero = instance_find(obj_hero, 0);
    var _dist = point_distance(x, y, _hero.x, _hero.y);

    if (_dist <= CRAWLER_DETECTION_RANGE) {
        // LOS check: walls block sight (and pathing fallback otherwise).
        var _has_los = (collision_line(x, y, _hero.x, _hero.y, obj_wall, false, true) == noone);

        var _move_dir = undefined;

        if (_has_los) {
            // Direct pursuit — aim straight at the hero.
            _move_dir = point_direction(x, y, _hero.x, _hero.y);
        } else if (instance_exists(obj_game_controller)) {
            // Grid pathfinding fallback. Recompute periodically; otherwise
            // follow the cached waypoint list.
            path_refresh_timer -= _dt;
            if (path_refresh_timer <= 0) {
                mp_grid_path(obj_game_controller.ai_grid,
                             path_resource,
                             x, y,
                             _hero.x, _hero.y,
                             true);
                path_current_node  = 1;   // node 0 is our own position
                path_refresh_timer = CRAWLER_PATH_REFRESH;
            }

            var _nodes = path_get_number(path_resource);
            // Advance waypoints we've already reached.
            while (path_current_node < _nodes) {
                var _nx = path_get_point_x(path_resource, path_current_node);
                var _ny = path_get_point_y(path_resource, path_current_node);
                if (point_distance(x, y, _nx, _ny) < CRAWLER_WAYPOINT_RADIUS) {
                    path_current_node++;
                } else {
                    break;
                }
            }
            if (path_current_node < _nodes) {
                var _tx = path_get_point_x(path_resource, path_current_node);
                var _ty = path_get_point_y(path_resource, path_current_node);
                _move_dir = point_direction(x, y, _tx, _ty);
            }
        }

        if (!is_undefined(_move_dir)) {
            var _mx = lengthdir_x(CRAWLER_SPEED, _move_dir);
            var _my = lengthdir_y(CRAWLER_SPEED, _move_dir);
            move_and_collide(_mx, _my, obj_wall);
            is_moving = true;
            if (abs(_mx) > 0.01) facing_x = sign(_mx);
        }
    }
}

// --- Bob phase integrates at the current animation period ------------------
var _period = is_moving ? CRAWLER_MOVE_BOB_PERIOD : CRAWLER_IDLE_BOB_PERIOD;
bob_phase = frac(bob_phase + _dt / _period);
