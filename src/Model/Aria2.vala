using Soup;
using Granite.Services;
namespace Arrive.Model {
    public class Aria2 : Object {
        private static int REFRESH_TIME=1000;
        public int num_active;
        public int num_waiting;
        public int num_stopped;
        public int download_speed;
        public int upload_speed;
        private string aria_ip="http://localhost";
        private string aria_port="6800";
        public string aria_uri;
        public bool is_listened;
        public DownloadList download_list;
        public FinishedList finished_list;
        
        public Aria2 () {
            num_active = 0;
            num_waiting = 0;
            num_stopped = 0;
            download_speed = 0;
            upload_speed = 0;
            //if(ip==null)aria_ip="http://localhost" else aria_ip = ip;
            //if(port==null)aria_port="6800" else aria_port = port;
            aria_uri = aria_ip+":"+aria_port+"/rpc";
            start_aria2c ();
            download_list = new DownloadList ();
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
        private void start_aria2c (){
    //~         var sc = new Granite.Services.SimpleCommand(Environment.get_home_dir(),"aria2c --enable-rpc");
    //~         sc.run();
    //~         message("aria output %s",sc.output_str);
            try {
                //max connection and split size are hardcoded for now
                //TODO:create preferences dialog to set max-connection-per-server and min-split-size (and almost everything)
                GLib.Process.spawn_command_line_async ("aria2c --enable-rpc --max-connection-per-server 5 --min-split-size 1M --pause=true");
                is_listened = true;
            } catch (GLib.SpawnError error)
            {
                critical ("cant start aria2c");
            }
    //~         delay(1000);//FIXME:need to wait for aria to load
		    Thread.usleep (500000);
		    if (get_version() == ""){
			    critical ("cant start or bind port, try to restart");
			    is_listened = false;
			    shutdown ();
		    }
        }
        private void refresh_status () {
            get_global_stat ();
            get_global_option ();
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

            return data;
        }
    }
}
