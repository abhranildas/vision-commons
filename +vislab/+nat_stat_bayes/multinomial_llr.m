function llr = multinomial_llr(counts_a, counts_b)
% MULTINOMIAL_LLR  Multinomial log-likelihood ratio, different vs same.
%   llr = vislab.nat_stat_bayes.multinomial_llr(counts_a, counts_b)
%
%   Implements the histogram decision variable of the HBO model (paper Eq. 1,
%   derived as Eq. A4): given the per-bin histogram counts of a feature in two
%   patches, returns the log-likelihood ratio that the patches were drawn from
%   different vs the same multinomial distribution. Empty bins contribute 0; the
%   ratio is clamped at 0 (matching the original R* code).
%
%   Inputs
%     counts_a, counts_b - per-bin histogram counts for the two patches.
%
%   Output
%     llr - log-likelihood ratio (>= 0). Paper symbol: ln L_h (spot/histogram DV).
%
%   See also vislab.nat_stat_bayes.DV_SPOT_HIST, vislab.nat_stat_bayes.DV_EDGE_HIST.

    a = counts_a(:);
    b = counts_b(:);
    total = a + b;
    na = sum(a);
    nb = sum(b);
    xlogx_ratio = @(N, n) sum(N(N > 0) .* log(N(N > 0) / n));   % skips empty bins
    llr = max(xlogx_ratio(a, na) + xlogx_ratio(b, nb) - xlogx_ratio(total, na + nb), 0);
end
