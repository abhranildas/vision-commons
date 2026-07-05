function img_lin = gamma_expand(img_gc, gamma_value)
% GAMMA_EXPAND  Gamma-compressed -> linear RGB (Adobe gamma).
%   img_lin = vislab.lib.gamma_expand(img_gc, gamma_value)
%
%   Inverse of vislab.lib.gamma_compress. Linearizes a gamma-compressed image so
%   that light-linear operations (optics, cone conversion) are valid. Operates
%   on an array of any shape/channel count (replaces adobe_expand).
%
%   Inputs
%     img_gc      - gamma-compressed image.
%     gamma_value - display gamma (default 2.19921875, the Adobe RGB gamma).
%
%   Output
%     img_lin - image in linear light (0..255 scale).
%
%   See also vislab.lib.GAMMA_COMPRESS.

    if nargin < 2 || isempty(gamma_value)
        gamma_value = 2.19921875;          % Adobe RGB (1998) gamma
    end
    white = 255;                           % 8-bit white level
    scale = white^(1 - gamma_value);
    img_lin = (img_gc.^gamma_value) * scale;
end
