//build with
//      valac --pkg granite arrive.vala MainWindow.vala
using Gtk;
namespace Arrive.Widgets {
    public class MainWindow : Gtk.Window  {
        private Gtk.ToolButton start_all;
        private Gtk.ToolButton pause_all;
        public Granite.Widgets.SearchBar search_bar;
        private Granite.Widgets.AppMenu app_menu;
        private Granite.Widgets.StaticNotebook static_notebook;
        public Widgets.DownloadingList downloading_list;
        public Widgets.FinishedList finished_list;
        private Granite.Widgets.StatusBar status_bar;
        public Gtk.Label download_speed_label;
        private Box vbox;
        private Model.SavedState saved_state;
        //private Arrive.Widgets.AddFileDialog add_file_dialog;
        private static string Style = "
            .content-view-window {
                background-image: -gtk-gradient (linear,
                    left top,
                    left bottom,
                    from (#f8f8f8),
                    color-stop (0.8, #f8f8f8),
                    to (#f0f0f0));
    
            }
        ";
        
        public MainWindow () {
            saved_state = new Model.SavedState ();
            
            set_title ("Arrive");
            set_position (Gtk.WindowPosition.CENTER);
            restore_saved_state ();
            resizable = true;
            //get_style_context ().add_class ("content-view-window");

            build_gui ();
            show_all ();

            Model.aria2.download_list.item_refreshed.connect (refresh_status);
            search_bar.text_changed_pause.connect (()=>{finished_list.filter (search_bar.text);});
            destroy.connect (()=> {
                                save_saved_state ();
                                this.hide ();
                                Gtk.main_quit ();
                                Model.aria2.download_list.destroy ();
                                Model.aria2.shutdown ();
                             });
        }
        private void refresh_status(){
            download_speed_label.set_text ("dl/up : %sps/%sps    ".printf (format_size (total_download_speed ()),
                                                                               format_size (total_upload_speed ())
                                                                               ));
            determine_toolbutton_status ();
        }
        //i think this two doesnt belong here
        private uint64 total_download_speed (){
            uint64 total_speed = 0;
            foreach(Model.IDownloadItem d_item in Model.aria2.download_list.files){
                total_speed += d_item.download_speed;
            }
            return total_speed;            
        }
        private uint64 total_upload_speed (){
            uint64 total_upload = 0;
            foreach(Model.IDownloadItem d_item in Model.aria2.download_list.files){
                total_upload += d_item.upload_speed;
            }
            return total_upload;
        }
        private void determine_toolbutton_status (){
            bool active_all = true;
            bool paused_all = true;
            foreach (Model.IDownloadItem ditem in Model.aria2.download_list.files) {
                if (ditem.status != "active")
                    active_all = false;
                if (ditem.status != "paused")
                    paused_all = false;
            }
            start_all.sensitive = !active_all;
            pause_all.sensitive = !paused_all;
        }
        private void save_saved_state (){
            
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
        }
        private void restore_saved_state (){
            resize (saved_state.window_width, saved_state.window_height);
            if (saved_state.window_state == Model.WindowState.MAXIMIZED)
                maximize ();
        }
        public override bool delete_event(Gdk.EventAny event){
            foreach (Model.IDownloadItem d_item in App.instance.download_list.files){
                if (d_item.status == "active"){
                    iconify ();
                    return true;
                }
            }
            return false;
        }
        void build_gui () {
            var toolbar = new Toolbar ();
            toolbar.set_vexpand (false);
            toolbar.set_hexpand (true);
            toolbar.get_style_context ().add_class ("primary-toolbar");
            
            var add_button = new ToolButton.from_stock (Gtk.Stock.ADD);
            add_button.clicked.connect (()=>{
                                             var add_file_dialog = new AddFileDialog ("");
                                             add_file_dialog.show_all ();
                                        });
            start_all = new Gtk.ToolButton.from_stock (Gtk.Stock.MEDIA_PLAY);
            start_all.clicked.connect (()=>{
                                           foreach(Arrive.Model.IDownloadItem ditem in Model.aria2.download_list.files)
                                               ditem.unpause ();
                                       });
            pause_all = new Gtk.ToolButton.from_stock (Gtk.Stock.MEDIA_PAUSE);
            pause_all.clicked.connect (()=>{
                                           foreach(Arrive.Model.IDownloadItem ditem in Model.aria2.download_list.files)
                                               ditem.pause ();
                                       });

            toolbar.insert (add_button, -1);
            toolbar.insert (start_all, -1);
            toolbar.insert (pause_all, -1);

            var spacer = new Gtk.ToolItem ();
            spacer.set_expand (true);
            toolbar.insert (spacer, -1);

            search_bar = new Granite.Widgets.SearchBar (_ ("Search"));
            //search_bar.sensitive = false; //disabled while hasnt implemented
            var search_bar_toolitem = new Gtk.ToolItem ();
            search_bar_toolitem.add (search_bar);

            //creating cogl menu
            var menu = new Gtk.Menu ();
            
            var power_menu = new Gtk.Menu();
            var nothing_menu = new Gtk.RadioMenuItem.with_label (null, _("Nothing"));
            var hibernate_menu = new Gtk.RadioMenuItem.with_label (nothing_menu.get_group (), _("Hibernate"));
            var suspend_menu = new Gtk.RadioMenuItem.with_label (nothing_menu.get_group (), _("Suspend"));
            var shutdown_menu = new Gtk.RadioMenuItem.with_label (nothing_menu.get_group (), _("Shutdown"));
            power_menu.append (nothing_menu);
            power_menu.append (hibernate_menu);
            power_menu.append (suspend_menu);
            power_menu.append (shutdown_menu);
            //disble for now
            //nothing_menu.sensitive = false;
            hibernate_menu.sensitive = false;
            suspend_menu.sensitive = false;
            shutdown_menu.sensitive = false;
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

            downloading_list =new Arrive.Widgets.DownloadingList ();

            finished_list =new Arrive.Widgets.FinishedList ();
            search_bar.text_changed_pause.connect (()=>{
                finished_list.tree_filter.refilter ();
            });
            
            //static bar
            static_notebook = new Granite.Widgets.StaticNotebook ();
            //static_notebook.get_style_context ().add_class ("content-view-window");
            static_notebook.get_style_context ().add_class (Granite.StyleClass.CONTENT_VIEW);
            static_notebook.append_page (downloading_list.widget, new Gtk.Label (_ ("Downloading")));
            static_notebook.append_page (finished_list.widget, new Gtk.Label (_ ("Finished")));

            status_bar = new Granite.Widgets.StatusBar ();
            download_speed_label = new Label (_("download idle"));
            status_bar.insert_widget (download_speed_label);

            vbox = new Box (Gtk.Orientation.VERTICAL, 0);
            vbox.pack_start (toolbar, false, false);
            vbox.pack_start (static_notebook, true, true);
            vbox.pack_start (status_bar, false, false);
            add (vbox);
        }
    }
}
