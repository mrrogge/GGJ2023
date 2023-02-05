class Door {
    public var color:Button.ButtonColor;
    public var level:Int;
    public var state:DoorState = CLOSED;

    public function new(level:Int, color:Button.ButtonColor) {
        this.color = color;
        this.level = level;
    }
}

enum DoorState {
    OPEN;
    CLOSED;
}