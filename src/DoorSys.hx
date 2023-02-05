import heat.ecs.ComQuery;
import heat.ecs.ComMap;
using heat.AllCore;
using tink.CoreApi;

@:access(Main)
class DoorSys {
    var query = new ComQuery();

    public function new() {
        query.with(Main.doors).with(Main.bitmaps);
    }

    public function update(dt:Float) {
        query.run();
        for (id in query.result) {
            var door = Main.doors[id];
            var bitmap = Main.bitmaps[id];

            switch door.state {
                case OPEN: {
                    bitmap.visible = false;
                }
                case CLOSED: {
                    bitmap.visible = true;
                }
            }
        }
    }
}