public class Arrive.Widgets.DownloadCellRenderer : Gtk.CellRenderer  {
    private static const int PADDING = 4;
    private static const int ICON_SIZE = 48;
    private static const int RIGHT_COLUMN_WIDTH = 80;

    private Gtk.CellRendererPixbuf icon_renderer;
    private Gtk.CellRendererText file_name_renderer;
    private Gtk.CellRendererProgress download_progress_renderer;
    private Gtk.CellRendererText status_renderer;
    private Gtk.CellRendererText download_renderer;
    private Gtk.CellRendererText upload_renderer;
    private Gtk.CellRendererText time_renderer;
    
    private Arrive.Model.DownloadItem _file;
    public Arrive.Model.DownloadItem file {
        get { return _file;}
        set {
            _file = value;
            
            icon_renderer.pixbuf=get_icon_for_file();
            
            //file_name_renderer.text=_file.filename;//parse file from path
            file_name_renderer.markup = Markup.printf_escaped ( "<span weight='bold' size='larger'>%s</span>",
            _file.filename);

            if(_file.total_length!=0)download_progress_renderer.value=(int)(100*_file.completed_length/_file.total_length);
            download_progress_renderer.text="%s/%s".printf(format_size(_file.completed_length)
                                                                      ,format_size(_file.total_length));
            status_renderer.text=_("status:%s pieces:%d").printf(_file.status,_file.num_pieces);
            
            download_renderer.text=format_size(_file.download_speed)+"ps";
            upload_renderer.text=format_size(_file.upload_speed)+"ps";
            time_renderer.text=get_remaining_time();


//~             switch(_file.status){
//~                 case IDownloadItem.Status.ACTIVE:
//~                     status_renderer.text="Downloading";
//~                     break;
//~                 case IDownloadItem.Status.WAITING:
//~                     status_renderer.text="Waiting";
//~                     break;
//~                 case IDownloadItem.Status.PAUSED:
//~                     status_renderer.text="Paused";
//~                     break;
//~                 case IDownloadItem.Status.ERROR:
//~                     status_renderer.text="Error";
//~                     break;
//~                 case IDownloadItem.Status.COMPLETE:
//~                     status_renderer.text="Download Completed";
//~                     break;
//~                 case IDownloadItem.Status.REMOVED:
//~                     status_renderer.text="Completed";
//~                     break;
//~                 default:
//~                     status_renderer.text="status unknown";
//~                     break;
//~             }
        }
    }
//~     public DownloadType tipe{get;set;}
//~     public Status status{get;set;}
    public string gid{get;set;}
    public string filename{get;set;}
    private string _dir;
    public string dir{
        get{return _dir;}
        set{
            _dir=value;
        }
    }
    //public ValueArray uris{get;set;}
    public uint64 total_length{get;set;}
    public uint64 completed_length{get;set;}
//~     public uint64 upload_length;
    public uint download_speed{get;set;}
    public uint upload_speed{get;set;}

    public DownloadCellRenderer () {
        icon_renderer = new Gtk.CellRendererPixbuf ();
        file_name_renderer = new Gtk.CellRendererText ();
        download_progress_renderer = new Gtk.CellRendererProgress ();
        status_renderer = new Gtk.CellRendererText ();
        //for right column
        download_renderer = new Gtk.CellRendererText ();
        upload_renderer = new Gtk.CellRendererText ();
        time_renderer = new Gtk.CellRendererText ();
    }
    public override void get_size (Gtk.Widget widget, Gdk.Rectangle? cell_area,
                                   out int x_offset, out int y_offset,
                                   out int width, out int height) {
        int file_name_renderer_height;
        int status_renderer_height;
        int download_progress_renderer_height;

        file_name_renderer.get_preferred_height (widget, null, out file_name_renderer_height);
        status_renderer.get_preferred_height (widget, null, out status_renderer_height);
        download_progress_renderer.get_preferred_height (widget, null, out download_progress_renderer_height);
//~         width=width;
        height = 2 * PADDING + file_name_renderer_height + download_progress_renderer_height + status_renderer_height;
    }
    public override void render (Cairo.Context ctx, Gtk.Widget widget,
                                 Gdk.Rectangle background_area,
                                 Gdk.Rectangle cell_area,
                                 Gtk.CellRendererState flags) {
        //render for icon, filename, download,progress and status
        int file_name_renderer_height;
        int status_renderer_height;
        int download_progress_renderer_height;
        file_name_renderer.get_preferred_height (widget,null, out file_name_renderer_height);
        status_renderer.get_preferred_height (widget, null, out status_renderer_height);
        download_progress_renderer.get_preferred_height (widget, null, out download_progress_renderer_height);

        Gdk.Rectangle icon_rect = Gdk.Rectangle () {
            x = cell_area.x,
            y = cell_area.y+PADDING,
            width = ICON_SIZE,
            height = ICON_SIZE
        };
        Gdk.Rectangle file_name_rect = Gdk.Rectangle () {
            x = cell_area.x+ICON_SIZE+PADDING,
            y = cell_area.y+PADDING,
            width = cell_area.width-(ICON_SIZE+RIGHT_COLUMN_WIDTH+2*PADDING),
            height = file_name_renderer_height
        };
        Gdk.Rectangle download_progress_rect = Gdk.Rectangle () {
            x= cell_area.x+ICON_SIZE+PADDING,
            y= cell_area.y+file_name_renderer_height+PADDING,
            width= cell_area.width-(ICON_SIZE+RIGHT_COLUMN_WIDTH+2*PADDING),
            height = download_progress_renderer_height
        };
        Gdk.Rectangle status_renderer_rect = Gdk.Rectangle () {
            x = cell_area.x+ICON_SIZE+PADDING,
            y = cell_area.y+file_name_renderer_height+download_progress_renderer_height+PADDING,
            height = status_renderer_height,
            width = cell_area.width-(ICON_SIZE+RIGHT_COLUMN_WIDTH+2*PADDING)
        };

        icon_renderer.render (ctx, widget, icon_rect, icon_rect, flags);
        file_name_renderer.render (ctx, widget, file_name_rect, file_name_rect, flags);
        download_progress_renderer.render (ctx, widget, download_progress_rect, download_progress_rect, flags);
        status_renderer.render (ctx, widget, status_renderer_rect, status_renderer_rect, flags);
        
        //render download, upload and remaining time
        int download_renderer_height;
        int upload_renderer_height;
        int time_renderer_height;
        download_renderer.get_preferred_height (widget,null, out download_renderer_height);
        upload_renderer.get_preferred_height (widget,null, out upload_renderer_height);
        time_renderer.get_preferred_height (widget,null, out time_renderer_height);
        
        Gdk.Rectangle download_renderer_rect = Gdk.Rectangle(){
           
            x = cell_area.x+cell_area.width-RIGHT_COLUMN_WIDTH+download_renderer_height,
            y = cell_area.y+PADDING,
            height = download_renderer_height,
            width = RIGHT_COLUMN_WIDTH-2*PADDING
        };
        Gdk.Rectangle upload_renderer_rect = Gdk.Rectangle(){
            x = cell_area.x+cell_area.width-RIGHT_COLUMN_WIDTH+upload_renderer_height,
            y = cell_area.y+download_renderer_height+PADDING,
            height = upload_renderer_height,
            width = RIGHT_COLUMN_WIDTH-2*PADDING
        };
        Gdk.Rectangle time_renderer_rect = Gdk.Rectangle(){
            x = cell_area.x+cell_area.width-RIGHT_COLUMN_WIDTH+time_renderer_height,
            y = cell_area.y+download_renderer_height+upload_renderer_height+PADDING,
            height = time_renderer_height,
            width = RIGHT_COLUMN_WIDTH-2*PADDING
        };
        
        download_renderer.render (ctx, widget, download_renderer_rect, download_renderer_rect, flags);
        upload_renderer.render (ctx, widget, upload_renderer_rect, upload_renderer_rect, flags);
        time_renderer.render (ctx, widget, time_renderer_rect, time_renderer_rect, flags);
        
        //render icon for download, upload and remaining
        var ri_renderer = new Gtk.CellRendererPixbuf();
        var ri_renderer_rect = Gdk.Rectangle(){
            x = cell_area.x+cell_area.width-RIGHT_COLUMN_WIDTH,
            y =download_renderer_rect.y,
            height = download_renderer_height,
            width = download_renderer_height
        };
        try{
            ri_renderer.pixbuf = Gtk.IconTheme.get_default().load_icon("go-down", download_renderer_height-6,0);
        }catch(Error e){
            message("error code %d",e.code);
        }
        ri_renderer.render(ctx, widget, ri_renderer_rect, ri_renderer_rect, flags);//download icon
        
        ri_renderer_rect = Gdk.Rectangle(){
            x = cell_area.x+cell_area.width-RIGHT_COLUMN_WIDTH,
            y = upload_renderer_rect.y,
            height = upload_renderer_height,
            width = upload_renderer_height
        };
        try{
            ri_renderer.pixbuf = Gtk.IconTheme.get_default().load_icon("go-up", upload_renderer_height-6,0);
        }catch(Error e){
            message("error code %d",e.code);
        }
        ri_renderer.render(ctx, widget, ri_renderer_rect, ri_renderer_rect, flags);//upload icon
        
        ri_renderer_rect = Gdk.Rectangle(){
            x = cell_area.x+cell_area.width-RIGHT_COLUMN_WIDTH,
            y = time_renderer_rect.y,
            height = time_renderer_height,
            width = time_renderer_height
        };
        try{
            ri_renderer.pixbuf = Gtk.IconTheme.get_default().load_icon("preferences-system-time", time_renderer_height-6,0);
        }catch(Error e){
            message("error code %d",e.code);
        }
        ri_renderer.render(ctx, widget, ri_renderer_rect, ri_renderer_rect, flags);//time icon
    }
    private string get_remaining_time(){
        if(_file.download_speed==0)return _("unknown");
        if(_file.total_length<_file.completed_length)return _("few seconds");
        uint64 seconds = (_file.total_length-_file.completed_length)/_file.download_speed;
        
        string remaining="";
        uint64 div;
        //divided by one week
        div = seconds/604800;
        if(div>=1){
            remaining+=_("%lldw").printf(div);
            seconds=seconds%604800;
        }
        //divided by one day
        div = seconds/86400;
        if(div>=1){
            remaining+=_("%lldd").printf(div);
            seconds=seconds%86400;
        }
        //divided by one day
        div = seconds/3600;
        if(div>=1){
            remaining+=_("%lldh").printf(div);
            seconds=seconds%3600;
        }
        //divided by one minute
        div = seconds/60;
        if(div>=1){
            remaining+=_("%lldm").printf(div);
            seconds=seconds%60;
        }
        //adding seconds left
        remaining += _("%llds").printf(seconds);
        return remaining;
        
    }
    private Gdk.Pixbuf? get_icon_for_file(){
        string icon_name;
        Gdk.Pixbuf pixbuf = null;
        
        string content_type = ContentType.guess(_file.filename,null,null);
        Icon icon = ContentType.get_icon(content_type);
        
        if(icon is ThemedIcon)
            icon_name=(icon as ThemedIcon).names[0];
        else
            icon_name="text-x-generic";
        
        if (icon_name==null)
            return null;
        try{
            pixbuf = Gtk.IconTheme.get_default().load_icon(icon_name, ICON_SIZE,0);
        }catch(Error e){
            pixbuf = null;
        }
        return pixbuf;
    }
}
