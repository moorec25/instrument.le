#!/usr/bin/bash

source venv/bin/activate

echo "Checking requirements"
pip install -r requirements.txt | grep "Requirement already satisfied" -v

export CAP_HOME=`pwd`
alias home="cd $CAP_HOME"
