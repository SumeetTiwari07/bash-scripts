#!/bin/bash
#Author: Sumeet Tiwari
# SemiBin2=v2.0.2
# Script to run SemiBin2

# Initialize variables
CONTIG=""
BAM=""
OUTPUTDIR=""
THREADS=1
ENVIRONMENT=""

# Function to display usage information
usage() {
    echo "Usage: $0 -c CONTIG -b BAM -e ENVIRONMENT -o OUTPUTDIR -t THREADS"
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
while getopts "c:b:e:o:t:" opt; do
    case $opt in
        c) CONTIG=$OPTARG ;;
        b) BAM=$OPTARG ;;
        e) ENVIRONMENT=$OPTARG ;;
        o) OUTPUTDIR=$OPTARG ;;
        t) THREADS=$OPTARG ;;
        \?) usage ;;
    esac
done

# Check if all the parameters are specified
if [ -z "$CONTIG" ] || [ -z "$BAM" ] || [ -z "$OUTPUTDIR" ] || [ -z "$ENVIRONMENT" ]; then
    echo "Error: $CONTIG, $BAM, $OUTPUTDIR and $ENVIRONMENT are required"
    usage
fi

# Check input files exist
check_file "$CONTIG"
check_file "$BAM"

# Run SemiBin2
echo "Running SemiBin2..."
SemiBin2 single_easy_bin \
    --environment "$ENVIRONMENT" \
    -i "$CONTIG" \
    -b "$BAM" \
    -o "$OUTPUTDIR"

echo "SemiBin2 complete."