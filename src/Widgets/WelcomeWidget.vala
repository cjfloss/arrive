namespace Arrive.Widgets {
public class WelcomeWidget : Gtk.Grid {
    public WelcomeWidget (string title, string subtitle) {
        set_row_homogeneous (true);
        var title_label = new Gtk.Label ("<span weight='bold' size='xx-large'>" + title + "</span>");
        title_label.set_use_markup (true);
        title_label.set_hexpand (true);
        title_label.set_halign (Gtk.Align.CENTER);
        title_label.set_valign (Gtk.Align.END);
        attach (title_label, 0, 0, 1, 1);

        var subtitle_label = new Gtk.Label ("<span size='large'>" + subtitle + "</span>");
        subtitle_label.set_hexpand (true);
        subtitle_label.set_halign (Gtk.Align.CENTER);
        subtitle_label.set_valign (Gtk.Align.START);
        subtitle_label.set_use_markup (true);
        attach (subtitle_label, 0, 1, 1, 1);
    }
}
}
