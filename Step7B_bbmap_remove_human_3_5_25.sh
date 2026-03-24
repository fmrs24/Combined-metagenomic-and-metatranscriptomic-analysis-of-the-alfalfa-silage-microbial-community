#!/bin/bash

#SBATCH --time=96:00:00					##(day-hour:minute:second) sets the max time for the job 
#SBATCH --cpus-per-task=60  				##request number of cpus 
#SBATCH --mem=300G						##max ram for the job 

#SBATCH --nodes=1						##request number of nodes (always keep at 1)
#SBATCH --mail-user=INPUT@iastate.edu		##email address to mail specified updates to
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END					##these say under what conditions do you want email updates
#SBATCH --mail-type=FAIL
#SBATCH --output="sb%j-bbmap-human_removal"			##stores slurm logfile to text file called slurmlog_(assigned job number) 

module load bbmap
module load samtools

#To start, this is set up for use with trimmed input fastq files ending in unmapped_no_alfalfa_1.fastq and unmapped_no_alfalfa_2.fastq corresponding to forward and reverse reads, respectively
##To map forward and reverse reads to a given reference genome:
cd bbduk_trimmed

for file in *unmapped_no_alfalfa_1.fastq; do
		shortname=$(echo "$file" | sed 's/unmapped_no_alfalfa_1.fastq//g') 
		bbmap.sh threads=60 minid=0.90 in1="$shortname"unmapped_no_alfalfa_1.fastq in2="$shortname"unmapped_no_alfalfa_2.fastq ref=Human_genome.fasta nodisk out="$shortname"_human_bbmap90_out.bam
		samtools view --threads 60 -b -f 13 "$shortname"_human_bbmap90_out.bam > "$shortname"_unmapped.bam
done
    #minid=0.90 indicates the minimum % identity required for a read to be mapped to the reference genome; may need to be changed for your specific case
    #samtools view -f 13 will grab all reads that match (-f = true) the samflag 13 (both the read and mate are unmapped), then this output is redirected into a new bam file 

##Sanity checks to see if all ok - check numbers of mapped and unmapped reads in original bam
	#f = true F = false , and samflag 4 = read unmapped.  So -f 4 will list all unmapped reads for that bam and -F 4 will give all mapped reads for that bam. Add 2 values for total # reads.
	#These values will be outputted to the end of slurm log file in the order they appear on the script
for bam in *_human_bbmap90_out.bam; do
	echo $bam "unmapped reads"
	samtools view --threads 60 -c -f 4 $bam
	echo $bam "mapped reads"
	samtools view --threads 60 -c -F 4 $bam 
done

##Sanity check to see number of reads (reads mapped then reads unmapped) in each bam after removing mapped reads. Should have 0 mapped since we only grabbed unmapped reads.
	# -f 4 = unmapped reads, -F 4 = mapped reads
for bam in *_unmapped.bam; do
	echo $bam "unmapped reads after removing mapped"
	samtools view --threads 60 -c -f 4 $bam
	echo $bam "mapped reads after removing mapped"
	samtools view --threads 60 -c -F 4 $bam 
done

##To convert the generated bam files of unmapped reads into an interlaced fastq file:
for bam in *_unmapped.bam; do
	shortname=$(echo "$bam" | sed 's/.bam//g') 
	samtools bam2fq -@ 20 "$bam" > "$shortname"_interlaced.fastq
done

##To split inerlaced fastq file into separate files for forward and reverse reads:
for fastq in *_interlaced.fastq; do
	shortname=$(echo "$fastq" | sed 's/_interlaced.fastq//g') 
	reformat.sh in="$fastq" out1="$shortname"_no_alfalfa_no_human_1.fastq out2="$shortname"_no_alfalfa_no_human_2.fastq
done

##Removing unneeded interlaced fastq files
for fastq in *_interlaced.fastq; do
	rm $fastq
done

