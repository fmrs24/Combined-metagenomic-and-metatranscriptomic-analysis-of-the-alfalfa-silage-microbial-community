#!/bin/bash
# Copy/paste this job script into a text file and submit with the command:
#    sbatch thefilename
# job standard output will go to the file slurm-%j.out (where %j is the job ID)

#SBATCH --time=72:00:00   # walltime limit (HH:MM:SS)
#SBATCH --nodes=1   # number of nodes
#SBATCH --ntasks-per-node=62   # 8 processor core(s) per node
#SBATCH --mem=150G   # maximum memory per node
#SBATCH --mail-user=INPUT@iastate.edu   # email address
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL
#SBATCH --output="sb%j- BBDuk trimq = 20 "

module load bbmap

#NOTE: for this command to work, make sure you have the file "bbduk_adapters.fasta" in the same folder

#Normal trimming command:

	##bbduk.sh in1=40STSA_S12_L002_R1_001.fastq.gz in2=40STSA_S12_L002_R2_001.fastq.gz \
out1=clean_40STSA_S12_L002_R1_001.fastq out2=clean_40STSA_S12_L002_R2_001.fastq \
ref=bbduk.adapters.fa ktrim=r ordered k=23 hdist=1 mink=11 tpe tbo qtrim=rl trimq=15 maq=15 minlen=50

#Looped trimming command for single-read data (USED)

for fwd in *.fastq.gz; do
    bbduk.sh in1="$fwd" out1=../bbduk_trimmed_maq20/${fwd%.fastq.gz}_trim.fastq \
    ref=bbduk.adapters.fa ktrim=r ordered k=23 hdist=1 mink=11 tpe tbo \
    qtrim=rl trimq=20 maq=20 minlen=50 threads=62
done







		###Explanation of command and options: 
#shorter kmer lengths "k" and higher values of hdist (up to about 3) are more sensitive and will filter out more reads than higher kmer and lower hdist values. Have k only be as large as the longest adapter (supported: k=1-31)
#ktrim=r : once a reference kmer is matched in a read, that kmer and all the bases to the right will be trimmed out, leaving only the bases to the left of the adapter sequence
	#this is the command to trim sequences that match the indicated reference sequences, using a kmer approach
#mink=11 : sets shortest kmer that can be used at the ends of the read (k=11 for the last 11 bases), allowing the ends of reads to be correctly matched to adapter sequences 
	#(ie if the last 14 bases are adapter sequence, they will not match to a k=23 kmer and will thus not be removed unless a smaller kmer is used)
#hdist=1 : hamming distance, higher number increases the number of stored kmers, decreasing specificity and increasing the chance for kmer matches
#stats : will create a statistics file of which contaminant sequences were seen and how many reads had them 
#qtrim=rl trimq=20: will trim bases below a quality score of 20 
#maq=20 = will filter out reads below an average quality score of 20 after trimming
#minlen=36 : will filter out all reads below a read length of 36
#tpe : specifies to trim both reads to the same length when removing adapter sequences
#tbo : specifies to also trim adapters based on pair overlap using BBMerge
#(x)hist : will generate a histogram for the specified parameter (x) 
#ordered will ensure the reads come out in the same order they went in

##NOTE: Need to also include the file bbduk_adapters.fasta in the directory this command is being run from, or change the command to point to the location of this file.
#This is the file the program references to know which sequences are adapter sequences, so without it no adapter sequences will be removed


 #Example usage:
#https://www.protocols.io/view/illumina-fastq-filtering-gydbxs6?step=1

#Webpages for complete BBDuk guides:
#https://jgi.doe.gov/data-and-tools/bbtools/bb-tools-user-guide/bbduk-guide/
#https://github.com/BioInfoTools/BBMap/blob/master/sh/bbduk.sh


