function patch_out = cntrst_norm(patch, target_contrast, patch_size)
% CNTRST_NORM  Normalize a patch to a target RMS contrast about its mean.
%   patch_out = vislab.lib.cntrst_norm(patch, target_contrast, patch_size)
%
%   Rescales the fluctuations of a (grayscale) patch so their RMS relative to
%   the patch mean equals target_contrast, leaving the mean unchanged.
%
%   Inputs
%     patch           - grayscale image patch [H x W].
%     target_contrast - desired RMS contrast (fluctuation RMS / mean).
%     patch_size      - side length used to normalize the sum of squares
%                       (default size(patch,1); assumes a square patch).
%
%   Output
%     patch_out - contrast-normalized patch, same size as patch.
%
%   See also vislab.lib.PTCH_NORM.

    if nargin < 3 || isempty(patch_size)
        patch_size = size(patch, 1);
    end
    patch_mean = mean(patch(:));
    centered   = patch - patch_mean;
    rms        = sqrt(sum(centered(:).^2) / patch_size^2);
    patch_out  = centered * target_contrast * patch_mean / rms + patch_mean;
end
