
namespace Arrive.Model{
    public enum WindowState {
        NORMAL = 0,
        MAXIMIZED
    }
    
    public class SavedState : Granite.Services.Settings {
        public int window_width {get; set;}
        public int window_height {get; set;}
        
        public WindowState window_state {get; set;}
        
        public SavedState (){
            base ("org.pantheon.scratch.saved-state");
        }
    }
}
