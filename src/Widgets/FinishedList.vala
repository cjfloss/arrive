public class Arrive.Widgets.FinishedList : Object {
	public Gtk.ScrolledWindow widget;
	private Gtk.TreeView tree_view;
	private Gtk.TreeStore tree_store;
    public FinishedList () {
		tree_store = new Gtk.TreeStore(2,typeof(string),typeof(string));
		tree_view = new Gtk.TreeView();
		tree_view.set_model(tree_store);
		tree_view.set_headers_visible(false);
		
		tree_view.insert_column_with_attributes(-1,_("filename"), new Gtk.CellRendererText(),"text",0,null);
		tree_view.insert_column_with_attributes(-1,_("size"), new Gtk.CellRendererText(),"text",1,null);
		setup_list();
		widget = new Gtk.ScrolledWindow(null,null);
		widget.add(tree_view);
		Arrive.App.aria2.finished_list.list_changed.connect(setup_list);
		tree_view.button_release_event.connect((event)=>{
			switch (event.button){
				case 5:
					debug("5");
					break;
			}
			return false;
		});
    }
    private void setup_list(){
		tree_store.clear();
		foreach(Arrive.Model.FinishedItem finished_item in Arrive.App.aria2.finished_list.list){
			var item = new Gtk.TreeIter();
			var iter = get_iter_from_date(finished_item.get_date_localized());
			if(iter==null){//if the date hasnt been added then add new date item 
				tree_store.prepend(out iter,null);
				tree_store.set(iter,0,finished_item.get_date_localized());
			}
			tree_store.prepend(out item,iter);//adding item in the proper date
			tree_store.set(item,0,finished_item.filename,1,format_size(finished_item.total_length),-1);
		}
		tree_view.expand_all();
	}
	private Gtk.TreeIter? get_iter_from_date(string date){//search for item with date string
		Gtk.TreeIter? iter=null;
		Gtk.TreeIter comparator;//used for comparison
		for (bool next = tree_store.get_iter_first (out comparator); next; next = tree_store.iter_next (ref comparator)) {
			Value val1, val2;
			tree_store.get_value (comparator, 0, out val1);
			if(date==(string)val1){//iter found, breaking
				iter=comparator;
				break;
			}
			
		}
		return iter;
	}
}
