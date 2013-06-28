using Soup;
using Granite.Services;
namespace Arrive.Model {
    public static Aria2 aria2;
    public class Aria2 : Object {
        private static int REFRESH_TIME = 1000;
        public int num_active;
        public int num_waiting;
        public int num_stopped;
        public int download_speed;
        public int upload_speed;
        private string aria_ip = "http://localhost";
        private string aria_port = "6800";
        public string aria_uri;
        public bool is_listened;
        public DownloadList download_list;
        public FinishedList finished_list;
        
        public Aria2 (IDownloadList d_list) {
            num_active = 0;
            num_waiting = 0;
            num_stopped = 0;
            download_speed = 0;
            upload_speed = 0;
            //if(ip==null)aria_ip="http://localhost" else aria_ip = ip;
            //if(port==null)aria_port="6800" else aria_port = port;
            aria_uri = aria_ip+":"+aria_port+"/rpc";
            start_aria2c ();
            download_list = d_list as DownloadList;
            finished_list = new FinishedList ();
            get_global_option ();
            
            var refresh_timer = new TimeoutSource (REFRESH_TIME);
            refresh_timer.set_callback (()=>{
                refresh_status ();
                return true;
            });
            refresh_timer.attach (null);
            message ("version = %s",get_version());
        }
        ~Aria2 (){
            shutdown ();
        }
        public string add_uri (string uris, string dir, int split, bool pause = false){
            var v_array = new ValueArray (0);
            v_array.append (uris);

            var option = new HashTable<string, Value ?>(str_hash, str_equal);
            option.insert ("dir", dir);
            if (split < 1)
                split = 1;
            option.insert ("split", split.to_string ());
            option.insert ("pause", pause.to_string ());

            Soup.Message msg = Soup.XMLRPC.request_new (Model.aria2.aria_uri,
                                                         "aria2.addUri",
                                                         typeof(ValueArray), v_array,
                                                         typeof(HashTable), option
                                                         );
            var data = send_message (msg);
            try {
                Value v;
                if (Soup.XMLRPC.parse_method_response (data,-1,out v)){
                    return v.get_string();//return gid
                }else{
                    debug ("error while add_uri2");
                }
            }catch(Error e){
                error ("error while add_uri "+e.message);
            }
            return "";
        }
        private void start_aria2c (){
            try {
                //max connection and split size are hardcoded for now
                //TODO:create preferences dialog to set max-connection-per-server and min-split-size (and almost everything)
                GLib.Process.spawn_command_line_async ("aria2c --enable-rpc --max-connection-per-server 16 --min-split-size 1M --pause=true");
                is_listened = true;
            } catch (GLib.SpawnError error)
            {
                critical ("cant start aria2c");
            }
            //need to wait for aria to load
            Thread.usleep (500000);
            if (get_version() == ""){
                critical ("cant start or bind port, try to restart");
                is_listened = false;
                shutdown ();
            }
        }
        public void pause(string gid){
            Soup.Message msg = XMLRPC.request_new (aria2.aria_uri, "aria2.pause",
                                                   typeof(string), gid);
            send_message (msg);
        }
        public void unpause(string gid){
            Soup.Message msg = XMLRPC.request_new (aria2.aria_uri, "aria2.unpause",
                                                   typeof(string), gid);
            send_message (msg);
        }
        public void remove(string gid){
            Soup.Message msg = XMLRPC.request_new (aria2.aria_uri, "aria2.remove",
                                                   typeof(string), gid);
            send_message (msg);
        }
        private void refresh_status () {
            refresh_active ();
            refresh_waiting ();
            refresh_stopped ();
            
            clean_finished ();
            download_list.item_refreshed ();
        }
        private void refresh_active(bool add_new_to_list=false){
            Soup.Message msg = Soup.XMLRPC.request_new (aria2.aria_uri
                                                        , "aria2.tellActive");
            string data = send_message (msg);
            put_data_to_list (data);
        }
        private void refresh_waiting(bool add_new_to_list=false){
            Soup.Message msg = Soup.XMLRPC.request_new (aria2.aria_uri
                                                        , "aria2.tellWaiting"
                                                        , typeof(int), 0,
                                                        typeof(int), 1000);
            string data = send_message (msg);
            put_data_to_list (data);
        }
        private void refresh_stopped(bool add_new_to_list=false){
            Soup.Message msg = Soup.XMLRPC.request_new (aria2.aria_uri
                                                        , "aria2.tellStopped"
                                                        , typeof(int), 0
                                                        , typeof(int), 1000);
            string data = send_message (msg);
            put_data_to_list (data);
        }
        private void put_data_to_list(string data){
            try {
                Value v;
                if(Soup.XMLRPC.parse_method_response (data, -1, out v) && v.holds (typeof(ValueArray))) {
                    unowned ValueArray va;
                    va =(ValueArray) v;
                    foreach(Value viter in va) {
                        if(viter.holds (typeof(HashTable))) {//viter will hold download list xml
                            HashTable<string, Value?> ht;
                            Value val;
                            
                            ht = (HashTable<string, Value ?>) viter;
                            val = ht.get ("gid");
                            var gid = val.get_string ();
                            
                            var d_item = aria2.download_list.get_by_gid (gid);
                            if ( d_item == null){
                                //TODO:viter that arent exist in download_list should be added to download_list
                            }else{
                                //just update the content
                                if (d_item is AriaHttp)
                                    (d_item as AriaHttp).update_by_ht (ht);
                            }
                        }
                    }
                }
            } catch (Error e){
                debug ("error parsing method response");
            }
        }
        private void clean_finished (){
            List<IDownloadItem> finished_items = aria2.download_list.get_by_status ("complete");
            foreach (IDownloadItem finished_item in finished_items){
                new Notify.Notification (finished_item.filename,"Download completed", App.instance.app_icon).show ();
                finished_list.append (finished_item);
                aria2.download_list.remove (finished_item);
            }
        }
        //TODO:Parse getGlobalOption response
        private void get_global_option () {
            Soup.Message msg = XMLRPC.request_new (aria_uri, "aria2.getGlobalOption");
            string data = send_message (msg);
        }
        private void get_global_stat () {
            Soup.Message msg = XMLRPC.request_new (aria_uri, "aria2.getGlobalStat");
            string data = send_message (msg);
            try {
                Value v;
                if (Soup.XMLRPC.parse_method_response (data, -1, out v)) {
                    HashTable<string,Value?> ht;
                    Value val;
                    
                    ht = (HashTable<string,Value?>) v;
                    
                    val = ht.get ("numStopped");
                    num_stopped = int.parse (val.get_string ());
                    
                    val = ht.get ("numWaiting");
                    num_waiting = int.parse (val.get_string ());
                    
                    val = ht.get ("numActive");
                    num_active = int.parse (val.get_string ());
                    
                    val = ht.get ("downloadSpeed");
                    download_speed = int.parse (val.get_string ());
                    
                    val = ht.get ("uploadSpeed");
                    upload_speed = int.parse (val.get_string ());
                }
            } catch (Error e) {
                debug ("Error while processing tellStatus response");
            }
        }
        private string get_version () {
            string version = "";
            Soup.Message msg = XMLRPC.request_new (aria_uri,"aria2.getVersion");
            string data = send_message (msg);
            try{
                Value v;
                if (Soup.XMLRPC.parse_method_response (data,-1,out v)){
                    HashTable<string,Value?> ht;
                    Value val;
                    
                    ht = (HashTable<string,Value?>) v;
                    
                    val = ht.get("version");
                    version = val.get_string();
                }
            }catch (Error e){
                debug ("Error while processing getVersion response");
            }
            return version;
        }
        public void shutdown () {
            Soup.Message msg = XMLRPC.request_new (aria_uri,"aria2.shutdown");
            send_message (msg);
        }
        private void force_shutdown() {
            Soup.Message msg = XMLRPC.request_new (aria_uri,"aria2.forceShutdown");
            send_message (msg);
        }
        //TODO:using system.multicall to call more than one method at once
        private void system_multicall () {
        }
        private string send_message (Soup.Message message) {
            var session = new SessionSync ();
            session.send_message (message);

            string data = (string) message.response_body.flatten ().data;
            if (data == null) debug ("send_message return null");
            return data;
        }
    }
}
