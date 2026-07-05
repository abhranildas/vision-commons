function edge_llr = dv_edge_hist(patch_a, patch_b, thresh, bin_bounds, n_bins, sd1, nsd1, sd2, nsd2, feature_list)
% DV_EDGE_HIST  Edge / bar geometry histogram decision variables.
%   edge_llr = vislab.nat_stat_bayes.dv_edge_hist(patch_a, patch_b, thresh, ...
%                  bin_bounds, n_bins, sd1, nsd1, sd2, nsd2, feature_list)
%
%   Multinomial LLRs (different vs same, paper: ln L_e) for first-derivative
%   ("edge") and second-derivative ("bar") steerable responses, plus binomial
%   count LLRs for the number of above-threshold elements. (Was Re.m; the 6
%   duplicated LLR blocks now call vislab.nat_stat_bayes.multinomial_llr.)
%
%   Feature indices
%     4  = edge count      5 = edge magnitude   6 = edge orientation   7 = edge mag x ori
%     8  = bar count       9 = bar magnitude   10 = bar orientation   11 = bar mag x ori
%
%   Inputs
%     patch_a, patch_b - the two patches being compared (grayscale).
%     thresh           - gradient threshold for the count features (4, 8).
%     bin_bounds       - per-feature histogram bin edges (row f = bin_bounds(f,1:n_bins(f))).
%     n_bins           - number of bin edges per feature.
%     sd1, nsd1        - 1st-derivative kernel SD (px) and width (in SDs), for edges.
%     sd2, nsd2        - 2nd-derivative kernel SD (px) and width (in SDs), for bars.
%     feature_list     - vector; feature f is computed where feature_list(f) == 1.
%
%   Output
%     edge_llr - 1 x numel(feature_list) DVs (0 where not requested).
%
%   Fix vs original: the bar-count (feature 8) now uses the 2nd-derivative map of
%   patch_b (was mistakenly the 1st-derivative map). Not artifact-changing for the
%   proximity pipeline, which uses features [5,7,9,10].
%
%   See also vislab.nat_stat_bayes.MULTINOMIAL_LLR, vislab.nat_stat_bayes.BINOMIAL_COUNT_LLR.

    edge_llr = zeros(1, numel(feature_list));

    % steerable responses: 1st derivative (edges) and 2nd derivative (bars)
    [mag1_a, ori1_a] = vislab.lib.steerable_grad_response(patch_a, sd1, nsd1);
    [mag1_b, ori1_b] = vislab.lib.steerable_grad_response(patch_b, sd1, nsd1);
    [mag2_a, ori2_a] = vislab.lib.grad2_response(patch_a, sd2, nsd2);
    [mag2_b, ori2_b] = vislab.lib.grad2_response(patch_b, sd2, nsd2);
    npix1 = numel(mag1_a);

    % count features (binomial LLR on # above-threshold elements)
    if feature_list(4) == 1
        edge_llr(4) = vislab.nat_stat_bayes.binomial_count_llr(sum(mag1_a(:) > thresh), sum(mag1_b(:) > thresh), npix1);
    end
    if feature_list(8) == 1
        % nmax kept as npix1 to match the original (equals npix2 when sd1/nsd1 == sd2/nsd2)
        edge_llr(8) = vislab.nat_stat_bayes.binomial_count_llr(sum(mag2_a(:) > thresh), sum(mag2_b(:) > thresh), npix1);
    end

    % histogram features: {feature index, values_a, values_b}
    specs = {
        5,  mag1_a(:),               mag1_b(:);
        6,  ori1_a(:),               ori1_b(:);
        7,  mag1_a(:) .* ori1_a(:),  mag1_b(:) .* ori1_b(:);
        9,  mag2_a(:),               mag2_b(:);
        10, ori2_a(:),               ori2_b(:);
        11, mag2_a(:) .* ori2_a(:),  mag2_b(:) .* ori2_b(:)
    };
    for s = 1:size(specs, 1)
        k = specs{s, 1};
        if feature_list(k) == 1
            N1 = histcounts(specs{s, 2}, bin_bounds(k, 1:n_bins(k)));
            N2 = histcounts(specs{s, 3}, bin_bounds(k, 1:n_bins(k)));
            edge_llr(k) = vislab.nat_stat_bayes.multinomial_llr(N1, N2);
        end
    end
end
