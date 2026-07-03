function patch_out = apply_color_rotation(patch, rotation, patch_size)
% APPLY_COLOR_ROTATION  Apply a 3x3 colour rotation to a patch (e.g. LMS->ABR).
%   patch_out = nat_stat_bayes.apply_color_rotation(patch, rotation, patch_size)
%
%   Rotates each pixel's colour vector by the given 3x3 matrix. Used to map LMS
%   cone responses into the PCA/opponent "ABR" (achromatic, blue-yellow,
%   red-green) axes learned from natural images. (Was rot.m.)
%
%   Inputs
%     patch      - [patch_size x patch_size x 3] colour patch.
%     rotation   - 3x3 rotation/PCA matrix (e.g. the coeff from learn_color_transform).
%     patch_size - patch side length in pixels.
%
%   Output
%     patch_out  - rotated patch, same size as patch.

    pixels = reshape(patch, [], 3) * rotation;
    patch_out = reshape(pixels, patch_size, patch_size, 3);
end
