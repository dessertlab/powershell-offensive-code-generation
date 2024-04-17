#!/bin/bash

LANG="powershell"
DATADIR=$1
OUTPUTDIR="/content/model"
PRETRAINDIR=$2  # will download pre-trained CodeGPT model
LOGFILE="/content/text2code.log"
NUM_EPOCHS=$3
NUM_TRAIN_SAMPLES=901
GRADIENT_STEPS=1
BATCH_SIZE=$((2 * $GRADIENT_STEPS))
STEPS=$(($NUM_EPOCHS * $NUM_TRAIN_SAMPLES / $BATCH_SIZE))
SAVE_STEPS=$(($STEPS / 3))
LOG_STEPS=$(($STEPS / 8))
OUT_DRIVE_DIR=$4 #.../model

echo $STEPS $SAVE_STEPS $BATCH_SIZE

python $PWD/Text-Code/text-to-code/code/run.py \
        --data_dir=$DATADIR \
        --langs=$LANG \
        --output_dir=$OUTPUTDIR \
        --pretrain_dir=$PRETRAINDIR \
        --model_type=gpt2 \
        --do_train \
        --do_infer \
        --node_index 0 \
        --gpu_per_node 1 \
        --learning_rate=5e-5 \
        --weight_decay=0.01 \
        --block_size=1024 \
        --evaluate_during_training \
        --per_gpu_train_batch_size=$BATCH_SIZE \
        --per_gpu_eval_batch_size=4 \
        --gradient_accumulation_steps=$GRADIENT_STEPS \
        --num_train_epochs=$NUM_EPOCHS \
        --logging_steps=$LOG_STEPS \
        --save_steps=$SAVE_STEPS \
        --save_total_limit=1 \
        --overwrite_output_dir \
        --log_file=$LOGFILE \
        --seed=42 \
        --hf_token=$5

mkdir $OUT_DRIVE_DIR
cp -r /content/model/checkpoint-last $OUT_DRIVE_DIR
cp /content/model/* $OUT_DRIVE_DIR
mv $LOGFILE $OUT_DRIVE_DIR