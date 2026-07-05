function plot_bin_bounds(bounds, n_bounds, first, last, pad)
% PLOT_BIN_BOUNDS  Diagnostic plots of histogram bin bounds.
%   vislab.nat_stat_bayes.plot_bin_bounds(bounds, n_bounds, first, last, pad)
%
%   Draws three diagnostic figures: bin bounds on a line, as stems, and bin
%   width vs bin center. Visualization only. (Was plotbnds.m.)
%
%   Inputs
%     bounds   - vector of bin bounds.
%     n_bounds - number of bounds to use.
%     first    - index of first bound to frame in the x-limits.
%     last     - index of last bound to frame in the x-limits.
%     pad      - extra x-axis padding.

    x_limits = [bounds(first) - pad, bounds(last) + pad];

    figure;
    plot(bounds(1:n_bounds), ones(n_bounds, 1), 'k-o', 'markerfacecolor', 'k');
    xlim(x_limits); set(gca, 'YTick', []); xlabel('Bin Bounds');

    figure;
    stem(bounds(1:n_bounds), ones(n_bounds, 1), 'k-o', 'markerfacecolor', 'k');
    xlim(x_limits); ylim([0 2]); set(gca, 'YTick', []); xlabel('Bin Bounds');

    centers = (bounds(1:n_bounds-1) + bounds(2:n_bounds)) / 2;
    widths  = diff(bounds(1:n_bounds));
    figure;
    plot(centers, widths, 'k-o', 'markerfacecolor', 'k');
    xlim(x_limits); xlabel('Bin Centers'); ylabel('Bin Width');
end
