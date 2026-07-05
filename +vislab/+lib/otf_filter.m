function img_filt = otf_filter(img, ppd, pupil_diameter, wavelength)
% OTF_FILTER  Apply the human-eye optical transfer function to an image.
%   img_filt = vislab.lib.otf_filter(img, ppd, pupil_diameter, wavelength)
%
%   Filters each channel in the frequency domain by Watson's OTF (approximate
%   human eye optics). Vectorized; works for non-square/odd sizes and for 1- or
%   3-channel images.
%
%   NOTE: this is the corrected canonical version. It subtracts and re-adds the
%   channel mean exactly once and zeros frequencies beyond the diffraction
%   cutoff. It supersedes texture-learning's aply_otf, which added the mean back
%   twice (doubled DC) and did not zero the out-of-cutoff band. Adopting it
%   changes texture-learning's numerics vs the original preprint artifacts
%   (see the reorganization plan / changelog).
%
%   Inputs
%     img            - image, [H x W] or [H x W x C].
%     ppd            - pixels per degree.
%     pupil_diameter - pupil diameter in mm (default 4).
%     wavelength     - wavelength in nm (default 555).
%
%   Output
%     img_filt - optically filtered image, same size as img.
%
%   See also vislab.lib.WATSON_OTF.

    if nargin < 3 || isempty(pupil_diameter), pupil_diameter = 4;   end
    if nargin < 4 || isempty(wavelength),     wavelength     = 555; end

    [n_rows, n_cols, n_channels] = size(img);

    % radial spatial frequency (c/deg) at each fft bin; DC at the fftshift centre
    [xx, yy] = meshgrid(1:n_cols, 1:n_rows);
    cx = floor(n_cols/2) + 1;
    cy = floor(n_rows/2) + 1;
    fx = (xx - cx) * (ppd / n_cols);
    fy = (yy - cy) * (ppd / n_rows);
    freq = sqrt(fx.^2 + fy.^2);

    otf = vislab.lib.watson_otf(freq, pupil_diameter, wavelength);
    cutoff = pupil_diameter * pi * 1e6 / (wavelength * 180);
    otf(freq >= cutoff) = 0;                        % zero beyond diffraction cutoff

    img_filt = zeros(size(img));
    for c = 1:n_channels
        channel = img(:, :, c);
        channel_mean = mean(channel(:));
        spectrum = fftshift(fft2(channel - channel_mean));
        img_filt(:, :, c) = real(ifft2(ifftshift(otf .* spectrum))) + channel_mean;
    end
end
