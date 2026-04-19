/// @description Expanding ring that notifies nearby objects as its edge crosses them.
///              Tunable after create via: max_radius, ping_color.

max_radius      = SIGNAL_PING_RADIUS_DEFAULT;
ping_color      = SIGNAL.BLUE;    // SIGNAL.BLUE / SIGNAL.RED
activates_mines = true;           // false for echo / preview pings that must not chain-trigger

radius       = 0;
radius_prev  = 0;
lifetime     = 0;                 // seconds
life_total   = 0;                 // seconds to reach max radius + fade
