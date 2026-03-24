#!/bin/bash

#SBATCH --time=300:00:00					##(day-hour:minute:second) sets the max time for the job 
#SBATCH --cpus-per-task=64 				##request number of cpus 
#SBATCH --mem=300G						##max ram for the job 

#SBATCH --nodes=1						##request number of nodes (always keep at 1)
#SBATCH --mail-user=INPUT@iastate.edu		##email address to mail specified updates to
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END					##these say under what conditions do you want email updates
#SBATCH --mail-type=FAIL
#SBATCH --output="sb%j-bbmap-human_removal_transcriptome"			##stores slurm logfile to text file called slurmlog_(assigned job number) 


module load bbmap
module load samtools

# To start, this is set up for use with trimmed single-end input fastq files
# Example: unmapped_no_alfalfa.fastq (single-end R1 read file)


# Loop through the files ending with unmapped_no_alfalfa.fastq (single-end reads)
for file in *unmapped_no_alfalfa.fastq; do
    shortname=$(echo "$file" | sed 's/unmapped_no_alfalfa.fastq//g')
    
    # Run bbmap with only a single input file (in1)
    bbmap.sh threads=60 minid=0.90 in1="$file" ref=Human_genome.fasta nodisk out="$shortname"_human_bbmap90_out.bam
    
    # Use samtools to extract unmapped reads (samflag 4) from the resulting bam file
    samtools view --threads 60 -b -f 4 "$shortname"_human_bbmap90_out.bam > "$shortname"_unmapped.bam
done

# Sanity check to see the number of mapped and unmapped reads in the original bam file
for bam in *_human_bbmap90_out.bam; do
    echo $bam "unmapped reads"
    samtools view --threads 60 -c -f 4 $bam
    echo $bam "mapped reads"
    samtools view --threads 60 -c -F 4 $bam
done

# Sanity check to see the number of reads after removing mapped reads (should only have unmapped reads)
for bam in *_unmapped.bam; do
    echo $bam "unmapped reads after removing mapped"
    samtools view --threads 60 -c -f 4 $bam
    echo $bam "mapped reads after removing mapped"
    samtools view --threads 60 -c -F 4 $bam
done

# Convert the generated bam files of unmapped reads into single-end fastq files
for bam in *_unmapped.bam; do
    shortname=$(echo "$bam" | sed 's/.bam//g')
    
    # Use samtools to convert the unmapped bam file into a fastq file
    samtools bam2fq -@ 20 "$bam" > "$shortname"_unmapped.fastq
done

# Remove the intermediate bam files (optional, to save space)
for bam in *_unmapped.bam; do
    rm $bam
done