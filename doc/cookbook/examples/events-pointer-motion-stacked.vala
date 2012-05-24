/*
 * Testing what happens with a stack of actors and pointer events
 * red and green are reactive; blue is not
 *
 * when the pointer is over green (even if green is obscured by blue)
 * signals are emitted by green (not by blue);
 *
 * but when the pointer is over the overlap between red and green,
 * signals are emitted by green
 */
using Clutter;

const Color stage_color = { 0x33, 0x33, 0x55, 0xff };
const Color red         = { 0xff, 0x00, 0x00, 0xff };
const Color green       = { 0x00, 0xff, 0x00, 0xff };
const Color blue        = { 0x00, 0x00, 0xff, 0xff };

bool
pointer_motion_cb(Actor actor, MotionEvent event)
{
  float actor_x, actor_y;
  
  /*
   * as the coordinates are relative to the stage, rather than
   * the actor which emitted the signal, it can be useful to
   * transform them to actor-relative coordinates
   */
  actor.transform_stage_point (event.x, event.y, out actor_x, out actor_y);
  stderr.printf("pointer on actor %s @ x %.0f, y %.0f\n", actor.name, actor_x, actor_y);

  return true;
}

int
main (string args[])
{
  if (Clutter.init(ref args) != InitError.SUCCESS)
    return 1;
  
  var stage = new Stage()
  {
    width  = 300,
    height = 300,
    color  = stage_color
  };
  stage.destroy.connect(Clutter.main_quit);
  
  var r1 = new Rectangle.with_color(red)
  {
    width  = 150,
    height = 150,
    reactive = true,
    name = "red  "
  };
  r1.add_constraint(new AlignConstraint(stage, AlignAxis.X_AXIS, 0.25f));
  r1.add_constraint(new AlignConstraint(stage, AlignAxis.Y_AXIS, 0.25f));
  
  var r2 = new Rectangle.with_color(green)
  {
    width = 150,
    height = 150,
    reactive = true,
    name = "green"
  };
  r2.add_constraint(new AlignConstraint(stage, AlignAxis.X_AXIS, 0.5f));
  r2.add_constraint(new AlignConstraint(stage, AlignAxis.Y_AXIS, 0.5f));
  
  var r3 = new Rectangle.with_color(blue)
  {
    width = 150,
    height = 150,
    reactive = true,
    opacity = 125,
    name = "blue "
  };
  r3.add_constraint(new AlignConstraint(stage, AlignAxis.X_AXIS, 0.75f));
  r3.add_constraint(new AlignConstraint(stage, AlignAxis.Y_AXIS, 0.75f));

  stage.add_actor(r1);
  stage.add_actor(r2);
  stage.add_actor(r3);

  r1.motion_event.connect(pointer_motion_cb);
  r2.motion_event.connect(pointer_motion_cb);

  stage.show();
  Clutter.main();

  return 0;
}
