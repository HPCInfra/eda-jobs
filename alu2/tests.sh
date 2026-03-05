#!/bin/bash
#SBATCH --job-name=alu-test
#SBATCH --array=1-32
#SBATCH --output=test-%a.out
#SBATCH --error=test-%a.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --time=00:05:00

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# alu_tb.out must already exist -- compile on the head node with: make submit
if [ ! -f alu_tb.out ]; then
    echo "ERROR: alu_tb.out not found. Please compile first: iverilog -Wall -o alu_tb.out alu.v alu_tb.v"
    exit 1
fi

TEST_NUM=$SLURM_ARRAY_TASK_ID
TEST_NAME=$(awk -v n="$TEST_NUM" '$1 == n { print $2 }' tests.txt)

echo "=== Test #${TEST_NUM} (${TEST_NAME}) ==="
echo "Host: $(hostname), Time: $(date)"
echo "---"

vvp alu_tb.out +TEST_NUM="$TEST_NUM"
