#!/usr/bin/env python3
from pathlib import Path
import json, os, shutil, signal, subprocess
base=Path(__file__).resolve().parent
backup=Path((base/'backup-path').read_text().strip())
state=json.loads((backup/'state.json').read_text())
for proc in Path('/proc').iterdir():
    if not proc.name.isdigit():continue
    try:
        args=(proc/'cmdline').read_bytes().split(b'\0')
        if str(base/'metrics.py').encode() in args or str(base/'Fosfor.conf').encode() in args:
            os.kill(int(proc.name),signal.SIGTERM)
    except OSError:pass
startup=Path.home()/'.config/autostart/start_conky.desktop'
if state['startup_existed']:shutil.copy2(backup/'start_conky.desktop',startup)
elif startup.exists():startup.unlink()
for key,value in state['wallpaper'].items():
    subprocess.run(['gsettings','set','org.gnome.desktop.background',key,value],check=True)
if state['fosfor_existed']:
    shutil.copytree(backup/'previous-Fosfor',base,dirs_exist_ok=True,symlinks=True)
for command in state['commands']:
    subprocess.Popen(command,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL,start_new_session=True)
print('Previous wallpaper and Conky startup restored. Backup retained:',backup)
