public class Arrive.Model.DownloadList: Object {
    public List <DownloadItem> _list;
//~     public IDownloadItem? get_file(string gid){
//~         DownloadItem download_item=new DownloadItem("0000");
//~         return download_item;
//~     }
//~     public void add_file(IDownloadItem download_item) {
//~         _list.append(download_item);
//~     }
    public int length{
        get{
            if(_list!=null){
                return (int)_list.length();
            } else return 0;
        }
        private set{}
    }
    public DownloadList(){
        _list = new List<DownloadItem>();
        add_file.connect((object,download_item)=>{
            _list.append(download_item);            
        });
        remove_file.connect((object)=>{
        });
        message("DownloadList created");
    }
    public signal void add_file(DownloadItem download_item);    //signall to broadcast when adding file
    public signal void remove_file();   //signal to broadcast when removing file
}
