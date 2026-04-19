/// @description Crawler state — detection, pathfinding handle, knockback.

#macro CRAWLER_DETECTION_RANGE   400
#macro CRAWLER_SPEED             3        // px/frame
#macro CRAWLER_DAMAGE            1
#macro CRAWLER_KNOCKBACK         6        // px/frame initial — smaller than the hero's
#macro CRAWLER_STUN_DURATION     0.85     // seconds — a touch longer than the knockback decay
#macro CRAWLER_PATH_REFRESH      0.4      // seconds between mp_grid_path recomputes
#macro CRAWLER_WAYPOINT_RADIUS   20       // px — considered "arrived" at a waypoint

#macro CRAWLER_IDLE_BOB_PERIOD   1.6
#macro CRAWLER_MOVE_BOB_PERIOD   0.32
#macro CRAWLER_IDLE_SQUASH       0.05
#macro CRAWLER_MOVE_SQUASH       0.14

// Movement / AI state
knockback_vx   = 0;
knockback_vy   = 0;
stun_ttl       = 0;

is_moving      = false;
facing_x       = 1;

// Pathfinding — each crawler owns its own path resource, but they all share
// the one mp_grid on obj_game_controller. Staggered refresh keeps the cost
// of mp_grid_path cheap even with many crawlers.
path_resource       = path_add();
path_current_node   = 0;
path_refresh_timer  = random_range(0, CRAWLER_PATH_REFRESH);

// Animation
bob_phase = random(1);
