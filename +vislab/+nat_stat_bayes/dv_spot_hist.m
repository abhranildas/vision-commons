function spot_llr = dv_spot_hist(abr_a, abr_b, patch_size, bin_bounds, n_bins, feature_list)
% DV_SPOT_HIST  Colour / center-surround histogram decision variables.
%   spot_llr = vislab.nat_stat_bayes.dv_spot_hist(abr_a, abr_b, patch_size, ...
%                  bin_bounds, n_bins, feature_list)
%
%   Multinomial log-likelihood ratios (different vs same, paper: ln L_h) for the
%   ABR opponent pixel channels (features 1-3) and center-surround responses of
%   the achromatic channel (features 12-14). Both patches must already be in ABR
%   opponent colour space. (Was Rh.m; the 6 duplicated LLR blocks now call
%   vislab.nat_stat_bayes.multinomial_llr, and the stray email note is removed.)
%
%   Feature indices
%     1  = A (achromatic) pixel        12 = A center-surround, log ratio (3x3)
%     2  = B (blue-yellow) pixel        13 = A center-surround, small linear (3x3)
%     3  = R (red-green) pixel          14 = A center-surround, large linear (5x5)
%
%   Inputs
%     abr_a, abr_b - patches in ABR opponent space, [H x W x 3].
%     patch_size   - patch side length in pixels.
%     bin_bounds   - per-feature histogram bin edges, row f = bin_bounds(f,1:n_bins(f)).
%     n_bins       - number of bin edges per feature.
%     feature_list - vector; feature f is computed where feature_list(f) == 1.
%
%   Output
%     spot_llr - 1 x numel(feature_list) DVs (0 where not requested).
%
%   See also vislab.nat_stat_bayes.MULTINOMIAL_LLR, vislab.nat_stat_bayes.DV_EDGE_HIST.

    spot_llr = zeros(1, numel(feature_list));
    npix = patch_size^2;
    px_a = reshape(abr_a, [], 3);
    px_b = reshape(abr_b, [], 3);

    % pixel channels 1-3 (A, B, R)
    for k = 1:3
        if feature_list(k) == 1
            N1 = histcounts(px_a(1:npix, k), bin_bounds(k, 1:n_bins(k)));
            N2 = histcounts(px_b(1:npix, k), bin_bounds(k, 1:n_bins(k)));
            spot_llr(k) = vislab.nat_stat_bayes.multinomial_llr(N1, N2);
        end
    end

    % center-surround responses of the achromatic channel (features 12-14)
    % columns: [feature index, surround width, cs_type, border trim]
    cs_spec = [12, 3, 1, 2;
               13, 3, 2, 2;
               14, 5, 4, 4];
    if any(feature_list(12:14) == 1)
        target_contrast = 0.25;
        ch_a = vislab.lib.cntrst_norm(abr_a(:, :, 1), target_contrast, patch_size);
        ch_b = vislab.lib.cntrst_norm(abr_b(:, :, 1), target_contrast, patch_size);
        for s = 1:size(cs_spec, 1)
            k = cs_spec(s, 1);
            if feature_list(k) == 1
                cs_a = vislab.lib.center_surround(ch_a, cs_spec(s, 2), cs_spec(s, 3));
                cs_b = vislab.lib.center_surround(ch_b, cs_spec(s, 2), cs_spec(s, 3));
                n_cs = (patch_size - cs_spec(s, 4))^2;
                va = reshape(cs_a, [], 1);
                vb = reshape(cs_b, [], 1);
                N1 = histcounts(va(1:n_cs), bin_bounds(k, 1:n_bins(k)));
                N2 = histcounts(vb(1:n_cs), bin_bounds(k, 1:n_bins(k)));
                spot_llr(k) = vislab.nat_stat_bayes.multinomial_llr(N1, N2);
            end
        end
    end
end
