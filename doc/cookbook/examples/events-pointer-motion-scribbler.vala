/*
 * Simple scribble application: move mouse over the dark yellow
 * rectangle to draw brighter yellow lines
 */
using Clutter;

const Color stage_color = { 0x33, 0x33, 0x55, 0xff };
const Color actor_color = { 0xaa, 0x99, 0x00, 0xff };


int
main (string args[])
{
  if (Clutter.init(ref args) != InitError.SUCCESS)
    return 1;
  
  var stage = new Stage()
  {
    width  = 400,
    height = 400,
    color = stage_color
  };
  stage.destroy.connect(Clutter.main_quit);
  
  var rect = new Rectangle.with_color(actor_color)
  {
    width  = 300,
    height = 300
  };
  rect.add_constraint(new AlignConstraint(stage, AlignAxis.X_AXIS, 0.5f));
  rect.add_constraint(new AlignConstraint(stage, AlignAxis.Y_AXIS, 0.5f));
  
  stage.add_actor(rect);
  
  var canvas = new Texture()
  {
    width = 300,
    height = 300,
    reactive = true
  };
  canvas.add_constraint(new AlignConstraint(rect, AlignAxis.X_AXIS, 0.5f));
  canvas.add_constraint(new AlignConstraint(rect, AlignAxis.Y_AXIS, 0.5f));
  
  stage.add_actor(canvas);

  var path = new Clutter.Path();
  
  Cogl.Path.new();
  unowned Cogl.Path cogl_path = Cogl.get_path();

  canvas.motion_event.connect((actor, event) =>
  {
    float x, y;
    actor.transform_stage_point(event.x, event.y, out x, out y);

    stderr.printf("motion; x %0.f, y %0.f\n", x, y);

    path.add_line_to((int)x, (int)y);

    actor.queue_redraw();

    return true;
  });

  canvas.enter_event.connect((actor, event) =>
  {
    float x, y;
    actor.transform_stage_point(event.x, event.y, out x, out y);

    stderr.printf("enter;  x %0.f, y %0.f\n", x, y);

    path.add_move_to((int)x, (int)y);

    actor.queue_redraw();

    return true;
  });
  
  canvas.paint.connect((actor) =>
  {
    Cogl.set_source_color4ub (255, 255, 0, 255);

    Cogl.set_path(cogl_path);

    path.foreach((node) =>
    {
      Knot knot;
      switch (node.type)
      {
      case PathNodeType.MOVE_TO:
        knot = node.points[0];
        Cogl.Path.move_to(knot.x, knot.y);
        stderr.printf("move to %d, %d\n", knot.x, knot.y);
        break;
      case PathNodeType.LINE_TO:
        knot = node.points[0];
        Cogl.Path.line_to(knot.x, knot.y);
        stderr.printf("line to %d, %d\n", knot.x, knot.y);
        break;
      }
    });

    Cogl.Path.stroke_preserve();

    path.clear();

    cogl_path = Cogl.get_path();

    Signal.stop_emission_by_name(actor, "paint");
  }); 

  stage.show();
  Clutter.main();
  
  return 0;
}
