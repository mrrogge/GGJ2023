class Button {
    public var color:ButtonColor;
    public var level:Int;
    public var state:ButtonState = UNPRESSED;

    public function new(level:Int, color:ButtonColor) {
        this.level = level;
        this.color = color;
    }
}

enum ButtonColor {
    RED;
    GREEN;
    BLUE;
}

enum ButtonState {
    PRESSED;
    UNPRESSED;
}