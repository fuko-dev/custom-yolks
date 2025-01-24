#!/bin/bash
# based on https://github.com/tynor88/docker-quakelive-server/blob/master/install_minqlx_plugins.sh

#wget https://bootstrap.pypa.io/get-pip.py
#python3 get-pip.py
#rm get-pip.py
python3 -m pip install --break-system-packages pyzmq hiredis
python3 -m pip install --break-system-packages -r minqlx-plugins/requirements.txt