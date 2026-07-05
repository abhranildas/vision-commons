function [patch_out, channel_means] = ptch_norm(patch, target_mean, target_contrast, norm_type, n_channels)
% PTCH_NORM  Normalize an image patch's mean and/or contrast.
%   [patch_out, channel_means] = vislab.lib.ptch_norm(patch, target_mean, ...
%                                    target_contrast, norm_type, n_channels)
%
%   Rescales a patch to a target mean grey level (and optionally RMS contrast)
%   using one of several conventions. This is the canonical version: it keeps
%   the exact numerics of the texture-learning implementation (correct and the
%   most complete) and supersedes the duplicated project copies and the buggy
%   root +lib copy (whose mean+contrast branch used an undefined variable).
%
%   Inputs
%     patch           - image patch, [H x W] (grayscale) or [H x W x 3] (colour).
%     target_mean     - target mean grey level (e.g. 128).
%     target_contrast - target RMS contrast (used only for norm_type == 2).
%     norm_type       - normalization convention:
%                         0 = none
%                         1 = mean            : scale each channel to target_mean
%                         2 = mean + contrast : per channel, set mean to
%                             target_mean and RMS contrast to target_contrast,
%                             then clip negatives to 0
%                         3 = average mean    : scale the whole patch so the mean
%                             across the channel means is target_mean (colour)
%                         4 = as type 3, then reverse contrast about target_mean
%     n_channels      - number of colour channels, 1 or 3 (default size(patch,3)).
%
%   Outputs
%     patch_out     - normalized patch, same size as patch.
%     channel_means - 3x1 vector of original per-channel means (unused entries 0).
%
%   See also vislab.lib.CNTRST_NORM.

    if nargin < 5 || isempty(n_channels)
        n_channels = size(patch, 3);
    end
    channel_means = zeros(3, 1);

    switch norm_type
        case 0                                          % no normalization
            patch_out = patch;

        case 1                                          % scale each channel to target_mean
            channel_means(1:n_channels) = squeeze(mean(patch, [1 2]));
            patch_out = patch .* reshape(target_mean ./ channel_means(1:n_channels), 1, 1, n_channels);

        case 2                                          % mean target_mean + RMS contrast target_contrast
            patch_out = zeros(size(patch));
            n_pixels  = size(patch, 1) * size(patch, 2);
            for k = 1:n_channels
                channel          = patch(:, :, k);
                channel_means(k) = mean(channel(:));
                channel = channel * target_mean / channel_means(k);          % set mean
                channel_sd = sqrt(sum((channel(:) - target_mean).^2) / n_pixels);
                channel = target_contrast * target_mean * (channel - target_mean) / channel_sd + target_mean;
                patch_out(:, :, k) = max(channel, 0);                        % clip negatives
            end

        case 3                                          % scale whole patch to average mean
            channel_means(1:n_channels) = squeeze(mean(patch, [1 2]));
            patch_out = patch * target_mean / mean(channel_means(1:n_channels));

        case 4                                          % as type 3, contrast-reversed about target_mean
            channel_means(1:n_channels) = squeeze(mean(patch, [1 2]));
            patch_out = patch * target_mean / mean(channel_means(1:n_channels));
            patch_out = -(patch_out - target_mean) + target_mean;

        otherwise
            error('vislab:lib:ptch_norm:badNormType', 'norm_type must be 0-4, got %g.', norm_type);
    end
end
