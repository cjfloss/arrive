public class Arrive.Widgets.PauseButton:Gtk.ToolButton{
    private enum State{
        START = 0,
        PAUSE,
        INACTIVE
    }
    private State state;
    public PauseButton(){
        state=State.PAUSE;
        change_icon();
        determine_state();
        change_icon();
        this.clicked.connect(()=>{
            switch(state){
                case state.START:
                    foreach(Arrive.Model.DownloadItem ditem in Arrive.App.aria2.download_list._list){
                            ditem.unpause();
                    }
                    
                break;
                case state.PAUSE:
                    foreach(Arrive.Model.DownloadItem ditem in Arrive.App.aria2.download_list._list){
                            ditem.pause();
                    }
                break;
                case state.INACTIVE:
                break;
            }
            determine_state();
            change_icon();
        });
        Arrive.App.aria2.download_list.notify["length"].connect((object)=>{
            determine_state();
            change_icon();
            message("list change");
        });
        message("PauseButton created\n");
    }
    private void determine_state(){
        stdout.printf(Arrive.App.aria2.download_list.length.to_string());
        if(Arrive.App.aria2.download_list.length > 0){
            state=State.PAUSE;
        }else{
            state=State.INACTIVE;
        }
    }
    private void change_icon(){
        switch(state){
            case State.START:
                set_stock_id(Gtk.Stock.MEDIA_PAUSE);
                sensitive = true;
                message("state = START");
            break;
            case State.PAUSE:
                set_stock_id(Gtk.Stock.MEDIA_PLAY);
                sensitive = true;
                message("state = PAUSE");
            break;
            case State.INACTIVE:
                sensitive = false;
                message("state = INACTIVE");
            break;
            default:
                message("PauseButton dont have state");
            break;
        }
    }
}
