function [test_bounds, test_indices] = find_bin_bound(bounds, indices, n_bins, bin, cdf_x, cdf_p)
% FIND_BIN_BOUND  Insert a candidate bin boundary at the CDF midpoint of a bin.
%   [test_bounds, test_indices] = vislab.nat_stat_bayes.find_bin_bound(bounds, ...
%                                     indices, n_bins, bin, cdf_x, cdf_p)
%
%   Adaptive-histogram-equalization step: split the given bin at its
%   cumulative-probability midpoint and return the candidate bound set (current
%   bounds plus the new one) for accuracy testing. (Was find_bnd.m; the original
%   mbin==1 special case was dead code -- both branches divided by 2 -- and is
%   removed.)
%
%   Inputs
%     bounds  - current bin bounds (length n_bins+1).
%     indices - CDF indices of the current bounds.
%     n_bins  - current number of bins.
%     bin     - index of the bin to split.
%     cdf_x   - feature values (CDF x-axis).
%     cdf_p   - cumulative probabilities (CDF y-axis).
%
%   Outputs
%     test_bounds  - candidate bounds including the new one (length n_bins+2).
%     test_indices - corresponding CDF indices.
%
%   See also vislab.nat_stat_bayes.MAKE_BINS.

    test_bounds  = zeros(1, n_bins + 2);
    test_indices = zeros(1, n_bins + 2);

    lo = indices(bin);
    hi = indices(bin + 1);
    target = cdf_p(lo) + (cdf_p(hi) - cdf_p(lo)) / 2;    % midpoint in cumulative prob

    j = 1;
    found = false;
    while ~found
        j = j + 1;
        if cdf_p(j) <= target && cdf_p(j+1) >= target
            found = true;
        end
    end

    test_bounds(1:bin)          = bounds(1:bin);
    test_bounds(bin + 1)        = cdf_x(j);
    test_bounds(bin+2:n_bins+2) = bounds(bin+1:n_bins+1);

    test_indices(1:bin)          = indices(1:bin);
    test_indices(bin + 1)        = j;
    test_indices(bin+2:n_bins+2) = indices(bin+1:n_bins+1);
end
