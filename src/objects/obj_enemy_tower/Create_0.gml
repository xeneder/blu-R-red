/// @description Tower state — holds its fire timer.

#macro TOWER_DETECTION_RANGE   520
#macro TOWER_FIRE_COOLDOWN     1.4    // seconds between shots
#macro TOWER_PROJECTILE_SPEED  6      // px/frame

fire_timer = 0;
stop_ttl   = 0;   // set by code_stop_enemies — suppresses fire while > 0
