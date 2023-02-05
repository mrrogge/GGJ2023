class Tiles {
    public final ent:Array<h2d.Tile>;
    public final tree:Array<h2d.Tile>;
    public final greenButton:Array<h2d.Tile>;
    public final redButton:Array<h2d.Tile>;
    public final blueButton:Array<h2d.Tile>;
    public final greenDoor:Array<h2d.Tile>;
    public final redDoor:Array<h2d.Tile>;
    public final blueDoor:Array<h2d.Tile>;

    public function new() {
        ent = makeTileArrayFromFixedSize(hxd.Res.img.ent1_png, 0, 0, 20, 36, 1, 10, 18);
        tree = makeTileArrayFromFixedSize(hxd.Res.img.tree_png, 0, 0, 64, 64, 1, 32, 32);
        greenButton = makeTileArrayFromFixedSize(hxd.Res.img.greenButton_png, 0, 0, 32, 32, 2, 0, 0);
        redButton = makeTileArrayFromFixedSize(hxd.Res.img.redButton_png, 0, 0, 32, 32, 2, 0, 0);
        blueButton = makeTileArrayFromFixedSize(hxd.Res.img.blueButton_png, 0, 0, 32, 32, 2, 0, 0);
        greenDoor = makeTileArrayFromFixedSize(hxd.Res.img.greenDoor_png, 0, 0, 16, 64, 1, 0, 0);
        redDoor = makeTileArrayFromFixedSize(hxd.Res.img.redDoor_png, 0, 0, 16, 64, 1, 0, 0);
        blueDoor = makeTileArrayFromFixedSize(hxd.Res.img.blueDoor_png, 0, 0, 64, 16, 1, 0, 0);
    }

    function makeTileArrayFromFixedSize(res:hxd.res.Image, x:Int, y:Int, w:Int, 
    h:Int, frames:Int, dx:Int, dy:Int):Array<h2d.Tile> 
    {
        var tileArray = new Array<h2d.Tile>();
        var imgTile = res.toTile();
        for (frameIdx in 0...frames) {
            var tile = imgTile.sub(x, y, w, h, -dx, -dy);
            tileArray.push(tile);
            x += w;
        }
        return tileArray;
    }
}