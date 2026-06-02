#!/bin/bash

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
    # "SeaLLMs/SeaLLMs-v3-1.5B"
    # "sail/Sailor2-L-1B"
    # "meta-llama/Llama-3.1-8B-Instruct"
    # "allenai/OLMo-2-1124-7B"
    # "/scratch/e1583535/llm/nus-olmo/para-only-7B-34B-checkpoints/step8290-unsharded-hf-para-only-7B-34.7B"
    # "/scratch/e1583535/llm/openseal-sft/openseal-SeaInstruct_stage1"
    # "/scratch/e1583535/llm/openseal-sft/openseal-sailor2ds-stage1"
    # "/scratch/e1583535/llm/openseal-sft/openseal-sailor2ds-stage2"
    # "/scratch/e1583535/llm/openseal-dpo/openseal_dpo_sailor2_stage1"
    # "aisingapore/Llama-SEA-LION-v3.5-8B-R"
    # "sail/Sailor2-8B"
    # "SeaLLMs/SeaLLMs-v3-7B"
    # "/scratch/e1583535/llm/sail/Sailor2-20B"
    # "aisingapore/Qwen-SEA-LION-v4-32B-IT"
    # "aisingapore/Gemma-SEA-LION-v4-27B-IT"
    # "/scratch/e1583535/llm/openseal-sft/openseal-seaexam-stage3"
    # "/scratch/e1583535/llm/openseal-sft/openseal-seaexam-stage3-cosmos"
    # "/scratch/e1583535/llm/openseal-sft/openseal-multilingual-sailor2ds-stage1"
    # "/scratch/e1583535/llm/openseal-sft/openseal-multilingual-sailor2ds-stage2"
    # "/scratch/e1583535/llm/openseal-dpo/openseal_dpo_multilingual_sail2s1"
    # "/scratch/e1583535/llm/openseal-dpo/openseal_dpo_sail2s1_seaexams3"
    # "/scratch/e1583535/llm/openseal-dpo/openseal_dpo_sail2s1_seaexams3_cosmos"
    # "/scratch/e1583535/llm/openseal-sft/openseal-seainstruct"
    # "swiss-ai/Apertus-8B-2509"
    # "swiss-ai/Apertus-8B-Instruct-2509"
    # "/scratch/e1583535/llm/openseal-sft/openseal-sft-quality_0.8_aya6lang_mcq"
    "/scratch/e1583535/llm/openseal-sft/openseal-sft-random_sailor_seainstruct_aya_mcq"
    "aisingapore/Llama-SEA-LION-v3-8B-IT"
    "aisingapore/Llama-SEA-LION-v3-8B"
)

# non-base-model Checkpoint
# CHECKPOINT_DIRS=(
#     # "SeaLLMs/SeaLLMs-v3-1.5B"
#     # "sail/Sailor2-L-1B"
#     # "aisingapore/Gemma-SEA-LION-v4-27B"
#     # "aisingapore/Qwen-SEA-LION-v4-32B-IT"
#     # "meta-llama/Llama-3.1-8B-Instruct"
# )

RUN_NAME="translation-only-260202"

BASE_MODEL=true

TASK_AND_NUM_EXAMPLES=(
    "translation_only 5"
    # "my_mixed_seahelm 5"
    # "my_mixed_seahelm 0"
    # "abssum 0"
    # "nlp_sentiment_nli_casual 5"
    # "qa_5shot 5"
    # "qa_0shot 0"
    # "abssum_5shot 5"
    # "abssum_1shot 1"
    # "abssum_2shot 2"
)

for TASK_AND_NUM in "${TASK_AND_NUM_EXAMPLES[@]}"; do
    TASK=$(echo $TASK_AND_NUM | cut -d' ' -f1)
    NUM_EXAMPLES=$(echo $TASK_AND_NUM | cut -d' ' -f2)

    echo "Running evaluation for task: $TASK with $NUM_EXAMPLES examples"

    OUTPUT_DIR="/scratch/e1583535/outputs/seahelm/${RUN_NAME}"

    POSTFIX=""
    if [ "$BASE_MODEL" = true ]; then
        POSTFIX="basemodel"
    else
        POSTFIX="instructed"
    fi 

    if [ "$NUM_EXAMPLES" -gt 0 ]; then
        POSTFIX="${POSTFIX}_${NUM_EXAMPLES}shot"
    else
        POSTFIX="${POSTFIX}_0shot"
    fi

    OUTPUT_DIR="${OUTPUT_DIR}/${POSTFIX}"

    echo "Output directory: $OUTPUT_DIR"

    if [ ! -d "$OUTPUT_DIR" ]; then
        mkdir -p "$OUTPUT_DIR"
    fi

    for CHECKPOINT_DIR in "${CHECKPOINT_DIRS[@]}"; do
        echo "Evaluating checkpoint directory: $CHECKPOINT_DIR"

        qsub -v CHECKPOINT_DIR="$CHECKPOINT_DIR",CHECKPOINT_NAME="$(basename $CHECKPOINT_DIR)",OUTPUT_DIR="$OUTPUT_DIR/$TASK",TASK="$TASK",NUM_EXAMPLES="$NUM_EXAMPLES",BASE_MODEL="$BASE_MODEL" \
        -N seahelm_eval_$(basename $CHECKPOINT_DIR)_$TASK \
        mass_seahelm_evaluation.pbs

        sleep 1
    done

    sleep 1
done
