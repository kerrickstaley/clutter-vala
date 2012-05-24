/* Simple rectangle drawing using button and pointer events;
 * click, drag and release a mouse button to draw a rectangle
 */
using Clutter;

const Color stage_color = { 0x33, 0x33, 0x55, 0xff };
const Color lasso_color = { 0xaa, 0xaa, 0xaa, 0x33 };

class LassoDrawer
{
  Rectangle? lasso;
  float start_x;
  float start_y;
  
  private uint8
  random_color_component()
  {
    return (uint8)Random.int_range(155, 255);
  }
  
  public bool
  button_press_cb(Actor actor, ButtonEvent event)
  {
    // start drawing the lasso actor
    lasso = new Rectangle.with_color(lasso_color);
    
    // store lasso's start coordinates
    start_x = event.x;
    start_y = event.y;
    
    actor.add_actor(lasso);
    
    return true;
  }
  
    
  public bool
  pointer_motion_cb(Actor actor, MotionEvent event)
  {
    if (lasso == null)
      return true;
      
    float new_x = float.min(event.x, start_x);
    float new_y = float.min(event.y, start_y);
    lasso.width  = (int)(float.max(event.x, start_x) - new_x);
    lasso.height = (int)(float.max(event.y, start_y) - new_y);
    lasso.x = (int)new_x;
    lasso.y = (int)new_y;
    
    return true;
  }
  
  public bool
  button_release_cb(Actor actor, ButtonEvent event)
  {
    if (lasso == null)
      return true;
    
    lasso.color = { random_color_component(),
                    random_color_component(),
                    random_color_component(),
                    random_color_component() };
    
    lasso = null;
    
    actor.queue_redraw();
    
    return true;
  }
}

int
main (string[] args)
{
  if (Clutter.init(ref args) != InitError.SUCCESS)
    return 1;
  
  // seed the random number generator
  Random.set_seed((uint32)(new DateTime.now_utc()).to_unix());
  
  var stage = new Stage()
  {
    width = 320,
    height = 240,
    color = stage_color
  };
  stage.destroy.connect(Clutter.main_quit);
  
  var lassoDrawer = new LassoDrawer();

  stage.button_press_event.connect(lassoDrawer.button_press_cb);
  stage.motion_event.connect(lassoDrawer.pointer_motion_cb);
  stage.button_release_event.connect(lassoDrawer.button_release_cb);

  stage.show();
  Clutter.main();
  
  return 0;
}
