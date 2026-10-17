#!/usr/bin/env python3
"""Build a portable GarudaOrbit distribution without machine-specific data."""
from pathlib import Path
import ast
import subprocess
import tarfile

root = Path(__file__).resolve().parent
for name in ['install.py', 'restore.py', 'theme/metrics.py', 'theme/visualizer.py']:
    ast.parse((root/name).read_text(), filename=name)
subprocess.run(['sh','-n',str(root/'theme/start.sh')], check=True)
output = root/'dist/Conky-GarudaOrbit-portable.tar.gz'
output.parent.mkdir(exist_ok=True)
with tarfile.open(output,'w:gz') as archive:
    for name in ['README.md','PETUNJUK.txt','install.py','restore.py','theme']:
        archive.add(root/name,arcname='Conky-GarudaOrbit/'+name,
                    filter=lambda info: None if '__pycache__' in info.name.split('/') or info.name.endswith('.pyc') else info)
print(output)
