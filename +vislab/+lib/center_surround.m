function response = center_surround(patch, surround_width, cs_type)
% CENTER_SURROUND  Center-surround filter response of a patch.
%   response = vislab.lib.center_surround(patch, surround_width, cs_type)
%
%   Applies a center-surround filter and returns the cropped response.
%   (Was cen_sur.m in texture-learning.)
%
%   Inputs
%     patch          - grayscale image patch.
%     surround_width - surround window width in pixels (used by cs_type 1,2).
%     cs_type        - filter type:
%                        1 = log(center / mean-surround)   (ratio)
%                        2 = center - surround             (linear, size surround_width)
%                        3 = center - surround             (fixed 4x4 kernel)
%                        4 = center - surround             (fixed 5x5 kernel)
%
%   Output
%     response - center-surround response map (border cropped).
%
%   Note: cs_type 3 and 4 use fixed kernel geometries and ignore surround_width
%   (preserved from the original).

    [sz, ~] = size(patch);
    crop = floor(surround_width / 2 + 1);

    switch cs_type
        case 1                                  % log center/surround ratio
            kernel = ones(surround_width) / surround_width^2;
            ratio  = patch ./ conv2(patch, kernel, 'same');
            keep   = crop:sz-crop+1;
            response = log(max(ratio(keep, keep), 0));

        case 2                                  % center - mean(surround), linear
            kernel = -ones(surround_width) / surround_width^2;
            kernel(crop, crop) = kernel(crop, crop) + 1;
            cs = conv2(patch, kernel, 'same');
            keep = crop:sz-crop+1;
            response = cs(keep, keep);

        case 3                                  % fixed 4x4 center-surround
            crop = 3;
            kernel = -ones(4, 4) / 16;
            kernel(2:3, 2:3) = 1/8;
            cs = conv2(patch, kernel, 'same');
            keep = crop:sz-crop+1;
            response = cs(keep, keep);

        case 4                                  % fixed 5x5 center-surround
            crop = 3;
            kernel = -ones(5, 5) / 32;
            kernel(2:4, 2:4) = 1/18;
            cs = conv2(patch, kernel, 'same');
            keep = crop:sz-crop+1;
            response = cs(keep, keep);

        otherwise
            error('vislab:lib:center_surround:badType', 'cs_type must be 1-4, got %g.', cs_type);
    end
end
