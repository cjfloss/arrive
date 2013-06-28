namespace Arrive.Widgets {
    public class FinishedList : Object {
        public Gtk.ScrolledWindow widget;
        private Gtk.TreeView tree_view;
        private Gtk.TreeStore tree_store;
        public Gtk.TreeModelFilter tree_filter;
        private string filter_string;
        public FinishedList () {
            tree_store = new Gtk.TreeStore (3, typeof(string), typeof(string), typeof(Model.FinishedItem));
            tree_filter = new Gtk.TreeModelFilter (tree_store, null);
            tree_filter.set_visible_func (visible_func);
            tree_view = new Gtk.TreeView ();
            tree_view.set_model (tree_filter);
            tree_view.set_headers_visible (false);
            tree_view.get_selection ().set_mode (Gtk.SelectionMode.MULTIPLE);
            

            Gtk.TreeViewColumn column = new Gtk.TreeViewColumn.with_attributes (_("filename"), new Gtk.CellRendererText (), "text", 0, null);
            column.set_sizing (Gtk.TreeViewColumnSizing.FIXED);
            column.set_expand (true);
            column.set_resizable (true);
            tree_view.insert_column (column, -1);
            
            Gtk.TreeViewColumn column_s = new Gtk.TreeViewColumn.with_attributes (_("size"), new Gtk.CellRendererText (), "text", 1, null);
            column_s.set_fixed_width (50);
            tree_view.insert_column (column_s, -1);
            
            setup_list ();
            widget = new Gtk.ScrolledWindow (null, null);
            widget.add (tree_view);
        
            Model.aria2.finished_list.list_changed.connect (setup_list);
            tree_view.button_release_event.connect ((event)=>{
                                                        switch (event.button) {
                                                        /*case 1:
                                                            if (get_selected_files ().length () == 1)
                                                                get_selected_files ().nth_data (0).open_file ();
                                                            break;*/
                                                        case 3:
                                                            show_popup_menu (event);
                                                            break;
                                                        }
                                                        return false;
                                                    });
        }
        //filetering using search bar
        private bool visible_func (Gtk.TreeModel t_model, Gtk.TreeIter t_iter){
            if (filter_string == "")
                return true;
            if (t_model.iter_has_child (t_iter)){//check if its date iter
                for (int i=0;i<t_model.iter_n_children (t_iter);i++){
                    Gtk.TreeIter child_iter;
                    t_model.iter_nth_child (out child_iter, t_iter, i);
                    if (contains_string (t_model, child_iter))
                        return true;//one of iter child contains search string 
                }
            }else{
                return contains_string (t_model, t_iter);
            }
            return false;
        }
        private bool contains_string (Gtk.TreeModel t_model, Gtk.TreeIter t_iter){
            Value item;
            t_model.get_value (t_iter, 2, out item);
            Model.FinishedItem f_item = (Model.FinishedItem) item;
            if (f_item.path.down ().contains (filter_string.down ())){
                return true;
            }
            return false;
        }
        private void setup_list(){
            tree_store.clear ();
            foreach(Arrive.Model.FinishedItem finished_item in Model.aria2.finished_list.list) {
                var item = Gtk.TreeIter ();
                var iter = get_iter_from_date (finished_item.get_date_localized ());
                if(iter == null) { //if the date hasnt been added then add new date item
                    tree_store.prepend (out iter, null);
                    tree_store.set (iter, 0, finished_item.get_date_localized ());
                }
                tree_store.prepend (out item, iter); //adding item in the proper date
                tree_store.set (item, 0, finished_item.filename, 1, format_size (finished_item.total_length), 2, finished_item, -1);
            }
            tree_view.expand_all ();
        }
        public void filter (string filter_string){
            this.filter_string = filter_string;
            tree_filter.refilter ();
            tree_view.expand_all ();
        }
        private void show_popup_menu (Gdk.EventButton event){
            List<Model.FinishedItem> selected_files;
            selected_files=get_selected_files ();
            var menu = new Gtk.Menu ();
            var open_file = new Gtk.MenuItem.with_label (_("Open File"));
            var open_folder = new Gtk.MenuItem.with_label (_("Open Folder"));
            var move_to = new Gtk.MenuItem.with_label (_("Move to.."));
            var copy = new Gtk.MenuItem.with_label (_("Copy"));
            var forget = new Gtk.MenuItem.with_label (_("Forget"));
            var move_to_trash = new Gtk.MenuItem.with_label (_("Move to Trash"));
            var properties = new Gtk.MenuItem.with_label (_("Properties"));
            
            open_file.activate.connect (()=>{
                if (get_selected_files ().length () == 1)
                    get_selected_files ().nth_data (0).open_file ();
            });
            open_folder.activate.connect (()=>{
                if (get_selected_files ().length () == 1)
                    get_selected_files ().nth_data (0).open_folder ();
            });
            move_to.activate.connect (()=>{
                var file_chooser = new Gtk.FileChooserDialog (_("Choose Destination Folder"), App.main_window as Gtk.Window,
                                          Gtk.FileChooserAction.SELECT_FOLDER,
                                          Gtk.Stock.CANCEL, Gtk.ResponseType.CANCEL,
                                          _("Select"), Gtk.ResponseType.ACCEPT);
                if (file_chooser.run () == Gtk.ResponseType.ACCEPT) {
                    var dest = file_chooser.get_filename();
                }
                file_chooser.destroy ();
            });
            copy.activate.connect (()=>{});
            forget.activate.connect (()=>{
                foreach(Model.FinishedItem f_item in get_selected_files ()){
                    Model.aria2.finished_list.forget (f_item);
                }
            });
            move_to_trash.activate.connect (()=>{
                foreach(Model.FinishedItem f_item in get_selected_files ()){
                    Model.aria2.finished_list.trash (f_item);
                }
            });
            properties.activate.connect (()=>{});
            
            if (get_selected_files ().length () == 1) menu.add (open_file);
            if (get_selected_files ().length () == 1) menu.add (open_folder);
            if (get_selected_files ().length () == 1) menu.add (new Gtk.SeparatorMenuItem ());
            
            menu.add (move_to);
            menu.add (copy);
            menu.add (new Gtk.SeparatorMenuItem ());
            menu.add (forget);
            menu.add (move_to_trash);
            
            menu.attach_to_widget (tree_view, null);
            menu.show_all ();
            menu.popup (null, null, null, event.button, event.time);
        }
        private Gtk.TreeIter ? get_iter_from_date (string date){ //search for item with date string
            Gtk.TreeIter ? iter=null;
            Gtk.TreeIter comparator; //used for comparison
            for (bool next = tree_store.get_iter_first (out comparator); next; next = tree_store.iter_next (ref comparator)) {
                Value val1, val2;
                tree_store.get_value (comparator, 0, out val1);
                if(date == (string) val1) { //iter found, breaking
                    iter=comparator;
                    break;
                }
            }
            return iter;
        }
        private List<Model.FinishedItem> get_selected_files(){
            var list = new List<Model.FinishedItem>();
            Gtk.TreeIter selection_iter;
            Gtk.TreeSelection selection = tree_view.get_selection ();
            GLib.List<Gtk.TreePath> d_items = selection.get_selected_rows (null);
            Gtk.TreeModel model = tree_view.get_model ();
            foreach(Gtk.TreePath selection_item in d_items) {
                if (selection_item.get_depth () < 2)
                    continue;
                Value vf_item;
                model.get_iter (out selection_iter, selection_item);
                model.get_value (selection_iter, 2, out vf_item);
                if(vf_item.holds (typeof(Model.FinishedItem))){
                    var f_item = (Model.FinishedItem) vf_item;
                    if (f_item.filename != null)
                        list.append ((Model.FinishedItem) f_item);
                }else
                    debug ("value arent FinishedItem");
            }
            return list;
        }
    }
}
