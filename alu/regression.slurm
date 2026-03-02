#!/bin/bash
#SBATCH --job-name=alu_verif
#SBATCH --array=1-100                 # Run 100 random seeds
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --time=00:15:00
#SBATCH --output=/dev/null            # Discard default slurm logs
#SBATCH --error=/dev/null

# 1. Safely create the logs directory (won't error if it exists)
mkdir -p logs

LOG_FILE="logs/sim_${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_TASK_ID}.log"

echo "Starting simulation array task ${SLURM_ARRAY_TASK_ID} on node $(hostname)" > $LOG_FILE

# 2. Execute the simulation and redirect output to the log file
vvp alu_regression.vvp +SEED=${SLURM_ARRAY_TASK_ID} >> $LOG_FILE 2>&1

echo "Finished task ${SLURM_ARRAY_TASK_ID}" >> $LOG_FILE