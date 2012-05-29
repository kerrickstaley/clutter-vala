using Clutter;

int
main (string[] args)
{
  if (Clutter.init(ref args) != InitError.SUCCESS)
    return 1;
  
  /* Create a new ClutterTexture that shows smiley.png */
  var image = new Texture.from_file("smiley.png");
  
  var stage = new Stage()
  {
    title = "Sub-texture",
    width = image.width * 3 / 2 + 30,
    height = image.height + 20
  };
  stage.destroy.connect(Clutter.main_quit);
  
  /* Create a new Cogl texture from image.cogl_texture. That new texture
   * is a rectangular region from image, more precisely the northwest
   * corner of the image */
  var sub_texture = new Cogl.Texture.from_sub_texture(image.cogl_texture,
                                                      0, 0,
                                                      image.width / 2,
                                                      image.height / 2);

  /* Finally, use the newly created Cogl texture to feed a new ClutterTexture
   * and thus create a new actor that displays sub_texture */
   var sub_image = new Texture()
   {
     cogl_texture = sub_texture
   };

  /* Put the original image at (10,10) and the new sub image next to it */
  image.x = 10;
  image.y = 10;
  sub_image.x = 20 + image.width;
  sub_image.y = 10;

  /* Add both ClutterTexture to the stage */
  stage.add_actor(image);
  stage.add_actor(sub_image);

  stage.show();
  Clutter.main();

  return 0;
}
