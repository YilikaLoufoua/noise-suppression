# MATLAB-denoise
MathWorks-Excellence-in-Innovation project 193 & SJTU EE397 project
## Introduction
This is the course project of SJTU EE397 course and project 193 of MathWorks Excellence in Innovation Projects. We learn from the idea of RNNoise and implement a speech noise reduction system based on MATLAB deep learning.
## Remind
* The TrainNetworks folder is used to train and simply test the network, use the ```DenoiseTrain.m``` to start it.
* The code in ```objective comment``` is used to evalute the effect, with the objective comment.
* Before run it, please download the ```voicebox``` in your MATLAB from http://www.ee.ic.ac.uk/hp/staff/dmb/voicebox/voicebox.html
* To use automatic unzip, download [bzip2](https://www.sourceware.org/bzip2/) if you are Windows user.
## What we have improved
* Train with DNS provided noise sample instead of random Gaussian noise
* Automatic batch processing, including automatically fetching from DNS database url and unzip
## Training result
We have included a pretrained model trained with over 16000 audio samples for over 16 hours. You can test out the result by running DenoiseTest.mlx live script.

Below is an sample plot and spectrogram:

![](https://github.com/YilikaLoufoua/noise-suppression/blob/main/MATLAB-denoise/result1.JPG?raw=true)
![](https://github.com/YilikaLoufoua/noise-suppression/blob/main/MATLAB-denoise/result2.JPG?raw=true)
