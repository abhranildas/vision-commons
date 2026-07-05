function [k_horiz, k_vert] = steerable_kernels(sd, nsd)
% STEERABLE_KERNELS  First-derivative-of-Gaussian steerable basis kernels.
%   [k_horiz, k_vert] = vislab.lib.steerable_kernels(sd, nsd)
%
%   Returns the horizontal and vertical first-derivative-of-Gaussian kernels
%   (the steerable basis G1^0, G1^90); steer to any orientation via
%   cos(theta)*k_horiz + sin(theta)*k_vert. Each is normalized to unit energy.
%   (Was mk_dg_hv.m in texture-learning.)
%
%   Inputs
%     sd  - Gaussian standard deviation in pixels.
%     nsd - kernel width in standard deviations (nsd=3 ~ Sobel).
%
%   Outputs
%     k_horiz, k_vert - [sz x sz] basis kernels, sz = nsd*sd, unit energy.
%
%   See also vislab.lib.STEERABLE_GRAD_RESPONSE, vislab.lib.GAUSS_DERIV2_KERNELS.

    sz       = nsd * sd;
    center   = (sz + 1) / 2;
    variance = sd^2;
    [row, col] = ndgrid(1:sz, 1:sz);
    envelope = exp(-0.5 * ((row - center).^2 + (col - center).^2) / variance);
    k_horiz  = -((row - center) / variance) .* envelope;
    k_vert   = -((col - center) / variance) .* envelope;
    k_horiz  = k_horiz / sqrt(sum(k_horiz(:).^2));   % normalize to unit energy
    k_vert   = k_vert  / sqrt(sum(k_vert(:).^2));
end
