# bashscripts
Progress on bash scripts for NorESM run automation

As of 071119 the main files are as follows:
pass_params.py : 
This python file reads 'sample_param_set.csv' and passes the casename, model parameters, and a time signature to a bashscript. To make sure parameter sets are not run multiple times, one column contains 0 or 1 to indicate whether a case has been submitted. Currently, output is written to a different .csv (2), this can be easily changed when I finally implement.

test.sh : 
Initial bash file for drafting things.

slf_only.sh : 
Does not add SourceMod files related to inp modifications, just wbf

slf_and_inp : 
Does both.
