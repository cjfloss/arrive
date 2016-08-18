namespace Arrive.Widgets {
    public class WelcomeWidget : Gtk.Grid {
        public WelcomeWidget (string title, string subtitle) {
            attach(new Gtk.Label(title),0,0,1,1);
            attach(new Gtk.Label(subtitle),0,1,1,1);
        }
    }
}
