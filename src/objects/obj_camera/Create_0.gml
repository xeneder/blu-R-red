/// @description Initialise smooth-follow camera and input polling.
camera = new Camera(0, 1366, 768);
camera.set_target(instance_find(obj_hero, 0));
camera.snap_to_target();
