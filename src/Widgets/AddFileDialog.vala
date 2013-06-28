using Granite.Services;
namespace Arrive.Widgets {
    public class AddFileDialog : Granite.Widgets.LightWindow {
        public AddFileDialog (string uri){
            var static_notebook = new Granite.Widgets.StaticNotebook (false);
            this.window_position=Gtk.WindowPosition.CENTER;
            var grid1=new Gtk.Grid ();
            grid1.set_column_homogeneous (false);
            grid1.set_row_homogeneous (true);

            //~         http://majalah.detik.com/cb/90014839209b829c310ce94f6d34afff/2013/20130211_MajalahDetik_63.pdf
            grid1.attach (new Gtk.Label (_("Uri :")), 0, 0, 1, 1);
            var uri_entry1 = new Granite.Widgets.HintedEntry ("");
            if (uri == "") {
                Gtk.Clipboard.get (Gdk.SELECTION_CLIPBOARD).request_text ((clipboard, cbtext)=>{
                                                                              //TODO:must verify that text are valid URI
                                                                              if (cbtext != null && true) {
                                                                                  string text=cbtext.strip ();
                                                                                  uri_entry1.text = text;

                                                                              }else
                                                                                  uri_entry1.text = "http://";
                                                                          }
                                                                          );
            }else
                uri_entry1.text=uri;

            grid1.attach (uri_entry1, 1, 0, 6, 1);
            grid1.attach (new Gtk.Label (_("Save to :")), 0, 1, 1, 1);
            var file_chooser1 = new Gtk.FileChooserButton (_("Save to"),
                                                           Gtk.FileChooserAction.SELECT_FOLDER);
            grid1.attach (file_chooser1, 1, 1, 3, 1);

            grid1.attach (new Gtk.Label (_("Segment :")), 4, 1, 1, 1);
            var segment_spin1 = new Gtk.SpinButton.with_range (1, 16, 1);
            grid1.attach (segment_spin1, 5, 1, 1, 1);

            var add_button1 = new Gtk.Button.with_label (_("Queue and start"));
            add_button1.clicked.connect (()=>{
                                             if (uri_entry1.text != "http://") {
                                                 var aria_http = new Model.AriaHttp.with_attribute (uri_entry1.text, 
                                                                        file_chooser1.get_uris().nth_data(0).replace("file://", "") , 
                                                                        segment_spin1.get_value_as_int ());
                                                 aria_http.start ();
                                                 Model.aria2.download_list.add_file(aria_http);
                                             }
                                             this.destroy ();
                                         });
            grid1.attach (add_button1, 5, 2, 1, 1);
            grid1.margin=12;
            grid1.margin_top = 0;

            static_notebook.append_page (grid1, new Gtk.Label (_("http/ftp")));
            static_notebook.append_page (new Gtk.Label ("torrent"), new Gtk.Label (_("torrent")));
            static_notebook.append_page (new Gtk.Label ("metalink"), new Gtk.Label (_("metalink")));
            this.add (static_notebook);

        }
    }
}
