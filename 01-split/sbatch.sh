#!/bin/bash -e

. ../common.sh

log=$logDir/sbatch.log

echo "01-split sbatch.sh running at `date`" >> $log
echo "  Dependencies are $SP_DEPENDENCY_ARG" >> $log
echo >> $log

# This will (unfortunately) run synchronously on localhost and emit task
# names.
./split.sh
