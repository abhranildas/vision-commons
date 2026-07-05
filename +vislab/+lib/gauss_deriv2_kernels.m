function [k0, k45, k90] = gauss_deriv2_kernels(sd, nsd)
% GAUSS_DERIV2_KERNELS  Second-derivative-of-Gaussian steerable basis kernels.
%   [k0, k45, k90] = vislab.lib.gauss_deriv2_kernels(sd, nsd)
%
%   Returns the 0, 45 and 90 degree second-derivative-of-Gaussian kernels used
%   as the steerable basis for bar/line responses. Each is zero-meaned and
%   normalized to unit energy, except the 45-degree kernel, which is scaled to
%   energy 0.22 for accurate small-kernel steerability (see paper appendix).
%   (Was mk_2dg_sf.m in texture-learning.)
%
%   Inputs
%     sd  - Gaussian standard deviation in pixels.
%     nsd - kernel width in standard deviations.
%
%   Outputs
%     k0, k45, k90 - [sz x sz] basis kernels, sz = nsd*sd.
%
%   See also vislab.lib.GRAD2_RESPONSE, vislab.lib.STEERABLE_KERNELS.

    scale45  = 0.22;                 % 45-deg energy for accurate steerability
    sz       = nsd * sd;
    center   = (sz + 1) / 2;
    variance = sd^2;
    [row, col] = ndgrid(1:sz, 1:sz);
    x0 = row - center;
    y0 = col - center;
    g  = exp(-0.5 * (x0.^2 + y0.^2) / variance);
    k0  = -(x0.^2 / (4*variance) - 1/(2*variance)) .* g;
    k90 = -(y0.^2 / (4*variance) - 1/(2*variance)) .* g;
    k45 = -(x0 .* y0 / (4*variance)) .* g;
    k0  = k0  - mean(k0(:));   k0  = k0  / sqrt(sum(k0(:).^2));
    k90 = k90 - mean(k90(:));  k90 = k90 / sqrt(sum(k90(:).^2));
    k45 = k45 - mean(k45(:));  k45 = scale45 * k45 / sqrt(sum(k45(:).^2));
end
