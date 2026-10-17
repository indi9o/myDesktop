#!/usr/bin/env python3
"""Install the GarudaOrbit theme for the current Linux user; preserve previous settings."""
from pathlib import Path
import datetime, json, os, shutil, subprocess
source = Path(__file__).resolve().parent / 'theme'
home = Path.home()
for command in ['conky', 'python3', 'gsettings', 'flock', 'pgrep', 'parec', 'pactl', 'xrandr']:
    if not shutil.which(command):
        raise SystemExit('Missing dependency: ' + command + '. Read PETUNJUK.txt first.')
try:
    subprocess.run(['python3', '-c', 'import numpy, tkinter'], check=True)
except subprocess.CalledProcessError:
    raise SystemExit('Install python3-numpy and python3-tk first. Read PETUNJUK.txt.')
dest = home / '.config/conky/GarudaOrbit'
startup = home / '.config/autostart/start_conky.desktop'
backup = home / '.config/conky/GarudaOrbit-backups' / datetime.datetime.now().strftime('%Y%m%d-%H%M%S-%f')
backup.mkdir(parents=True)
if startup.exists(): shutil.copy2(startup, backup / 'start_conky.desktop')
editor = home / '.local/share/applications/garuda-orbit-visualizer.desktop'
if editor.exists(): shutil.copy2(editor, backup/'garuda-orbit-visualizer.desktop')
if dest.exists(): shutil.copytree(dest, backup / 'previous-GarudaOrbit', symlinks=True)
settings = {key: subprocess.check_output(['gsettings', 'get', 'org.gnome.desktop.background', key], text=True).strip() for key in ['picture-uri','picture-uri-dark','picture-options']}
commands = []
for proc in Path('/proc').iterdir():
    if not proc.name.isdigit(): continue
    try:
        if proc.stat().st_uid == os.getuid() and (proc/'comm').read_text().strip() == 'conky':
            command = [arg.decode() for arg in (proc/'cmdline').read_bytes().split(b'\0') if arg]
            if any(arg.endswith('/GarudaOrbit/Visualizer.conf') for arg in command): continue
            if any(arg.endswith('/GarudaOrbit/GarudaOrbit.conf') for arg in command): command = [str(dest/'start.sh')]
            commands.append(command)
    except (OSError, UnicodeDecodeError): pass
(backup/'state.json').write_text(json.dumps({'wallpaper':settings,'commands':commands,'startup_existed':startup.exists(),'editor_existed':editor.exists(),'garuda-orbit_existed':dest.exists()}, indent=2))
dest.mkdir(parents=True, exist_ok=True)
for path in source.iterdir():
    if path.is_file(): shutil.copy2(path, dest/path.name)
(dest/'backup-path').write_text(str(backup))
shutil.copy2(Path(__file__).resolve().parent/'restore.py', dest/'restore.py')
startup.parent.mkdir(parents=True, exist_ok=True)
startup.write_text('[Desktop Entry]\nType=Application\nName=Conky GarudaOrbit\nExec="'+str(dest/'start.sh')+'"\nHidden=false\nX-GNOME-Autostart-enabled=true\n')
editor.parent.mkdir(parents=True, exist_ok=True)
editor.write_text('[Desktop Entry]\nType=Application\nName=Garuda Orbit — Atur visualizer\nComment=Geser dan simpan posisi visualizer audio\nExec=python3 \"'+str(dest/'visualizer.py')+'\" --configure\nIcon=audio-x-generic\nTerminal=false\nCategories=Settings;\n')
for key in ['picture-uri','picture-uri-dark']:
    subprocess.run(['gsettings','set','org.gnome.desktop.background',key,(dest/'garuda-orbit-lapang-wallpaper.png').as_uri()],check=True)
subprocess.run(['gsettings','set','org.gnome.desktop.background','picture-options','zoom'],check=True)
cache=home/'.cache/conky-garuda-orbit';cache.mkdir(parents=True,exist_ok=True)
with (cache/'conky.log').open('a') as log:
    subprocess.Popen([str(dest/'start.sh')],stdout=log,stderr=log,start_new_session=True)
print('GarudaOrbit installed. Backup:',backup)
print('Restore: python3 '+str(dest/'restore.py'))
