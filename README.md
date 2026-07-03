# geisler-commons

Shared MATLAB code for the Geisler Lab vision-science projects. Consumed as a **git submodule** by
`texture-learning`, `texture-segmentation`, and `camouflage_detection`, so that common code lives in
exactly one place.

## Packages

Each subfolder is a MATLAB namespace package; call functions as `<package>.<function>`.

| Package | Purpose |
|---|---|
| `+vislib` | General vision/numerical utilities: optics (OTF), CSF, steerable/DoG/LoG filters, noise, `downsample`, patch/contrast normalization, color conversions, sample statistics (`dPrime`, `gauss_llr`, `maha_dist`), image math. |
| `+nat_stat_bayes` | Natural-scene-statistics & Bayesian-observer toolkit: efficient-coding/PCA transforms, CDF + adaptive-histogram bin learning, and likelihood-ratio decision variables (power, histogram, edge, border). |
| `+segmentation` | General texture-segmentation grouping algorithm (content-similarity matrix + local/mutual/transitive/confidence/region grouping). Applies to any texture image. |
| `+gtr` | Grown-Texture-Region test harness: GTR stimulus generation and ground-truth region scoring. |
| `+psychframework` | Psychtoolbox experiment framework (trial/interval/feedback primitives, session I/O). |

## Usage

Add the repo root (the folder containing the `+package` dirs) to the MATLAB path. Each consuming
project ships a `setup.m` that does this, e.g.:

```matlab
addpath(fullfile(repo_root, 'geisler-commons'));   % exposes vislib.*, nat_stat_bayes.*, etc.
```

## External dependencies

- [IntClassNorm](https://github.com/abhranildas/Integrate-and-Classify-Normal-Distributions)
  (`classify_normals`, `quad2fun`) — used by the Bayesian decision-variable code; itself depends on
  the generalized chi-square package `gx2`.
- MATLAB toolboxes used by parts of `+vislib`: Image Processing, Statistics & Machine Learning,
  DSP System, Parallel Computing.

## License

CC-BY-NC 4.0 (matches the associated preprints).
