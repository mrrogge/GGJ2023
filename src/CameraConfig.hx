class CameraConfig {
    public var lockX:Float;
    public var lockY:Float;
    public var enableLock:Bool;
    public var moveType:CameraConfigMoveType;
    public var deadzone:heat.aabb.MRect;
    public var enableDeadzoneX = true;
    public var enableDeadzoneY = true;


    public function new() {
        lockX = 0;
        lockY = 0;
        enableLock = true;
        moveType = DAMPENED(1);
        deadzone = new heat.aabb.MRect();
    }
}

enum CameraConfigMoveType {
    LINEAR(speed:Float);
    DAMPENED(stiffness:Float);
    NULL;
}