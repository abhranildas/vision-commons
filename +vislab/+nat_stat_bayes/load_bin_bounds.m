function [n_bins, bin_bounds] = load_bin_bounds(feature_btype, ecc, filter)
% LOAD_BIN_BOUNDS  Load per-feature adaptive-histogram bin bounds from disk.
%   [n_bins, bin_bounds] = vislab.nat_stat_bayes.load_bin_bounds(feature_btype, ecc, filter)
%
%   Loads the precomputed histogram bin bounds for each feature dimension. (Was
%   mk_bb.m.) The bounds used to live in one file per feature/eccentricity
%   (AHE(O)<btype><feature><ecc>.mat); they are now kept in a SINGLE consolidated
%   file that holds every feature and eccentricity:
%     * filter == 1 (optics applied):  AHEO_bins.mat
%     * filter == 0 (no optics):       AHE_bins.mat
%   written by s4_optimize_bins and placed on the MATLAB path by the project setup.
%
%   Consolidated-file contents (see also s4_optimize_bins):
%     bin_bounds - cell, size [n_features x n_ecc]. bin_bounds{f,e} is the column
%                  vector of bin edges for feature f at eccentricity column e
%                  (empty [] if that feature/eccentricity was not trained).
%     n_bins     - double [n_features x n_ecc]; n_bins(f,e) = numel(bin_bounds{f,e}).
%     eccs       - 1 x n_ecc; the eccentricity (1,2,4,8) of each column e.
%     btype      - bound type (5 = natural images).
%
%   Inputs
%     feature_btype - vector; feature_btype(f) > 0 selects feature f (0 = skip it).
%                     Paper features are indexed 1-14.
%     ecc           - eccentricity (1,2,4,8); must appear in the file's `eccs`.
%     filter        - 1 if optics (OTF) applied when the bounds were trained, else 0.
%
%   Outputs (UNCHANGED from the per-file version -- callers are unaffected)
%     n_bins     - 1 x n_features vector of the number of bin bounds per feature.
%     bin_bounds - n_features x max_bins matrix; row f holds bin_bounds(f,1:n_bins(f)).
%
%   See also vislab.nat_stat_bayes.DV_SPOT_HIST, vislab.nat_stat_bayes.DV_EDGE_HIST.

    if filter == 0
        file = 'AHE_bins.mat';
    else
        file = 'AHEO_bins.mat';
    end
    S = load(file, 'bin_bounds', 'n_bins', 'eccs');

    ecc_idx = find(S.eccs == ecc, 1);
    if isempty(ecc_idx)
        error('nat_stat_bayes:load_bin_bounds:noEcc', ...
            'No bin bounds for eccentricity %d in %s (available eccentricities: %s).', ...
            ecc, file, mat2str(S.eccs));
    end

    n_features = numel(feature_btype);
    max_bins   = max(100, max(S.n_bins(:)));   % output width; callers read only 1:n_bins(f)
    bin_bounds = zeros(n_features, max_bins);
    n_bins     = zeros(1, n_features);

    for f = 1:n_features
        if feature_btype(f) > 0
            b = S.bin_bounds{f, ecc_idx};
            n_bins(f) = numel(b);
            bin_bounds(f, 1:numel(b)) = b(:).';
        end
    end
end
