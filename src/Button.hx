class Button {
    public var color:ButtonColor;

    public function new(color:ButtonColor) {
        this.color = color;
    }
}

enum ButtonColor {
    RED;
    GREEN;
    BLUE;
}