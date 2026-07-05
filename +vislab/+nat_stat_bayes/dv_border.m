function border = dv_border(patch_a, patch_b, patch_size, direction, sd, nsd, show)
% DV_BORDER  Border decision variables between two adjacent patches.
%   border = vislab.nat_stat_bayes.dv_border(patch_a, patch_b, patch_size, direction, sd, nsd, show)
%
%   Concatenates the two patches along their shared edge, filters with the
%   first-derivative-of-Gaussian steerable kernels, and returns:
%     border(1) - log edge-energy ratio at the shared border (paper: E_b)
%     border(2) - mean log edge-energy ratio away from the border (paper: Ebar_b)
%     border(3) - normalized cross-correlation peak between the patches
%   (Was Rb.m.)
%
%   Inputs
%     patch_a, patch_b - the two patches being compared.
%     patch_size       - patch side length in pixels.
%     direction        - location of patch_b relative to patch_a:
%                          1 = below (stack vertically), 2 = right.
%     sd, nsd          - steerable Gaussian kernel SD (px) and width (in SDs).
%     show             - if true, display the joined patch (default false).
%
%   Output
%     border - 1x3 vector [border_energy, off_border_energy, cross_correlation].
%
%   NOTE: border(2) is the mean of the element-wise log edge-energy ratios ('./')
%   away from the border. The original Rb.m used '/' (matrix right-division = one
%   pooled least-squares ratio); Geisler confirmed (2026-07) it was meant to be
%   './' and corrected it in his fixed Rb.m, so we use './'. This is
%   behaviour-changing vs the preprint artifacts (affects the border DV dbndb/dbndbc).
%
%   See also vislab.nat_stat_bayes.XCORR_PATCHES, vislab.lib.DERIV_GAUSS1_KERNELS.

    if nargin < 7 || isempty(show), show = false; end

    border = zeros(1, 3);
    [k_horiz, k_vert] = vislab.lib.steerable_kernels(sd, nsd);
    psz2 = 2 * patch_size;

    if direction == 1                       % patch_b below patch_a
        joined = [patch_a; patch_b];
    else                                    % patch_b right of patch_a, then transpose
        joined = [patch_a, patch_b]';
    end

    if show
        clf; imagesc(joined); axis([1 patch_size 1 psz2], 'equal'); colormap('gray');
    end

    gh = conv2(joined, k_horiz, 'same');
    gv = conv2(joined, k_vert,  'same');
    sum_h = sum(abs(gh), 2)';               % per-row horizontal edge energy (1 x 2*psz)
    sum_v = sum(abs(gv), 2)';               % per-row vertical edge energy

    % (1) edge-energy ratio at the join (rows patch_size, patch_size+1)
    border(1) = log(sum(sum_h(patch_size:patch_size+1)) / sum(sum_v(patch_size:patch_size+1)));

    % (2) mean element-wise log-ratio away from the border  ('./' — Geisler-confirmed; see NOTE)
    av1 = mean(log(sum_h(1:patch_size-1) ./ sum_v(1:patch_size-1)));
    av2 = mean(log(sum_h(patch_size+1:psz2) ./ sum_v(patch_size+1:psz2)));
    border(2) = (av1 + av2) / 2;

    % (3) spatial cross-correlation of the two patches
    border(3) = vislab.nat_stat_bayes.xcorr_patches(patch_a, patch_b);
end
