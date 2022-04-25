# noise-suppression
Using MATLAB and its Audio Toolbox™ and Deep Learning Toolbox™ products to develop and train a noise suppression deep learning network.

## Introduction
This is a MLH Fellowship project assignment and project 193 of MathWorks Excellence in Innovation Projects. Detailed problem description proposed by MathWorks [here](https://github.com/mathworks/MathWorks-Excellence-in-Innovation/tree/main/projects/Speech%20Background%20Noise%20Suppression%20with%20Deep%20Learning). Part of [Microsoft Deep Noise Suppression (DNS) Challenge](https://github.com/microsoft/DNS-Challenge).

Our submission is a MATLAB implementation of the resarch paper, [FullSubNet: A Full-Band and Sub-Band Fusion Model for Real-Time Single-Channel Speech Enhancement](https://arxiv.org/abs/2010.15508), submitted by Hao, Xiang, et al. from Cornell University in October 2020.

## Notes
Our repository includes the previous submission of this MathWorks Excellence in Innovation project, [MATLAB-denoise](https://github.com/YilikaLoufoua/noise-suppression/tree/main/MATLAB-denoise), which performed noise suppression with the neural network they designed and trained using Gaussian noise (algorithmically generated signals). As a result, the model performed less idealy when tasked to denoise speech with realistic background noise (such as noises from a washing machine). Therefore, as part of our project, we trained their model on noise datasets provided in the Microsoft DNS Challenge repository.

## Getting Started
### Data
#### Clean Speech and Noise
Our datasets used are from Deep Noise Suppression (DNS) Challenge 4 Personalized Track - ICASSP 2022. It consists of roughly 200 GB of clean speech and noise audio data. You can download the desired datasets from https://github.com/microsoft/DNS-Challenge.git by following the instruction.

### Environment
Our model was built and trained using MATLAB R2021b. It's been found that using a newer version of MATLAB for training will lead to critical errors due to deep learning related updates.

#### Required MATLAB Add-Ons
Audio Toolbox, Deep Learning Toolbox

#### Optional MATLAB Add-Ons
Parallel Computing Toolbox (for improved training speed)

### Training
First, clone the repository, then move the downloaded and extracted datasets into the directory `noise-suppression`, organized by `datasets_fullband/clean_fullband` and `datasets_fullband/noise_fullband`. Navigate into the directory `model`, and run the script `denoiseTrain`. The trained the model will be saved out to 'denoiseNet.mat'.

### Inference 
After training, you can denoise audio using our model. Run the script `denoise`, and you will be prompted to select an audio file. Then, our model will generated the denoised audio and save out to 'denoisedAudio.wav'.

## Acknowledgements
https://github.com/haoxiangsnr/FullSubNet  
https://github.com/BanmaS/MATLAB-denoise

## Licenses
This project is licensed under the BSD 2-Clause License - see the LICENSE file for details.
