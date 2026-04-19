/// @description Crawler stepped on the mine — instant kill for it, mine
///              detonates and may splash the hero via mine_detonate().

with (other) instance_destroy();
mine_detonate(id);
