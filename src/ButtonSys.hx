import heat.ecs.ComQuery;
import heat.ecs.ComMap;
using heat.AllCore;
using tink.CoreApi;

@:access(Main)
class ButtonSys {
    var query = new ComQuery();

    public function new() {
        query.with(Main.buttons).with(Main.bitmaps);
    }

    public function update(dt:Float) {
        query.run();
        for (id in query.result) {
            var button = Main.buttons[id];
            var bitmap = Main.bitmaps[id];
            button.state = UNPRESSED;
            switch Main.aabbWorld.check(id, new VectorFloat2(bitmap.x, bitmap.y), Main.colFilters[id]) {
                case Success(result): {
                    for (col in result.cols) {
                        if (Main.ents.exists(col.otherId)) {
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