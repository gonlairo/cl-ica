#!/bin/bash
#SBATCH --partition=normal
#SBATCH --job-name=dynl-worker
#SBATCH --time=08:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=20
#SBATCH --mem=30000
#SBATCH --gres=gpu:full:1
#SBATCH --output=slurm_output/worker_3dicml%A_%a_%j.out
#SBATCH --signal=TERM@300


# Function to handle the SIGTERM signal
terminate() {
    echo "Caught SIGTERM signal! Terminating child processes..."
    # Send SIGTERM to all background processes
    kill $(jobs -p)
    wait
    echo "All background processes terminated."
}

source ~/miniconda3/etc/profile.d/conda.sh
conda activate dynamics
which python
python -c "import torch; print('torch', torch.__version__)"
python -c "import torch; print('torch:is_cuda_available', torch.cuda.is_available())"
python -c "import numpy; print('numpy', numpy.__version__)"
python -c "import dynamic_cebra; print('Dynamic-Cebra package available')"

nvidia-smi

python main_3dident.py --offline-dataset "/home/hgf_hmgu/hgf_gib4562/dynamics-learning/data/3dident-icml/train" --mode "unsupervised" --batch-size 512 --workers 0 --n-eval-samples 4096 --iterations 5000 --save-model "/home/hgf_hmgu/hgf_gib4562/dynamics-learning/logs" --n-log-steps 500 --save-every 500

wait

echo DONE