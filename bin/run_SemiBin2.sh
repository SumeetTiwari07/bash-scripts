#!/bin/bash
#Author: Sumeet Tiwari
# SemiBin2=v2.0.2
# Script to run SemiBin2

# Initialize variables
FORWARD=""
REVERSE=""
CONTIG=""
OUTPUTDIR=""
ENVIRONMENT=""
THREADS=1

# Function to display usage information
usage() {
    echo "Usage: $0 -1 FORWARD -2 REVERSE -c CONTIG -e ENVIRONMENT -o OUTPUTDIR -t THREADS"
    exit 1
}

# Function to check if a file exists
check_file() {
  if [ ! -f "$1" ]; then
    echo "Error: File $1 not found" 
    exit 1
  fi
}

# Parse command-line arguments
while getopts "1:2:c:e:o:t:" opt; do
    case $opt in
        1) FORWARD=$OPTARG ;;
        2) REVERSE=$OPTARG ;;
        c) CONTIG=$OPTARG ;;
        e) ENVIRONMENT=$OPTARG ;;
        o) OUTPUTDIR=$OPTARG ;;
        t) THREADS=$OPTARG ;;
        \?) usage ;;
    esac
done

# Check if all the parameters are specified
if [ -z "$FORWARD" ] || [ -z "$REVERSE" ] || [ -z "$CONTIG" ] || [ -z "$OUTPUTDIR" ] || [ -z "$ENVIRONMENT" ]; then
    echo "Error: $FORWARD, $REVERSE, $CONTIG, $OUTPUTDIR and $ENVIRONMENT are required"
    usage
fi

# Check input files exist
check_file "$FORWARD"
check_file "$REVERSE"
check_file "$CONTIG"

mkdir -p "$OUTPUTDIR" # Create directory

# Run mapping
echo "Mapping reads to the reference..."
bowtie2-build -f "$CONTIG" "$OUTPUTDIR/ref"
bowtie2 -q --fr -x "$OUTPUTDIR/ref" -1 $FORWARD -2 $REVERSE -S "$OUTPUTDIR/sample.sam" -p $THREADS
samtools view -h -b -S "$OUTPUTDIR/sample.sam" -o "$OUTPUTDIR/sample.bam"
samtools view -b -F 4 "$OUTPUTDIR/sample.bam" -o "$OUTPUTDIR/sample.mapped.bam"
samtools sort "$OUTPUTDIR/sample.mapped.bam" -o "$OUTPUTDIR/sample.mapped.sorted.bam"
samtools index "$OUTPUTDIR/sample.mapped.sorted.bam"

BAM="$OUTPUTDIR/sample.mapped.sorted.bam"

# Check if the bam file exists
check_file "$BAM"

# Run SemiBin2
echo "Running SemiBin2..."
SemiBin2 single_easy_bin \
    --environment "$ENVIRONMENT" \
    -i "$CONTIG" \
    -b "$BAM" \
    -o "$OUTPUTDIR/bins"

# remove temporary files
rm $OUTPUTDIR/ref*
rm $OUTPUTDIR/sample*

echo "SemiBin2 complete."