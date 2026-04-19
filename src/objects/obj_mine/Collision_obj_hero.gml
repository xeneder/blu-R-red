/// @description Mine triggers on hero contact: explosion + HP loss + camera kick.

instance_create_depth(x, y, -200, obj_explosion);
hero_damage(1);

// Camera shake gives the impact some weight.
if (instance_exists(obj_camera)) {
    with (obj_camera) { camera.shake(14); }
}

instance_destroy();
