function img_out = downsample(img, factor)
% DOWNSAMPLE  Blur with a 3x3 Gaussian and halve, repeated log2(factor) times.
%   img_out = vislab.lib.downsample(img, factor)
%
%   Models the drop in sampling resolution with retinal eccentricity: each
%   factor-of-two step blurs with a small Gaussian kernel and then decimates by
%   nearest-neighbor (minimizing aliasing while keeping the resolution loss
%   accurate). Numerically identical to texture-learning's dsmp, generalized to
%   any number of channels (replaces its 4x-duplicated per-eccentricity blocks and the
%   grayscale-only texseg downsample).
%
%   Inputs
%     img    - image, [H x W] or [H x W x C].
%     factor - total downsampling factor; a power of two (1, 2, 4, 8, 16).
%              factor = 1 returns the image unchanged.
%
%   Output
%     img_out - downsampled image.

    n_halvings = log2(factor);
    if mod(n_halvings, 1) ~= 0 || factor < 1
        error('vislab:lib:downsample:badFactor', 'factor must be a power of two >= 1, got %g.', factor);
    end

    kernel = [1/16 1/8 1/16; 1/8 1/4 1/8; 1/16 1/8 1/16];   % small Gaussian blur
    img_out = img;
    for h = 1:n_halvings
        blurred = zeros(size(img_out));
        for c = 1:size(img_out, 3)
            blurred(:, :, c) = conv2(img_out(:, :, c), kernel, 'same');
        end
        img_out = imresize(blurred, 0.5, 'nearest');
    end
end
