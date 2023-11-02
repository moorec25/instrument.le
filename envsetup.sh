#!/usr/bin/bash

if [ ! -d "$CAPSTONE_HOME/venv" ]; then
    echo "Creating python venv..."
    cd $CAPSTONE_HOME
    python3 -m venv venv
fi

source $CAPSTONE_HOME/venv/bin/activate

echo "Checking requirements"
pip install -r $CAPSTONE_HOME/requirements.txt | grep "Requirement already satisfied" -v

