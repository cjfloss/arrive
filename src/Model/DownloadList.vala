public class Arrive.Model.DownloadList: Object {
    private static int REFRESH_TIME=1000;
    public List <DownloadItem> _list;
//~     public IDownloadItem? get_file(string gid){
//~         DownloadItem download_item=new DownloadItem("0000");
//~         return download_item;
//~     }
//~     public void add_file(IDownloadItem download_item) {
//~         _list.append(download_item);
//~     }
    private uint prev_list_lenght;//used to determine list change;
    public uint length{
        get{
            if(_list!=null){
                return _list.length();
            } else return 0;
        }
        private set{}
    }
    public DownloadList(){
        _list = new List<DownloadItem>();
        add_file.connect((object,download_item)=>{
           // _list.append(download_item);   
            list_changed();         
        });
        var refresh_timer = new TimeoutSource(REFRESH_TIME);
        refresh_timer.set_callback(()=>{
            refresh_list();
            //list_changed();   
            return true;
        });
        refresh_timer.attach(null);
        message("DownloadList created");
    }
    private Arrive.Model.DownloadItem get_download_item(string gid){
        foreach(Arrive.Model.DownloadItem di in _list){
            if(di.gid==gid)return di;
        }
        return null;
    }
    private void populate_list(){
        //clearing all _list content
        foreach(Arrive.Model.DownloadItem diter in _list){
            _list.remove(diter);
        }
        
        Value v;
        Soup.Message msg = Soup.XMLRPC.request_new(Arrive.App.aria2.aria_uri,"aria2.tellActive");
        string data = send_message (msg);
        try {
            if(Soup.XMLRPC.parse_method_response(data, -1, out v) && v.holds(typeof(ValueArray))) {
                unowned ValueArray va;
                va =(ValueArray) v;
                foreach(Value viter in va){
                    HashTable<string,Value?> ht;
                    if(viter.holds(typeof(HashTable))){
                        var di = new Arrive.Model.DownloadItem();
                        di.tell_status(viter);
                        _list.append(di);
                    }
                    
                }
            }
            
        }catch(Error e){
            message("error parsing method response");
        }
        message("populate list, list lenght %u",_list.length());
    }
    private void refresh_list(){
        //clearing all _list content
//~         foreach(Arrive.Model.DownloadItem diter in _list){
//~             _list.remove(diter);
//~         }
        
        Value v;
        Soup.Message msg = Soup.XMLRPC.request_new(Arrive.App.aria2.aria_uri,"aria2.tellActive");
        string data = send_message (msg);
        try {
            if(Soup.XMLRPC.parse_method_response(data, -1, out v) && v.holds(typeof(ValueArray))) {
                unowned ValueArray va;
                va =(ValueArray) v;
                foreach(Value viter in va){
                    HashTable<string,Value?> ht;
                    if(viter.holds(typeof(HashTable))){
                        var di = new Arrive.Model.DownloadItem();
                        di.tell_status(viter);
                        var diptr = get_download_item(di.gid);
                        if(diptr != null){diptr.tell_status(viter);} else {populate_list();list_changed();}
                    }
                    
                }
            }
            
        }catch(Error e){
            message("error parsing method response");
        }
        msg = Soup.XMLRPC.request_new(Arrive.App.aria2.aria_uri,"aria2.tellWaiting",typeof(int),0,typeof(int),999);
        data = send_message (msg);
        try {
            if(Soup.XMLRPC.parse_method_response(data, -1, out v) && v.holds(typeof(ValueArray))) {
                unowned ValueArray va;
                va =(ValueArray) v;
                foreach(Value viter in va){
                    HashTable<string,Value?> ht;
                    if(viter.holds(typeof(HashTable))){
                        var di = new Arrive.Model.DownloadItem();
                        di.tell_status(viter);
                        var diptr = get_download_item(di.gid);
                        if(diptr != null){diptr.tell_status(viter);} else {populate_list();list_changed();}
                    }
                    
                }
            }
            
        }catch(Error e){
            message("error parsing method response");
        }
        msg = Soup.XMLRPC.request_new(Arrive.App.aria2.aria_uri,"aria2.tellStopped",typeof(int),0,typeof(int),999);
        data = send_message (msg);
        try {
            if(Soup.XMLRPC.parse_method_response(data, -1, out v) && v.holds(typeof(ValueArray))) {
                unowned ValueArray va;
                va =(ValueArray) v;
                foreach(Value viter in va){
                    HashTable<string,Value?> ht;
                    if(viter.holds(typeof(HashTable))){
                        var di = new Arrive.Model.DownloadItem();
                        di.tell_status(viter);
                        var diptr = get_download_item(di.gid);
                        if(diptr != null){diptr.tell_status(viter);} else {populate_list();list_changed();}
                    }
                    
                }
            }
            
        }catch(Error e){
            message("error parsing method response");
        }
        //if(_list.length()!=prev_list_lenght)list_changed();
        //prev_list_lenght=_list.length();

    }
    private string send_message(Soup.Message msg) {
        var session = new Soup.SessionSync();
        session.send_message(msg);
        string data = (string) msg.response_body.flatten().data;
        return data;
    }
    public signal void add_file(DownloadItem download_item);    //signall to broadcast when adding file
    public signal void remove_file();   //signal to broadcast when removing file
    public signal void list_changed();
}
