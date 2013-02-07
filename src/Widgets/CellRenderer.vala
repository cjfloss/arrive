public class Arrive.Widgets.DownloadingCellRenderer : Gtk.CellRenderer {
    private static const int PADDING = 4;
    private static const int ICON_SIZE = 48;
    private static const int RIGHT_COLUMN_WIDTH = 100;

    private Gtk.CellRendererPixbuf icon_renderer;
    private Gtk.CellRendererText file_name_renderer;
    private Gtk.CellRendererProgress download_progress_renderer;
    private Gtk.CellRendererText status_renderer;
    private string _filename;
    public string text {
        get { return _filename;}
        set {
            _filename = value;
            file_name_renderer.text = _filename;
            file_name_renderer.markup = Markup.printf_escaped ( "<span weight='bold' size='larger'>%s</span>",
            _filename);
            status_renderer.text="download status";
            download_progress_renderer.value = 50;
            //icon_renderer.pixbuf= new Gdk.Pixbuf.from_file("/usr/local/share/icons/hicolor/48x48/apps/arrive.svg");

        }
    }

    public DownloadingCellRenderer () {
        icon_renderer = new Gtk.CellRendererPixbuf ();
        file_name_renderer = new Gtk.CellRendererText ();
        download_progress_renderer = new Gtk.CellRendererProgress ();
        status_renderer = new Gtk.CellRendererText ();
    }
    public override void get_size (Gtk.Widget widget, Gdk.Rectangle? cell_area,
                                   out int x_offset, out int y_offset,
                                   out int width, out int height) {
        int file_name_renderer_height;
        int status_renderer_height;
        int download_progress_renderer_height;

        file_name_renderer.get_preferred_height (widget, null, out file_name_renderer_height);
        status_renderer.get_preferred_height (widget, null, out status_renderer_height);
        download_progress_renderer.get_preferred_height (widget, null, out download_progress_renderer_height);
        height = 2 * PADDING + file_name_renderer_height + download_progress_renderer_height + status_renderer_height;
    }
    public override void render (Cairo.Context ctx, Gtk.Widget widget,
                                 Gdk.Rectangle background_area,
                                 Gdk.Rectangle cell_area,
                                 Gtk.CellRendererState flags) {
        int file_name_renderer_height;
        int status_renderer_height;
        int download_progress_renderer_height;
        file_name_renderer.get_preferred_height (widget,null, out file_name_renderer_height);
        status_renderer.get_preferred_height (widget, null, out status_renderer_height);
        download_progress_renderer.get_preferred_height (widget, null, out download_progress_renderer_height);

        Gdk.Rectangle icon_rect = Gdk.Rectangle () {
            x = cell_area.x,
            y = cell_area.y+PADDING,
            width = ICON_SIZE,
            height = ICON_SIZE
        };
        Gdk.Rectangle file_name_rect = Gdk.Rectangle () {
            x = cell_area.x+ICON_SIZE+PADDING,
            y = cell_area.y+PADDING,
            width = cell_area.width-(ICON_SIZE+RIGHT_COLUMN_WIDTH+2*PADDING),
            height = file_name_renderer_height
        };
        Gdk.Rectangle download_progress_rect = Gdk.Rectangle () {
            x= cell_area.x+ICON_SIZE+PADDING,
            y= cell_area.y+file_name_renderer_height+PADDING,
            width= cell_area.width-(ICON_SIZE+RIGHT_COLUMN_WIDTH+2*PADDING),
            height = download_progress_renderer_height
        };
        Gdk.Rectangle status_renderer_rect = Gdk.Rectangle () {
            x = cell_area.x+ICON_SIZE+PADDING,
            y = cell_area.y+file_name_renderer_height+download_progress_renderer_height+PADDING,
            height = status_renderer_height,
            width = cell_area.width-(ICON_SIZE+RIGHT_COLUMN_WIDTH+2*PADDING)
        };

        icon_renderer.render (ctx, widget, icon_rect, icon_rect, flags);
        file_name_renderer.render (ctx, widget, file_name_rect, file_name_rect, flags);
        download_progress_renderer.render (ctx, widget, download_progress_rect, download_progress_rect, flags);
        status_renderer.render (ctx, widget, status_renderer_rect, status_renderer_rect, flags);
        status_renderer.text= file_name_renderer_height.to_string();


    }

}
