function power_llr = dv_power(patch_a, patch_b, noise_suppress, patch_size)
% DV_POWER  Power-spectrum decision variable between two patches.
%   power_llr = vislab.nat_stat_bayes.dv_power(patch_a, patch_b, noise_suppress, patch_size)
%
%   The HBO power-spectrum log-likelihood ratio (paper: ln L_p). Each patch's
%   normalized power spectrum is compared frequency by frequency; the DV is the
%   mean log of (Pa+Pb)^2 / (4 Pa Pb) over the spectrum. (Was Rp.m.)
%
%   Inputs
%     patch_a, patch_b - patches to compare (grayscale).
%     noise_suppress   - weak-power (noise) suppression constant (paper: beta).
%     patch_size       - patch side length in pixels (normalizer).
%
%   Output
%     power_llr - power-spectrum decision variable. Paper symbol: ln L_p.
%
%   See also vislab.nat_stat_bayes.DV_SPOT_HIST, vislab.nat_stat_bayes.DV_EDGE_HIST.

    spec_a = normalized_power(patch_a, noise_suppress);
    spec_b = normalized_power(patch_b, noise_suppress);
    ratio = (spec_a + spec_b).^2 ./ (4 * spec_a .* spec_b);
    power_llr = sum(log(ratio(:))) / patch_size^2;
end

function power = normalized_power(patch, noise_suppress)
    patch = patch - mean(patch(:));
    spec  = abs(fftshift(fft2(fftshift(patch)))).^2;
    power = spec / mean(spec(:)) + noise_suppress;
end
