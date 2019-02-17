/// cli_clear_tiles_recent()
/// clears all tiles if not cleared in the last 50 frames.

if tile_clear_timer > 50 {
    while (true) {
        var tiles = tile_get_ids();
        if array_length_1d(tiles) <= 0
            break;
        tile_layer_delete(tile_get_depth(tiles[0]));
    }
}

tile_clear_timer = 0;