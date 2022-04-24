
# FullSubNet Denoise Model **[INCOMPLETE]**
This version of the model is a matlab implementation of the paper ["FullSubNet: A Full-Band and Sub-Band Fusion Model for Real-Time Single-Channel Speech Enhancement"](https://arxiv.org/abs/2010.15508) and referencing the [pytorch implementation](https://github.com/haoxiangsnr/FullSubNet) of the same model provided by the researchers.This version of a model uses fusion of sub-band and full-band and is trained using [DNS dataset](https://github.com/microsoft/DNS-Challenge).

The entry point to the training is [fullsubnet.m](https://github.com/YilikaLoufoua/noise-suppression/blob/main/noise-suppression/model/fullsubnet.m).

## Current issue
Although our team tried our best to write out and debug the model, we are still not able to produce satisfactory training result. The best RMSE is ~40. Nonetheless, we have included the trained model after 16 hours in the folder. 

The major area we suspect that might be causing the issue is the custom layers we write out.
* unfoldLayer.m & im2col_cus.m: apply unfolding to the full-band portion of model, convert windows to column vectors [line 95](https://github.com/haoxiangsnr/FullSubNet/blob/main/recipes/dns_interspeech_2020/fullsubnet/model.py)
* normLayer.m: apply offline laplace normalization once in full-band and another in sub-band portion according to [line 63](https://github.com/haoxiangsnr/FullSubNet/blob/main/recipes/dns_interspeech_2020/fullsubnet/model.py)
* buld_complex_ideal_ratio_mask.m: part of preprocessing, according to pytorch code [line 30](https://github.com/haoxiangsnr/FullSubNet/blob/main/recipes/dns_interspeech_2020/fullsubnet/trainer.py)

**We welcome anyone who might be interested to improve on our code!**
