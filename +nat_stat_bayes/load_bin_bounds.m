function [n_bins, bin_bounds] = load_bin_bounds(feature_btype, lev, filter)
% LOAD_BIN_BOUNDS  Load per-feature adaptive-histogram bin bounds from disk.
%   [n_bins, bin_bounds] = nat_stat_bayes.load_bin_bounds(feature_btype, lev, filter)
%
%   Loads the precomputed histogram bin bounds for each feature dimension.
%   (Was mk_bb.m.) File naming: AHE<btype><feature><lev>.mat (filter == 0) or
%   AHEO<btype><feature><lev>.mat (filter == 1, optics applied), each containing
%   variables `bnds` and `nbnds`. The bound files must be on the MATLAB path
%   (added by the project's setup.m / config).
%
%   Inputs
%     feature_btype - vector; feature_btype(f) = bin type for feature f
%                     (0 = skip that feature). Paper features are indexed 1-14.
%     lev           - eccentricity downsample level (1, 2, 4, 8).
%     filter        - 1 if optics (OTF) applied when the bounds were trained, else 0.
%
%   Outputs
%     n_bins     - 1 x n_features vector of the number of bin bounds per feature.
%     bin_bounds - n_features x max_bins matrix; row f holds bin_bounds(f,1:n_bins(f)).
%
%   See also NAT_STAT_BAYES.DV_SPOT_HIST, NAT_STAT_BAYES.DV_EDGE_HIST.

    max_bins = 100;
    n_features = numel(feature_btype);
    bin_bounds = zeros(n_features, max_bins);
    n_bins = zeros(1, n_features);

    for f = 1:n_features
        if feature_btype(f) > 0
            if filter == 0
                name = sprintf('AHE%d%d%d.mat', feature_btype(f), f, lev);
            else
                name = sprintf('AHEO%d%d%d.mat', feature_btype(f), f, lev);
            end
            s = load(name, 'bnds', 'nbnds');
            n_bins(f) = s.nbnds;
            bin_bounds(f, 1:s.nbnds) = s.bnds;
        end
    end
end
