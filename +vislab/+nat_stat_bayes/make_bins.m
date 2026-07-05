function [bin_edges, edge_indices] = make_bins(cdf_x, cdf_p, n_bins)
% MAKE_BINS  Equal-probability histogram bin edges from a CDF (efficient coding).
%   [bin_edges, edge_indices] = vislab.nat_stat_bayes.make_bins(cdf_x, cdf_p, n_bins)
%
%   Places bin edges at equal steps of cumulative probability (1/n_bins apart),
%   i.e. histogram equalization of the prior feature distribution. If several
%   target probabilities fall within one CDF step (a flat region), the bin count
%   is reduced accordingly, so the returned edges may be fewer than requested.
%   (Was mk_bins.m.)
%
%   Inputs
%     cdf_x  - feature values (CDF x-axis).
%     cdf_p  - cumulative probabilities at cdf_x (CDF y-axis), in [0,1].
%     n_bins - requested number of bins.
%
%   Outputs
%     bin_edges    - bin edges (first -inf, last inf), length (final n_bins)+1.
%     edge_indices - indices into the CDF for each edge.
%
%   See also vislab.nat_stat_bayes.FIND_BIN_BOUND.

    [~, ncdf] = size(cdf_x);
    n_edges = 1;
    bin_edges    = zeros(1, n_bins + 1);
    edge_indices = zeros(1, n_bins + 1);
    p_step = 1 / n_bins;
    p = p_step;
    for i = 1:ncdf-2
        if (cdf_p(i) < p) && (cdf_p(i+1) > p)
            n_edges = n_edges + 1;
            bin_edges(n_edges)    = cdf_x(i);
            edge_indices(n_edges) = i + 1;
            p = p + p_step;
            while cdf_p(i+1) > p        % skip target probabilities in a flat CDF region
                p = p + p_step;
                n_bins = n_bins - 1;
            end
        end
    end
    bin_edges(n_bins + 1) = inf;
    bin_edges(1) = -inf;
    edge_indices(1) = 1;
    bin_edges = bin_edges(1:n_bins + 1);
    edge_indices(n_bins + 1) = ncdf - 1;
end
