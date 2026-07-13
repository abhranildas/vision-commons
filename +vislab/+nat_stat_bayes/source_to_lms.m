function [lms, a] = source_to_lms(file, cfg, opts)
% SOURCE_TO_LMS  Read one source image and process it to LMS (and optionally A).
%   lms       = vislab.nat_stat_bayes.source_to_lms(file, cfg)
%   lms       = vislab.nat_stat_bayes.source_to_lms(file, cfg, opts)
%   [lms, a]  = vislab.nat_stat_bayes.source_to_lms(...)
%
%   THE single shared per-image ingestion step for the whole project. Both the
%   Bayesian pipeline (s1/s2/s3 natural images, load_texture_images textures) and
%   the twin CNN (natural-image pool, texture test set) call this, so the optics
%   (ppd, pupil, wavelength) and colour calibration cannot drift apart between the
%   two models -- they come from one place, `cfg` (config.m).
%
%   Steps, in order:
%     1. read the file
%     2. (textures) resize a 1024px pertex sheet to cfg.patch.image_size   [opts.resize_pertex]
%     3. (grayscale sheets) replicate the single channel to 3              [opts.gray]
%     4. (gamma-compressed sheets) linearize                               [opts.gamma]
%     5. (16-bit natural images) scale by opts.prescale (e.g. 255/max_val) [opts.prescale]
%     6. eye-optics OTF at cfg.optics.ppd/pupil_diameter/wavelength        [if cfg.optics.apply]
%     7. RGB -> LMS (shared camera calibration)
%     8. downsample to eccentricity opts.ecc
%   Steps 2-5 are the per-dataset pre-steps that get each source into common linear
%   RGB; steps 6-8 are the shared physics. Natural images use only prescale; texture
%   sheets use gray/gamma/resize per database (see cfg.textures).
%
%   With a second output, also returns the achromatic channel
%   a = apply_color_rotation(lms)(:,:,1) using the shared LMS->ABR matrix -- a
%   per-image rotation (rotation is per-pixel, so it commutes with cutting patches).
%   The CNN uses this A directly (it normalizes per patch in its input layer); the
%   Bayesian pipeline ignores it and instead normalizes each patch then rotates via
%   vislab.nat_stat_bayes.patch_to_a.
%
%   Inputs
%     file - full path to the source image.
%     cfg  - config struct; uses cfg.optics.{ppd,pupil_diameter,wavelength,apply}
%            and cfg.patch.image_size (for the pertex resize).
%     opts - struct, all fields optional:
%              .gray          (false)  replicate a grayscale sheet to 3 channels
%              .gamma         (false)  gamma-linearize a compressed sheet
%              .resize_pertex (false)  resize a 1024px pertex sheet to cfg.patch.image_size
%              .prescale      ([])     scalar multiply of the raw image (e.g. 255/max_val)
%              .ecc           (1)      eccentricity downsample factor
%
%   Outputs
%     lms - [H x W x 3] image in LMS cone space (at eccentricity ecc).
%     a   - [H x W] achromatic (A) channel (optional).
%
%   See also VISLAB.NAT_STAT_BAYES.PATCH_TO_A, VISLAB.LIB.RGB2LMS,
%   VISLAB.LIB.OTF_FILTER, VISLAB.LIB.DOWNSAMPLE.

    if nargin < 3 || isempty(opts), opts = struct(); end
    gray          = get_opt(opts, 'gray', false);
    gamma         = get_opt(opts, 'gamma', false);
    resize_pertex = get_opt(opts, 'resize_pertex', false);
    prescale      = get_opt(opts, 'prescale', []);
    ecc           = get_opt(opts, 'ecc', 1);

    raw = double(imread(file));

    if resize_pertex                                   % 1024 -> cfg.patch.image_size (round, uint8)
        raw = double(uint8(round(imresize(raw, cfg.patch.image_size / 1024))));
    end
    if gray                                            % grayscale sheet -> 3 equal channels
        cimg = repmat(raw(:, :, 1), 1, 1, 3);
    else
        cimg = raw;
    end
    if gamma                                           % linearize gamma-compressed sheet
        cimg = vislab.lib.gamma_expand(cimg);
    end
    if ~isempty(prescale)                              % scale raw values (e.g. 16-bit -> 0..255)
        cimg = cimg * prescale;
    end
    if cfg.optics.apply                                % eye optics on linear RGB
        cimg = vislab.lib.otf_filter(cimg, cfg.optics.ppd, cfg.optics.pupil_diameter, cfg.optics.wavelength);
    end
    lms = vislab.lib.rgb2lms(cimg);                    % shared camera RGB -> LMS calibration
    lms = vislab.lib.downsample(lms, ecc);             % eccentricity model

    if nargout > 1
        abr = vislab.nat_stat_bayes.apply_color_rotation(lms);
        a = abr(:, :, 1);
    end
end

function v = get_opt(opts, name, default)
    if isfield(opts, name) && ~isempty(opts.(name))
        v = opts.(name);
    else
        v = default;
    end
end
