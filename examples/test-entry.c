#include <clutter/clutter.h>

static void
on_entry_text_changed (ClutterEntry *entry)
{
  g_print ("Text changed\n");
}

void                
on_key_release_cb (ClutterStage *stage, ClutterEvent *event, ClutterEntry *entry)
{
  if (event->type == CLUTTER_KEY_RELEASE) 
  {
    ClutterKeyEvent* kev = (ClutterKeyEvent *) event;
    clutter_entry_handle_key_event (entry, kev);
    return;
  }
}

int
main (int argc, char *argv[])
{
  ClutterTimeline *timeline;
  ClutterActor    *entry;
  ClutterActor    *stage;
  gchar           *text;
  gsize            size;
  ClutterColor     stage_color = { 0x00, 0x00, 0x00, 0xff };
  ClutterColor     entry_color = { 0x33, 0xdd, 0xff, 0xff };

  clutter_init (&argc, &argv);

  stage = clutter_stage_get_default ();

  clutter_actor_set_size (stage, 800, 600);
  clutter_stage_set_color (CLUTTER_STAGE (stage), &stage_color);

  entry = clutter_entry_new_with_text ("Sans 14", 
                                       "Type something, be sure to use the "
                                       "left/right arrow keys to move the "
                                       "cursor position.");
  clutter_entry_set_color (CLUTTER_ENTRY (entry), &entry_color);
  clutter_actor_set_size (entry, 600, 50);
  clutter_actor_set_position (entry, 100, 100);
  /*clutter_entry_set_visibility (CLUTTER_ENTRY (entry), FALSE);*/
  /*clutter_entry_set_max_length (CLUTTER_ENTRY (entry), 50);*/
  
  clutter_group_add (CLUTTER_GROUP (stage), entry);
  clutter_group_show_all (CLUTTER_GROUP (stage));

  g_signal_connect (stage, "key-release-event",
		    G_CALLBACK (on_key_release_cb), (gpointer)entry);
 
  /*
  g_signal_connect (entry, "text-changed",
                    G_CALLBACK (on_entry_text_changed), NULL);
  */
  clutter_main();

  return 0;
}
