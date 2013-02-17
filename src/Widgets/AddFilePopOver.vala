public class AddFilePopOver : Granite.Widgets.PopOver{
    private Granite.Widgets.HintedEntry uri_entry;
    public AddFilePopOver(){
        var hbox=new Gtk.Box(Gtk.Orientation.HORIZONTAL,5);
        var grid=new Gtk.Grid();
        grid.set_column_homogeneous(false);
        grid.set_row_homogeneous(true);
        
        grid.attach(new Gtk.Label("uri :"),0,0,1,1);
        uri_entry = new Granite.Widgets.HintedEntry("http://...");
        uri_entry.text="http://";
        grid.attach(uri_entry,1,0,6,1);
        grid.attach(new Gtk.Label("save to :"),0,1,1,1);
        var file_chooser = new Gtk.FileChooserButton("save to",Gtk.FileChooserAction.SELECT_FOLDER);
        grid.attach(file_chooser,1,1,3,1);
        
        Gtk.Button add_button = new Gtk.Button.with_label("add to list");
        add_button.clicked.connect(()=>{
            if(uri_entry.text!="http://"){                
                var v_array = new ValueArray(0);
                v_array.append(uri_entry.text);
                Arrive.App.aria2.add_file(v_array);
            }
            destroy();
        });
        grid.attach(new Gtk.Label("segment :"),4,1,1,1);
        var segment_spin = new Gtk.SpinButton.with_range(1,16,1);
        grid.attach(segment_spin,5,1,1,1);
        grid.attach(add_button,5,2,1,1);
        
        get_content_area().add(grid);
        
        //get_content_area().add(uri_entry);
        

    }
}
