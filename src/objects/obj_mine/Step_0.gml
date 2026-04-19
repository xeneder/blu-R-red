if (revealed) {
    reveal_cd -= delta_time / 1000000;
    if (reveal_cd <= 0) {
        revealed = false;
    }
}