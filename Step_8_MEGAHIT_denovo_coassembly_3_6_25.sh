#!/bin/bash

#SBATCH --time=96:00:00					##(day-hour:minute:second) sets the max time for the job 
#SBATCH --cpus-per-task=64  				##request number of cpus 
#SBATCH --mem=500G						##max ram for the job 

#SBATCH --nodes=1						##request number of nodes (always keep at 1)
#SBATCH --mail-user=INPUT@iastate.edu		##email address to mail specified updates to
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END					##these say under what conditions do you want email updates
#SBATCH --mail-type=FAIL
#SBATCH --output="sb%j-MEGAHIT 3 6 25"			##stores slurm logfile to text file called slurmlog_(assigned job number) 

module load micromamba 

eval "$(micromamba shell hook --shell=bash)" #this is telling micromamba you're in a bash shell (i think)- must be run everytime you use micromamba.

micromamba activate megahit-env

##################################################################

megahit -1 1-A01-2_Day1_UnT_S11_L002___unmapped_no_alfalfa_no_human_1.fastq,1-A02-4_Day3_UnT_S12_L002___unmapped_no_alfalfa_no_human_1.fastq,1-A03-8_Day5_UnT_S13_L002___unmapped_no_alfalfa_no_human_1.fastq,1-A04-11_Day7_UnT_S14_L002___unmapped_no_alfalfa_no_human_1.fastq,1-A05-14_Day14_UnT_S15_L002___unmapped_no_alfalfa_no_human_1.fastq,1-A06-18_Day32_UnT_S16_L002___unmapped_no_alfalfa_no_human_1.fastq \
        -2 1-A01-2_Day1_UnT_S11_L002___unmapped_no_alfalfa_no_human_2.fastq,1-A02-4_Day3_UnT_S12_L002___unmapped_no_alfalfa_no_human_2.fastq,1-A03-8_Day5_UnT_S13_L002___unmapped_no_alfalfa_no_human_2.fastq,1-A04-11_Day7_UnT_S14_L002___unmapped_no_alfalfa_no_human_2.fastq,1-A05-14_Day14_UnT_S15_L002___unmapped_no_alfalfa_no_human_2.fastq,1-A06-18_Day32_UnT_S16_L002___unmapped_no_alfalfa_no_human_2.fastq \
        -o megahit_assembly 




##megahit takes input of at least one (up to 9) libraries of paired or single-end reads in FASTA and FASTQ files 
##it assumes paired-end reads are in forward-reverse (fr) orientation, but this can be changed with options
##-o specifies output directory
##-1 denotes the file has fwd reads and -2 denotes the file has rvs reads
##-12 denotes the file has interlaced reads
#	Note: don't need to specficy number of CPU threads to use - default settings automatically use all 
#The default minimum length of contigs is 200 bp
# -v -> print version
# default settings use 90% of available memory 


# MEGAHIT manual: https://www.metagenomics.wiki/tools/assembly/megahit

