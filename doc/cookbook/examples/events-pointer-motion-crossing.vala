using Clutter;

const Color stage_color = { 0x33, 0x33, 0x55, 0xff };
const Color yellow      = { 0xaa, 0x99, 0x00, 0xff };
const Color white       = { 0xff, 0xff, 0xff, 0xff };

int
main(string args[])
{
  if (Clutter.init(ref args) != InitError.SUCCESS)
    return 1;
  
  var stage = new Stage()
  {
      title = "btn",
      background_color = stage_color
  };
  stage.destroy.connect(Clutter.main_quit);
  
  var box = new Box(new BinLayout(BinAlignment.FILL, BinAlignment.FILL))
  {
    x = 25,
    y = 25,
    reactive = true,
    width = 100,
    height = 30
  };
  box.add_child(new Rectangle.with_color(yellow));
  
  var text = new Text()
  {
    font_name = "Sans 10pt",
    text = "Hover me",
    color = white,
    width = 100
  };
  /*
   * NB don't set the height, so the actor assumes the height of the text;
   * then when added to the bin layout, it gets centred on it;
   * also if you don't set the width, the layout goes gets really wide;
   * the 10pt text fits inside the 30px height of the rectangle
   */
   
  ((BinLayout)box.layout_manager).add(text, BinAlignment.CENTER, BinAlignment.CENTER);
  
  var transitions = new State()
  {
    duration = 50
  };
  
 /*
  * NB the parameter "value" (for which we pass the argument "(uint)180")
  * has type GLib.Value. Whatever we pass for this parameter will get
  * wrapped in a Glib.Value. Hence, it is imperative that this parameter
  * have exactly the same type as the property we're animating. If
  * we don't cast the 180 to a uint, it will be interpreted as an int
  * (which is signed); this will cause an error because opacity is a
  * uint.
  */ 
  transitions.set_key(null, "fade-out",
                      box, "opacity",
                      AnimationMode.LINEAR, (uint)180,
                      0, 0);
 /*
  * NB you can't use an easing mode where alpha > 1.0 if you're
  * animating to a value of 255, as the value you're animating
  * to will possibly go > 255
  */
  transitions.set_key(null, "fade-in",
                      box, "opacity",
                      AnimationMode.LINEAR, (uint)255,
                      0, 0);
  
  transitions.warp_to_state("fade-out");

  box.enter_event.connect(() => { transitions.state = "fade-in";  return true; });
  box.leave_event.connect(() => { transitions.state = "fade-out"; return true; });
  
  /* bind the stage size to the box size + 50px in each axis */
  stage.add_constraint(new BindConstraint(box, BindCoordinate.HEIGHT, 50));
  stage.add_constraint(new BindConstraint(box, BindCoordinate.WIDTH,  50));
  
  stage.add_child(box);
  
  stage.show();
  Clutter.main();

  return 0;
}
