namespace Arrive.Widgets {
    public class DownloadingList : Gtk.Stack {
        private static int REFRESH_TIME=1000;
        public Gtk.ScrolledWindow widget;
        private Gtk.ScrolledWindow scrolled;
        private Gtk.ListStore list_store;
        private Gtk.TreeView tree_view;
        private Gtk.TreeModelFilter tree_filter;
        private string filter_string;
        private Model.DownloadList download_list;

        public DownloadingList (Model.DownloadList download_list) {
            this.download_list = download_list;
            filter_string = "";

            list_store = new Gtk.ListStore (1, typeof (Arrive.Model.IDownloadItem));
            tree_filter = new Gtk.TreeModelFilter (list_store, null);
            tree_filter.set_visible_func (visible_func);
            tree_view = new Gtk.TreeView.with_model (tree_filter);
            tree_view.set_headers_visible (false);
            tree_view.get_selection ().set_mode (Gtk.SelectionMode.MULTIPLE);
            scrolled = new Gtk.ScrolledWindow (null, null);
            scrolled.add (tree_view);
            add_named (scrolled, "scrolled");

            var welcome = new Granite.Widgets.Welcome (_("No Download Yet"), _("But you can add it"));
            welcome.append ("list-add", _("Add Download"), _("Any http, ftp, magnet link or torrent file"));
            welcome.activated.connect ((index) => {
                switch (index) {
                    case 0:
                        var add_file_dialog = new AddFileDialog ("");
                        add_file_dialog.show_all ();
                        break;

                }
            });
            add_named (welcome, "welcome");

            add_named (new Granite.Widgets.Welcome ("", _("Search Not Found")), "not found");

            tree_view.button_release_event.connect ((event) => {
                                                      if (event.button == 3)
                                                          show_popup_menu (event);
                                                      return false;
                                                  });

            download_list.file_added.connect (() => {
                 populate_list_store ();
                 filter (filter_string);
             });
            download_list.file_removed.connect (() => {
                 populate_list_store ();
                 filter (filter_string);
             });

            var cell_renderer = new DownloadCellRenderer ();
            tree_view.insert_column_with_attributes (-1, "column", cell_renderer, "file", 0);

            var refresh_timer = new TimeoutSource (REFRESH_TIME);
            refresh_timer.set_callback (() => {
                tree_view.queue_draw ();
                return true;
            });
            refresh_timer.attach (null);

            populate_list_store ();
            debug ("DownloadingList created");
        }
        private void populate_list_store () {
            list_store.clear ();
            debug ("list lenght %u", download_list.files.length ());
            foreach (Arrive.Model.IDownloadItem file in download_list.files) {
                Gtk.TreeIter iter;
                list_store.append (out iter);
                list_store.set (iter, 0, file);
            }
        }
        private void show_popup_menu (Gdk.EventButton event) {
            List<Arrive.Model.IDownloadItem> selected_files;
            selected_files = get_selected_files ();
            var menu = new Gtk.Menu ();
            var start = new Gtk.MenuItem.with_label (_("Continue"));
            var pause = new Gtk.MenuItem.with_label (_("Pause"));
            var remove = new Gtk.MenuItem.with_label (_("Remove"));
            var properties = new Gtk.MenuItem.with_label (_("Properties"));
            //TODO:implement right click event
            start.activate.connect (() => {
                foreach (Arrive.Model.IDownloadItem d_item in selected_files) {
                    if (d_item.status == "paused") d_item.unpause ();
                    if (d_item.status == "") d_item.start ();
                    if (d_item.status == "stopped") d_item.start ();
                }
            });
            pause.activate.connect (() => {
                foreach (Arrive.Model.IDownloadItem d_item in selected_files)
                    d_item.pause ();
            });
            remove.activate.connect (() => {
                string text;
                if (selected_files.length () ==1) {
                    text =
                        _("Are You sure you want to delete %s ?").printf (selected_files.nth_data (0).filename);
                } else {
                    text =
                        _("Are You sure you want to delete %d downloads?").printf ((int)selected_files.length ());
                }
                Gtk.MessageDialog msg = new Gtk.MessageDialog (App.instance.main_window,
                                                            Gtk.DialogFlags.MODAL,
                                                            Gtk.MessageType.WARNING,
                                                            Gtk.ButtonsType.YES_NO,
                                                            text);
                msg.set_title (_("Delete Download"));
                msg.response.connect ((response_id) => {
                     if (response_id == Gtk.ResponseType.YES) {
                         foreach (Arrive.Model.IDownloadItem d_item in selected_files)
                             download_list.remove_file (d_item);
                     }
                     msg.destroy ();
                });
                msg.show ();
             });
            //~         properties.connect();

            if (allow_start (selected_files)) menu.add (start);
            if (allow_pause (selected_files)) menu.add (pause);
            menu.add (new Gtk.SeparatorMenuItem ());
            if (allow_remove (selected_files)) menu.add (remove);
            //if(allow_properties (selected_files)) menu.add (properties);

            menu.attach_to_widget (tree_view, null);
            menu.show_all ();
            menu.popup (null, null, null, event.button, event.time);
        }
        private bool allow_start(List<Arrive.Model.IDownloadItem> selected_files) {
            bool allow = false;
            foreach (Arrive.Model.IDownloadItem d_item in selected_files) {
                if (d_item.status != "active")
                    allow = true;
            }
            return allow;
        }
        private bool allow_pause(List<Arrive.Model.IDownloadItem> selected_files) {
            bool allow = false;
            foreach (Arrive.Model.IDownloadItem d_item in selected_files)
                if (d_item.status == "active") allow = true;
            return allow;
        }
        private bool allow_remove(List<Arrive.Model.IDownloadItem> selected_files) {
            return true;
        }
        private bool allow_properties(List<Arrive.Model.IDownloadItem> selected_files) {
            return true;
        }
        private List<Arrive.Model.IDownloadItem> get_selected_files() {
            var list = new List<Model.IDownloadItem>();
            Gtk.TreeIter selection_iter;
            Gtk.TreeSelection selection=tree_view.get_selection ();
            GLib.List<Gtk.TreePath> d_items = selection.get_selected_rows (null);
            Gtk.TreeModel model = tree_view.get_model ();
            foreach (Gtk.TreePath selection_item in d_items) {
                Value d_item;
                model.get_iter (out selection_iter, selection_item);
                model.get_value (selection_iter, 0, out d_item);
                if (d_item.holds (typeof (Model.IDownloadItem)))
                    list.append ((Model.IDownloadItem) d_item);
                else
                    debug ("value arent download item");
            }
            return list;
        }
                //filetering using search bar
        private bool visible_func (Gtk.TreeModel t_model, Gtk.TreeIter t_iter) {
            if (filter_string == "" || filter_string == null)
                return true;
            if (t_model.iter_has_child (t_iter)) {//check if its date iter
                for (int i=0; i<t_model.iter_n_children (t_iter); i++) {
                    Gtk.TreeIter child_iter;
                    t_model.iter_nth_child (out child_iter, t_iter, i);
                    if (contains_string (t_model, child_iter))
                        return true;//one of iter child contains search string 
                }
            } else {
                return contains_string (t_model, t_iter);
            }
            return false;
        }
        public void filter (string filter_string) {
            this.filter_string = filter_string;
            tree_filter.refilter ();
            var row_length = length ();
            //simple logic for showing welcome screen and search not found
            if (row_length == 0) {
                if (this.filter_string == "")
                    this.set_visible_child_name ("welcome");
                else
                    this.set_visible_child_name ("not found");
            } else
               this.set_visible_child_name ("scrolled");
        }
        private int length () {
            int length = 0;
            Gtk.TreeIter iter;
            for (bool next = tree_filter.get_iter_first (out iter); next; next = tree_filter.iter_next (ref iter)) {
                length++;
            }
            return length;
        }
        private bool contains_string (Gtk.TreeModel t_model, Gtk.TreeIter t_iter) {
            Value item;
            t_model.get_value (t_iter, 0, out item);
            Model.IDownloadItem d_item = (Model.IDownloadItem) item;
            if (d_item.filename.down ().contains (filter_string.down ())) {
                return true;
            }
            return false;
        }
    }
}
