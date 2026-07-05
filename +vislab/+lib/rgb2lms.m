function img_lms = rgb2lms(img_rgb, rgb_to_lms)
% RGB2LMS  Convert a camera-RGB image to human LMS cone space.
%   img_lms = vislab.lib.rgb2lms(img_rgb)              % uses the shared lab matrix
%   img_lms = vislab.lib.rgb2lms(img_rgb, rgb_to_lms)  % uses a supplied 3x3 matrix
%
%   Applies a 3x3 camera-RGB -> LMS colour matrix to every pixel and clips negative
%   cone responses to zero.
%
%   The RGB->LMS matrix is a fixed, lab-global calibration. If not supplied it is
%   loaded once (cached for the session) from the shared data store
%   data/cps_rgb2lms.mat (variable `lms`) -- resolved inside vislab-common,
%   alongside the +vislab package. Pass rgb_to_lms explicitly to override (tests, alternative
%   calibrations). Callers should NOT load the matrix themselves; just call this.
%
%   Inputs
%     img_rgb    - [H x W x 3] image in the camera's linear RGB space.
%     rgb_to_lms - (optional) 3x3 matrix mapping an RGB pixel (row vector) to [L M S].
%
%   Output
%     img_lms    - [H x W x 3] image in LMS cone space (non-negative).
%
%   See also VISLAB.NAT_STAT_BAYES.APPLY_COLOR_ROTATION, VISLAB.LIB.PTCH_NORM.

    if nargin < 2 || isempty(rgb_to_lms)
        rgb_to_lms = shared_rgb_to_lms();
    end
    [n_rows, n_cols, n_channels] = size(img_rgb);
    pixels  = reshape(img_rgb, [], n_channels) * rgb_to_lms;  % transform each pixel
    img_lms = max(reshape(pixels, n_rows, n_cols, 3), 0);     % clip negative cones
end

function M = shared_rgb_to_lms()
% Load the lab-global RGB->LMS calibration once, from data/ (alongside +vislab in vislab-common).
    persistent lms
    if isempty(lms)
        f = fullfile(fileparts(mfilename('fullpath')), '..', '..', 'data', 'cps_rgb2lms.mat');
        s = load(f, 'lms');
        lms = s.lms;
    end
    M = lms;
end
