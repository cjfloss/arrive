public class Arrive.Widgets.DownloadingList : Object {
    public Gtk.ScrolledWindow widget;
    public DownloadingList () {
        Gtk.ListStore list_store = new Gtk.ListStore (1, typeof(string));
        Gtk.TreeIter iter;
        Gtk.TreeView tree_view = new Gtk.TreeView.with_model (list_store);
        tree_view.set_headers_visible (false);
        widget = new Gtk.ScrolledWindow(null, null);
        widget.add(tree_view);

        list_store.append (out iter);
        list_store.set (iter, 0, "appan yah");
        list_store.append (out iter);
        list_store.set (iter, 0, "appan yah2");


        var cell_renderer = new Arrive.Widgets.DownloadingCellRenderer ();
        tree_view.insert_column_with_attributes (-1, "column", cell_renderer, "text", 0);
    }

}
