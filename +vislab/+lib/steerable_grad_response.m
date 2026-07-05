function [magnitude, orientation] = steerable_grad_response(patch, sd, nsd)
% STEERABLE_GRAD_RESPONSE  First-derivative steerable response (magnitude & orientation).
%   [magnitude, orientation] = vislab.lib.steerable_grad_response(patch, sd, nsd)
%
%   Convolves the patch with the horizontal/vertical first-derivative-of-Gaussian
%   kernels and steers to the orientation of maximum response at each pixel,
%   returning that response magnitude and orientation. The border (kernel
%   half-width) is cropped. (Was imgrad.m in texture-learning.)
%
%   Inputs
%     patch - grayscale image patch.
%     sd    - Gaussian standard deviation in pixels.
%     nsd   - kernel width in standard deviations.
%
%   Outputs
%     magnitude   - steered response magnitude map (cropped).
%     orientation - orientation of maximum response, degrees (cropped).
%
%   See also vislab.lib.STEERABLE_KERNELS, vislab.lib.GRAD2_RESPONSE.

    [sz, ~] = size(patch);
    crop = floor(sd * nsd / 2 + 1);
    [k_horiz, k_vert] = vislab.lib.steerable_kernels(sd, nsd);
    resp_h = conv2(patch, k_horiz, 'same');
    resp_v = conv2(patch, k_vert,  'same');
    orientation = atan2d(resp_h, resp_v);
    magnitude   = sind(orientation) .* resp_h + cosd(orientation) .* resp_v;
    keep = crop:sz-crop+1;
    magnitude   = magnitude(keep, keep);
    orientation = orientation(keep, keep);
end
