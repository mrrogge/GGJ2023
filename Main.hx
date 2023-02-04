class Main extends hxd.App {
    public static function main() {
        new Main();
    }

    override function init() {
        super.init();
        initRects();

    }

    override function update(dt:Float) {
        super.update(dt);
    }

    function initRects() {
        for (i in 0...100) {
            var rectGraphic = new h2d.Graphics();
            var leftX = Std.int(Math.random()*1000);
            var topY = Std.int(Math.random()*1000);
            var width = Std.int(Math.random()*100);
            var height = Std.int(Math.random()*100);
            // rectGraphic.moveTo(leftX, topY);
            rectGraphic.lineStyle(3, 0xff0000, 1);
            rectGraphic.beginFill(0x770000, 1);
            rectGraphic.drawRect(leftX, topY, width, height);
            rectGraphic.endFill();
            s2d.addChild(rectGraphic);
            // var tile = h2d.Tile.fromColor(0x770000, Std.int(Math.random()*50), 
            //     Std.int(Math.random()*50));
            // var bitmap = new h2d.Bitmap(tile);
            // bitmap.setPosition(Std.int(Math.random()*1000), 
            //     Std.int(Math.random()*1000));
            // s2d.addChild(bitmap);
        }
    }
}