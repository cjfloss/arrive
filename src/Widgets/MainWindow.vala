//build with
//      valac --pkg granite arrive.vala MainWindow.vala
using Gtk;
public class Arrive.Widgets.MainWindow : Gtk.Window  {
	private Gtk.ToolButton start_all;
	private Gtk.ToolButton pause_all;
    private Granite.Widgets.SearchBar search_bar;
    private Granite.Widgets.AppMenu app_menu;
    private Granite.Widgets.StaticNotebook static_notebook;
    public Arrive.Widgets.DownloadingList downloading_list;
    public Arrive.Widgets.FinishedList finished_list;
    private Granite.Widgets.StatusBar status_bar;
    public Gtk.Label download_speed_label;
    private Box vbox;
    private Arrive.Widgets.AddFileDialog add_file_dialog;
    public MainWindow () {
        set_title ("Arrive");
        set_position (Gtk.WindowPosition.CENTER);
        set_default_size (400, 500);
        resizable = true;
        get_style_context ().add_class ("content-view-window");
        
        build_gui();
        show_all ();

        Arrive.App.aria2.notify["download-speed"].connect((object,param)=>{refresh_status();});
        Arrive.App.aria2.notify["upload-speed"].connect((object,param)=>{refresh_status();});
        destroy.connect(()=> { this.hide();Gtk.main_quit();Arrive.App.aria2.shutdown(); });
    }
    private void refresh_status(){
        download_speed_label.set_text("dl/up speed:%sps/%sps    ".printf(format_size(Arrive.App.aria2.download_speed),
                                                                                    format_size(Arrive.App.aria2.upload_speed)
                                                                                    ));
		determine_toolbutton_status();
    }
    private void determine_toolbutton_status (){
		bool active_all=true;
		bool paused_all=true;
		foreach (Arrive.Model.DownloadItem ditem in Arrive.App.aria2.download_list._list){
			if (ditem.status!="active")
				active_all = false;
			if (ditem.status!="paused")
				paused_all = false;
		}
		if (active_all){
			start_all.sensitive = false;
		}else{
			start_all.sensitive = true;
		}
		if (paused_all){
			pause_all.sensitive = false;
		}else{
			pause_all.sensitive = true;
		}
	}
    void build_gui () {
        var toolbar = new Toolbar ();
        toolbar.set_vexpand (false);
        toolbar.set_hexpand (true);
        toolbar.get_style_context ().add_class ("primary-toolbar");

        var add_button = new ToolButton.from_stock (Gtk.Stock.ADD);
        add_button.clicked.connect(()=>{
                //Granite.PopOver doesnt support File Chooser Button;
//~                 var add_file_pop = new AddFilePopOver();
//~                 add_file_pop.set_parent_pop(this);
//~                 add_file_pop.move_to_widget(add_button);
//~                 add_file_pop.show_all();
//~                 add_file_pop.present();
//~                 add_file_pop.run();
//~                 add_file_pop.destroy();

//FIXME: add_file_dialog should only one, but the code doesnt work
//~                 if(add_file_dialog != null){
//~                     add_file_dialog.present();
//~                 }else{
                    add_file_dialog=new AddFileDialog("");
                    add_file_dialog.show_all();
                    
//~                 }
                

        });
        //var pause_button = new Arrive.Widgets.PauseButton();
        start_all = new Gtk.ToolButton.from_stock (Gtk.Stock.MEDIA_PLAY);
        start_all.clicked.connect(()=>{
			foreach(Arrive.Model.DownloadItem ditem in Arrive.App.aria2.download_list._list){
                            ditem.unpause();
			}
		});
        pause_all = new Gtk.ToolButton.from_stock (Gtk.Stock.MEDIA_PAUSE);
        pause_all.clicked.connect(()=>{
			foreach(Arrive.Model.DownloadItem ditem in Arrive.App.aria2.download_list._list){
                            ditem.pause();
			}
		});

        toolbar.insert (add_button, -1);
        toolbar.insert (start_all, -1);
        toolbar.insert (pause_all, -1);

        var spacer = new Gtk.ToolItem ();
        spacer.set_expand (true);
        toolbar.insert (spacer,-1);

        search_bar = new Granite.Widgets.SearchBar (_("Search"));
        search_bar.sensitive = false;//disabled while hasnt implemented
        var search_bar_toolitem = new Gtk.ToolItem ();
        search_bar_toolitem.add (search_bar);
        
        //creating cogl menu
        var menu = new Gtk.Menu ();
        Gtk.MenuItem about_item = new Gtk.MenuItem.with_label("About");
        about_item.activate.connect(()=>{Arrive.App.instance.show_about(this);});
        menu.append(about_item);
        app_menu = new Granite.Widgets.AppMenu(menu);
        toolbar.insert (search_bar_toolitem,-1);
        toolbar.insert (app_menu,-1);

        downloading_list =new Arrive.Widgets.DownloadingList ();

        finished_list =new Arrive.Widgets.FinishedList ();

        static_notebook = new Granite.Widgets.StaticNotebook ();
        static_notebook.get_style_context ().add_class ("content-view");
        static_notebook.append_page (downloading_list.widget, new Gtk.Label (_("Downloading")));
        static_notebook.append_page (finished_list, new Gtk.Label (_("Finished")));

        status_bar = new Granite.Widgets.StatusBar ();
        download_speed_label = new Label("");
        status_bar.insert_widget(download_speed_label);

        vbox = new Box (Gtk.Orientation.VERTICAL,0);
        vbox.pack_start (toolbar,false,false);
        vbox.pack_start (static_notebook,true,true);
        vbox.pack_start (status_bar,false,false);
        add (vbox);
    }
}
