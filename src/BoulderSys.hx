import heat.ecs.ComQuery;
import heat.ecs.ComMap;
using heat.AllCore;
using tink.CoreApi;

class BoulderSys {
    public final colSlot:heat.event.Slot<heat.aabb.World.Collision>;

    public function new() {
        colSlot = new heat.event.Slot(onCollision);
    }

    function onCollision(col:heat.aabb.World.Collision) {
        if (!Main.boulders.exists(col.otherId)) return;
        var bitmap = Main.bitmaps[col.otherId];
        var goal = new MVectorFloat2(bitmap.x, bitmap.y) + col.normal.toVectorFloat2();
        var moveResult = Main.aabbWorld.move(col.otherId, goal, 
            Main.colFilters[col.otherId]);
        switch moveResult {
            case Success(result): {
                bitmap.x = result.actualPos.x;
                bitmap.y = result.actualPos.y;
            }
            case Failure(_): {}
        }
    }
}