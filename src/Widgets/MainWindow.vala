//build with
//      valac --pkg granite arrive.vala MainWindow.vala
using Gtk;
using Gdk;
namespace Arrive.Widgets {
    //public static MainWindow main_window;
    public class MainWindow : Gtk.Window {
        private Gtk.ToolButton start_all;
        private Gtk.ToolButton pause_all;
        public Granite.Widgets.SearchBar search_bar;
        private Granite.Widgets.AppMenu app_menu;
        private Granite.Widgets.StaticNotebook static_notebook;
        public Widgets.DownloadingList downloading_list;
        public Widgets.FinishedList finished_list;
        private Granite.Widgets.StatusBar status_bar;
        public Gtk.Label download_speed_label;
        public Gtk.Label status_label;
        private Box vbox;
        private Model.SavedState saved_state;
        private Model.DownloadList download_list_model;
        private Model.FinishedList finished_list_model;
        //private Arrive.Widgets.AddFileDialog add_file_dialog;
        
        public MainWindow (Model.IDownloadList d_list, Model.FinishedList f_list) {
            download_list_model = d_list as Model.DownloadList;
            finished_list_model = f_list;
            
            saved_state = new Model.SavedState ();
            
            set_title ("Arrive");
            //get_style_context ().add_class ("content-view-window");
            //resizable = true;
            build_gui ();
            restore_window_state ();
            set_position (Gtk.WindowPosition.CENTER);
            show_all ();
            downloading_list.filter (search_bar.text);
            finished_list.filter (search_bar.text);
            static_notebook.page = saved_state.notebook_state;
            
            download_list_model.item_refreshed.connect (refresh_status);
            download_list_model.file_removed.connect (()=>{
                if (download_list_model.files.length () == 0)
                    on_all_finished ();
            });
            
            destroy.connect (()=> {
                hide ();
                download_list_model.destroy ();
                Model.aria2.shutdown ();
                Gtk.main_quit ();
             });

            Notify.init(get_title ());
        }
        private void refresh_status(){
            download_speed_label.set_text (
                "dl/up : %sps/%sps    ".printf (
                format_size (total_download_speed ()),
                format_size (total_upload_speed ())
            ));
            determine_toolbutton_status ();
        }
        //i think this two doesnt belong here
        private uint64 total_download_speed (){
            uint64 total_speed = 0;
            foreach(Model.IDownloadItem d_item in download_list_model.files){
                total_speed += d_item.download_speed;
            }
            return total_speed;            
        }
        private uint64 total_upload_speed (){
            uint64 total_upload = 0;
            foreach(Model.IDownloadItem d_item in download_list_model.files){
                total_upload += d_item.upload_speed;
            }
            return total_upload;
        }
        private void determine_toolbutton_status (){
            bool active_all = true;
            bool paused_all = true;
            foreach (Model.IDownloadItem ditem in download_list_model.files) {
                if (ditem.status != "active")
                    active_all = false;
                if (ditem.status != "paused")
                    paused_all = false;
            }
            start_all.sensitive = !active_all;
            pause_all.sensitive = !paused_all;
        }
        private void save_window_state (){
            //FIXME:get_window dont want to return Gdk.Window
            if (get_window ().get_state () == Gdk.WindowState.MAXIMIZED)
                saved_state.window_state = Model.WindowState.MAXIMIZED;
            else
                saved_state.window_state = Model.WindowState.NORMAL;
            
            if (saved_state.window_state == Model.WindowState.NORMAL){
                int width, height;
                get_size (out width, out height);
                saved_state.window_width = width;
                saved_state.window_height = height;
            }
            saved_state.notebook_state = static_notebook.page;
            saved_state.search_string = search_bar.text;
        }
        private void restore_window_state (){
            resize (saved_state.window_width, saved_state.window_height);
            if (saved_state.window_state == Model.WindowState.MAXIMIZED)
                maximize ();
            search_bar.text = saved_state.search_string;
        }
        public override bool delete_event(Gdk.EventAny event){
            foreach (Model.IDownloadItem d_item in download_list_model.files){
                if (d_item.status == "active"){
                    iconify ();
                    return true;
                }
            }
            save_window_state ();
            return false;
        }
        void build_gui () {
            //toolbar left button
            var toolbar = new Toolbar ();
            toolbar.set_vexpand (false);
            toolbar.set_hexpand (true);
            toolbar.get_style_context ().add_class ("primary-toolbar");
            
            var add_button = new ToolButton.from_stock (Gtk.Stock.ADD);
            add_button.clicked.connect (()=>{
                create_add_dialog ();
            });
            start_all = new Gtk.ToolButton.from_stock (Gtk.Stock.MEDIA_PLAY);
            start_all.clicked.connect (()=>{
                   foreach(Arrive.Model.IDownloadItem ditem in download_list_model.files)
                       ditem.unpause ();
               });
            pause_all = new Gtk.ToolButton.from_stock (Gtk.Stock.MEDIA_PAUSE);
            pause_all.clicked.connect (()=>{
                   foreach(Arrive.Model.IDownloadItem ditem in download_list_model.files)
                       ditem.pause ();
               });

            toolbar.insert (add_button, -1);
            toolbar.insert (start_all, -1);
            toolbar.insert (pause_all, -1);

            var spacer = new Gtk.ToolItem ();
            spacer.set_expand (true);
            toolbar.insert (spacer, -1);
            
            //toolbar right item
            search_bar = new Granite.Widgets.SearchBar (_ ("Search"));
            var search_bar_toolitem = new Gtk.ToolItem ();
            search_bar_toolitem.add (search_bar);

            //creating cogl menu
            var menu = new Gtk.Menu ();
            
            var power_menu = new Gtk.Menu();
            var nothing_menu = new Gtk.RadioMenuItem.with_label (null, _("Nothing"));
            var suspend_menu = 
                new Gtk.RadioMenuItem.with_label (nothing_menu.get_group (), _("Suspend"));
            var hibernate_menu = 
                new Gtk.RadioMenuItem.with_label (nothing_menu.get_group (), _("Hibernate"));
            var shutdown_menu = 
                new Gtk.RadioMenuItem.with_label (nothing_menu.get_group (), _("Shutdown"));
            
            nothing_menu.activate.connect (()=>{
                App.instance.settings.finished_action = Model.FinishedAction.NOTHING;
            });
            suspend_menu.activate.connect (()=>{
                App.instance.settings.finished_action = Model.FinishedAction.SUSPEND;
            });
            hibernate_menu.activate.connect (()=>{
                App.instance.settings.finished_action = Model.FinishedAction.HIBERNATE;
            });
            shutdown_menu.activate.connect (()=>{
                App.instance.settings.finished_action = Model.FinishedAction.SHUTDOWN;
            });
            App.instance.settings.notify["finished-action"].connect (()=>{
                switch (App.instance.settings.finished_action){
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
            
            hibernate_menu.sensitive = false;
            
            var submenu = new Gtk.MenuItem.with_label (_("When all finished..."));
            submenu.set_submenu (power_menu);
            menu.append (submenu);
            
            menu.append (new Gtk.SeparatorMenuItem ());
            
            Gtk.MenuItem about_item = new Gtk.MenuItem.with_label ("About");
            about_item.activate.connect (()=>{Arrive.App.instance.show_about (this); });
            menu.append (about_item);
            
            app_menu = new Granite.Widgets.AppMenu (menu);
            toolbar.insert (search_bar_toolitem, -1);
            toolbar.insert (app_menu, -1);
            
            //downloading list
            downloading_list = new Arrive.Widgets.DownloadingList (download_list_model);

            //finished list
            finished_list =new Arrive.Widgets.FinishedList (finished_list_model);
            finished_list.notify["status"].connect ((s, p)=>{
                status_label.set_text(finished_list.status);
            });
            
            search_bar.text_changed_pause.connect (()=>{
                downloading_list.filter (search_bar.text);
                finished_list.filter (search_bar.text);
            });
            
            //static notebook
            static_notebook = new Granite.Widgets.StaticNotebook ();
            static_notebook.get_style_context ().add_class (Granite.StyleClass.CONTENT_VIEW);
            static_notebook.append_page (downloading_list, new Gtk.Label (_ ("Downloading")));
            static_notebook.append_page (finished_list, new Gtk.Label (_ ("Finished")));

            //status bar
            status_bar = new Granite.Widgets.StatusBar ();
            download_speed_label = new Label (_("download idle"));
            status_bar.insert_widget (download_speed_label, false);
            status_label = new Label ("");
            status_bar.insert_widget (status_label, true);

            vbox = new Box (Gtk.Orientation.VERTICAL, 0);
            vbox.pack_start (toolbar, false, false);
            vbox.pack_start (static_notebook, true, true);
            vbox.pack_start (status_bar, false, false);
            add (vbox);
        }
        public void create_add_dialog (string uri="", string dir="", int num_segment=0){            
             var add_file_dialog = new AddFileDialog (uri);
             add_file_dialog.show_all ();
        }
        private void hibernate (){
            suspend (true);
        }
        private void suspend (bool to_disk = false){
            try {
                UPower upower = Bus.get_proxy_sync (BusType.SYSTEM,
                    "org.freedesktop.UPower", "/org/freedesktop/UPower");
                if (to_disk){
                    //hibernate
                    if (upower.HibernateAllowed ())
                        upower.Hibernate ();
                }else{
                    //suspend
                    if (upower.SuspendAllowed ())
                        upower.Suspend ();
                }
            } catch (Error e) { warning (e.message); }   
        }
        private void shutdown (){
            try {
                GnomeSessionManager session_manager = Bus.get_proxy_sync (BusType.SESSION,
                    "org.gnome.SessionManager", "/org/gnome/SessionManager");
                if (session_manager.CanShutdown ())
                    session_manager.Shutdown ();
            }catch (Error e){warning (e.message);}
        }
        private void on_all_finished (){
            switch (App.instance.settings.finished_action){
                case Model.FinishedAction.SUSPEND:
                    App.instance.settings.finished_action = Model.FinishedAction.NOTHING;
                    suspend ();
                    break;
                case Model.FinishedAction.HIBERNATE:
                    App.instance.settings.finished_action = Model.FinishedAction.NOTHING;
                    hibernate ();
                    break;
                case Model.FinishedAction.SHUTDOWN:
                    App.instance.settings.finished_action = Model.FinishedAction.NOTHING;
                    shutdown ();
                    break;
            }
        }
    }
}
