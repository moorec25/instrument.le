# Nov 22nd
## Tasks
Carter - Work on signal processing on python
Vito/Will - Look into openunmix Separator and OpenUnmix classes and figure out how they work
Eric - Get FPGA board running
Cameron - Look into quantifying output quality

# Nov 2nd
## Environment Setup
Everybody should clone the repo and create a VM if necessary.  
Environment is very simple to setup, just need to add a line or two to your .bashrc. I've provided a shell script that will do all the work of creating the python virtual environment and installing dependencies.  
When working on the python model, make sure the venv is loaded. Just type `activate` into the terminal and it will run the script.  
If any more python libraries need to be installed then do the following: Install the library, run `pip freeze > requirements.txt`, then commit and push requirements.txt. When somebody else pulls the updated requirements file and runs `activate` it will install the library.

## Objectives for Monday Meeting
- Get open-unmix model running and be able to run a test case
- Have some decisions made about how we will be moving forward in the coming weeks

## Game plan for next few weeks/month
### Create stimulus/logs
The open-unmix implementation does full end to end separation starting from an input wav file and ending with separated audio. In our design, we will want to have this split into multiple stages.  
Add trace dumps that will give stimulus and expected output of each stage. For example, dump out the spectrogram of the input audio. This spectrogram is the output of the audio pre-processing stage, and the input of the neural network stage. People working on the pre-processing can check their outputs against this trace, and people working on the neural network can use the same trace as input.

The flow would look something like this:
1. Run open-unmix on a short test piece of music
2. Spit out input/output of each stage
3. Use trace as input for whatever stage you are working on, and check it against the expected output

### Begin working on separating into blocks
Main blocks can be pre-processing, neural network, post-processing (this could change).
Can split up into groups for this.

Carter - Audio Processing  
Cameron - Neural Network  
Eric - Neural Network  
Vito - Audio Processing  
Will - Neural Network  

### Profiling
Profile the runtime of a test case to see which parts of the audio separation take the longest. Things that take a long time might get priority when it comes to being put onto the FPGA

### Using the FPGA
Once a few of the above tasks have been taken care of, one or two people should get the FPGA up and running and do some simple "hello world" type things on it to get a hang of the tools and workflow.

Things that will need to be done: 

- Get vivado/vitis installed
- Download board files
- Learn Vitis HLS
- Learn how to do communication between PL and PS (AXI Lite, DMA, etc)
- Write python drivers for PYNQ overlay
- Lots of other things

### Learning Resources
We will need to do some research in our free time regarding what portions of the design we are working on.  
https://www.youtube.com/@ValerioVelardoTheSoundofAI/  
This guy on youtube has lots of videos about music and AI. There is lots of content so if you don't want to go through all of it just do the parts that you will be working on the most.

## Other Design Decisions
### Pipelining/Block processing

The open-unmix model processes the entire audio track at once. We will probably run into issues with larger audio files when we are doing this on the FPGA, since there is a limited amount of memory. We should split the audio into blocks and then pipeline the different stages.  
The type of neural network used in open-unmix (and most audio applications) is a BIDIRECTIONAL LSTM. The audio is looked at both forwards and backwards. This means the system is non-causal and future inputs will effect the output. If we split into blocks and pipeline, we will need to play with the block sizes and see the effect of different block sizes on the separation quality. In short, blocks that are too large will have issues with memory and fitting the design on the FPGA. Blocks that are too short will lower the separation of the audio. Need to find a good middle ground.

### FPGA Implementation Decisions
We will need to decide if we will be doing things in handwritten verilog or if we will use Vitis (Xilinx's HLS tool). HLS probably a better idea. Will also need to look at the Xilinx IP cores to see if there is anything we would want to use (for example should we use the FFT IP core or should we be making our own)

### Game/Web App and Database Stuff
We probably won't be touching this until January.
