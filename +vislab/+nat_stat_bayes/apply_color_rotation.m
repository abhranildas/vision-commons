function img_out = apply_color_rotation(img, rotation)
% APPLY_COLOR_ROTATION  Apply the lab-global LMS->ABR colour rotation.
%   img_out = vislab.nat_stat_bayes.apply_color_rotation(img)            % shared transform
%   img_out = vislab.nat_stat_bayes.apply_color_rotation(img, rotation)  % supplied 3x3
%
%   Rotates each pixel's colour vector by a 3x3 matrix, mapping LMS cone responses
%   into the PCA/opponent "ABR" axes (achromatic, blue-yellow, red-green) learned
%   from natural images. Works on any [H x W x 3] input (a patch or a full image);
%   the output keeps the input's H x W. (Was rot.m.)
%
%   The rotation is lab-global. If not supplied it is loaded once (cached for the
%   session) from the shared data store data/cps_lms2abr_otf.mat (variable
%   `coeff`, the OTF-derived transform) -- resolved inside vislab-common, alongside
%   the +vislab package. Pass `rotation` explicitly to override: the non-OTF transform, tests,
%   or stage s1 (which *produces* the transform and so cannot load it). Callers
%   should NOT load the matrix themselves; just call this.
%
%   Inputs
%     img      - [H x W x 3] colour image/patch in LMS space.
%     rotation - (optional) 3x3 rotation/PCA matrix; loaded from the shared store if omitted.
%
%   Output
%     img_out  - rotated image, same H x W x 3 as the input.
%
%   See also VISLAB.LIB.RGB2LMS.

    if nargin < 2 || isempty(rotation)
        rotation = shared_lms_to_abr();
    end
    [n_rows, n_cols, ~] = size(img);
    pixels  = reshape(img, [], 3) * rotation;
    img_out = reshape(pixels, n_rows, n_cols, 3);
end

function M = shared_lms_to_abr()
% Load the lab-global LMS->ABR transform (OTF) once, from data/ (alongside +vislab in vislab-common).
    persistent coeff
    if isempty(coeff)
        f = fullfile(fileparts(mfilename('fullpath')), '..', '..', 'data', 'cps_lms2abr_otf.mat');
        s = load(f, 'coeff');
        coeff = s.coeff;
    end
    M = coeff;
end
