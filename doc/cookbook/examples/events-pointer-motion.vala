using Clutter;

const Color stage_color = { 0x33, 0x33, 0x55, 0xff };
const Color rectangle_color = { 0xaa, 0x99, 0x00, 0xff };


int
main(string args[])
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
  
  var rectangle = new Rectangle.with_color(rectangle_color)
  {
    width = 300,
    height = 300,
    x = 50,
    y = 50,
    reactive = true
  };
  rectangle.motion_event.connect((actor, event) =>
  {
    // event is a MotionEvent, not just a generic Event, so we can
    // access event.x and event.y without casting
    
    float actor_x, actor_y;
    actor.transform_stage_point(event.x, event.y, out actor_x, out actor_y);
    stderr.printf("pointer @ stage x %.0f, y %.0f; actor x %.0f, y %.0f\n",
                  event.x, event.y, actor_x, actor_y);
    return true;
  });
  
  stage.add_actor(rectangle);
  
  stage.show();

  Clutter.main();
  return 0;
}
