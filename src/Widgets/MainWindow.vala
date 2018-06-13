//build with
//      valac --pkg granite arrive.vala MainWindow.vala
using Gtk;
using Gdk;
namespace Arrive.Widgets {
public class MainWindow : Gtk.Window {
    private Gtk.HeaderBar header_bar;
    private Gtk.ToolButton start_all;
    private Gtk.ToolButton pause_all;
    public Gtk.SearchEntry search_bar;
    private Gtk.StackSwitcher stack_switcher;
    private Gtk.Stack stack;
    public Widgets.DownloadingList downloading_list;
    public Widgets.FinishedList finished_list;
    private Gtk.ActionBar action_bar;
    public Gtk.Label download_speed_label;
    public Gtk.Label status_label;
    private Gtk.Grid grid;
    private Model.SavedState saved_state;
    private Model.DownloadList download_list_model;
    private Model.FinishedList finished_list_model;
    private Model.Settings settings;

    public MainWindow (Model.IDownloadList d_list, Model.FinishedList f_list, Model.Settings _settings) {

        download_list_model = d_list as Model.DownloadList;
        finished_list_model = f_list;
        settings = _settings;

        saved_state = new Model.SavedState ();

        /* get_style_context ().add_class ("content-view-window"); */
        build_gui ();
        restore_window_state ();
        set_position (Gtk.WindowPosition.CENTER);
        show_all ();
        downloading_list.filter (search_bar.text);
        finished_list.filter (search_bar.text);
        stack.set_visible_child_name (saved_state.notebook_state);

        download_list_model.item_refreshed.connect (refresh_status);
        download_list_model.file_removed.connect (() => {
            if (download_list_model.files.length () == 0) {
                on_all_finished ();
            }
        });

        destroy.connect (() => {
            hide ();
            download_list_model.destroy ();
            Model.aria2.shutdown ();
            /* Gtk.main_quit (); */
        });
        window_state_event.connect ( (e) => {
            if (e.changed_mask == Gdk.WindowState.FULLSCREEN) {
                bool f = ( (e.new_window_state & Gdk.WindowState.FULLSCREEN) != 0);
                Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = f;
                colorize_stack_switcher ();
            }
            return false;
        });

        Notify.init (get_title () );
    }
    private void refresh_status() {
        download_speed_label.set_text (
            "dl/up : %sps/%sps    ".printf (
                format_size (total_download_speed () ),
                format_size (total_upload_speed () )
            ) );
        determine_toolbutton_status ();
    }
    //i think this two doesnt belong here
    private uint64 total_download_speed () {
        uint64 total_speed = 0;
        foreach (Model.IDownloadItem d_item in download_list_model.files) {
            total_speed += d_item.download_speed;
        }
        return total_speed;
    }
    private uint64 total_upload_speed () {
        uint64 total_upload = 0;
        foreach (Model.IDownloadItem d_item in download_list_model.files) {
            total_upload += d_item.upload_speed;
        }
        return total_upload;
    }
    private void determine_toolbutton_status () {
        bool active_all = true;
        bool paused_all = true;
        foreach (Model.IDownloadItem ditem in download_list_model.files) {
            if (ditem.status != "active") {
                active_all = false;
            }
            if (ditem.status != "paused") {
                paused_all = false;
            }
        }
        start_all.sensitive = !active_all;
        pause_all.sensitive = !paused_all;
    }
    private void save_window_state () {
        //FIXME:get_window dont want to return Gdk.Window
        if (get_window ().get_state () == Gdk.WindowState.MAXIMIZED) {
            saved_state.window_state = Model.WindowState.MAXIMIZED;
        } else {
            saved_state.window_state = Model.WindowState.NORMAL;
        }

        if (saved_state.window_state == Model.WindowState.NORMAL) {
            int width, height;
            get_size (out width, out height);
            saved_state.window_width = width;
            saved_state.window_height = height;
        }
        saved_state.notebook_state = stack.get_visible_child_name ();
        saved_state.search_string = search_bar.text;
    }
    private void restore_window_state () {
        resize (saved_state.window_width, saved_state.window_height);
        if (saved_state.window_state == Model.WindowState.MAXIMIZED) {
            maximize ();
        }
        search_bar.text = saved_state.search_string;
    }
    public override bool delete_event (Gdk.EventAny event) {
        foreach (Model.IDownloadItem d_item in download_list_model.files) {
            if (d_item.status == "active") {
                iconify ();
                return true;
            }
        }
        save_window_state ();
        return false;
    }
    void build_gui () {
        header_bar = new HeaderBar ();
        header_bar.set_title ("Arrive");
        header_bar.set_show_close_button (true);
        /* header_bar.set_has_subtitle (false); */
        set_titlebar (header_bar);

        var add_button = new ToolButton (null, null);
        add_button.set_tooltip_text (_ ("Add download") );
        add_button.set_icon_name ("list-add");
        add_button.clicked.connect (() => {
            create_add_dialog ();
        });
        start_all = new Gtk.ToolButton (null, null);
        start_all.set_icon_name ("media-playback-start");
        start_all.clicked.connect (() => {
            foreach (Arrive.Model.IDownloadItem ditem in download_list_model.files) {
                ditem.unpause ();
            }
        });
        pause_all = new Gtk.ToolButton (null, null);
        pause_all.set_icon_name ("media-playback-pause");
        pause_all.clicked.connect (() => {
            foreach (Arrive.Model.IDownloadItem ditem in download_list_model.files) {
                ditem.pause ();
            }
        });

        header_bar.pack_start (add_button);
        header_bar.pack_start (start_all);
        header_bar.pack_start (pause_all);

        //toolbar right item
        search_bar = new Gtk.SearchEntry ();
        search_bar.set_placeholder_text (_ ("Search") );
        var search_bar_toolitem = new Gtk.ToolItem ();
        search_bar_toolitem.add (search_bar);

        header_bar.pack_end (search_bar_toolitem);


        var power_menu = new Gtk.Menu();
        var nothing_menu = new Gtk.RadioMenuItem.with_label (null, _ ("Nothing") );
        var suspend_menu =
            new Gtk.RadioMenuItem.with_label (nothing_menu.get_group (), _ ("Suspend") );
        var hibernate_menu =
            new Gtk.RadioMenuItem.with_label (nothing_menu.get_group (), _ ("Hibernate") );
        var shutdown_menu =
            new Gtk.RadioMenuItem.with_label (nothing_menu.get_group (), _ ("Shutdown") );

        nothing_menu.activate.connect (() => {
            settings.finished_action = Model.FinishedAction.NOTHING;
        });
        suspend_menu.activate.connect (() => {
            settings.finished_action = Model.FinishedAction.SUSPEND;
        });
        hibernate_menu.activate.connect (() => {
            settings.finished_action = Model.FinishedAction.HIBERNATE;
        });
        shutdown_menu.activate.connect (() => {
            settings.finished_action = Model.FinishedAction.SHUTDOWN;
        });
        settings.notify["finished-action"].connect (() => {
            switch (settings.finished_action) {
                case Model.FinishedAction.NOTHING:
                    nothing_menu.set_active (true);
                    break;
                case Model.FinishedAction.SUSPEND:
                    suspend_menu.set_active (true);
                    break;
                case Model.FinishedAction.HIBERNATE:
                    hibernate_menu.set_active (true);
                    break;
                case Model.FinishedAction.SHUTDOWN:
                    shutdown_menu.set_active (true);
                    break;
            }
        });
        power_menu.append (nothing_menu);
        power_menu.append (suspend_menu);
        //power_menu.append (hibernate_menu);
        power_menu.append (shutdown_menu);
        power_menu.show_all ();

        hibernate_menu.sensitive = false;

        //finish menu
        var finish_button = new Gtk.MenuButton();
        finish_button.set_popup (power_menu);
        finish_button.set_direction (ArrowType.UP);
        finish_button.set_tooltip_text (_ ("When download finished...") );
        finish_button.image = new Gtk.Image.from_icon_name ("object-select-symbolic", Gtk.IconSize.SMALL_TOOLBAR);

        //downloading list
        downloading_list = new Arrive.Widgets.DownloadingList (download_list_model);
        downloading_list.set_vexpand (true);

        //finished list
        finished_list = new Arrive.Widgets.FinishedList (finished_list_model);
        finished_list.notify["status"].connect ( (s, p) => {
            status_label.set_text (finished_list.status);
        });

        search_bar.search_changed.connect (() => {
            downloading_list.filter (search_bar.text);
            finished_list.filter (search_bar.text);
        });

        // Stack
        stack = new Gtk.Stack ();
        stack.add_titled (downloading_list, "downloading_list", _ ("Downloading") );
        stack.add_titled (finished_list, "finished_list", _ ("Finished") );
        stack_switcher = new Gtk.StackSwitcher ();
        stack_switcher.set_hexpand (true);
        stack_switcher.set_margin_top (2);
        stack_switcher.set_margin_bottom (2);
        stack_switcher.set_halign (Align.CENTER);
        stack_switcher.set_stack (stack);

        //action bar
        action_bar = new Gtk.ActionBar ();
        download_speed_label = new Label (_ ("download idle") );
        status_label = new Label ("");
        action_bar.pack_start (finish_button);
        action_bar.pack_end (download_speed_label);
        action_bar.pack_end (status_label);

        // Main Grid
        grid = new Gtk.Grid ();
        //grid.attach (stack_switcher, 0, 0, 1, 1);
        grid.attach (stack, 0, 1, 1, 1);
        grid.attach (action_bar, 0, 2, 1, 1);
        colorize_stack_switcher ();
        header_bar.set_custom_title (stack_switcher);
        add (grid);

    }
    public void create_add_dialog (string uri = "", string dir = "", int num_segment = 0) {
        var add_file_dialog = new AddFileDialog (download_list_model, settings, uri);
        add_file_dialog.show_all ();
    }
    private void hibernate () {
        suspend (true);
    }
    private void suspend (bool to_disk = false) {
        try {
            UPower upower = Bus.get_proxy_sync (BusType.SYSTEM,
                                                "org.freedesktop.UPower", "/org/freedesktop/UPower");
            if (to_disk) {
                //hibernate
                if (upower.HibernateAllowed () ) {
                    upower.Hibernate ();
                }
            } else {
                //suspend
                if (upower.SuspendAllowed () ) {
                    upower.Suspend ();
                }
            }
        } catch (Error e) {
            warning (e.message);
        }
    }
    private void shutdown () {
        try {
            GnomeSessionManager session_manager = Bus.get_proxy_sync (BusType.SESSION,
                                                  "org.gnome.SessionManager", "/org/gnome/SessionManager");
            if (session_manager.CanShutdown () ) {
                session_manager.Shutdown ();
            }
        } catch (Error e) {
            warning (e.message);
        }
    }
    private void on_all_finished () {
        switch (settings.finished_action) {
            case Model.FinishedAction.SUSPEND:
                settings.finished_action = Model.FinishedAction.NOTHING;
                suspend ();
                break;
            case Model.FinishedAction.HIBERNATE:
                settings.finished_action = Model.FinishedAction.NOTHING;
                hibernate ();
                break;
            case Model.FinishedAction.SHUTDOWN:
                settings.finished_action = Model.FinishedAction.NOTHING;
                shutdown ();
                break;
        }
    }
    private void colorize_stack_switcher () {
        // steal treeview background color for stack switcher
        var dummy_treeview = new Gtk.TreeView ();
        var bg_color = dummy_treeview.get_style_context ().get_background_color (Gtk.StateFlags.NORMAL);
        grid.override_background_color (Gtk.StateFlags.NORMAL, bg_color);
    }
}
}
