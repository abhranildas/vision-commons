function img_lms = rgb2lms(img_rgb, rgb_to_lms)
% RGB2LMS  Convert a camera-RGB image to human LMS cone space.
%   img_lms = vislib.rgb2lms(img_rgb, rgb_to_lms)
%
%   Applies a 3x3 camera-RGB -> LMS colour matrix to every pixel and clips
%   negative cone responses to zero.
%
%   Inputs
%     img_rgb    - [H x W x 3] image in the camera's linear RGB space.
%     rgb_to_lms - 3x3 matrix mapping an RGB pixel (row vector) to [L M S].
%
%   Output
%     img_lms    - [H x W x 3] image in LMS cone space (non-negative).
%
%   See also VISLIB.PTCH_NORM.

    [n_rows, n_cols, n_channels] = size(img_rgb);
    pixels  = reshape(img_rgb, [], n_channels) * rgb_to_lms;  % transform each pixel
    img_lms = max(reshape(pixels, n_rows, n_cols, 3), 0);     % clip negative cones
end
