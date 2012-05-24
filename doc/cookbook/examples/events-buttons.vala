using Clutter;

const Color stage_color = { 0x33, 0x33, 0x55, 0xff };
const Color red_color   = { 0xff, 0x00, 0x00, 0xff };
const Color green_color = { 0x00, 0xff, 0x00, 0xff };

bool
button_event_cb (Actor actor, ButtonEvent event)
{
  /*
   * event.button indicates which button
   * triggered the event (e.g. 1 for the primary
   * button)
   *
   * event.type indicates the type of event;
   * it will be one of EventType.BUTTON_PRESSED
   * and EventType.BUTTON_RELEASED
   *
   * event.x and event.y indicate
   * where the pointer was (relative to the stage)
   *
   * event.button indicates which button
   * triggered the event
   *
   * event.state indicates which keys were down
   * when the event occurred; it is a bitmask
   * of values from the ModifierType enum
   *
   * event.click_count indicates how many
   * times the button was clicked (i.e. 1 for
   * a single-click and 2 for a double-click)
   */

  string event_type = "pressed";
  if (event.type == EventType.BUTTON_RELEASE)
    event_type = "released";

  string ctrl_pressed = "ctrl not pressed";
  if ((event.modifier_state & ModifierType.CONTROL_MASK) > 0)
    ctrl_pressed = "ctrl pressed";

  stderr.printf("button %d was %s at %.0f,%.0f; %s; click count %d\n",
                (int)event.button,
                event_type,
                event.x,
                event.y,
                ctrl_pressed,
                (int)event.click_count);

  return true;
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
  
  var red = new Rectangle.with_color(red_color)
  {
    width = 100,
    height = 100,
    x = 50,
    y = 150,
    reactive = true
  };
  red.button_press_event.connect(button_event_cb);
  red.button_release_event.connect(button_event_cb);
  
  var green = new Rectangle.with_color(green_color)
  {
    width = 100,
    height = 100,
    x = 250,
    y = 150,
    reactive = true
  };
  green.button_press_event.connect(button_event_cb);
  green.button_release_event.connect(button_event_cb);
  
  stage.add_actor(red);
  stage.add_actor(green);
  
  stage.show();
  Clutter.main();
  
  return 0;
}
