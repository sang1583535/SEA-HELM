#!/bin/bash

source ~/miniconda3/bin/activate

conda activate seahelm

export CUDA_VISIBLE_DEVICES=2,3

echo "Starting evaluating at $(date)"
echo "Running on host: $(hostname)"
echo "GPU info:"
nvidia-smi --query-gpu=name,memory.total,memory.free --format=csv,noheader,nounits || echo "No GPU detected"

python seahelm_evaluation.py \
--tasks nlp_classics \
--output_dir /home/tansang/multilingual-llm-scripts/outputs/nlp_classics \
--model_type vllm \
--model_name /home/tansang/models/nus-olmo/para-last \
--model_args "enable_prefix_caching=True,tensor_parallel_size=2,max_num_seqs=128," \
--is_base_model