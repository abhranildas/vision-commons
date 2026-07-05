function img_gc = gamma_compress(img_lin, gamma_value)
% GAMMA_COMPRESS  Linear RGB -> gamma-compressed (Adobe gamma).
%   img_gc = vislab.lib.gamma_compress(img_lin, gamma_value)
%
%   Inverse of vislab.lib.gamma_expand. Operates on an array of any shape/channel
%   count (vectorized; replaces the per-channel copy in adobe_compress).
%
%   Inputs
%     img_lin     - image in linear light (0..255 scale).
%     gamma_value - display gamma (default 2.19921875, the Adobe RGB gamma).
%
%   Output
%     img_gc - gamma-compressed image.
%
%   See also vislab.lib.GAMMA_EXPAND.

    if nargin < 2 || isempty(gamma_value)
        gamma_value = 2.19921875;          % Adobe RGB (1998) gamma
    end
    white = 255;                           % 8-bit white level
    scale = 1 / (white^(1 - gamma_value));
    img_gc = (img_lin * scale).^(1/gamma_value);
end
