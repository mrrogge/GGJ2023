import heat.ecs.ComQuery;
import heat.ecs.ComMap;
using heat.AllCore;
using tink.CoreApi;

@:access(Main)
class ButtonSys {
    var btnQuery = new ComQuery();

    public function new() {
        btnQuery.with(Main.buttons).with(Main.bitmaps);
    }

    public function update(dt:Float) {
        btnQuery.run();
        for (id in btnQuery.result) {
            var button = Main.buttons[id];
            var bitmap = Main.bitmaps[id];
            button.state = UNPRESSED;
            switch Main.aabbWorld.check(id, new VectorFloat2(bitmap.x, bitmap.y), Main.colFilters[id]) {
                case Success(result): {
                    for (col in result.cols) {
                        if (Main.ents.exists(col.otherId) || Main.boulders.exists(col.otherId)) {
                            button.state = PRESSED;
                            break;
                        }
                    }
                }
                case Failure(_): {}
            }

            switch button.state {
                case PRESSED: {
                    bitmap.tile = switch button.color {
                        case RED: Main.tiles.redButton[1];
                        case BLUE: Main.tiles.blueButton[1];
                        case GREEN: Main.tiles.greenButton[1];
                    }
                }
                case UNPRESSED: {
                    bitmap.tile = switch button.color {
                        case RED: Main.tiles.redButton[0];
                        case BLUE: Main.tiles.blueButton[0];
                        case GREEN: Main.tiles.greenButton[0];
                    }
                }
            }
        }
    }
}