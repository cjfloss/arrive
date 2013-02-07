//build with
//	valac --pkg granite arrive.vala MainWindow.vala
using Gtk;
public class Arrive.Widgets.MainWindow : Gtk.Window  {
    Granite.Widgets.SearchBar search_bar;
    Granite.Widgets.AppMenu app_menu;
    Granite.Widgets.StaticNotebook static_notebook;
    Arrive.Widgets.DownloadingList downloading_list;
    Arrive.Widgets.FinishedList finished_list;
    Granite.Widgets.StatusBar status_bar;
    Box vbox;
    public MainWindow () {

        set_title ("Arrive");
        set_position (Gtk.WindowPosition.CENTER);
        set_default_size (400, 500);
        resizable = true;
        delete_event.connect(()=> { Gtk.main_quit(); return false; });
        build_gui();
        get_style_context ().add_class ("content-view-window");
        show_all ();

    }
    void build_gui () {
        var toolbar = new Toolbar ();
        toolbar.set_vexpand (false);
        toolbar.set_hexpand (true);
        toolbar.get_style_context ().add_class ("primary-toolbar");

        var add_button = new ToolButton.from_stock (Gtk.Stock.ADD);
        var pause_button = new ToolButton.from_stock (Gtk.Stock.MEDIA_PAUSE);
        toolbar.insert (add_button,-1);
        toolbar.insert (pause_button,-1);

        var spacer = new Gtk.ToolItem ();
        spacer.set_expand (true);
        toolbar.insert (spacer,-1);

        search_bar = new Granite.Widgets.SearchBar ("Search");
        var search_bar_toolitem = new Gtk.ToolItem ();
        search_bar_toolitem.add (search_bar);
        var menu = new Gtk.Menu ();
        app_menu = new Granite.Widgets.AppMenu.with_app (Arrive.App.instance, menu);
        //app_menu = create_appmenu (new Gtk.Menu());
        toolbar.insert (search_bar_toolitem,-1);
        toolbar.insert (app_menu,-1);

        downloading_list =new Arrive.Widgets.DownloadingList ();

        finished_list =new Arrive.Widgets.FinishedList ();

        static_notebook = new Granite.Widgets.StaticNotebook ();
        static_notebook.get_style_context ().add_class ("content-view");
        static_notebook.append_page (downloading_list.widget, new Gtk.Label ("downloading"));
        static_notebook.append_page (finished_list, new Gtk.Label ("finished"));

        status_bar = new Granite.Widgets.StatusBar ();
        status_bar.set_text ("status bar");

        vbox = new Box (Gtk.Orientation.VERTICAL,0);
        vbox.pack_start (toolbar,false,false);
        vbox.pack_start (static_notebook,true,true);
        vbox.pack_start (status_bar,false,false);
        add (vbox);
    }
}
