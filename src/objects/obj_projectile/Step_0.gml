/// @description Integrate motion, then resolve wall or hero collision.

x += vx;
y += vy;

// Wall hit — burst and despawn.
if (collision_circle(x, y, PROJECTILE_RADIUS, obj_wall, false, true) != noone) {
    spawn_burst(x, y,
                PROJECTILE_BURST_COUNT,
                PROJECTILE_BURST_SIZE_MIN,  PROJECTILE_BURST_SIZE_MAX,
                PROJECTILE_BURST_LIFE_MIN,  PROJECTILE_BURST_LIFE_MAX,
                PROJECTILE_BURST_SPEED_MIN, PROJECTILE_BURST_SPEED_MAX);
    instance_destroy();
    exit;
}

// Hero hit — damage (gated by i-frames), burst, despawn. The burst fires
// regardless of whether damage landed so i-framed hits still read visually.
if (instance_exists(obj_hero) &&
    collision_circle(x, y, PROJECTILE_RADIUS, obj_hero, false, true) != noone) {
    hero_damage(PROJECTILE_DAMAGE, x, y);
    spawn_burst(x, y,
                PROJECTILE_BURST_COUNT,
                PROJECTILE_BURST_SIZE_MIN,  PROJECTILE_BURST_SIZE_MAX,
                PROJECTILE_BURST_LIFE_MIN,  PROJECTILE_BURST_LIFE_MAX,
                PROJECTILE_BURST_SPEED_MIN, PROJECTILE_BURST_SPEED_MAX);
    instance_destroy();
}
