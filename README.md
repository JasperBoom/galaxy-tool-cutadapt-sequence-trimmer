# galaxy-tool-cutadapt-sequence-trimmer
Use CutAdapt to trim and discard reads and read sections.  
The CutAdapt tool will trim and discard reads and read sections based on user input and quality thresholds.

Files in fastQ format should always have a .fastq extension.

## Getting started

### Prerequisites
Download and install the following software according to the following steps.
```
sudo apt-get install python
sudo apt-get install python-pip
sudo pip install cutadapt
```

### Installing
Download and install the tool according to the following steps.
```
sudo mkdir -m 755 /home/Tools
cd /home/Tools
sudo git clone https://github.com/JasperBoom/galaxy-tool-cutadapt-trimmer
sudo chmod -R 755 galaxy-tool-cutadapt-trimmer
```
```
sudo mkdir -m 755 /home/galaxy/tools/directoryname
sudo cp /home/Tools/galaxy-tool-cutadapt-trimmer/runCutAdapt.sh /home/galaxy/tools/directoryname/runCutAdapt.sh
sudo cp /home/Tools/galaxy-tool-cutadapt-trimmer/runCutAdapt.xml /home/galaxy/tools/directoryname/runCutAdapt.xml
```
Edit the following file in order to make galaxy display the tool.
```
/home/galaxy/config/tool_conf.xml
```
```
<tool file="airdentification/runCutAdapt.xml"/>
```

## Source(s)
* __Martin M__, Cutadapt Removes Adapter Sequences From High-throughput Sequencing Reads.  
  EMBnet.journal. 2011. __doi: 10.14806/ej.17.1.200__  
  [CutAdapt](http://cutadapt.readthedocs.io/en/stable/guide.html)
* __Giardine B, Riemer C, Hardison RC, Burhans R, Elnitski L, Shah P__,  
  Galaxy: A platform for interactive large-scale genome analysis.  
  Genome Research. 2005; 15(10) 1451-1455 __doi: 10.1101/gr.4086505__  
  [GALAXY](https://www.galaxyproject.org/)
