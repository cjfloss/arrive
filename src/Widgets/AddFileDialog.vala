using Granite.Services;
namespace Arrive.Widgets {
    public class AddFileDialog : Granite.Widgets.LightWindow {
        public AddFileDialog (string uri){
            var static_notebook = new Granite.Widgets.StaticNotebook (false);
            this.window_position=Gtk.WindowPosition.CENTER;
            
            static_notebook.append_page (create_page_1 (uri), new Gtk.Label (_("http/ftp")));
            static_notebook.append_page (create_page_2 (uri), new Gtk.Label (_("magnet")));
            static_notebook.append_page (create_page_3 (uri), new Gtk.Label (_("torrent")));
            this.add (static_notebook);

        }
        private Gtk.Widget create_page_1 (string uri){
            var grid1=new Gtk.Grid ();
            grid1.set_column_homogeneous (false);
            grid1.set_row_homogeneous (true);

            grid1.attach (new Gtk.Label (_("Uri :")), 0, 0, 1, 1);
            var uri_entry1 = new Granite.Widgets.HintedEntry ("");
            if (uri == "") {
                Gtk.Clipboard.get (Gdk.SELECTION_CLIPBOARD).request_text ((clipboard, cbtext)=>{
                                                                              uri_entry1.text = valid_http (cbtext)??"http://";
                                                                          });
            }else
                uri_entry1.text=valid_http (uri)??"http://";

            grid1.attach (uri_entry1, 1, 0, 6, 1);
            grid1.attach (new Gtk.Label (_("Save to :")), 0, 1, 1, 1);
            var file_chooser1 = new Gtk.FileChooserButton (_("Save to"),
                                                           Gtk.FileChooserAction.SELECT_FOLDER);
            grid1.attach (file_chooser1, 1, 1, 3, 1);

            grid1.attach (new Gtk.Label (_("Segment :")), 4, 1, 1, 1);
            var segment_spin1 = new Gtk.SpinButton.with_range (1, 16, 1);
            segment_spin1.set_value ((double) App.instance.settings.default_segment_num);
            grid1.attach (segment_spin1, 5, 1, 1, 1);

            var add_button1 = new Gtk.Button.with_label (_("Queue and start"));
            add_button1.clicked.connect (()=>{
                                             if (uri_entry1.text != "http://") {
                                                 var aria_http = new Model.AriaHttp.with_attribute (uri_entry1.text, 
                                                                        file_chooser1.get_uris().nth_data(0).replace("file://", "") , 
                                                                        segment_spin1.get_value_as_int ());
                                                 aria_http.start ();
                                                 App.instance.download_list.add_file(aria_http);
                                             }
                                             this.destroy ();
                                         });
            grid1.attach (add_button1, 5, 2, 1, 1);
            grid1.margin=12;
            grid1.margin_top = 0;
            
            return grid1;
        }
        private Gtk.Widget create_page_2 (string magnet){
            var grid=new Gtk.Grid ();
            grid.set_column_homogeneous (false);
            grid.set_row_homogeneous (true);

            grid.attach (new Gtk.Label (_("Magnet Link :")), 0, 0, 1, 1);
            var uri_entry1 = new Granite.Widgets.HintedEntry ("");
            if (magnet == "") {
                Gtk.Clipboard.get (Gdk.SELECTION_CLIPBOARD).request_text ((clipboard, cbtext)=>{
                    uri_entry1.text = valid_magnet (cbtext)??"magnet:";
                                                                          });
            }else
                uri_entry1.text =  valid_magnet (magnet)??"magnet:";

            grid.attach (uri_entry1, 1, 0, 2, 1);
            grid.attach (new Gtk.Label (_("Save to :")), 0, 1, 1, 1);
            var file_chooser1 = new Gtk.FileChooserButton (_("Save to"),
                                                           Gtk.FileChooserAction.SELECT_FOLDER);
            grid.attach (file_chooser1, 1, 1, 2, 1);

            var add_button1 = new Gtk.Button.with_label (_("Queue and start"));
            add_button1.clicked.connect (()=>{
                                             if (is_valid_magnet(uri_entry1.text)) {
                                                 var aria_magnet = new Model.AriaMagnet.with_attribute (uri_entry1.text, 
                                                                        file_chooser1.get_uris().nth_data(0).replace("file://", "") 
                                                                        );
                                                 aria_magnet.start ();
                                                 App.instance.download_list.add_file(aria_magnet);
                                             }
                                             this.destroy ();
                                         });
            grid.attach (add_button1, 2, 2, 1, 1);
            grid.margin=12;
            grid.margin_top = 0;
            
            return grid;
        }
        private Gtk.Widget create_page_3 (string uri){
            var grid = new Gtk.Grid ();
            grid.set_column_homogeneous (false);
            grid.set_row_homogeneous (false);
            grid.margin = 12;
            grid.margin_top = 0;
            
            grid.attach (new Gtk.Label (_("Torrent file :")), 0, 0, 1, 1);
            var file_chooser = new Gtk.FileChooserButton (_("Select .torrent file"),
                                                           Gtk.FileChooserAction.OPEN);
            var filter = new Gtk.FileFilter ();
            filter.add_mime_type ("application/x-bittorrent");
            file_chooser.set_filter (filter);
            grid.attach (file_chooser, 1, 0, 5, 1);
            
            var add_button = new Gtk.Button.with_label (_("Queue and start"));
            add_button.clicked.connect (()=>{
                                            Model.aria2.add_torrent (file_chooser.get_uris ().nth_data(0).replace ("file://",""));
                                            message (file_chooser.get_uris ().nth_data(0));
                                            this.destroy ();
                                         });
            grid.attach (add_button, 1, 1, 1, 1);
            
            //return grid;
            return new Gtk.Label("torrent file");
        }
        private bool is_valid_http (string? uri){
            return valid_http (uri)!=null;
        }
        private string? valid_http (string? uri){
            string valid = null;
            if (uri!=null&&uri.has_prefix ("http://")||uri.has_prefix ("ftp://")){
                valid = uri.down ();
                valid = valid.split (" ")[0];
            }
            return valid;
        }
        private bool is_valid_magnet (string uri){
            return valid_magnet (uri)!=null;
        }
        private string? valid_magnet (string? uri){
            string valid = null;
            if (uri!=null&&uri.has_prefix ("magnet")){
                valid = uri.down ();
                valid = valid.split (" ")[0];
            }
            return valid;
        }
    }
}
