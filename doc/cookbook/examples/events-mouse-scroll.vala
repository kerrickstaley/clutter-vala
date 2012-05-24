using Clutter;

namespace ClutterCookbook {
  const int STAGE_WIDTH = 300;
  const int STAGE_HEIGHT = STAGE_WIDTH;
  const float SCROLL_AMOUNT = STAGE_HEIGHT * 0.125f;
  const string TEST_DATA_DIR = "/home/kerrick/Open_Source_Contrib/Clutter/git/tests/data/";
  
  bool
  scroll_event_cb(Actor viewport,
                  Actor scrollable,
                  ScrollEvent event) {
    /* no need to scroll if the scrollable is shorter than the viewport */
    if (scrollable.height < viewport.height)
      return true;
    
    float y = scrollable.y;
    
    switch (event.direction) {
    case ScrollDirection.UP:
      y += SCROLL_AMOUNT;
      break;
    case ScrollDirection.DOWN:
      y -= SCROLL_AMOUNT;
      break;
    case ScrollDirection.LEFT:
    case ScrollDirection.RIGHT:
      return true;
    }
    
    scrollable.animate(AnimationMode.EASE_OUT_CUBIC,
                       300,
                       "y",
                       y.clamp(viewport.height - scrollable.height, 0));
    
    return true;
  }
  
  void main(string[] args) {
    Clutter.init(ref args);
    
    var stage = new Stage();
    stage.width = STAGE_WIDTH;
    stage.height = STAGE_HEIGHT;
    
    stage.destroy.connect(main_quit);
    
    var scrollable = new Texture.from_file(TEST_DATA_DIR + "/redhand.png");
    
    /* set the scrollable's height so it's as tall as the stage,
       with its width scaled accordingly */
    scrollable.height = STAGE_HEIGHT;
    scrollable.keep_aspect_ratio = true;
    scrollable.request_mode = RequestMode.WIDTH_FOR_HEIGHT;
    
    var viewport = new Box(new FixedLayout());
    viewport.width = STAGE_WIDTH;
    viewport.height = STAGE_HEIGHT * 0.5f;
    
    viewport.add_constraint(new AlignConstraint(stage, AlignAxis.Y_AXIS, 0.5f));
    
    viewport.reactive = true;
    
    /* clip all actors inside the viewport to that group's allocation */
    viewport.clip_to_allocation = true;
    
    viewport.add_actor(scrollable);
    stage.add_actor(viewport);
    
    viewport.scroll_event.connect((viewport, event) => {
      return scroll_event_cb(viewport,
                             scrollable,
                             event);
    });
    
    stage.show();
    Clutter.main();
  }
}
