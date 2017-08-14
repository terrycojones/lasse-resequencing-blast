#!/bin/bash -e

. ../common.sh

task=$1
log=$logDir/sbatch.log

echo "02-blastn sbatch.sh running at `date`" >> $log
echo "  Task is $task" >> $log
echo "  Dependencies are $SP_DEPENDENCY_ARG" >> $log

if [ "$SP_SIMULATE" = "1" -o "$SP_SKIP" = "1" ]
then
    exclusive=
    echo "  Simulating or skipping. Not requesting exclusive node." >> $log
else
    # Request an exclusive machine because diamond.sh will tell DIAMOND to
    # use 24 threads.
    exclusive=--exclusive
    echo "  Not simulating or skipping. Requesting exclusive node." >> $log
fi

echo >> $log

jobid=`sbatch -n 1 --profile=none $SP_DEPENDENCY_ARG $SP_NICE_ARG $exclusive submit.sh $task | cut -f4 -d' '`
echo "TASK: $task $jobid"
