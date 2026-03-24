#!/bin/bash

#SBATCH --time=150:00:00					##(day-hour:minute:second) sets the max time for the job 
#SBATCH --cpus-per-task=64  				##request number of cpus 
#SBATCH --mem=500G						##max ram for the job 

#SBATCH --nodes=1						##request number of nodes (always keep at 1)
#SBATCH --mail-user=INPUT@iastate.edu		##email address to mail specified updates to
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END					##these say under what conditions do you want email updates
#SBATCH --mail-type=FAIL
#SBATCH --output="sb%j-metabat bins w the checkm 3 11 25"			##stores slurm logfile to text file called slurmlog_(assigned job number) 

module load micromamba 

eval "$(micromamba shell hook --shell=bash)" #this is telling micromamba you're in a bash shell (i think)- must be run everytime you use micromamba.

micromamba activate metabat2-checkm-env


########Prep work! #########
	#Need to have your contigs file from your preferred metagenome assembly software
    #Need to have access to a CheckM data folder (see notes below)
    #If using contig read depth to enhance binning, need to run script 3.5 to map trimmed reads to assembled contigs, sort resulting bams, then generate read depth file with "jgi_summarize_bam_contig_depths" command through metabat2

########Step 1: Making bins with metabat2 ########
#Running binning twice to compare success of binning using default (2500) and minimum (1500) contig size cutoffs
###mkdir metabat2_1500_with_read_depth
###metabat2 --minContig 1500 -i /work/PATH/lane2/bbduk_trimmed/USED_no_alfalfa_no_human_fastq_3_6_25/megahit.final.contigs.fa -a bbmap_reads_to_contigs/JGIReadDepth.txt -o /work/PATH/lane2/bbduk_trimmed/USED_no_alfalfa_no_human_fastq_3_6_25/metabat2_1500_with_read_depth -t 64
###mkdir metabat2_2500_with_read_depth
###metabat2 --minContig 2500 -i /work/PATH/lane2/bbduk_trimmed/USED_no_alfalfa_no_human_fastq_3_6_25/megahit.final.contigs.fa -a bbmap_reads_to_contigs/JGIReadDepth.txt -o /work/PATH/lane2/bbduk_trimmed/USED_no_alfalfa_no_human_fastq_3_6_25/metabat2_2500_with_read_depth -t 64


##Syntax notes:
    #-i = input contigs
    #-a = read depth file (mapped reads to contigs with bbmap, generated this file in script 3.5)
    #-o = output folder
    #-t = number of threads to use
    #Can set --minContig 1500 to make metabat2 use the minimum size contigs for binning (minimum = 1500bp, default = 2500bp)
    #Can also enhance binning by providing a separate file of contig read depth from reads mapped to your contigs
        #option -a path/JGIReadDepth.txt
#Manual: https://bitbucket.org/berkeleylab/metabat/src/master/README.md 



########Step 2: Running checkM to assess quality of your bins/mags ########
export CHECKM_DATA_PATH=/work/sse/Faith/Agriking_Metagenome_2025/lane2/bbduk_trimmed/USED_no_alfalfa_no_human_fastq_3_6_25/checkMData
checkm lineage_wf -x fa -t 64 /work/PATH/lane2/bbduk_trimmed/USED_no_alfalfa_no_human_fastq_3_6_25/metabat2_1500_with_read_depth /work/PATH/lane2/bbduk_trimmed/USED_no_alfalfa_no_human_fastq_3_6_25/metabat2_1500_with_read_depth_CheckM
checkm lineage_wf -x fa -t 64 /work/PATH/lane2/bbduk_trimmed/USED_no_alfalfa_no_human_fastq_3_6_25/metabat2_2500_with_read_depth /work/PATH/lane2/bbduk_trimmed/USED_no_alfalfa_no_human_fastq_3_6_25/metabat2_2500_with_read_depth_CheckM

##Syntax notes:
    #Standard workflow: checkm lineage_wf <bin folder> <output folder>
    #-x denotes the file extension of your binned mags
    #export command sets path to checkM data folder

##Notes: export requires a path to a checkM data folder: can download this stuff https://github.com/Ecogenomics/CheckM/wiki/Installation#how-to-install-checkm see "required reference data"
## make sure you move or rename your contigs if they ended in .fa and are in the folder you are using.
#Manual:https://github.com/Ecogenomics/CheckM/wiki


########Step 3: Create a tsv with checkM information about your bins ########   
checkm qa -o 2 -t 64 -f /work/PATH/lane2/bbduk_trimmed/USED_no_alfalfa_no_human_fastq_3_6_25/metabat2_1500_with_read_depth_CheckM/CheckmOut.tsv --tab_table /work/PATH/lane2/bbduk_trimmed/USED_no_alfalfa_no_human_fastq_3_6_25/metabat2_1500_with_read_depth_CheckM/lineage.ms /work/PATH/lane2/bbduk_trimmed/USED_no_alfalfa_no_human_fastq_3_6_25/metabat2_1500_with_read_depth_CheckM
checkm qa -o 2 -t 64 -f /work/PATH/lane2/bbduk_trimmed/USED_no_alfalfa_no_human_fastq_3_6_25/metabat2_2500_with_read_depth_CheckM/CheckmOut.tsv --tab_table /work/PATH/lane2/bbduk_trimmed/USED_no_alfalfa_no_human_fastq_3_6_25/metabat2_2500_with_read_depth_CheckM/lineage.ms /work/PATH/lane2/bbduk_trimmed/USED_no_alfalfa_no_human_fastq_3_6_25/metabat2_2500_with_read_depth_CheckM

##Syntax notes:
    #Standard command: checkm qa <marker file> <analyze_folder>
    #-o denotes output format (1-9)
    #-f denotes print results to file instead of the console (output)
    #command info:https://github.com/Ecogenomics/CheckM/wiki/Genome-Quality-Commands#qa


