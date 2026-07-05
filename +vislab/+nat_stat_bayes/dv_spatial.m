function spatial_dv = dv_spatial(patch_a, patch_b, patch_size)
% DV_SPATIAL  Spatial-pattern-similarity decision variable between two patches.
%   spatial_dv = vislab.nat_stat_bayes.dv_spatial(patch_a, patch_b, patch_size)
%
%   Compares the spatial layout of two patches by the best normalized
%   cross-correlation over all circular shifts: each patch is zero-meaned and
%   L2-normalized, then patch_a is circularly shifted by every (dx, dy) in
%   1:patch_size and correlated with patch_b; the largest correlation is the
%   best spatial match. The DV is the reciprocal of that maximum, so more
%   similar patterns give a SMALLER value. (Was Rs.m in texture-segmentation /
%   camouflage_detection edgecode; the unused post-loop reshift was dropped.)
%
%   Inputs
%     patch_a, patch_b - patches to compare (grayscale, patch_size x patch_size).
%     patch_size       - patch side length in pixels (circular-shift range).
%
%   Output
%     spatial_dv - 1 / (max shifted normalized cross-correlation).
%
%   See also vislab.nat_stat_bayes.DV_POWER, vislab.nat_stat_bayes.XCORR_PATCHES.

    p1 = normalize_patch(patch_a);
    p2 = normalize_patch(patch_b);

    best_corr = -1;
    for dx = 1:patch_size
        for dy = 1:patch_size
            corr = sum(sum(circshift(p1, [dx, dy]) .* p2));
            if corr > best_corr
                best_corr = corr;
            end
        end
    end
    spatial_dv = 1 / best_corr;
end

function p = normalize_patch(patch)
    p = patch - mean(patch(:));
    p = p / sqrt(sum(p(:).^2));
end
