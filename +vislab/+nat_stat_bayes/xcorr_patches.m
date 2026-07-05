function [peak_xcorr, peak_index] = xcorr_patches(patch_a, patch_b)
% XCORR_PATCHES  Normalized circular cross-correlation peak between two patches.
%   [peak_xcorr, peak_index] = vislab.nat_stat_bayes.xcorr_patches(patch_a, patch_b)
%
%   Whitens each patch's amplitude spectrum, cross-correlates them circularly
%   via the FFT, and returns the peak (scaled by 1e4) and its linear index.
%   Used as the spatial-similarity component of the border DV.
%
%   (Was Rcc.m. The unused "structuredness" branch (crits > 0) is removed here:
%   every in-repo caller passed crits = 0, and it depended on the missing
%   fstruc function.)
%
%   Inputs
%     patch_a, patch_b - patches to compare (grayscale).
%
%   Outputs
%     peak_xcorr - maximum normalized cross-correlation, scaled by 1e4.
%     peak_index - linear index of the peak in the cross-correlation map.
%
%   See also vislab.nat_stat_bayes.DV_BORDER.

    fa = whitened_spectrum(patch_a);
    fb = whitened_spectrum(patch_b);
    xcorr_map = ifftshift(ifft2(ifftshift(fa .* fb)));
    [peak, peak_index] = max(xcorr_map, [], 'all');
    peak_xcorr = peak * 1e4;
end

function f = whitened_spectrum(patch)
    patch = patch - mean(patch(:));
    spec  = fftshift(fft2(fftshift(patch)));
    f     = spec / sqrt(sum(abs(spec(:)).^2));   % unit total power
end
