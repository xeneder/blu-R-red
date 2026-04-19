/// @description Draw a bezier-smoothed expanding ring.

if (radius <= 0) exit;

var _col = signal_color(ping_color);

// Alpha: stays high during expansion, then fades with an ease-in curve so
// it lingers visible and softly disappears.
var _fade_t = clamp(lifetime / (life_total * 1.4), 0, 1);
var _alpha  = (1 - bezier_ease(_fade_t, BEZIER_EASE_IN)) * 0.9;

// Ring thickness tapers as the wave spreads — preserves mass, looks right.
var _thick = lerp(14, 4, bezier_ease(_fade_t, BEZIER_EASE_OUT));
var _inner = max(0, radius - _thick);

draw_ring(x, y, _inner, radius, _col, _alpha);
