using Xml;
using Soup;
//~ class MulticallMethod : Glib.Object{
//~ 	Xml.Doc* doc;
//~ 	string _xml_string;
//~ 	string xml_string{
//~ 		get {
//~ 			doc->dump_memory(out _xml_string);
//~ 			return _xml_string;
//~ 			}
//~ 		private set;
//~ 	}
//~ 	public MulticallMethod(){
//~ 		doc = new Xml.Doc("1.0");
//~ 	}
//~ 	void add_tell_active(){
//~ 	}
//~ }
public class Arrive.Aria2Model : Object {
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
    public string version="";
    private string aria_ip="http://localhost";
    private string aria_port="6800";
    private string aria_uri="";
    public Aria2Model() {
        //if(ip==null)aria_ip="http://localhost" else aria_ip = ip;
        //if(port==null)aria_port="6800" else aria_port = port;
        aria_uri = aria_ip+":"+aria_port+"/rpc";
        get_version();
        get_global_stat();
    }
    bool start_aria2c() {
        return true;
    }
    void refresh_properties() {
        get_global_stat();
    }
    void tell_active() {
    }
    void tell_waiting() {
    }
    void tell_stopped() {
    }
    public void get_global_option() {
        Soup.Message message = XMLRPC.request_new(aria_uri,"aria2.getGlobalOption");
        string data = send_message (message);
        stdout.printf(data);
        parse_response(data);
    }
    void get_global_stat() {
        Soup.Message message = XMLRPC.request_new(aria_uri,"aria2.getGlobalStat");
        string data = send_message (message);
        parse_response(data);
    }
    void get_version() {
        Soup.Message message = XMLRPC.request_new(aria_uri,"aria2.getVersion");
        string data = send_message (message);
        parse_response(data);
    }
    public void shutdown() {
        Soup.Message message = XMLRPC.request_new(aria_uri,"aria2.shutdown");
        string data = send_message (message);
    }
    void force_shutdown() {
        Soup.Message message = XMLRPC.request_new(aria_uri,"aria2.forceShutdown");
        string data = send_message (message);
    }
    //TODO:using system.multicall to call more than one method at once
    void system_multicall() {
    }
    void parse_node(Xml.Node* node) {
        string speed="0";
        for (Xml.Node* iter = node->children; iter != null; iter=iter->next) {
            if(iter->type !=ElementType.ELEMENT_NODE)continue;
            string node_name = iter->name;
            string node_content = iter->get_content();
            if (node_name=="member")parse_member(iter);
            parse_node(iter);
        }
    }
    void parse_member(Xml.Node* node) {
        string member_name="";
        string member_value="";
        for (Xml.Node* iter = node->children; iter !=null; iter=iter->next) {
            if(iter->type !=ElementType.ELEMENT_NODE)continue;
            if(iter->name=="name")member_name=iter->get_content();
            if(iter->name=="value")member_value=iter->get_content();
        }
        switch(member_name) {
        case "numStopped":
            num_stopped=int.parse(member_value);
            break;
        case "numWaiting" :
            num_waiting=int.parse(member_value);
            break;
        case "numActive" :
            num_active=int.parse(member_value);
            break;
        case "downloadSpeed" :
            download_speed=int.parse(member_value);
            break;
        case "uploadSpeed" :
            upload_speed=int.parse(member_value);
            break;
        case "version" :
            version=member_value;
            break;
        default :
            break;
        }
    }
    bool parse_response(string data) {
        Parser.init();
        Xml.Doc* doc = Parser.parse_memory (data, data.length);
        if (doc == null)stderr.printf("cantparse memory");
        Xml.Node* root=doc->get_root_element();
        if (root == null) {
            delete doc;
            stderr.printf("cant parse root");
            return false;
        }
        stdout.printf("Root node"+root->name+"\n");
        parse_node(root);
        stdout.printf("\n");
        delete doc;
        Parser.cleanup();
        return true;
    }
    string send_message(Soup.Message message) {
        var session = new SessionSync();
        session.send_message(message);

        string data = (string) message.response_body.flatten().data;

        return data;
    }
}
