function complex_ratio_mask = buld_complex_ideal_ratio_mask(noisy_real, noisy_imag, clean_real, clean_imag)
denominator =noisy_real.^2 + noisy_imag.^2 + eps;
mask_real = (noisy_real .* clean_real + noisy_imag .* clean_imag) ./ denominator;
mask_imag = (noisy_real .* clean_imag - noisy_imag .* clean_real) ./ denominator;
complex_ratio_mask = cat( length(size(mask_real))+1,mask_real, mask_imag);
complex_ratio_mask = compress_cIRM(complex_ratio_mask, 10,0.1);
end

function result_mask = compress_cIRM(mask, K, C)
    mask = -100 .* (mask <= -100) + mask .* (mask > -100);
    result_mask = K .* (1 - exp(-C .* mask)) ./ (1 + exp(-C .* mask));
end
