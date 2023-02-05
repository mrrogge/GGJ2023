using tink.CoreApi;

@:access(Main)
class Ent {
    public var state:EntState = ENT;
    public var tile:h2d.Tile;
    public var switchFormRequest = false;

    public function new() {
        tile = Main.tiles.ent[0];
    }
}

enum EntState {
    ENT;
    BECOMING_TREE;
    TREE;
    BECOMING_ENT;
}