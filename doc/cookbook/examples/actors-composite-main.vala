using Clutter;
using ClutterCookbook;

internal void clicked(Button button) {
    stdout.printf("Clicked\n");
    
    if (button.text == "hello")
        button.text = "world";
    else
        button.text = "hello";
}

void main(string[] args) {
    Clutter.init(ref args);
    
    Stage stage = new Stage();
    stage.set_size(400, 400);
    stage.color = {0x33, 0x33, 0x55, 0xff};
    stage.destroy.connect(Clutter.main_quit);
    
    Button button = new Button();
    button.text = "hello";
    button.text_color = {0xff, 0xff, 0xff, 0xff};
    button.background_color = {0x88, 0x88, 0x00, 0xff};
    button.clicked.connect(clicked);
    button.add_constraint(new AlignConstraint(stage, AlignAxis.X_AXIS, 0.5f));
    button.add_constraint(new AlignConstraint(stage, AlignAxis.Y_AXIS, 0.5f));
    
    stage.add_actor(button);
    
    stage.show_all();
    
    Clutter.main();
}
