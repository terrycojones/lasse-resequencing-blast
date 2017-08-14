#!/bin/bash -e

. $HOME/.virtualenvs/35/bin/activate
. ../common.sh

# Remove the marker file that indicates when a job is fully complete or
# that there has been an error and touch the file that shows we're running.
rm -f $doneFile $errorFile
touch $runningFile

# Remove the top-level logging directory. With a sanity check!
if [ ! $logDir = ../logs ]
then
    # SLURM will catch this output and put it into slurm-N.out where N is
    # out job id.
    echo "$0: logDir variable has unexpected value '$logDir'!" >&2
    exit 1
fi

rm -fr $logDir

mkdir $logDir || {
    # SLURM will catch this output and put it into slurm-N.out where N is
    # out job id.
    echo "$0: Could not create log directory '$logDir'!" >&2
    exit 1
}

log=$sampleLogFile

echo "SLURM pipeline started at `date`" >> $log

echo >> $log
echo "00-start started at `date`" >> $log

echo "00-start stopped at `date`" >> $log
echo >> $log
