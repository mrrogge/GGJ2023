import heat.ecs.ComQuery;
import heat.ecs.ComMap;
using heat.AllCore;
using tink.CoreApi;

class CameraSys {
    var query = new ComQuery();

    public function new() {
        query.with(Main.cameras).with(Main.camConfigs);
    }

    public function update(dt:Float) {
        followActiveEnt();

        query.run();
        for (id in query.result) {
            var cam = Main.cameras[id];
            var config = Main.camConfigs[id];
            if (config.enableLock) {
                var dx = config.lockX-cam.x;
                var dy = config.lockY-cam.y;
                if (config.deadzone.containsPoint(new VectorFloat2(dx, dy))) return;
                switch config.moveType {
                    case NULL: {
                        cam.x = config.lockX;
                        cam.y = config.lockY;
                    }
                    case LINEAR(speed): {
                        cam.x += Math.sign(dx) * Math.min(Math.abs(dx), 32 * speed * dt);
                        cam.y += Math.sign(dy) * Math.min(Math.abs(dy), 32 * speed * dt);
                    }
                    case DAMPENED(stiffness): {
                        cam.x += Math.sign(dx) * Math.min(Math.abs(dx), 
                            Math.abs(dx) * dt * stiffness);
                        cam.y += Math.sign(dy) * Math.min(Math.abs(dy), 
                            Math.abs(dy) * dt * stiffness);
                    }
                }
            }
        }
    }

    public function followActiveEnt() {
        var entBitmap = Main.bitmaps[Main.activeEntId];
        Main.worldCamConfig.lockX = entBitmap.x;
        Main.worldCamConfig.lockY = entBitmap.y;
    }
}