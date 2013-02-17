using Soup;
using Granite.Services;
public class Arrive.Model.Aria2 : Object {
    private static int REFRESH_TIME=1000;
    public int num_active {
        get;
        set;
    default=0;
    }
    public int num_waiting {
        get;
        set;
    default=0;
    }
    public int num_stopped {
        get;
        set;
    default=0;
    }
    public int download_speed {
        get;
        set;
    default=0;
    }
    public int upload_speed {
        get;
        set;
    default=0;
    }
    public Arrive.Model.DownloadList download_list;
    public string version="";
    private string aria_ip="http://localhost";
    private string aria_port="6800";
    public string aria_uri="";
    public Aria2() {
        //if(ip==null)aria_ip="http://localhost" else aria_ip = ip;
        //if(port==null)aria_port="6800" else aria_port = port;
        aria_uri = aria_ip+":"+aria_port+"/rpc";
        start_aria2c();
//~         var d_item=new IDownloadItem();
//~         d_item.uris.append("http://example.com");
//~         var v_array = new ValueArray(0);
//~         v_array.append("http://google.com");
//~         add_file(v_array);
        download_list=new DownloadList();
        get_global_option();
        
        var refresh_timer = new TimeoutSource(REFRESH_TIME);
        refresh_timer.set_callback(()=>{
            refresh_status();
            return true;
        });
        refresh_timer.attach(null);
        
    }
    ~Aria2(){
        shutdown();
    }
    private void start_aria2c() {
//~         var sc = new Granite.Services.SimpleCommand(Environment.get_home_dir(),"aria2c --enable-rpc");
//~         sc.run();
//~         message("aria output %s",sc.output_str);
        try{
            GLib.Process.spawn_command_line_async ("aria2c --enable-rpc");
        }catch(GLib.SpawnError error)
        {
            message("cant start aria2c");
            
        }
    }
//~     public void add_file(ValueArray uris) {
//~         DownloadItem d_item = new DownloadItem();
//~         d_item.gid = add_uri(uris);
//~         message("uri added");
//~         download_list.add_file((DownloadItem) d_item);
//~     }
    public void add_uri(ValueArray uris, HashTable<string,Value?> option) {
//~         DownloadItem d_item = new DownloadItem();
//~         var option = new HashTable<string,Value?>(str_hash,str_equal);
//~         option.insert("dir","/home/vikoadi");
        
//~         Soup.Message msg = XMLRPC.request_new(aria_uri,"aria2.addUri",typeof(ValueArray),uris,typeof(HashTable),option);
//~         string data = send_message (msg);
//~         stdout.printf(data);
//~         try {
//~             Value v = Value(typeof(string));
//~             if(XMLRPC.parse_method_response(data, -1, out v)) {
//~                 string gid;
//~                 if(v.holds(typeof(string))){
//~                     gid = v.get_string();
//~                     Granite.Services.Logger.notification("added gid = %s \n".printf(gid));
//~                     d_item.gid=gid;
//~                     download_list.add_file(d_item);
//~                 }
//~             }else{
//~                 message("cant pares_method_response");
//~             }
//~         } catch(Error e) {
//~             message("Error while processing addUri response");
//~         }
//~         message("cant adduri");
    }
    public void remove_file(string GID) {
    }
    private void refresh_status() {
        get_global_stat();
        get_global_option();
    }
    public int get_percent_completed(){
        return 0;
    }
    public string get_time_remaining(){
        return "don't know";
    }

    private void tell_active() {
    }
    private void tell_waiting() {
    }
    private void tell_stopped() {
    }
    //TODO:Parse getGlobalOption response
    private void get_global_option() {
        Soup.Message msg = XMLRPC.request_new(aria_uri,"aria2.getGlobalOption");
        string data = send_message (msg);        
    }
    private void get_global_stat() {
        Soup.Message msg = XMLRPC.request_new(aria_uri,"aria2.getGlobalStat");
        string data = send_message (msg);
        try {
            Value v;
            if(Soup.XMLRPC.parse_method_response(data, -1, out v)) {
                HashTable<string,Value?> ht;
                Value val;
                
                ht = (HashTable<string,Value?>) v;
                
                val=ht.get("numStopped");
                //stdout.printf("coba = "+val.get_string());
                num_stopped=int.parse(val.get_string());
                
                val = ht.get("numWaiting");
                num_waiting=int.parse(val.get_string());
                
                val = ht.get("numActive");
                num_active=int.parse(val.get_string());
                
                val = ht.get("downloadSpeed");
                download_speed=int.parse(val.get_string());
                
                val = ht.get("uploadSpeed");
                upload_speed=int.parse(val.get_string());
                //stdout.printf(val.get_string());
            }
        } catch(Error e) {
            message("Error while processing tellStatus response");
        }
        //stdout.printf("num_active = %s\n num_stopped = %d \n num_waiting = %d \n",num_active.to_string(),(int)num_stopped,(int)num_waiting);
    }
    private void get_version() {
        Soup.Message msg = XMLRPC.request_new(aria_uri,"aria2.getVersion");
        string data = send_message (msg);
        try{
            Value v;
            if(Soup.XMLRPC.parse_method_response(data,-1,out v)){
                HashTable<string,Value?> ht;
                Value val;
                
                ht = (HashTable<string,Value?>) v;
                
                val=ht.get("version");
                version=val.get_string();
            }
        }catch(Error e){
            message("Error while processing getVersion response");
        }
        stdout.printf("version  = %s\n",version);
    }
    public void shutdown() {
        Soup.Message msg = XMLRPC.request_new(aria_uri,"aria2.shutdown");
        send_message (msg);
    }
    private void force_shutdown() {
        Soup.Message msg = XMLRPC.request_new(aria_uri,"aria2.forceShutdown");
        send_message (msg);
    }
    //TODO:using system.multicall to call more than one method at once
    private void system_multicall() {
    }
    private string send_message(Soup.Message message) {
        var session = new SessionSync();
        session.send_message(message);

        string data = (string) message.response_body.flatten().data;

        return data;
    }
}
