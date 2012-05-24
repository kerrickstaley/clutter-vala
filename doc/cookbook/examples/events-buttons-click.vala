using Clutter;

const Color stage_color = { 0x33, 0x33, 0x55, 0xff };
const Color red         = { 0xff, 0x00, 0x00, 0xff };
const Color blue        = { 0x00, 0x00, 0xff, 0xff };

void
clicked_cb (ClickAction action, Actor actor)
{
  stderr.printf("Pointer button %d clicked on actor %s\n",
                (int)action.get_button(), actor.name);
}

int
main (string[] args)
{
  if (Clutter.init(ref args) != InitError.SUCCESS)
    return 1;
  
  var stage = new Stage()
  {
    width = 400,
    height = 400,
    color = stage_color
  };
  stage.destroy.connect(Clutter.main_quit);
  
  var actor1 = new Rectangle()
  {
    name = "Red Button",
    // background_color = Color.get_static(StaticColor.RED),
    color = red,
    width = 100,
    height = 100,
    reactive = true,
    x = 50,
    y = 150
  };
  stage.add_actor(actor1);
  
  var actor2 = new Rectangle()
  {
    name = "Blue Button",
    // background_color = Color.get_static(StaticColor.BLUE),
    color = blue,
    width = 100,
    height = 100,
    reactive = true,
    x = 250,
    y = 150
  };
  stage.add_actor(actor2);

  var action1 = new ClickAction();
  actor1.add_action(action1);
  action1.clicked.connect(clicked_cb);

  var action2 = new ClickAction();
  actor2.add_action(action2);
  action2.clicked.connect(clicked_cb);
  
  stage.show();
  Clutter.main();

  return 0;
}
