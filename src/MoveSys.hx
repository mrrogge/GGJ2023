import heat.ecs.ComQuery;
import heat.ecs.ComMap;
using heat.AllCore;

@:access(Main)
class MoveSys {
    var bitmapQuery = new ComQuery();

    public function new() {
        bitmapQuery.with(Main.velocities).with(Main.prevVels).with(Main.bitmaps);
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
            bitmap.x += dx;
            bitmap.y += dy;

            prevVel.initFrom(vel);
        }
    }
}


// class MoveSys {
//     var coms:ComStore;
//     var world:BumpWorld;
//     var query = new heat.ecs.ComQuery();
//     static inline final EPSILON = 1e-7;
//     public var colSignal:heat.event.ISignal<hxbump.World.Collision<heat.ecs.EntityId>>;
//     var colSignalEmitter = new heat.event.SignalEmitter<hxbump.World.Collision<heat.ecs.EntityId>>();
//     public var preMoveSignal:heat.event.ISignal<heat.ecs.EntityId>;
//     var preMoveSignalEmitter = new heat.event.SignalEmitter<heat.ecs.EntityId>();
//     var filter:Null<hxbump.World.ColFilterFunc<heat.ecs.EntityId>> = null;
//     var maxCheckDist = 1500;
//     public var checkRefPos = new heat.core.MFloatVector2();

//     public function new(coms:ComStore, world:BumpWorld, 
//     ?filter:hxbump.World.ColFilterFunc<heat.ecs.EntityId>) {
//         this.coms = coms;
//         this.world = world;
//         query.with(coms.velocities).with(coms.bumpObjects).with(coms.objects);
//         colSignal = colSignalEmitter.signal;
//         preMoveSignal = preMoveSignalEmitter.signal;
//         this.filter = filter;
//         colSignal.connect(new heat.event.Slot(onCollision));
//     }

//     inline function sign(v:Float):Float {
//         return v/Math.abs(v);
//     }

//     //Moves everything based on velocities
//     var __move_objectVector = new heat.core.MFloatVector2();
//     public function move(dt:Float) {
//         query.run();
//         for (id in query.result) {
//             var object = coms.objects[id];
//             var absPos = object.getAbsPos();
//             __move_objectVector.x = absPos.x;
//             __move_objectVector.y = absPos.y;
//             if (checkRefPos.distSquared(__move_objectVector) > maxCheckDist*maxCheckDist) continue;
//             var vel = coms.velocities[id];
//             var dvx = vel.x - vel.prevX;
//             var dvy = vel.y - vel.prevY;
//             var dx = Math.min(Math.max(vel.x + dvx/2*dt, -vel.xMax), vel.xMax) * dt;
//             var dy = Math.min(Math.max(vel.y + dvy/2*dt, -vel.yMax), vel.yMax) * dt;
//             if (dx == 0 && dy == 0) continue;
//             preMoveSignalEmitter.emit(id);
//             vel.prevX = vel.x;
//             vel.prevY = vel.y;
//             switch world.moveBy(id, 0, dy, filter)
//             {
//                 case Failure(failure): {}
//                 case Success(moveResult): {
//                     for (col in moveResult.cols) {
//                         colSignalEmitter.emit(col);
//                     }
//                 }
//             }
//             switch world.moveBy(id, dx, 0, filter)
//             {
//                 case Failure(failure): {}
//                 case Success(moveResult): {
//                     for (col in moveResult.cols) {
//                         colSignalEmitter.emit(col);
//                     }
//                 }
//             }
//         }
//     }

//     function onCollision(arg:hxbump.World.Collision<heat.ecs.EntityId>) {
//         var vel = coms.velocities[arg.item];
//         if (vel == null) return;
//         switch arg.kind {
//             case SLIDE: {
//                 if (arg.normal.y != 0) vel.y = 0;
//                 else if (arg.normal.x != 0) vel.x = 0;
//             }
//             case TOUCH: {
//                 vel.x = 0;
//                 vel.y = 0;
//             }
//             case BOUNCE: {
//                 if (arg.normal.y != 0) vel.y *= -1;
//                 else if (arg.normal.x != 0) vel.x *= -1;
//             }
//             case CROSS, NONE, OTHER(_): {}
//         }
//     }
// }