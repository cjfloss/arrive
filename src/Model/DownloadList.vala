namespace Arrive.Model {
    public class DownloadList : Object {
        private static int REFRESH_TIME=1000;
        public List <DownloadItem> _list;
        private File save_file = File.new_for_path (Environment.get_user_data_dir ()+"/arrive/download_list.xml");
        private uint prev_list_lenght; //used to determine list change;
        private bool is_populate_needed;
        public uint length {
            get{
                if(_list != null)
                    return _list.length ();
                else return 0;
            }
            private set{}
        }
        public DownloadList (){
            _list = new List<DownloadItem>();
            //~         add_file.connect((object,download_item)=>{
            //~            // _list.append(download_item);
            //~             list_changed();
            //~         });
            is_populate_needed=true;
            var refresh_timer = new TimeoutSource (REFRESH_TIME);
            refresh_timer.set_callback (()=>{
                                            if(is_populate_needed) {
                                                populate_list ();
                                                is_populate_needed=false;
                                            }else
                                                refresh_list ();
                                            save_list_to_file ();
                                            return true;
                                        });
            refresh_timer.attach (null);
            list_changed.connect (()=>{
                                      //~             save_list_to_file();
                                  });
            debug ("DownloadList created");
            load_list_from_file ();
        }
        public bool is_downloading (){
            foreach (DownloadItem di in _list)
                if (di.status == "active")
                    return true;
            return false;
        }
        private DownloadItem get_download_item(string gid){
            foreach(DownloadItem di in _list)
                if(di.gid == gid) return di;
            return null;
        }
        private DownloadItem get_download_item_from_value(Value va){
            HashTable<string, Value ?> ht;
            Value val;

            ht = (HashTable<string, Value ?>)va;
            val=ht.get ("gid");
            return get_download_item (val.get_string ());
        }
        private void populate_list(){
            //clearing all _list content
            while(length > 0) {
                _list.remove (_list.nth_data (0));
            }
            refresh_active (true);
            refresh_waiting (true);
            refresh_stopped (true);
            list_changed ();
            debug ("populating  download_list, lenght %u", length);
        }
        private void refresh_list(){
            refresh_active ();
            refresh_waiting ();
            refresh_stopped ();
            clean_finished ();

        }
        private void clean_finished(){
            foreach(DownloadItem di in _list)
                if(di.status == "complete"||di.status == "removed") {
                    //new Notify.Notification(di.filename,"completed",null).show();
                    Arrive.App.aria2.finished_list.append (di);
                    di.remove_download_result ();
                    populate_list ();
                }
        }
        private void refresh_active(bool add_new_to_list=false){
            Soup.Message msg = Soup.XMLRPC.request_new (Arrive.App.aria2.aria_uri
                                                        , "aria2.tellActive");
            string data = send_message (msg);
            //~         debug(data);
            put_data_to_list (data, add_new_to_list);
        }
        private void refresh_waiting(bool add_new_to_list=false){
            Soup.Message msg = Soup.XMLRPC.request_new (Arrive.App.aria2.aria_uri
                                                        , "aria2.tellWaiting"
                                                        , typeof(int), 0,
                                                        typeof(int), 1000);
            string data = send_message (msg);
            //~         debug(data);
            put_data_to_list (data, add_new_to_list);
        }
        private void refresh_stopped(bool add_new_to_list=false){
            Soup.Message msg = Soup.XMLRPC.request_new (Arrive.App.aria2.aria_uri
                                                        , "aria2.tellStopped"
                                                        , typeof(int), 0
                                                        , typeof(int), 1000);
            string data = send_message (msg);
            put_data_to_list (data, add_new_to_list);
        }
        private void put_data_to_list(string data, bool add_new_to_list){
            try {
                Value v;
                if(Soup.XMLRPC.parse_method_response (data, -1, out v) && v.holds (typeof(ValueArray))) {
                    unowned ValueArray va;
                    va =(ValueArray) v;
                    foreach(Value viter in va) {
                        HashTable<string, Value ?> ht;
                        if(viter.holds (typeof(HashTable))) {
                            if(add_new_to_list) {
                                var diptr = new DownloadItem ();
                                diptr.xml_value=viter;
                                _list.append (diptr);
                            }else{
                                var diptr = get_download_item_from_value (viter);
                                if(diptr != null) diptr.xml_value=viter; else is_populate_needed=true;
                            }
                        }

                    }
                }

            } catch (Error e){
                debug ("error parsing method response");
            }
        }
        private string send_message(Soup.Message msg) {
            var session = new Soup.SessionSync ();
            session.send_message (msg);
            string data = (string) msg.response_body.flatten ().data;
            return data;
        }
        private void save_list_to_file(){
            //create ValueArray of all DownloadItem in list
            ValueArray va= new ValueArray (0);
            foreach(DownloadItem di in _list)
                va.append (di.xml_value);
            //create xml string of valuearray
            string data = Soup.XMLRPC.build_method_response (va);
            //save xmlstring
            if(!save_file.get_parent ().query_exists ())
                save_file.get_parent ().make_directory_with_parents ();

            if(save_file.query_exists ())
                save_file.delete ();

            try {
                {
                    var file_stream = save_file.create (FileCreateFlags.NONE);
                    var data_stream = new DataOutputStream (file_stream);
                    data_stream.put_string (data);
                }
            } catch (Error e){
                error ("cant save downloadlist ; %s", e.message);
            }


        }
        private void load_list_from_file(){
            if(save_file.query_exists ()) {
                try {
                    var data_stream = new DataInputStream (save_file.read ());
                    string data = data_stream.read_until ("", null);
                    put_data_to_list (data, true);

                } catch (Error e){
                    error ("cant load downloadlist: %s", e.message);
                }
            }else
                message ("can't find downloadlist ");
            //~         ValueArray v_array = new ValueArray(0);
            //~         v_array.append("http://google.com");
            //~         Soup.Message msg = Soup.XMLRPC.request_new("http://localhost:6800/rpc","aria2.addUri",typeof(ValueArray),v_array);
            foreach(DownloadItem ditem in _list) {
                ValueArray v_array = ditem.uris.copy ();
                var option = new HashTable<string, Value ?>(str_hash, str_equal);
                option.insert ("dir", ditem.dir);
                //FIXME:the xml always save connections to 0 and caused aria2c unable to parse
                //option.insert("split",ditem.connections.to_string());
                if(ditem.status == "active") option.insert ("pause", "false"); else option.insert ("pause", "true"); Soup.Message msg = Soup.XMLRPC.request_new ("http://localhost:6800/rpc", "aria2.addUri",
                                                                                                                                                                 typeof(ValueArray), v_array,
                                                                                                                                                                 typeof(HashTable), option);
                string data = send_message (msg);
                debug ("ditem.data %s", data);
            }
            list_changed ();
        }
        public signal void add_file(DownloadItem download_item);    //signall to broadcast when adding file
        public signal void remove_file();   //signal to broadcast when removing file
        public signal void list_changed();
    }
}
