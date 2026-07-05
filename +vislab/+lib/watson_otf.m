function otf = watson_otf(spatial_freq, pupil_diameter, wavelength)
% WATSON_OTF  Watson's descriptive optical transfer function of the human eye.
%   otf = vislab.lib.watson_otf(spatial_freq, pupil_diameter, wavelength)
%
%   Descriptive MTF/OTF of the average human eye (Watson 2013, J. Vision).
%
%   Inputs
%     spatial_freq   - spatial frequency in cycles/deg (scalar or array).
%     pupil_diameter - pupil diameter in mm.
%     wavelength     - wavelength in nm.
%
%   Output
%     otf - optical modulation at each spatial frequency (same size as input).
%           Undefined (complex/NaN) beyond the diffraction cutoff u0, where
%           acos(u/u0) is complex; callers (e.g. vislab.lib.otf_filter) zero it there.
%
%   See also vislab.lib.OTF_FILTER.

    cutoff = pupil_diameter * pi * 1e6 / (wavelength * 180);   % diffraction cutoff u0 (c/deg)
    uh = spatial_freq / cutoff;
    diffraction = (acos(uh) - uh .* sqrt(1 - uh.^2)) * 2/pi;   % diffraction-limited term
    u1 = 21.95 - 5.512*pupil_diameter + 0.3922*pupil_diameter^2;
    otf = sqrt(diffraction) .* (1 + (spatial_freq/u1).^2).^(-0.62);
end
