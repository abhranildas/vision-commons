function patch_out = apply_color_rotation(patch, rotation, patch_size)
% APPLY_COLOR_ROTATION  Apply the lab-global LMS->ABR colour rotation to a patch.
%   patch_out = vislab.nat_stat_bayes.apply_color_rotation(patch)                 % shared transform
%   patch_out = vislab.nat_stat_bayes.apply_color_rotation(patch, rotation)       % supplied 3x3
%   patch_out = vislab.nat_stat_bayes.apply_color_rotation(patch, rotation, patch_size)
%
%   Rotates each pixel's colour vector by a 3x3 matrix, mapping LMS cone responses
%   into the PCA/opponent "ABR" axes (achromatic, blue-yellow, red-green) learned
%   from natural images. (Was rot.m.)
%
%   The rotation is lab-global. If not supplied it is loaded once (cached for the
%   session) from the shared data store vislab_data/cps_lms2abr_otf.mat (variable
%   `coeff`, the OTF-derived transform) -- resolved as a sibling of the +vislab
%   package. Pass `rotation` explicitly to override: the non-OTF transform, tests,
%   or stage s1 (which *produces* the transform and so cannot load it). Callers
%   should NOT load the matrix themselves; just call this.
%
%   Inputs
%     patch      - [patch_size x patch_size x 3] colour patch.
%     rotation   - (optional) 3x3 rotation/PCA matrix; loaded from the shared store if omitted.
%     patch_size - (optional) patch side length in pixels; inferred from patch if omitted.
%
%   Output
%     patch_out  - rotated patch, same size as patch.
%
%   See also VISLAB.LIB.RGB2LMS.

    if nargin < 2 || isempty(rotation)
        rotation = shared_lms_to_abr();
    end
    if nargin < 3 || isempty(patch_size)
        patch_size = size(patch, 1);
    end
    pixels = reshape(patch, [], 3) * rotation;
    patch_out = reshape(pixels, patch_size, patch_size, 3);
end

function M = shared_lms_to_abr()
% Load the lab-global LMS->ABR transform (OTF) once, from vislab_data (sibling of +vislab).
    persistent coeff
    if isempty(coeff)
        f = fullfile(fileparts(mfilename('fullpath')), '..', '..', 'vislab_data', 'cps_lms2abr_otf.mat');
        s = load(f, 'coeff');
        coeff = s.coeff;
    end
    M = coeff;
end
