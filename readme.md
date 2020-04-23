This repo contains the instructions, scripts, and codes needed to reproduce the
experiments for our SC paper named:
"XPlacer: A framework for Guiding Optimal Use of GPU Unified Memory"

Overview of major steps
* Step 1. Collect baseline metrics for both kernel-level and object level features
* Step 2. Merge kernel and object level features
* Step 3. Label the training data
* Step 4. Generate the model
* Step 5. Use the model to predict a new kernel’s object policies	

# Step 1. Collect Baseline Metrics for Kernel and Object Level Features

Kernel level feature vector: f(K1) = < f1, f2… fn,> (K1)  
* e.g.  <input size, cycles (8991), duration (3520, nsecond), mem % (9.27, %)>

How to collect kernel level metrics (baseline experiment)
* using nsight run default, discrete memory API version of a program  (select this for now)

Build all necessary code variants for the program
Prerequisites: 
* aws-volta: nvcc --version, V10.2.89
* a GPU machine running Ubuntu 18.04 LTS
* python3 and python3-pandas  // apt-get install python3-pandas

Build the cuda-adapter library 
cd rodinia_3.1/cuda-adapter 
type make 

Build up to 7*7*7 = 343 binary variants for the benchmark, using a script 

e.g: rodinia_3.1/cuda/cfd/compile.sh or compile-aws-volta.sh (trying to run nvcc in background with some parallelism) 
you need to customize the environment variables in the scripts first.

hostname-exectuable/ will contain the generated binary variants. run “ls |wc” will show if there are correct number of files under this path


