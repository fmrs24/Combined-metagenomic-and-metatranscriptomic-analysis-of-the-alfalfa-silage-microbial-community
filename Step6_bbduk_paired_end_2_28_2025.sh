#!/bin/bash
# Copy/paste this job script into a text file and submit with the command:
#    sbatch thefilename
# job standard output will go to the file slurm-%j.out (where %j is the job ID)

#SBATCH --time=72:00:00   # walltime limit (HH:MM:SS)
#SBATCH --nodes=1   # number of nodes
#SBATCH --ntasks-per-node=50   # 8 processor core(s) per node
#SBATCH --mem=150G   # maximum memory per node
#SBATCH --mail-user=INPUT@iastate.edu   # email address
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL
#SBATCH --output="sb%j- Metagenome 2025 BBDuk trimq = 20 "

module load bbmap


	########Prep work! #########
#1 Within the base folder you want to house the project in, create 2 sub-folders: "bbduk_trimmed" and "raw_reads"
#3 Within the "raw_reads" subfolder, place the "bbduk_adapters.fasta" file (or a file containing your known adapter sequences)
#4 Within the "raw_reads" subfolder, place your gzipped (.gz) raw fastq files 
#5 Make sure your forward raw fastq files end in "_1.fastq.gz" and your corresponding reverse raw fastq files end in "_2.fastq.gz"
#6 After the following have been completed, you should be good to run the script (from the base folder you are housing the project in)!
	#Make sure to first make any necessary changes to the reference file names, created directory names, program options/settings, etc. in this script as needed
	
		######NOTE: This script is part 2, and should be run after checking your raw read files for good quality with fastQC with script 1. ######

	########Step 1: Trim raw sequencing data with bbduk and output to new clean trimmed fastq files to use for rest of pipeline ########

#Note: I swapped quality trimming from window (w) to right and left (rl) because the developer claimed rl allowed for optimal trimming and w is not recommended (http://seqanswers.com/forums/showthread.php?t=42776&page=7)
#Should alter the trimq and minlen (at least) to fit your data (based on desired quality, read length, etc.)

mkdir bbduk_trimmed
cd raw_reads
for fwd in *1_001.fastq.gz; do
	rvs=$(echo $fwd | sed 's/1_001.fastq.gz/2_001.fastq.gz/g'); 
	bbduk.sh in1="$fwd" in2="$rvs" out1=../bbduk_trimmed/${fwd%.fastq.gz}_trim.fastq out2=../bbduk_trimmed/${rvs%.fastq.gz}_trim.fastq ref=bbduk.adapters.fa ktrim=r ordered k=23 hdist=1 mink=11 tpe tbo qtrim=rl trimq=20 minlen=75 threads=50
done 


####syntax notes: 
	#the ${fwd%.fastq.gz} calls the fwd variable, but does not include the .fastq.gz part of the variable.  Therefore, by adding_clean.fastq, we replace .fastq.gz in the variable with the new extension and ending for the output
#adaptor trimming stuff:
	#Raw reads were already removed of adapter content in my data, so I didn't need to adapter trim these; only quality trim.
	#ktrim=r : once a reference kmer is matched in a read, that kmer and all the bases to the right will be trimmed out, leaving only the bases to the left of the adapter sequence
		#this is the command to trim sequences that match the indicated reference sequences, using a kmer approach
	#mink=11 : sets shortest kmer that can be used at the ends of the read (k=11 for the last 11 bases), allowing the ends of reads to be correctly matched to adapter sequences 
		#(ie if the last 14 bases are adapter sequence, they will not match to a k=23 kmer and will thus not be removed unless a smaller kmer is used)
	#hdist=1 : hamming distance, higher number increases the number of stored kmers, decreasing specificity and increasing the chance for kmer matches
	#tpe : specifies to trim both reads to the same length when removing adapter sequences
	#tbo : specifies to also trim adapters based on pair overlap using BBMerge
		#both tpe and tbo should be used when adaptor trimming
	##NOTE: Need to also include the file bbduk_adapters.fasta in the directory this command is being run from, or change the command to point to the location of this file.
		#This is the file the program references to know which sequences are adapter sequences, so without it no adapter sequences will be removed
#quality trimming stuff:
	#qtrim=rl trimq=25: will trim bases below a Phred quality score of 25 on both the right and left sides of a read
	#maq=20 = will filter out reads below an average quality score of 15
	#minlen=75 : will filter out all reads below a read length of 75
	#ordered will ensure the reads come out in the same order they went in
 #Example usage:
#https://www.protocols.io/view/illumina-fastq-filtering-gydbxs6?step=1

#Webpages for complete BBDuk guides:
#https://jgi.doe.gov/data-and-tools/bbtools/bb-tools-user-guide/bbduk-guide/
#https://github.com/BioInfoTools/BBMap/blob/master/sh/bbduk.sh

##gzipping trimmed fastq files to save disk space
cd ../bbduk_trimmed
gzip *_trim.fastq

########Step 2: Assess read quality with fastQC after trimming with BBDuk ########

module load fastqc
mkdir fastqc
fastqc *_trim.fastq.gz -t 30 --outdir=fastqc

	##Check fastQC output for each trimmed file to make sure everything looks good with no adapter sequences!


##Next: move onto script 3: contig assembly