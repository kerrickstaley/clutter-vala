using Clutter;

const string TESTS_DATA_DIR = "../../../tests/data/";

/* pixels between the source and its reflection */
const int V_PADDING = 4;

class ReflectClone : Clone
{
  public ReflectClone(Actor source)
  {
    // can't use base() because Clutter was written in C, not Vala
    this.source = source;
  }
  
  public override void paint()
  {
    var source = (Texture)source;
    if (source == null)
    {
      // this shouldn't happen?
    }
    
    if (source.cogl_material == null)
    {
      // this shouldn't happen?
    }

    /* get the allocation box of the actor, whose size will be used to
     * size the reflection */
    var box = get_allocation_box();

    /* figure out the two colors for the reflection: the first is
     * full color and the second is the same, but at 0 opacity
     */
    var color_1 = Cogl.Color.from_4f(1, 1, 1, opacity / 255f);
    color_1.premultiply();
    var color_2 = Cogl.Color.from_4f(1, 1, 1, 0);
    color_2.premultiply();

    /* describe the four vertices of the quad; since it has
     * to be a reflection, we need to invert it as well
     */
    Cogl.TextureVertex[] vertices = new Cogl.TextureVertex[4];
    vertices[0] = Cogl.TextureVertex()
    {
      x = 0,
      y = 0,
      z = 0,
      tx = 0,
      ty = 1,
      color = color_1
    };
    
    vertices[1] = Cogl.TextureVertex()
    {
      x = box.get_width(),
      y = 0,
      z = 0,
      tx = 1,
      ty = 1,
      color = color_1
    };
    
    vertices[2] = Cogl.TextureVertex()
    {
      x = box.get_width(),
      y = box.get_height(),
      z = 0,
      tx = 1,
      ty = 0,
      color = color_2
    };
    
    vertices[3] = Cogl.TextureVertex()
    {
      x = 0,
      y = box.get_height(),
      z = 0,
      tx = 0f,
      ty = 0f,
      color = color_2
    };
    
    /* paint the same texture but with a different geometry */
    Cogl.set_source(source.cogl_material);
    Cogl.polygon(vertices, true);
  }
}

int
main (string[] args)
{
  if (Clutter.init(ref args) != InitError.SUCCESS)
    return 1;
  
  var stage = new Stage()
  {
    title = "Reflection"
  };
  stage.destroy.connect(Clutter.main_quit);
  
  var texture = new Texture.from_file(TESTS_DATA_DIR + "/redhand.png");
  texture.add_constraint(new AlignConstraint(stage, AlignAxis.X_AXIS, 0.5f));
  texture.add_constraint(new AlignConstraint(stage, AlignAxis.Y_AXIS, 0.5f));
  
  var y_offset = texture.height + V_PADDING;

  var clone = new ReflectClone(texture);
  clone.add_constraint(new BindConstraint(texture, BindCoordinate.X, 0));
  clone.add_constraint(new BindConstraint(texture, BindCoordinate.Y, y_offset));
  
  stage.add_actor(texture);
  stage.add_actor(clone);
  
  stage.show();
  Clutter.main();

  return 0;
}
