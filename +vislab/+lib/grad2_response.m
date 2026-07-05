function [magnitude, orientation] = grad2_response(patch, sd, nsd)
% GRAD2_RESPONSE  Second-derivative steerable response (magnitude & orientation).
%   [magnitude, orientation] = vislab.lib.grad2_response(patch, sd, nsd)
%
%   Convolves the patch with the 0/45/90-degree second-derivative-of-Gaussian
%   basis and analytically steers to the orientation of maximum |response| at
%   each pixel (choosing between the two roots of the steering equation). The
%   border (kernel half-width) is cropped. (Was imgrad2.m in texture-learning.)
%
%   Inputs
%     patch - grayscale image patch.
%     sd    - Gaussian standard deviation in pixels.
%     nsd   - kernel width in standard deviations.
%
%   Outputs
%     magnitude   - steered |response| magnitude map (cropped).
%     orientation - orientation of maximum response, degrees (cropped).
%
%   See also vislab.lib.GAUSS_DERIV2_KERNELS, vislab.lib.STEERABLE_GRAD_RESPONSE.

    [sz, ~] = size(patch);
    crop = floor(sd * nsd / 2 + 1);
    [k0, k45, k90] = vislab.lib.gauss_deriv2_kernels(sd, nsd);
    r0  = conv2(patch, k0,  'same');
    r45 = conv2(patch, k45, 'same');
    r90 = conv2(patch, k90, 'same');

    % two roots of the steering equation for the extremal orientation
    b = (r0 - r90) ./ (2 * r45);
    ori_a = atand(b + sqrt(b.^2 + 1));
    ori_b = atand(b - sqrt(b.^2 + 1));
    mag_a = r0.*cosd(ori_a).^2 + r90.*sind(ori_a).^2 - 2*sind(ori_a).*cosd(ori_a).*r45;
    mag_b = r0.*cosd(ori_b).^2 + r90.*sind(ori_b).^2 - 2*sind(ori_b).*cosd(ori_b).*r45;

    % keep, per pixel, the root with the larger magnitude
    pick_a = max(sign(abs(mag_a) - abs(mag_b)), 0);
    pick_b = max(-sign(abs(mag_a) - abs(mag_b)), 0);
    orientation = pick_a .* ori_a + pick_b .* ori_b;
    magnitude = r0.*cosd(orientation).^2 + r90.*sind(orientation).^2 ...
                - 2*sind(orientation).*cosd(orientation).*r45;

    keep = crop:sz-crop+1;
    magnitude   = abs(magnitude(keep, keep));
    orientation = orientation(keep, keep);
end
