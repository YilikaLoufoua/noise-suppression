# MATLAB-denoise
This code is an improvement based on the repo [MathWorks-Excellence-in-Innovation project 193 & SJTU EE397 project](https://github.com/BanmaS/MATLAB-denoise/tree/cd98bbfd014d84b742b596c2857edc16b789cf66).

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
