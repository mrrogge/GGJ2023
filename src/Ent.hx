using tink.CoreApi;

@:access(Main)
class Ent {
    public var state:EntState = ENT;
    public var tile:h2d.Tile;
    public var switchFormRequest(default, set) = false;
    function set_switchFormRequest(b:Bool):Bool {
        switchFormRequest = b;
        if (b) switchFormRequestResult = None;
        return b;
    }
    public var switchFormRequestResult:Option<Outcome<Noise, Error>> = None;

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