#!/bin/bash
#Author: Sumeet Tiwari
#Metaphlan4=v4.0.6
# Script to run metaphlan4

# Initialize variables
FORWARD=""
REVERSE=""
OUTPUTDIR=""
THREADS=1

# Function to display usage information
usage() {
    echo "Usage: $0 -1 FORWARD -2 REVERSE -o OUTPUTDIR -t THREADS"
    exit 1
}

# Parse command-line arguments
while getopts "1:2:o:t:" opt; do
    case $opt in
        1) FORWARD=$OPTARG ;;
        2) REVERSE=$OPTARG ;;
        o) OUTPUTDIR=$OPTARG ;;
        t) THREADS=$OPTARG ;;
        *) usage ;;
    esac
done

# Check if all the parameters are specified
if [ -z "$FORWARD" ] || [ -z "$REVERSE" ] || [ -z "$OUTPUTDIR" ]; then
    echo "Error: All parameters are required."
    usage
fi

# Check if file input reads are found else exit
if [ ! -e "$FORWARD" ] || [ ! -e "$REVERSE" ]; then
    echo "Error: Missing $FORWARD and $REVERSE reads files. Exiting..."
    exit 1
fi

echo "Both $FORWARD and $REVERSE found."

# Merge the reads
mkdir -p $OUTPUTDIR
gzip -c -d $FORWARD >$OUTPUTDIR/reads.fq
gzip -c -d $REVERSE >>$OUTPUTDIR/reads.fq

# Image and database location
IMAGE="/qib/platforms/Informatics/transfer/outgoing/singularity/core/metaphlan__4.0.6.simg"
MPA="/qib/platforms/Informatics/transfer/outgoing/databases/humann_db/mpa/mpa_vOct22_CHOCOPhlAnSGB_202212"
INDEX=$(cat $MPA/mpa_latest)
echo "$INDEX"

singularity exec $IMAGE metaphlan $OUTPUTDIR/reads.fq --input_type fastq \
    -o $OUTPUTDIR/$(basename $OUTPUTDIR).tsv --force \
    --bowtie2db $MPA -x $INDEX \
    --nproc $THREADS --unclassified_estimation \
    -t rel_ab

rm $OUTPUTDIR/reads.fq