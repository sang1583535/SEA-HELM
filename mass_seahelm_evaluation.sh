#!/bin/bash

OUTPUT_DIR="/scratch/e1583535/outputs/seahelm/translation-only-02022026"
CHECKPOINT_DIRS=(
    # "/scratch/e1583535/llm/nus-olmo/mixed-n10B"
    # "/scratch/e1583535/llm/nus-olmo/para-first-n10B"
    # "/scratch/e1583535/llm/nus-olmo/para-last-n10B-rerun"
    # "/scratch/e1583535/llm/nus-olmo/multi-uniform-n10B-SEA-7.5_replay-2.5-checkpoints/step4770-unsharded-hf-multi-uniform"
    # "/scratch/e1583535/llm/nus-olmo/multilingual-n10B-7.5-replay-2.5-checkpoints/step4770-unsharded-hf-multilingual"
    # "/scratch/e1583535/llm/nus-olmo/para-replay-n10B"
    # "/scratch/e1583535/llm/nus-olmo/para-only-34B8"
    # "/scratch/e1583535/llm/nus-olmo/multilingual-uniform-7B_n34.8-26_replay-8.7-checkpoints/step8290-unsharded-hf-multilingual-uniform-34.7B"
    # "/scratch/e1583535/llm/nus-olmo/multilingual-7B_n34.8-26_replay-8.7-checkpoints/step8290-unsharded-hf-multilingual-7B-34.7B"
    # "/scratch/e1583535/llm/nus-olmo/para-only-7B-34B-checkpoints/step8290-unsharded-hf-para-only-7B-34.7B"
    # "SeaLLMs/SeaLLMs-v3-1.5B"
    # "sail/Sailor2-L-1B"
    # "meta-llama/Llama-3.1-8B-Instruct"
    # "aisingapore/Llama-SEA-LION-v3.5-8B-R"
    # "sail/Sailor2-8B"
    # "SeaLLMs/SeaLLMs-v3-7B"
    # "allenai/OLMo-2-1124-7B"
    "sail/Sailor2-20B"
)

# non-base-model Checkpoint
# CHECKPOINT_DIRS=(
#     # "SeaLLMs/SeaLLMs-v3-1.5B"
#     # "sail/Sailor2-L-1B"
#     # "aisingapore/Gemma-SEA-LION-v4-27B"
#     # "aisingapore/Qwen-SEA-LION-v4-32B-IT"
#     # "meta-llama/Llama-3.1-8B-Instruct"
# )

BASE_MODEL=true

TASK_AND_NUM_EXAMPLES=(
    "translation_only 5"
    # "nlp_sentiment_nli_casual 5"
    # "qa_5shot 5"
    # "qa_0shot 0"
    # "abssum_5shot 5"
    # "abssum_1shot 1"
    # "abssum_2shot 2"
)

for CHECKPOINT_DIR in "${CHECKPOINT_DIRS[@]}"; do
    echo "Evaluating checkpoint directory: $CHECKPOINT_DIR"

    # check if the directory exists
    # if [ ! -d "$CHECKPOINT_DIR" ]; then
    #     echo "Directory $CHECKPOINT_DIR does not exist. Skipping..."
    #     continue
    # fi

    for TASK_AND_NUM in "${TASK_AND_NUM_EXAMPLES[@]}"; do
        TASK=$(echo $TASK_AND_NUM | cut -d' ' -f1)
        NUM_EXAMPLES=$(echo $TASK_AND_NUM | cut -d' ' -f2)

        echo "Running evaluation for task: $TASK with $NUM_EXAMPLES examples"

        qsub -v CHECKPOINT_DIR="$CHECKPOINT_DIR",CHECKPOINT_NAME="$(basename $CHECKPOINT_DIR)",OUTPUT_DIR="$OUTPUT_DIR/$TASK",TASK="$TASK",NUM_EXAMPLES="$NUM_EXAMPLES",BASE_MODEL="$BASE_MODEL" \
        -N seahelm_eval_$(basename $CHECKPOINT_DIR)_$TASK \
        mass_seahelm_evaluation.pbs

        sleep 2
    done

    sleep 2
done
