class Button {
    public var color:ButtonColor;
    public var level:Int;
    public var state:ButtonState = UNPRESSED;
    public var inverted = false;

    public function new(level:Int, color:ButtonColor, inverted=false) {
        this.level = level;
        this.color = color;
        this.inverted = inverted;
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