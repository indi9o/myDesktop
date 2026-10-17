#!/usr/bin/env python3
"""Install the Atlas theme for the current Linux user; preserve previous settings."""
from pathlib import Path
import argparse, datetime, json, os, shutil, subprocess
parser=argparse.ArgumentParser(description='Install Atlas desktop theme')
parser.add_argument('--live',action='store_true',help='Enable Cairo animation and start it automatically at login')
args=parser.parse_args()
mode='--live' if args.live else '--static'
source = Path(__file__).resolve().parent / 'theme'
home = Path.home()
for command in ['conky', 'python3', 'gsettings', 'flock', 'pgrep']:
    if not shutil.which(command):
        raise SystemExit('Missing dependency: ' + command + '. Read PETUNJUK.txt first.')
dest = home / '.config/conky/Atlas'
startup = home / '.config/autostart/start_conky.desktop'
backup = home / '.config/conky/Atlas-backups' / datetime.datetime.now().strftime('%Y%m%d-%H%M%S-%f')
backup.mkdir(parents=True)
if startup.exists(): shutil.copy2(startup, backup / 'start_conky.desktop')
if dest.exists(): shutil.copytree(dest, backup / 'previous-Atlas', symlinks=True)
settings = {key: subprocess.check_output(['gsettings', 'get', 'org.gnome.desktop.background', key], text=True).strip() for key in ['picture-uri','picture-uri-dark','picture-options']}
commands = []
for proc in Path('/proc').iterdir():
    if not proc.name.isdigit(): continue
    try:
        if proc.stat().st_uid == os.getuid() and (proc/'comm').read_text().strip() == 'conky':
            commands.append([arg.decode() for arg in (proc/'cmdline').read_bytes().split(b'\0') if arg])
    except (OSError, UnicodeDecodeError): pass
(backup/'state.json').write_text(json.dumps({'wallpaper':settings,'commands':commands,'startup_existed':startup.exists(),'atlas_existed':dest.exists()}, indent=2))
dest.mkdir(parents=True, exist_ok=True)
for path in source.iterdir(): shutil.copy2(path, dest/path.name)
(dest/'backup-path').write_text(str(backup))
shutil.copy2(Path(__file__).resolve().parent/'restore.py', dest/'restore.py')
startup.parent.mkdir(parents=True, exist_ok=True)
startup.write_text('[Desktop Entry]\nType=Application\nName=Conky Atlas\nExec="'+str(dest/'start.sh')+'" '+mode+'\nHidden=false\nX-GNOME-Autostart-enabled=true\n')
for key in ['picture-uri','picture-uri-dark']:
    subprocess.run(['gsettings','set','org.gnome.desktop.background',key,(dest/'topography-wallpaper.png').as_uri()],check=True)
subprocess.run(['gsettings','set','org.gnome.desktop.background','picture-options','zoom'],check=True)
cache=home/'.cache/conky-atlas';cache.mkdir(parents=True,exist_ok=True)
with (cache/'conky.log').open('a') as log:
    subprocess.Popen([str(dest/'start.sh'),mode],stdout=log,stderr=log,start_new_session=True)
print('Atlas installed in '+('live' if args.live else 'static')+' mode. Backup:',backup)
print('Restore: python3 '+str(dest/'restore.py'))
