using Clutter;

namespace ClutterCookbook {
    class Button : Box {
        private Box child;
        private Text label;
        private ClickAction click_action;
        
        public string? text {
            get { return label.text; }
            set { label.text = value; }
        }
        
        public Color background_color {
            get { return child.color; }
            set { child.color = value; }
        }
        
        public Color text_color {
            get { return label.color; }
            set { label.color = value; }
        }
        
        public signal void clicked(Button b);
        
        public Button() {
            reactive = true;
            
            child = new Box(new BinLayout(BinAlignment.CENTER, BinAlignment.CENTER));
            add_actor(child);
            
            label = new Text();
            label.line_alignment = Pango.Alignment.CENTER;
            label.ellipsize = Pango.EllipsizeMode.END;
            child.add_actor(label);
            
            click_action = new ClickAction();
            add_action(click_action);
            click_action.clicked.connect((a) => { clicked((Button)a); });
        }
        
        public override void get_preferred_height(float for_width,
                                         out float min_height,
                                         out float natural_height) {
            
            child.get_preferred_height(for_width, out min_height, out natural_height);
            
            min_height += 20;
            natural_height += 20;
        }
        
        public override void get_preferred_width(float for_height,
                                        out float min_width,
                                        out float natural_width) {
            
            child.get_preferred_width(for_height, out min_width, out natural_width);
            
            min_width += 20;
            natural_width += 20;
        }
        
        public override void allocate(ActorBox box, AllocationFlags flags) {
            base.allocate(box, flags);
            
            ActorBox child_box = ActorBox() {
                x1 = 0,
                y1 = 0,
                x2 = box.get_width(),
                y2 = box.get_height()
            };
            
            child.allocate(child_box, flags);
        }
        
        public override void paint() {
            child.paint();
        }
    }
}
