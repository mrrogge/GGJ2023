import heat.ecs.ComQuery;
import heat.ecs.ComMap;
using heat.AllCore;

@:access(Main)
class MoveSys {
    final bitmapQuery = new ComQuery();

    public final colSignal:heat.event.ISignal<heat.aabb.World.Collision>;
    final colSignalEmitter = new heat.event.SignalEmitter<heat.aabb.World.Collision>();

    public function new() {
        bitmapQuery.with(Main.velocities).with(Main.prevVels).with(Main.bitmaps);
        colSignal = colSignalEmitter.signal;
        colSignal.connect(new heat.event.Slot(onCollision));
    }

    public function update(dt:Float) {
        bitmapQuery.run();
        for (id in bitmapQuery.result) {
            var vel = Main.velocities[id];
            var prevVel = Main.prevVels[id];
            var bitmap = Main.bitmaps[id];

            var dvx = vel.x - prevVel.x;
            var dvy = vel.y - prevVel.y;
            var dx = vel.x * dt + dvx/2 * dt * dt;
            var dy = vel.y * dt + dvy/2 *dt * dt;
            if (dx == 0 && dy == 0) continue;
            var colFilter = Main.colFilters.exists(id) ? Main.colFilters[id] : Main.aabbWorld.defaultFilter;
            switch Main.aabbWorld.move(id, new VectorFloat2(bitmap.x+dx, bitmap.y), colFilter) {
                case Success(result): {
                    bitmap.x = result.actualPos.x;
                    bitmap.y = result.actualPos.y;
                }
                case Failure(err): {
                    bitmap.x += dx;
                }
            }
            switch Main.aabbWorld.move(id, new VectorFloat2(bitmap.x, bitmap.y+dy), colFilter) {
                case Success(result): {
                    bitmap.x = result.actualPos.x;
                    bitmap.y = result.actualPos.y;
                }
                case Failure(err): {
                    bitmap.y += dy;
                }
            }
            prevVel.initFrom(vel);
        }
    }

    function onCollision(col:heat.aabb.World.Collision) {
        var vel = Main.velocities[col.movingId];
        if (vel == null) return;
        switch col.kind {
            case SLIDE: {
                if (col.normal.y != 0) vel.y = 0;
                else if (col.normal.x != 0) vel.x = 0;
            }
            case TOUCH: {
                vel.x = 0;
                vel.y = 0;
            }
            case BOUNCE: {
                if (col.normal.y != 0) vel.y *= -1;
                else if (col.normal.x != 0) vel.x *= -1;
            }
            case CROSS, NONE, OTHER(_): {}
        }
    }
}