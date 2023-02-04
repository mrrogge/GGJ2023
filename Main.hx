class Main extends hxd.App {
    public var ldtkProject:LdtkProject;

    public static inline final VIEW_WIDTH = 960;
    public static inline final VIEW_HEIGHT = 450;

    public static function main() {
        new Main();
    }

    override function init() {
        super.init();
        loadLevel();
    }

    function initScene() {
        //sets the scene to a fixed size with space around it to fill the window. Hardcoding this for now, should eventually configurable via game UI
       s2d.scaleMode = LetterBox(VIEW_WIDTH, VIEW_HEIGHT, true, Center, Center);
    }

    override function update(dt:Float) {
        super.update(dt);
    }

    function loadLevel() {
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

}