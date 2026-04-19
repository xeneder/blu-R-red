/// @description Contact damage: hurt hero, knockback self, stun.
///              `stun_ttl` gate stops every frame of overlap from re-firing.

if (stun_ttl > 0) exit;

hero_damage(CRAWLER_DAMAGE, x, y);

// Bounce away from the hero. point_direction(hero → me) is the push vector.
var _away = point_direction(other.x, other.y, x, y);
knockback_vx = lengthdir_x(CRAWLER_KNOCKBACK, _away);
knockback_vy = lengthdir_y(CRAWLER_KNOCKBACK, _away);
stun_ttl = CRAWLER_STUN_DURATION;
