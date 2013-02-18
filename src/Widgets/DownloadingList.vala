public class Arrive.Widgets.DownloadingList : Object {
    private static int REFRESH_TIME=1000;
    public Gtk.ScrolledWindow widget;
    private Gtk.ListStore list_store;
    private Gtk.TreeView tree_view;
    
    public DownloadingList () {
        /*Gtk.ListStore*/ list_store = new Gtk.ListStore (1, typeof(Arrive.Model.DownloadItem));
        /*Gtk.TreeView*/ tree_view = new Gtk.TreeView.with_model (list_store);
        tree_view.set_headers_visible (false);
        tree_view.get_selection().set_mode(Gtk.SelectionMode.MULTIPLE);
        widget = new Gtk.ScrolledWindow(null, null);
        widget.add(tree_view);

        tree_view.button_press_event.connect((event)=>{
            if(event.button==3){                        
                show_popup_menu(event);
            }
            return false;
        });
                
        Arrive.App.aria2.download_list.list_changed.connect(()=>{
            populate_list_store();
        });
        
        var cell_renderer = new Arrive.Widgets.DownloadCellRenderer ();
        tree_view.insert_column_with_attributes (-1, "column", cell_renderer, "file", 0);
        
        var refresh_timer = new TimeoutSource(REFRESH_TIME);
        refresh_timer.set_callback(()=>{
            tree_view.queue_draw();
            return true;
        });
        refresh_timer.attach(null);
        debug("DownloadingList created");
    }
    private void populate_list_store(){
        list_store.clear();
        foreach(Arrive.Model.DownloadItem file in Arrive.App.aria2.download_list._list){
            Gtk.TreeIter iter;
            list_store.append(out iter);
            list_store.set(iter,0,file);
        }
    }
    private void show_popup_menu(Gdk.EventButton event){
        List<Arrive.Model.DownloadItem> selected_files;
        selected_files=get_selected_files();
        var menu = new Gtk.Menu();
        var start = new Gtk.MenuItem.with_label(_("Continue"));
        var pause = new Gtk.MenuItem.with_label(_("Pause"));
        var cancel = new Gtk.MenuItem.with_label(_("Cancel"));
        var properties = new Gtk.MenuItem.with_label(_("Properties"));
        //TODO:implement right click event
        start.activate.connect(()=>{
            foreach(Arrive.Model.DownloadItem d_item in selected_files){
                if(d_item.status=="paused")d_item.unpause();
                if(d_item.status=="")d_item.start(null);
            }
        });
        pause.activate.connect(()=>{
            foreach(Arrive.Model.DownloadItem d_item in selected_files){
                d_item.pause();
            }
        });
        cancel.activate.connect(()=>{
            foreach(Arrive.Model.DownloadItem d_item in selected_files){
                d_item.remove();
            }
        });
//~         properties.connect();
        
        if(allow_start(selected_files))menu.add(start);
        if(allow_pause(selected_files))menu.add(pause);
        if(allow_cancel(selected_files))menu.add(cancel);
        if(allow_properties(selected_files))menu.add(properties);
        
        menu.attach_to_widget(tree_view,null);
        menu.show_all();
        menu.popup(null,null,null,event.button,event.time);
    }
    private bool allow_start(List<Arrive.Model.DownloadItem> selected_files){
        bool allow=false;
        foreach(Arrive.Model.DownloadItem d_item in selected_files){
            if(d_item.status=="paused")allow=true;
            if(d_item.status=="")allow=true;
        }
        return allow;
    }
    private bool allow_pause(List<Arrive.Model.DownloadItem> selected_files){
        bool allow=false;
        foreach(Arrive.Model.DownloadItem d_item in selected_files){
            if(d_item.status=="active")allow=true;
        }
        return allow;
    }
    private bool allow_cancel(List<Arrive.Model.DownloadItem> selected_files){
        bool allow=false;
        foreach(Arrive.Model.DownloadItem d_item in selected_files){
            if(d_item.status=="active")allow=true;
        }
        return allow;
    }
    private bool allow_properties(List<Arrive.Model.DownloadItem> selected_files){
        return true;
    }
    private List<Arrive.Model.DownloadItem> get_selected_files(){
        var list = new List<Arrive.Model.DownloadItem>();
        Gtk.TreeIter selection_iter;
        Gtk.TreeSelection selection=tree_view.get_selection();
        GLib.List<Gtk.TreePath> d_items = selection.get_selected_rows(null);
        Gtk.TreeModel model = tree_view.get_model();
        foreach(Gtk.TreePath selection_item in d_items){
           /*Arrive.Model.DownloadItem*/Value d_item;
           model.get_iter (out selection_iter, selection_item);
           model.get_value(selection_iter,0, out d_item);
           if(d_item.holds(typeof(Arrive.Model.DownloadItem))){
                list.append((Arrive.Model.DownloadItem)d_item);
            } else {
                debug("value arent download item");
            }
        }
        
        return list;
    }
}
