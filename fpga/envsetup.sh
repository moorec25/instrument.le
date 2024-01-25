#!/usr/bin/bash

if [ ! -d "$CAPSTONE_HOME/fpga/venv" ]; then
    echo "Creating python venv..."
    cd $CAPSTONE_HOME/fpga
    python3.10 -m venv venv
fi

source $CAPSTONE_HOME/fpga/venv/bin/activate

echo "Checking requirements"
pip install -r $CAPSTONE_HOME/fpga/requirements.txt | grep "Requirement already satisfied" -v

export OUT_HOME="$CAPSTONE_HOME/out"
export TEST_HOME="$CAPSTONE_HOME/fpga/DSD100subset/Mixtures"
