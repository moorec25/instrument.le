# instrument.le
## Setup
Install Python 3.10
```bash
sudo apt-get install python3.10
sudo apt-get install python3.10-venv
```
Clone Repository (HTTP)
```bash
git clone https://github.com/moorec25/instrument.le.git
```
Clone Repository (SSH)
```bash
git clone git@github.com:moorec25/instrument.le.git
```
Add the following lines to your bashrc
```bash
export CAPSTONE_HOME=#Path to repository
alias activate="source $CAPSTONE_HOME/envsetup.sh"
```
To setup the environment and install all dependencies run the command `activate`. 
