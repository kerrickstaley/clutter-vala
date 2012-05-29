using Clutter;

internal string? source;
internal string? target;
internal int duration;

const OptionEntry?[] entries =
{
  {
    "source", 's',
    0,
    OptionArg.FILENAME, ref source,
    "The source image of the cross-fade", "FILE"
  },
  {
    "target", 't',
    0,
    OptionArg.FILENAME, ref target,
    "The target image of the cross-fade", "FILE"
  },
  {
    "duration", 'd',
    0,
    OptionArg.INT, ref duration,
    "The duration of the cross-fade, in milliseconds", "MSECS"
  }
};

void
load_image(Texture texture, string image_path)
{
  try
  {
    texture.set_from_file(image_path);
  }
  catch (TextureError e)
  {
    error("Error loading %s:\n%s", image_path, e.message);
    Process.exit(1);
  }
}

int
main(string[] args)
{  
  if (Clutter.init_with_args(ref args, " - cross-fade", entries, null) != InitError.SUCCESS)
    return 1;
  
  if (source == null || target == null)
  {
    stdout.printf("Usage: %s -s <source> -t <target> [-d <duration>]\n", args[0]);
    Process.exit(1);
  }

  if (Clutter.init(ref args) != InitError.SUCCESS)
    return 1;
  
  var stage = new Stage()
  {
    title = "cross-fade",
    width = 400,
    height = 300
  };
  stage.destroy.connect(Clutter.main_quit);
  var box = new Box(new BinLayout(BinAlignment.CENTER, BinAlignment.CENTER))
  {
    width = 400,
    height = 300
  };
  
  var bottom = new Texture();
  var top = new Texture();
  
  box.add_actor(bottom);
  box.add_actor(top);
  stage.add_actor(box);
  
  /* load the first image into the bottom */
  load_image(bottom, source);
  /* load the second image into the top */
  load_image(top, target);

  /* animations */
  var transitions = new State()
  {
    duration = 1000
  };
  transitions.set_key(null, "show-bottom",
                      top, "opacity",
                      AnimationMode.LINEAR, 0u,
                      0, 0);
  transitions.set_key(null, "show-bottom",
                      bottom, "opacity",
                      AnimationMode.LINEAR, 255u,
                      0, 0);
  transitions.set_key(null, "show-top",
                      top, "opacity",
                      AnimationMode.LINEAR, 255u,
                      0, 0);
  transitions.set_key(null, "show-top",
                      bottom, "opacity",
                      AnimationMode.LINEAR, 255u,
                      0, 0);

  /* make the bottom opaque and top transparent */
  transitions.warp_to_state("show-bottom");

  /* on key press, fade in the top texture and fade out the bottom texture */
  stage.key_press_event.connect((stage, event) =>
  {
    transitions.state = "show-top";
    return true;
  });
  
  stage.show();
  Clutter.main();

  return 0;
}
