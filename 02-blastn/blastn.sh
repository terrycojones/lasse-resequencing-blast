#!/bin/bash -e

. $HOME/.virtualenvs/35/bin/activate
. ../common.sh

task=$1
log=$logDir/$task.log
fasta=../01-split/$task.fasta
out=$task.json.bz2

echo "02-blastn on task $task started at `date`" >> $log
echo "  FASTA file is $fasta" >> $log

db=hbv-complete-nt

# This is just one of the BLAST db files.
dbfile=$HOME/scratch/root/share/ncbi/blast-dbs/$db.nsq

if [ ! -f $dbfile ]
then
    echo "  blastn database file $dbfile does not exist!" >> $log
    exit 1
fi

function skip()
{
    if [ ! -f $out ]
    then
        # Make it look like we ran and produced no output.
        echo "  Creating no-results output file due to skipping." >> $log
        bzip2 < header.json > $out
    fi
}

function run_blast()
{
    echo "  blastn started at `date`" >> $log
    # Subtract 2 from the number of threads so convert-blast-xml-to-json.py
    # and bzip2 can get their work done too.
    blastn \
        -task blastn \
        -query $fasta \
        -db $db \
        -num_threads $(( $(nproc --all) - 2 )) \
        -evalue 0.01 \
        -outfmt 5 |
    convert-blast-xml-to-json.py | bzip2 > $out
    echo "  blastn stopped at `date`" >> $log
}


if [ $SP_SIMULATE = "1" ]
then
    echo "  This is a simulation." >> $log
else
    echo "  This is not a simulation." >> $log
    if [ $SP_SKIP = "1" ]
    then
        echo "  BLAST is being skipped on this run." >> $log
        skip
    elif [ -f $out ]
    then
        if [ $SP_FORCE = "1" ]
        then
            echo "  Pre-existing output file $out exists, but --force was used. Overwriting." >> $log
            run_blast
        else
            echo "  Will not overwrite pre-existing output file $out. Use --force to make me." >> $log
        fi
    else
        echo "  Pre-existing output file $out does not exist. Running BLAST." >> $log
        run_blast
    fi
fi

echo "02-blastn on task $task stopped at `date`" >> $log
echo >> $log
