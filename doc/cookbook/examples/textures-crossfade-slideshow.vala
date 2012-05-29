/*
 * Simple slideshow application, cycling images between
 * two ClutterTextures
 *
 * Run by passing one or more image paths or directory globs
 * which will pick up image files
 *
 * When running, press any key to go to the next image
 */
using Clutter;

internal const int stage_side = 600;
internal const int animation_duration_ms = 1500;

internal const Color stage_color = { 0x33, 0x33, 0x55, 0xff };

delegate bool LoadNextImage();

int
main (string[] args)
{
  if (args.length < 2)
  {
    stderr.printf("Usage: %s <image paths to load>\n", args[0]);
    return 1;
  }
  
  if (Clutter.init(ref args) != InitError.SUCCESS)
    return 1;
    /*
   * NB if your shell globs arguments to this program so argv
   * includes non-image files, they will fail to load and throw errors
   */
  var stage = new Stage()
  {
    title = "cross-fade",
    width = stage_side,
    height = stage_side,
    color = stage_color
  };
  stage.destroy.connect(Clutter.main_quit);

  var box = new Box(new BinLayout(BinAlignment.CENTER, BinAlignment.CENTER))
  {
    width = stage.width,
    height = stage.height
  };

  var bottom = new Texture()
  {
    keep_aspect_ratio = true
  };
  var top = new Texture()
  {
    keep_aspect_ratio = true
  };
  
  box.add_actor(bottom);
  box.add_actor(top);
  
  stage.add_actor(box);
  
  var transitions = new State()
  {
    duration = animation_duration_ms
  };
  transitions.set_key(null, "show-top",
                      top, "opacity",
                      AnimationMode.EASE_IN_CUBIC, 255u,
                      0, 0);
  transitions.set_key(null, "show-top",
                      bottom, "opacity",
                      AnimationMode.EASE_IN_CUBIC, 0u,
                      0, 0);
  transitions.set_key(null, "show-bottom",
                      top, "opacity",
                      AnimationMode.EASE_IN_CUBIC, 0u,
                      0, 0);
  transitions.set_key(null, "show-bottom",
                      bottom, "opacity",
                      AnimationMode.EASE_IN_CUBIC, 255u,
                      0, 0);
  var im_idx = 0;
  LoadNextImage load_next_image = () =>
  {    
    if (transitions.get_timeline().is_playing())
    {
      debug("Animation is running already");
      return false;
    }
    
    if (++im_idx == args.length)
      im_idx = 1;
    
    bottom.cogl_texture = top.cogl_texture;    
    top.set_from_file(args[im_idx]);
    
    transitions.warp_to_state("show-bottom");
    transitions.state = "show-top";
    
    return true;
  };
  
  load_next_image();
  
  stage.key_press_event.connect((actor, event) =>
  {
    load_next_image();
    return true;
  });
  
  stage.show();
  Clutter.main();

  return 0;
}

