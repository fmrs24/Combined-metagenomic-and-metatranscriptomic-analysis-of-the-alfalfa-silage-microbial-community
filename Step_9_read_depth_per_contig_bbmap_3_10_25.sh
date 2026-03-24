#!/bin/bash

#SBATCH --time=120:00:00					##(day-hour:minute:second) sets the max time for the job 
#SBATCH --cpus-per-task=60  				##request number of cpus 
#SBATCH --mem=500G						##max ram for the job 

#SBATCH --nodes=1						##request number of nodes (always keep at 1)
#SBATCH --mail-user=INPUT@iastate.edu		##email address to mail specified updates to
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END					##these say under what conditions do you want email updates
#SBATCH --mail-type=FAIL
#SBATCH --output="sb%j-contig depth 3 9 25"			##stores slurm logfile to text file called slurmlog_(assigned job number) 


module load bbmap
module load samtools

#The below command builds a reference and runs the mapping all in one step, and does not write the reference to disk (writes it to memory and deletes after, due to "nodisk" option)

########Step 3: Generating read depth tables for Metabat2 using mapped bam files ########
module load metabat/2.15

jgi_summarize_bam_contig_depths --outputDepth JGIReadDepth.txt --referenceFasta /work/PATH/bbduk_trimmed/USED_no_alfalfa_no_human_fastq_3_6_25/megahit.final.contigs.fa bbmap_reads_to_contigs/*_sorted.bam 

#*sorted.bam will grab all the sorted.bam files in your current directory at once so you don't have to type out the whole list
#outputDepth = name of output file
#referenceFasta = fasta of assembled contigs