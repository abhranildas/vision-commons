function a = patch_to_a(patch, target_mean, target_contrast)
% PATCH_TO_A  Per-patch normalize -> LMS->ABR rotate -> keep the achromatic (A) channel.
%   a = vislab.nat_stat_bayes.patch_to_a(patch, target_mean, target_contrast)
%
%   The shared per-patch ingestion step for both the Bayesian pipeline and the twin
%   CNN. Takes one image patch and returns its achromatic (A) channel, 2-D.
%
%   If PATCH is 3-channel (LMS), it is normalized with vislab.lib.ptch_norm
%   (norm_type 3: scale the whole patch so the mean across the 3 channel means is
%   TARGET_MEAN), then rotated LMS->ABR (vislab.nat_stat_bayes.apply_color_rotation),
%   and channel 1 (A) is kept. This is the exact order the Bayesian pipeline has
%   always used (normalize on 3-channel LMS, then rotate) -- so results are unchanged.
%
%   If PATCH is already 1-channel, it is assumed to be A produced this same way
%   upstream and is returned unchanged. That lets callers accept either the new
%   A-only stored patch pairs or older 3-channel LMS ones without branching.
%
%   The normalization uses all three LMS channels, so it MUST happen before the
%   rotation (you cannot recover the 3-channel scale factor from A alone). This is
%   why the step is bundled here rather than split across storage and downstream.
%
%   Inputs
%     patch           - [H x W x 3] LMS patch, or [H x W (x 1)] achromatic A patch.
%     target_mean     - ptch_norm target mean (e.g. cfg.norm.target_mean = 128).
%     target_contrast - ptch_norm target contrast (unused by norm_type 3; pass cfg value).
%
%   Output
%     a - [H x W] achromatic channel.
%
%   See also VISLAB.LIB.PTCH_NORM, VISLAB.NAT_STAT_BAYES.APPLY_COLOR_ROTATION.

    if size(patch, 3) == 1
        a = patch(:, :, 1);                 % already A (normalized + rotated upstream)
        return;
    end

    p = vislab.lib.ptch_norm(patch, target_mean, target_contrast, 3, 3);  % normalize 3-channel LMS
    p = vislab.nat_stat_bayes.apply_color_rotation(p);                     % LMS -> ABR
    a = p(:, :, 1);                                                       % keep achromatic channel
end
