import heat.ecs.ComMap;
using heat.AllCore;
using tink.CoreApi;
class Main extends hxd.App {
    public static var ldtkProject:LdtkProject;
    public static var tiles:Tiles;

    public static final velocities = new ComMap<MVectorFloat2>();
    public static final prevVels = new ComMap<MVectorFloat2>();
    public static final bitmaps = new ComMap<h2d.Bitmap>();
    public static final ents = new ComMap<Ent>();

    public static var ent1Id:Int;
    public static var ent2Id:Int;
    public static var ent2Active = false;

    static var nextId = 0;

    public static inline final TILE_SIZE = 16;
    public static inline final CAM_PX_WIDTH = TILE_SIZE * 20;
    public static inline final CAM_PX_HEIGHT = TILE_SIZE * 16;

    var moveSys:MoveSys;
    var entSys:EntSys;
    var updaters = new Updater.UpdaterGroup();

    static inline final FIXED_UPDATE_RATE = 30.;
    static inline final MAX_UPDATE_CALLS_PER_FRAME = 5;
    var updateAcc = 0.;

    public static function main() {
        new Main();
    }

    override function init() {
        super.init();
        initWindow();
        initTiles();
        initScene();
        initSystems();
        loadLevels();
    }

    function initWindow() {
        hxd.Window.getInstance().resize(CAM_PX_WIDTH*3, CAM_PX_HEIGHT*3);
        hxd.Window.getInstance().addEventTarget(keyEventHandler);
    }

    function initTiles() {
        tiles = new Tiles();
    }

    function initScene() {
        //sets the scene to a fixed size with space around it to fill the window. Hardcoding this for now, should eventually configurable via game UI
       s2d.scaleMode = LetterBox(CAM_PX_WIDTH, CAM_PX_HEIGHT, true, Center, Center);
    }

    function initSystems() {
        moveSys = new MoveSys();
        entSys = new EntSys();
    }
    
    function onUpdate(dt:Float) {
        updaters.update(dt);
        moveSys.update(dt);
        entSys.update(dt);
    }

    override function update(dt:Float) {
        super.update(dt);
        updateAcc += dt;
        if (updateAcc > MAX_UPDATE_CALLS_PER_FRAME/FIXED_UPDATE_RATE) {
            updateAcc = MAX_UPDATE_CALLS_PER_FRAME/FIXED_UPDATE_RATE;
        }
        while (updateAcc >= 1/FIXED_UPDATE_RATE) {
            onUpdate(1/FIXED_UPDATE_RATE);
            updateAcc -= 1/FIXED_UPDATE_RATE;
        }
    }

    function loadLevels() {
        ldtkProject = new LdtkProject();
        var level0 = ldtkProject.all_levels.Level_0.l_Floor.render();
        level0.setPosition(ldtkProject.all_levels.Level_0.worldX, ldtkProject.all_levels.Level_0.worldY);
        s2d.addChild(level0);
        var level1 = ldtkProject.all_levels.Level_1.l_Floor.render();
        level1.setPosition(ldtkProject.all_levels.Level_1.worldX, ldtkProject.all_levels.Level_1.worldY);
        s2d.addChild(level1);
        var level2 = ldtkProject.all_levels.Level_2.l_Floor.render();
        level2.setPosition(ldtkProject.all_levels.Level_2.worldX, ldtkProject.all_levels.Level_2.worldY);
        s2d.addChild(level2);
        var level3 = ldtkProject.all_levels.Level_3.l_Floor.render();
        level3.setPosition(ldtkProject.all_levels.Level_3.worldX, ldtkProject.all_levels.Level_3.worldY);
        s2d.addChild(level3);
        var level4 = ldtkProject.all_levels.Level_4.l_Floor.render();
        level4.setPosition(ldtkProject.all_levels.Level_4.worldX, ldtkProject.all_levels.Level_4.worldY);
        s2d.addChild(level4);
        var level5 = ldtkProject.all_levels.Level_5.l_Floor.render();
        level5.setPosition(ldtkProject.all_levels.Level_5.worldX, ldtkProject.all_levels.Level_5.worldY);
        s2d.addChild(level5);

        loadEnts();
    }

    function loadEnts() {
        ent1Id = getId();
        var ent1 = new Ent();
        ents[ent1Id] = ent1;
        var bitmap1 = new h2d.Bitmap();
        bitmaps[ent1Id] = bitmap1;
        var ldtkEnt1 = ldtkProject.all_levels.Level_0.l_Entities.all_Ent[0];
        bitmap1.setPosition(ldtkEnt1.pixelX, ldtkEnt1.pixelY);
        s2d.addChild(bitmap1);
        velocities[ent1Id] = new MVectorFloat2();
        prevVels[ent1Id] = new MVectorFloat2();
        

        ent2Id = getId();
        var ent2 = new Ent();
        ents[ent2Id] = ent2;
        ent2.switchFormRequest = true;
        var bitmap2 = new h2d.Bitmap();
        bitmaps[ent2Id] = bitmap2;
        var ldtkEnt2 = ldtkProject.all_levels.Level_0.l_Entities.all_Tree[0];
        bitmap2.setPosition(ldtkEnt2.pixelX, ldtkEnt2.pixelY);
        s2d.addChild(bitmap2);
        velocities[ent2Id] = new MVectorFloat2();
        prevVels[ent2Id] = new MVectorFloat2();
    }

    override function loadAssets(onLoaded:() -> Void) {
        #if js
        hxd.Res.initEmbed();
        #else
        hxd.res.Resource.LIVE_UPDATE = true;
        hxd.Res.initLocal();
        #end
        super.loadAssets(onLoaded);
    }

    function keyEventHandler(event:hxd.Event) {
        switch event.kind {
            case EKeyDown: {
                if (!hxd.Key.ALLOW_KEY_REPEAT && hxd.Key.isDown(event.keyCode)) return;
                switch event.keyCode {
                    case hxd.Key.A | hxd.Key.W | hxd.Key.D | hxd.Key.S: {
                        makeActiveEntWalk(event.keyCode);
                    }
                    case hxd.Key.SPACE: {
                        handleEntSwitch();
                    }
                }
            }
            case EKeyUp: {
                stopActiveEntWalking(event.keyCode);
            }
            default: {}
        }
    }

    function makeActiveEntWalk(keyCode:Int) {
        var id = ent2Active ? ent2Id : ent1Id;
        var vel = velocities[id];
        final SPEED = 100;
        switch keyCode {
            case hxd.Key.A: {
                vel.x = -SPEED;
            }
            case hxd.Key.W: {
                vel.y = -SPEED;
            }
            case hxd.Key.D: {
                vel.x = SPEED;
            }

            case hxd.Key.S: {
                vel.y = SPEED;
            }
            default: {}
        }
    }

    function stopActiveEntWalking(keyCode:Int) {
        var id = ent2Active ? ent2Id : ent1Id;
        var vel = velocities[id];
        switch keyCode {
            case hxd.Key.A: {
                vel.x = 0;
            }
            case hxd.Key.W: {
                vel.y = 0;
            }
            case hxd.Key.D: {
                vel.x = 0;
            }

            case hxd.Key.S: {
                vel.y = 0;
            }
            default: {}
        }
    }

    function handleEntSwitch() {
        var ent1 = ents[ent1Id];
        ent1.switchFormRequest = true;
        new Updater(updaters)
        .withOnUpdate((me:Updater, dt:Float)->{
            var ent1 = ents[ent1Id];
            switch ent1.switchFormRequestResult {
                case Some(Success(_)): {  
                    me.resolve();
                }
                case Some(Failure(_)): {
                    me.reject();
                }
                case None: {}
            }
        })
        .begin()
        .next(new Updater(updaters)
            .withOnUpdate((me:Updater, dt:Float)->{
                var ent = ents[ent2Id];
                ent.switchFormRequest = true;
                ent2Active = !ent2Active;
                me.resolve();
            })
        )
        .next(new Updater(updaters)
            .withOnUpdate((me:Updater, dt:Float)->{
                var ent = ents[ent2Id];
                switch ent.switchFormRequestResult {
                    case Some(Success(_)): {
                        me.resolve();
                    }
                    case Some(Failure(_)): {
                        me.reject();
                    }
                    case None: {}
                }
            })
        );    
    }

    public static function getId():Int {
        return nextId++;
    }
}