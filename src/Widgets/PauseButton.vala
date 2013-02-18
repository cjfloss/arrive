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
            debug("list change");
        });
    }
    private void determine_state(){
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
                debug("state = START");
            break;
            case State.PAUSE:
                set_stock_id(Gtk.Stock.MEDIA_PLAY);
                sensitive = true;
                debug("state = PAUSE");
            break;
            case State.INACTIVE:
                sensitive = false;
                debug("state = INACTIVE");
            break;
            default:
                debug("PauseButton dont have state");
            break;
        }
    }
}
