import heat.ecs.ComQuery;
import heat.ecs.ComMap;
using heat.AllCore;
using tink.CoreApi;

@:access(Main)
class EntSys {
    var query = new ComQuery();
    public final colSlot:heat.event.Slot<heat.aabb.World.Collision>;

    public function new() {
        query.with(Main.ents).with(Main.velocities).with(Main.bitmaps);
        colSlot = new heat.event.Slot(onCollision);
    }

    public function update(dt:Float) {
        query.run();
        for (id in query.result) {
            var ent = Main.ents[id];
            var bitmap = Main.bitmaps[id];
            var vel = Main.velocities[id];
            
            vel.init(0,0);
            switch ent.state {
                case ENT: {
                    if (ent.moveDownCmd) vel.y += 1;
                    if (ent.moveUpCmd) vel.y -= 1;
                    if (ent.moveLeftCmd) vel.x -= 1;
                    if (ent.moveRightCmd) vel.x += 1;
                    vel.normalize().multiplyBy(100);
                }
                case BECOMING_TREE | BECOMING_ENT | TREE: {}
            }

            switch ent.state {
                case BECOMING_TREE: {
                    ent.tile = Main.tiles.tree[0];
                    updateAABB(id, 64, 64);
                    ent.state = TREE;
                }
                case BECOMING_ENT: {
                    ent.tile = Main.tiles.ent[0];
                    updateAABB(id, 16, 32);
                    ent.state = ENT;
                }
                case ENT | TREE if (ent.switchFormRequest): {
                    switch tryToSwitchForms(ent, bitmap) {
                        case Success(_): {
                            ent.switchFormRequestResult = Some(Success(Noise));
                        }
                        case Failure(err): {
                            ent.switchFormRequestResult = Some(Failure(err));
                        }
                    }
                    ent.switchFormRequest = false;
                }
                case ENT: {}
                case TREE: {}
            }

            bitmap.tile = ent.tile;
        }
    }

    function isOverGrass(bitmap:h2d.Bitmap):Bool {
        var level = Main.ldtkProject.getLevelAt(Std.int(bitmap.x), Std.int(bitmap.y));
        if (level == null) return false;
        var cx = Std.int((bitmap.x - level.worldX) / level.l_Floor.gridSize);
        var cy = Std.int((bitmap.y - level.worldY) / level.l_Floor.gridSize);
        var stack = level.l_Floor.getTileStackAt(cx, cy);
        for (tile in stack) {
            if (Main.ldtkProject.all_tilesets.Tileset.hasTag(tile.tileId, Grass)) {
                return true;
            }
        }
        return false;
    }

    function tryToSwitchForms(ent:Ent, bitmap:h2d.Bitmap):Outcome<Ent.EntState, Error> {
        if (!isOverGrass(bitmap)) return Failure(new Error("not over grass"));
        switch ent.state {
            case ENT: {
                ent.state = BECOMING_TREE;
                return Success(BECOMING_TREE);
            }
            case TREE: {
                ent.state = BECOMING_ENT;
                return Success(BECOMING_ENT);
            }
            case BECOMING_TREE | BECOMING_ENT: return Failure(new Error("already in-progress"));
        }
    }

    function updateAABB(id:Int, width:Float, height:Float) {
        switch Main.aabbWorld.getRect(id) {
            case Success(aabb): {
                Main.aabbWorld.update(id, aabb.pos, new VectorFloat2(width, height),
                    new VectorFloat2(width/2, height/2));
            }
            case Failure(_): {}
        }
    }

    function onCollision(col:heat.aabb.World.Collision) {
        if (!Main.ents.exists(col.movingId)) return;
        if (!Main.boulders.exists(col.otherId)) return;
        var bitmap = Main.bitmaps[col.otherId];
        var goal = new VectorFloat2(bitmap.x, bitmap.y) - col.normal.toVectorFloat2();
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