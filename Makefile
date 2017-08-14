.PHONY: x, run, clean-1, clean-2, clean-3

x:
	@echo "There is no default make target. Use 'make run' to run the SLURM pipeline."

run:
	slurm-pipeline.py -s specification.json > status.json

# Remove all large intermediate files. Only run this if you're sure you
# want to throw away all that work!
clean-1:
	rm -f \
              01-split/*.fasta \
              02-blastn/*.json.bz2

# Remove even more intermediate files.
clean-2: clean-1
	rm -f \
              01-split/*.out \
              02-blastn/*.out \
              03-panel/*.out \
              04-stop/*.out

# Remove *all* intermediates, including the final panel output.
clean-3: clean-2
	rm -fr \
               03-panel/out \
               03-panel/summary-virus \
               slurm-pipeline.done \
               slurm-pipeline.running \
               logs \
               status.json
