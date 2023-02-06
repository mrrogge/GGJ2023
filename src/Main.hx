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
    public static final buttons = new ComMap<Button>();
    public static final doors = new ComMap<Door>();
    public static final cameras = new ComMap<h2d.Camera>();
    public static final camConfigs = new ComMap<CameraConfig>();
    public static var worldCamera:h2d.Camera;
    public static var worldCamConfig:CameraConfig;
    public static final boulders = new ComMap<Boulder>();

    public static var ent1Id:Int;
    public static var ent2Id:Int;
    public static var ent2Active = false;
    public static var activeEntId(get, never):Int;
    static function get_activeEntId():Int {
        return ent2Active ? ent2Id : ent1Id;
    }

    static var nextId = 0;

    public static inline final TILE_SIZE = 16;
    public static inline final CAM_PX_WIDTH = TILE_SIZE * 20;
    public static inline final CAM_PX_HEIGHT = TILE_SIZE * 16;

    var moveSys:MoveSys;
    var entSys:EntSys;
    var buttonSys:ButtonSys;
    var doorSys:DoorSys;
    var updaters = new Updater.UpdaterGroup();
    var buttonDoorLinkSys:ButtonDoorLinkSys;
    var cameraSys:CameraSys;
    var boulderSys:BoulderSys;

    static inline final FIXED_UPDATE_RATE = 30.;
    static inline final MAX_UPDATE_CALLS_PER_FRAME = 5;
    var updateAcc = 0.;

    public static function main() {
        new Main();
    }

    override function init() {
        super.init();
        initWindow();
        initCameras();
        initTiles();
        initScene();
        initSystems();
        loadLevels();
    }

    function initWindow() {
        hxd.Window.getInstance().resize(CAM_PX_WIDTH*3, CAM_PX_HEIGHT*3);
        hxd.Window.getInstance().addEventTarget(keyEventHandler);
    }

    function initCameras() {
        worldCamera = s2d.camera;
        worldCamera.setAnchor(0.5, 0.5);
        worldCamera.setPosition(CAM_PX_WIDTH/2, CAM_PX_HEIGHT/2);
        worldCamera.clipViewport = true;
        worldCamera.layerVisible = layer -> {
            return true;
        }
        var id = getId();
        cameras[id] = worldCamera;
        worldCamConfig = new CameraConfig();
        worldCamConfig.lockX = CAM_PX_WIDTH/2;
        worldCamConfig.lockY = CAM_PX_HEIGHT/2;
        worldCamConfig.deadzone.init(new VectorFloat2(-16, -16), new VectorFloat2(32, 32));
        camConfigs[id] = worldCamConfig;
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
        buttonSys = new ButtonSys();
        doorSys = new DoorSys();
        buttonDoorLinkSys = new ButtonDoorLinkSys();
        cameraSys = new CameraSys();
        boulderSys = new BoulderSys();
        boulderSys.colSlot.connect(moveSys.colSignal);
    }
    
    function onUpdate(dt:Float) {
        updaters.update(dt);
        moveSys.update(dt);
        entSys.update(dt);
        buttonSys.update(dt);
        doorSys.update(dt);
        buttonDoorLinkSys.update(dt);
        cameraSys.update(dt);
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
        for (level in ldtkProject.levels) {
            var tileGroup = level.l_Floor.render();
            tileGroup.setPosition(level.worldX, level.worldY);
            s2d.addChild(tileGroup);

            for (cy in 0...level.l_Floor.cHei) {
                for (cx in 0...level.l_Floor.cWid) {
                    if (!level.l_Floor.hasAnyTileAt(cx, cy)) continue;
                    var stack = level.l_Floor.getTileStackAt(cx, cy);
                    for (tile in stack) {
                        if (level.l_Floor.tileset.hasTag(tile.tileId, Wall)) {
                            var gridSize = level.l_Floor.gridSize;
                            var id = getId();
                            var aabb = new heat.aabb.Rect(
                                new VectorFloat2(level.worldX+cx*gridSize, level.worldY+cy*gridSize),
                                new VectorFloat2(gridSize, gridSize)
                            );
                            aabbWorld.add(id, aabb);
                            walls[id] = true;
                            colFilters[id] = noneColFilter;
                        }
                    }
                }
            }
        }

        loadText();

        loadButtons();
        loadDoors();
        loadBoulders();
        loadEnts();
    }

    function loadButtons() {
        for (level in ldtkProject.levels) {
            for (btn in level.l_Entities.all_GreenBtn) {
                var id = getId();
                var bitmap = new h2d.Bitmap(tiles.greenButton[0]);
                bitmaps[id] = bitmap;
                bitmap.setPosition(level.worldX+btn.pixelX, level.worldY+btn.pixelY);
                s2d.addChild(bitmap);
                var aabb = new heat.aabb.Rect(
                    new VectorFloat2(level.worldX+btn.pixelX, level.worldY+btn.pixelY),
                    new VectorFloat2(btn.width, btn.height)
                );
                aabbWorld.add(id, aabb);
                var button = new Button(level.arrayIndex, GREEN, btn.f_inverted);
                buttons[id] = button;
                colFilters[id] = buttonColFilter;
            }
            for (btn in level.l_Entities.all_RedBtn) {
                var id = getId();
                var bitmap = new h2d.Bitmap(tiles.redButton[0]);
                bitmaps[id] = bitmap;
                bitmap.setPosition(level.worldX+btn.pixelX, level.worldY+btn.pixelY);
                s2d.addChild(bitmap);
                var aabb = new heat.aabb.Rect(
                    new VectorFloat2(level.worldX+btn.pixelX, level.worldY+btn.pixelY),
                    new VectorFloat2(btn.width, btn.height)
                );
                aabbWorld.add(id, aabb);
                var button = new Button(level.arrayIndex, RED, btn.f_inverted);
                buttons[id] = button;
                colFilters[id] = buttonColFilter;
            }
            for (btn in level.l_Entities.all_BlueBtn) {
                var id = getId();
                var bitmap = new h2d.Bitmap(tiles.blueButton[0]);
                bitmaps[id] = bitmap;
                bitmap.setPosition(level.worldX+btn.pixelX, level.worldY+btn.pixelY);
                s2d.addChild(bitmap);
                var aabb = new heat.aabb.Rect(
                    new VectorFloat2(level.worldX+btn.pixelX, level.worldY+btn.pixelY),
                    new VectorFloat2(btn.width, btn.height)
                );
                aabbWorld.add(id, aabb);
                var button = new Button(level.arrayIndex, BLUE, btn.f_inverted);
                buttons[id] = button;
                colFilters[id] = buttonColFilter;
            }
        }
    }

    function loadEnts() {
        ent1Id = getId();
        var ent1 = new Ent();
        ents[ent1Id] = ent1;
        var bitmap1 = new h2d.Bitmap();
        bitmaps[ent1Id] = bitmap1;
        var level = ldtkProject.all_levels.Title;
        var ldtkEnt1 = level.l_Entities.all_Ent[0];
        bitmap1.setPosition(level.worldX+ldtkEnt1.pixelX, level.worldY+ldtkEnt1.pixelY);
        s2d.addChild(bitmap1);
        velocities[ent1Id] = new MVectorFloat2();
        prevVels[ent1Id] = new MVectorFloat2();
        var aabb1 = new heat.aabb.Rect(
            new VectorFloat2(bitmap1.x, bitmap1.y),
            new VectorFloat2(ldtkEnt1.width, ldtkEnt1.height),
            new VectorFloat2(ldtkEnt1.width*ldtkEnt1.pivotX, ldtkEnt1.height*ldtkEnt1.pivotY)
        );
        aabbWorld.add(ent1Id, aabb1);
        colFilters[ent1Id] = entColFilter;

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
        colFilters[ent2Id] = entColFilter;
    }

    function loadDoors() {
        for (level in ldtkProject.levels) {
            for (door in level.l_Entities.all_GreenDoor) {
                var id = getId();
                var bitmap = new h2d.Bitmap(tiles.greenDoor[0]);
                bitmaps[id] = bitmap;
                bitmap.setPosition(level.worldX+door.pixelX, level.worldY+door.pixelY);
                s2d.addChild(bitmap);
                var aabb = new heat.aabb.Rect(
                    new VectorFloat2(level.worldX+door.pixelX, level.worldY+door.pixelY),
                    new VectorFloat2(door.width, door.height)
                );
                aabbWorld.add(id, aabb);
                var obj = new Door(level.arrayIndex, GREEN);
                doors[id] = obj;
            }
            for (door in level.l_Entities.all_RedDoor) {
                var id = getId();
                var bitmap = new h2d.Bitmap(tiles.redDoor[0]);
                bitmaps[id] = bitmap;
                bitmap.setPosition(level.worldX+door.pixelX, level.worldY+door.pixelY);
                s2d.addChild(bitmap);
                var aabb = new heat.aabb.Rect(
                    new VectorFloat2(level.worldX+door.pixelX, level.worldY+door.pixelY),
                    new VectorFloat2(door.width, door.height)
                );
                aabbWorld.add(id, aabb);
                var obj = new Door(level.arrayIndex, RED);
                doors[id] = obj;
            }
            for (door in level.l_Entities.all_BlueDoor) {
                var id = getId();
                var bitmap = new h2d.Bitmap(tiles.blueDoor[0]);
                bitmaps[id] = bitmap;
                bitmap.setPosition(level.worldX+door.pixelX, level.worldY+door.pixelY);
                s2d.addChild(bitmap);
                var aabb = new heat.aabb.Rect(
                    new VectorFloat2(level.worldX+door.pixelX, level.worldY+door.pixelY),
                    new VectorFloat2(door.width, door.height)
                );
                aabbWorld.add(id, aabb);
                var obj = new Door(level.arrayIndex, BLUE);
                doors[id] = obj;
            }
        }
    }

    function loadBoulders() {
        for (level in ldtkProject.levels) {
            for (boulder in level.l_Entities.all_Boulder) {
                var id = getId();
                var bitmap = new h2d.Bitmap(tiles.boulder[0]);
                bitmaps[id] = bitmap;
                bitmap.setPosition(level.worldX+boulder.pixelX, level.worldY+boulder.pixelY);
                s2d.addChild(bitmap);
                var aabb = new heat.aabb.Rect(
                    new VectorFloat2(level.worldX+boulder.pixelX, level.worldY+boulder.pixelY),
                    new VectorFloat2(boulder.width, boulder.height)
                );
                aabbWorld.add(id, aabb);
                colFilters[id] = boulderColFilter;
                var obj = new Boulder();
                boulders[id] = obj;
            }
        }
    }

    function loadText() {
        var titleFont = makeDefaultFont(24);
        var titleText = new h2d.Text(titleFont, s2d);
        var level = ldtkProject.all_levels.Title;
        titleText.setPosition(level.worldX+TILE_SIZE*2, level.worldY+TILE_SIZE*1);
        titleText.text = "Are You Not ENTertained?";
        titleText.maxWidth = TILE_SIZE * 14;
        // titleText.textAlign = Center;

        var smallFont = makeDefaultFont(12);
        var creditText = new h2d.Text(smallFont, s2d);
        creditText.setPosition(level.worldX+TILE_SIZE*2, level.worldY+TILE_SIZE*5);
        creditText.text = "A game by Matt Rogge";

        var instText = new h2d.Text(smallFont, s2d);
        instText.setPosition(level.worldX+TILE_SIZE*2, level.worldY+TILE_SIZE*6);
        instText.maxWidth = TILE_SIZE * 14;
        instText.text = "Move with WASD; Press SPACE to swap while over grass";

        var noEnemiesText = new h2d.Text(smallFont, s2d);
        level = ldtkProject.all_levels.Level_2;
        noEnemiesText.setPosition(level.worldX+TILE_SIZE*2, level.worldY+TILE_SIZE*1);
        noEnemiesText.text = "I didn't have time to make enemies :/";
        noEnemiesText.maxWidth = TILE_SIZE * 12;

        var noBossText = new h2d.Text(smallFont, s2d);
        level = ldtkProject.all_levels.Level_4;
        noBossText.setPosition(level.worldX+TILE_SIZE*2, level.worldY+TILE_SIZE*1);
        noBossText.text = "The boss has decided he had better things to do today.\n\nWow what a memorable moment this is!";
        noBossText.maxWidth = TILE_SIZE * 14;

        var theEndText = new h2d.Text(smallFont, s2d);
        level = ldtkProject.all_levels.Level_5;
        theEndText.setPosition(level.worldX+TILE_SIZE*2, level.worldY+TILE_SIZE*1);
        theEndText.text = "And so, Leaf Erikson and Bark Walberg spent the rest of their days in a beautiful, lush forest, where they lived happily ever after.\n\nThank you for playing my \"game\".";
        theEndText.maxWidth = TILE_SIZE * 14;
    }

    override function loadAssets(onLoaded:() -> Void) {
        hxd.Res.initEmbed();
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

    public static function entColFilter(item:Int, other:Int):heat.aabb.World.CollisionKind {
        if (!ents.exists(item)) return NONE;
        if (walls.exists(other)) return SLIDE;
        if (buttons.exists(other)) return CROSS;
        if (ents.exists(other)) return CROSS;
        if (doors.exists(other)) {
            var door = doors[other];
            return switch door.state {
                case OPEN: NONE;
                case CLOSED: SLIDE;
            }
        }
        if (boulders.exists(other)) return CROSS;
        return NONE;
    }

    public static function buttonColFilter(item:Int, other:Int):heat.aabb.World.CollisionKind {
        if (!buttons.exists(item)) return NONE;
        if (ents.exists(other)) return CROSS;
        if (boulders.exists(other)) return CROSS;
        return NONE;
    }

    public static function boulderColFilter(item:Int, other:Int):heat.aabb.World.CollisionKind {
        if (!boulders.exists(item)) return NONE;
        if (ents.exists(other)) return SLIDE;
        if (walls.exists(other)) return SLIDE;
        return NONE;
    }

    function makeDefaultFont(size:Int):h2d.Font {
        var font = hxd.res.DefaultFont.get().clone();
        font.resizeTo(size);
        return font;
    }
}