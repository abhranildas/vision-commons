# vislab

Shared MATLAB code for the Geisler Lab vision-science projects. Used by `texture-learning`,
`texture-segmentation`, and `camouflage_detection` — kept as a **sibling folder** (`+vislab`) next to those
repos (each project's `setup.m` auto-fetches it if it's missing), so the shared code lives in exactly one place.

This repo folder **is** the `+vislab` MATLAB package (it contains `+lib`, `+nat_stat_bayes`, `+psychframework`
directly). On GitHub the repo is named `vislab`; clone it into a folder named `+vislab`.

## Package

Everything is one MATLAB namespace package, `vislab`, with three subpackages. Call functions as
`vislab.<subpackage>.<function>`.

| Subpackage | Call as | Purpose |
|---|---|---|
| `+vislab/+lib` | `vislab.lib.*` | General vision/numerical utilities: optics (OTF), CSF, steerable/DoG/LoG filters, noise, `downsample`, patch/contrast normalization, color conversions, sample statistics (`dPrime`, `gauss_llr`, `maha_dist`), image math. |
| `+vislab/+nat_stat_bayes` | `vislab.nat_stat_bayes.*` | Natural-scene-statistics & Bayesian-observer toolkit: efficient-coding/PCA transforms, CDF + adaptive-histogram bin learning, and likelihood-ratio decision variables (power, histogram, edge, border, spatial). |
| `+vislab/+psychframework` | `vislab.psychframework.*` | Psychtoolbox experiment framework (trial/interval/feedback primitives, session I/O). |

Only genuinely cross-project code lives here. Project-specific code stays in its own repo — e.g. the
texture-segmentation grouping algorithm and GTR stimulus generation currently live in `texture-learning`
(as local `+segmentation` / `+gtr` packages) and may be promoted here later if shared. (Note: a project's
own local `+lib` is a different, project-scoped `lib.*` namespace — distinct from the shared `vislab.lib.*`.)

## Usage

Because this folder **is** the `+vislab` package, put its **parent** directory on the MATLAB path (not the
`+vislab` folder itself) so `vislab.*` resolves. Each consuming project ships a `setup.m` that does this,
e.g. (`vislab_dir` = path to the `+vislab` folder):

```matlab
addpath(fileparts(vislab_dir));   % exposes vislab.lib.*, vislab.nat_stat_bayes.*, vislab.psychframework.*
```

## Shared colour transforms (auto-loaded)

The two lab-global colour transforms live in the shared data store `vislab_data/` (a sibling of this
package) and are loaded automatically the first time they're used (cached thereafter) — **callers just
call the function; they do not load the matrix**:
- `vislab.lib.rgb2lms(img)` — camera-RGB → LMS, using `vislab_data/cps_rgb2lms.mat` (var `lms`).
- `vislab.nat_stat_bayes.apply_color_rotation(patch)` — LMS → ABR, using `vislab_data/cps_lms2abr_otf.mat`
  (var `coeff`, the OTF-derived rotation produced by texture-learning stage 1).

Each also accepts an optional explicit matrix to override the shared one (tests, the non-OTF transform, or
the producing stage s1). This is the one place `vislab.*` reads from `vislab_data`.

## External dependencies

- [IntClassNorm](https://github.com/abhranildas/IntClassNorm)
  (`classify_normals`, `quad2fun`) -- used by the Bayesian decision-variable code; itself depends on
  the generalized chi-square package `gx2`.
- MATLAB toolboxes used by parts of `vislab.lib`: Image Processing, Statistics & Machine Learning,
  DSP System, Parallel Computing.

## License

MIT License (see `LICENSE`).
