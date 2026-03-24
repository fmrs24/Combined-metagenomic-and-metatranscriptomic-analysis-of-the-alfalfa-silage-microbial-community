#!/bin/bash

#SBATCH --time=300:00:00					##(day-hour:minute:second) sets the max time for the job 
#SBATCH --cpus-per-task=64 				##request number of cpus 
#SBATCH --mem=300G						##max ram for the job 

#SBATCH --nodes=1						##request number of nodes (always keep at 1)
#SBATCH --mail-user=INPUT@iastate.edu		##email address to mail specified updates to
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END					##these say under what conditions do you want email updates
#SBATCH --mail-type=FAIL
#SBATCH --output="sb%j-bbmap-alfalfa_removal_transcriptome"			##stores slurm logfile to text file called slurmlog_(assigned job number) 


module load bbmap
module load samtools

# To start, this is set up for use with trimmed input FASTQ files ending in R1_001_trim.fastq
# This is for mapping a single-ended FASTQ file to a given reference genome:

for file in *R1_001_trim.fastq; do
    shortname=$(echo "$file" | sed 's/R1_001_trim.fastq//g')
    # Use only the R1 file for mapping (no in2)
    bbmap.sh threads=64 minid=0.90 in1="$shortname"R1_001_trim.fastq ref=Alfalfa_genome.fasta nodisk out="$shortname"_alfalfa_bbmap90_out.bam
    samtools view --threads 64 -b -f 4 "$shortname"_alfalfa_bbmap90_out.bam > "$shortname"_unmapped.bam
done
    # minid=0.90 indicates the minimum % identity required for a read to be mapped to the reference genome; may need to be changed for your specific case
    # samtools view -f 4 will grab all unmapped reads

## Sanity checks to see if all is ok - check numbers of mapped and unmapped reads in the original bam
    # f = true, F = false, and samflag 4 = read unmapped. So -f 4 will list all unmapped reads for that bam and -F 4 will give all mapped reads for that bam.
    # These values will be outputted to the end of the slurm log file in the order they appear on the script
for bam in *_alfalfa_bbmap90_out.bam; do
    echo $bam "unmapped reads"
    samtools view --threads 64 -c -f 4 $bam
    echo $bam "mapped reads"
    samtools view --threads 64 -c -F 4 $bam
done

## Sanity check to see number of reads (reads mapped then reads unmapped) in each bam after removing mapped reads.
    # -f 4 = unmapped reads, -F 4 = mapped reads
for bam in *_unmapped.bam; do
    echo $bam "unmapped reads after removing mapped"
    samtools view --threads 64 -c -f 4 $bam
    echo $bam "mapped reads after removing mapped"
    samtools view --threads 64 -c -F 4 $bam
done

## To convert the generated bam files of unmapped reads into a FastQ file (single-end)
for bam in *_unmapped.bam; do
    shortname=$(echo "$bam" | sed 's/.bam//g')
    # Directly convert to FastQ (no interlacing needed since it's single-end)
    samtools bam2fq -@ 20 "$bam" > "$shortname"_no_alfalfa.fastq
done

## Removing unmapped BAM files after conversion (optional)
for bam in *_unmapped.bam; do
    rm $bam
done