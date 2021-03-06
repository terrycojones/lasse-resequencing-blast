#!/bin/bash -e

. ../common.sh

log=$logDir/sbatch.log

echo "04-stop sbatch.sh running at `date`" >> $log
echo "  Dependencies are $SP_DEPENDENCY_ARG" >> $log

jobid=`sbatch --profile=none -n 1 $SP_DEPENDENCY_ARG $SP_NICE_ARG submit.sh "$@" | cut -f4 -d' '`
echo "TASK: stop $jobid"

echo "  Job id is $jobid" >> $log
echo >> $log
