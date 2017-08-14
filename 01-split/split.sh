#!/bin/bash -e

. $HOME/.virtualenvs/35/bin/activate
. ../common.sh

log=$sampleLogFile

echo "01-split started at `date`" >> $log

prexistingCount=`ls chunk-* 2>/dev/null | wc -l | awk '{print $1}'`
echo "  There are $prexistingCount pre-existing split files." >> $log

function skip()
{
    echo "  Skipping."
}

function makeFasta()
{
    # Find all sequencing files corresponding to this sample.
    tasks=$(find $rootDir -name '*.trim.fastq.gz')

    if [ -z "$tasks" ]
    then
        echo "  No FASTQ found for this sample." >> $log
        exit 1
    fi

    allFASTQ=
    for task in $tasks
    do
        echo "  Task (i.e., sequencing run) $task" >> $log
        base=$(basename $task | sed -e 's/\.trim\.fastq\.gz//')

        FASTQ=../../initial/02-map/$base-unmapped.fastq.gz
        test -f $FASTQ || {
            echo "FASTQ file $FASTQ does not exist." >> $log
            exit 1
        }
        allFASTQ="$allFASTQ $FASTQ"
    done

    echo >> $log

    # BLAST can't read FASTQ and can't read gzipped files. So make a bunch
    # of FASTA files for it. Note that we know reads just take a single
    # line in the output and that we need to split on an even number of
    # input FASTA lines.
    echo "  Uncompressing and splitting all FASTQ at `date`" >> $log
    zcat $allFASTQ | filter-fasta.py --fastq --saveAs fasta | split -l 500000 -a 5 --additional-suffix=.fasta - chunk-
    echo "  FASTQ uncompressed at `date`" >> $log
    echo "  Split into `ls chunk-* | wc -l | awk '{print $1}'` files." >> $log
}


if [ $SP_SIMULATE = "1" ]
then
    echo "  This is a simulation." >> $log
else
    echo "  This is not a simulation." >> $log
    if [ $SP_SKIP = "1" ]
    then
        echo "  Panel is being skipped on this run." >> $log
        skip
    elif [ $prexistingCount -ne 0 ]
    then
        if [ $SP_FORCE = "1" ]
        then
            echo "  Pre-existing split files exist, but --force was used. Overwriting." >> $log
            makeFasta
        else
            echo "  Not overwriting pre-existing split files. Use --force to make me." >> $log
        fi
    else
        echo "  No pre-existing split files exists, making them." >> $log
        makeFasta
    fi
fi

for file in chunk-*.fasta
do
    task=`echo $file | cut -f1 -d.`
    echo "TASK: $task"
done

echo "01-split stopped at `date`" >> $log
echo >> $log
