import heat.ecs.ComQuery;
import heat.ecs.ComMap;
using heat.AllCore;
using tink.CoreApi;

class ButtonDoorLinkSys {
    var btnQuery = new ComQuery();
    var doorQuery = new ComQuery();

    public function new() {
        btnQuery.with(Main.buttons);
        doorQuery.with(Main.doors);
    }

    public function update(dt:Float) {
        btnQuery.run();
        doorQuery.run();
        for (btnId in btnQuery.result) {
            var btn = Main.buttons[btnId];
            for (id in doorQuery.result) {
                var door = Main.doors[id];
                if (door.level != btn.level || door.color != btn.color) continue;
                door.state = switch btn.state {
                    case PRESSED: OPEN;
                    case UNPRESSED: CLOSED;
                }
                break;
            }
        }
    }
}