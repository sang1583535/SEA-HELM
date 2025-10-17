#!/bin/bash

# Submit server job first
server_job=$(qsub vllm_serve.pbs)
echo "Submitted server job: $server_job"

# Wait a bit to ensure server starts
sleep 10

# Submit evaluation job with dependency
eval_job=$(qsub -W depend=after:$server_job seahelm_eval.pbs)
echo "Submitted evaluation job: $eval_job"