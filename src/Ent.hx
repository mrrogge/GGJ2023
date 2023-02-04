@:access(Main)
class Ent extends h2d.Bitmap {

    override public function new(?parent:h2d.Object) {
        super(Main.tiles.ent[0], parent);
    }



    public function update(dt:Float) {

    }

    public function isOverGrass():Bool {
        var level = Main.ldtkProject.getLevelAt(Std.int(absX), Std.int(absY));
        if (level == null) return false;
        var stack = level.l_Floor.getTileStackAt(Std.int(absX), Std.int(absY));
        for (tile in stack) {
            if (Main.ldtkProject.all_tilesets.Tileset.hasTag(tile.tileId, Grass)) {
                return true;
            }
        }
        return false;
    }

    public function toTreeForm() {
        tile = Main.tiles.tree[0];
    }
}

enum EntState {

}