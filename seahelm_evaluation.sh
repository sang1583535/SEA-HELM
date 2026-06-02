#!/bin/bash

export HF_HOME=/scratch/e1583535/cache 
export HF_DATASETS_CACHE=/scratch/e1583535/cache/datasets 
export VLLM_USE_V1=0

if [ -d "/scratch/e1583535/virtualenvs/my-seahelm" ]; then
    source /scratch/e1583535/virtualenvs/my-seahelm/bin/activate
fi

# if [ -d "/hpctmp/e1583535/virtualenvs/seahelm" ]; then
#     source /hpctmp/e1583535/virtualenvs/seahelm/bin/activate
# fi

echo "Starting evaluating at $(date)"
echo "Running on host: $(hostname)"
echo "GPU info:"
nvidia-smi --query-gpu=name,memory.total,memory.free --format=csv,noheader,nounits || echo "No GPU detected"

python /scratch/e1583535/SEA-HELM/seahelm_evaluation.py \
    --tasks translation_only \
    --output_dir /scratch/e1583535/outputs/seahelm/translation-only-260202/translation_only \
    --model_type vllm \
    --model_name /scratch/e1583535/llm/openseal-sft/openseal-sft-quality_0.8_aya6lang_mcq \
    --model_args enable_prefix_caching=True,tensor_parallel_size=1 \
    --is_base_model \
    --num_in_context_examples 5

# python /scratch/e1583535/SEA-HELM/seahelm_evaluation.py \
# --tasks translation_xalma_sea \
# --output_dir /scratch/e1583535/multiLingual-llm-project/outputs/parallel-last-100B-checkpoints-evaluation/translation_only-0shot \
# --model_type vllm \
# --model_name haoranxu/X-ALMA-13B-Group4 \
# --model_args "enable_prefix_caching=True,tensor_parallel_size=2" \
# --num_in_context_examples 0