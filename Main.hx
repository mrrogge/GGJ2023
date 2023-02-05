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
    public static final aabbWorld = new heat.aabb.World();
    public static final colFilters = new ComMap<heat.aabb.World.ColFilterFunc>();
    public static final walls = new ComMap<Bool>();

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
        var level0 = ldtkProject.all_levels.Level_0;
        var level0TG = level0.l_Floor.render();
        level0TG.setPosition(level0.worldX, level0.worldY);
        s2d.addChild(level0TG);
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

        for (cy in 0...level0.l_Floor.cHei) {
            for (cx in 0...level0.l_Floor.cWid) {
                if (!level0.l_Floor.hasAnyTileAt(cx, cy)) continue;
                var stack = level0.l_Floor.getTileStackAt(cx, cy);
                for (tile in stack) {
                    if (level0.l_Floor.tileset.hasTag(tile.tileId, Wall)) {
                        var gridSize = level0.l_Floor.gridSize;
                        var id = getId();
                        var aabb = new heat.aabb.Rect(
                            new VectorFloat2(level0.worldX+cx*gridSize, level0.worldY+cy*gridSize),
                            new VectorFloat2(gridSize, gridSize)
                        );
                        aabbWorld.add(id, aabb);
                        walls[id] = true;
                        colFilters[id] = noneColFilter;
                    }
                }
            }
        }

        loadButtons();
        loadEnts();
    }

    function loadButtons() {
        var level0 = ldtkProject.all_levels.Level_0.l_Entities;
        for (btn in level0.all_GreenBtn) {
            var id = getId();
            var bitmap = new h2d.Bitmap(tiles.greenButton[0]);
            bitmaps[id] = bitmap;
            bitmap.setPosition(btn.pixelX, btn.pixelY);
            s2d.addChild(bitmap);
        }
        for (btn in level0.all_RedBtn) {
            var id = getId();
            var bitmap = new h2d.Bitmap(tiles.redButton[0]);
            bitmaps[id] = bitmap;
            bitmap.setPosition(btn.pixelX, btn.pixelY);
            s2d.addChild(bitmap);
        }
        for (btn in level0.all_BlueBtn) {
            var id = getId();
            var bitmap = new h2d.Bitmap(tiles.blueButton[0]);
            bitmaps[id] = bitmap;
            bitmap.setPosition(btn.pixelX, btn.pixelY);
            s2d.addChild(bitmap);
        }
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
        var aabb1 = new heat.aabb.Rect(
            new VectorFloat2(bitmap1.x, bitmap1.y),
            new VectorFloat2(ldtkEnt1.width, ldtkEnt1.height),
            new VectorFloat2(ldtkEnt1.width*ldtkEnt1.pivotX, ldtkEnt1.height*ldtkEnt1.pivotY)
        );
        aabbWorld.add(ent1Id, aabb1);

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
        var aabb2 = new heat.aabb.Rect(
            new VectorFloat2(bitmap2.x, bitmap2.y),
            new VectorFloat2(ldtkEnt2.width, ldtkEnt2.height),
            new VectorFloat2(ldtkEnt2.width*ldtkEnt2.pivotX, ldtkEnt2.height*ldtkEnt2.pivotY)
        );
        aabbWorld.add(ent2Id, aabb2);
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
            case EKeyDown | EKeyUp: {
                updateActiveEntWalkCmds(event);
            }
            default: {}
        }
        switch event.kind {
            case EKeyDown: {
                switch event.keyCode {
                    case hxd.Key.SPACE: {
                        handleEntSwitch();
                    }
                }
            }
            default: {}
        }
    }

    function updateActiveEntWalkCmds(event:hxd.Event) {
        var id = ent2Active ? ent2Id : ent1Id;
        var ent = ents[id];
        switch event.kind {
            case EKeyDown: {
                switch event.keyCode {
                    case hxd.Key.A: {
                        ent.moveLeftCmd = true;
                    }
                    case hxd.Key.W: {
                        ent.moveUpCmd = true;
                    }
                    case hxd.Key.D: {
                        ent.moveRightCmd = true;
                    }
                    case hxd.Key.S: {
                        ent.moveDownCmd = true;
                    }
                    default: {}
                }
            }
            case EKeyUp: {
                switch event.keyCode {
                    case hxd.Key.A: {
                        ent.moveLeftCmd = false;
                    }
                    case hxd.Key.W: {
                        ent.moveUpCmd = false;
                    }
                    case hxd.Key.D: {
                        ent.moveRightCmd = false;
                    }
        
                    case hxd.Key.S: {
                        ent.moveDownCmd = false;
                    }
                    default: {}
                }
            }
            default: {}
        }
    }

    function handleEntSwitch() {
        var activeId = ent2Active ? ent2Id : ent1Id;
        var inactiveId = ent2Active ? ent1Id : ent2Id;
        var activeEnt = ents[activeId];
        var inactiveEnt = ents[inactiveId];
        activeEnt.switchFormRequest = true;
        new Updater(updaters)
        .withOnUpdate((me:Updater, dt:Float)->{
            switch activeEnt.switchFormRequestResult {
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
                inactiveEnt.switchFormRequest = true;
                ent2Active = !ent2Active;
                me.resolve();
            })
        )
        .next(new Updater(updaters)
            .withOnUpdate((me:Updater, dt:Float)->{
                switch inactiveEnt.switchFormRequestResult {
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

    public static function noneColFilter(item:Int, other:Int):heat.aabb.World.CollisionKind {
        return NONE;
    }
}