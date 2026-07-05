function llr = binomial_count_llr(count_a, count_b, n_max)
% BINOMIAL_COUNT_LLR  Log-likelihood ratio for present/absent element counts.
%   llr = vislab.nat_stat_bayes.binomial_count_llr(count_a, count_b, n_max)
%
%   Decision variable for the number of above-threshold edge (or bar) elements
%   in two patches: the LLR that the two counts came from different vs the same
%   binomial rate, out of n_max possible locations. Returns 0 if undefined
%   (NaN), matching the original R* code.
%
%   Inputs
%     count_a, count_b - number of above-threshold elements in each patch.
%     n_max            - number of possible locations (pixels).
%
%   Output
%     llr - log-likelihood ratio.
%
%   See also vislab.nat_stat_bayes.DV_EDGE_HIST.

    n1 = count_a;
    n2 = count_b;
    llr = n1*log(2*n1/(n1+n2)) + (n_max-n1)*log(2*(n_max-n1)/(2*n_max-n1-n2)) + ...
          n2*log(2*n2/(n1+n2)) + (n_max-n2)*log(2*(n_max-n2)/(2*n_max-n1-n2));
    if isnan(llr)
        llr = 0;
    end
end
