# Lab vision-science code: architecture

How the lab's texture / camouflage projects, the shared `vislab` library, the external
toolboxes, and the shared data store fit together. This document lives in `vislab-common` (the shared
hub) and is referenced from each project's README.

## Dependency graph

```
   gx2  ────────────►  IntClassNorm  ─────────────────────────────────────┐
   (add-on toolbox)    (add-on toolbox: classify_normals, quad2fun)        │  used by the model code of
                                                                           ▼  all project repos
                   vislab-common  (sibling folder: the +vislab package + the data/ store)
                     +vislab.lib              general vision / numerical utilities
                     +vislab.nat_stat_bayes   natural-scene-stats + Bayesian-observer DVs
                     +vislab.psychframework   Psychtoolbox experiment harness
                                 │  on the MATLAB path via each project's setup.m
             ┌───────────────────┼────────────────────────────┐
             ▼                   ▼                             ▼
   camouflage_detection   texture-segmentation         texture-learning
   (edge-power detection;  (Geisler & Das seg. paper;   (Geisler proximity paper;
    PTB experiments)        PTB experiments + models)    proximity-trained DVs + segmentation)

   vislab-common/data/  (natural images, texture sheets, colour transforms, large CDFs) —
                 gitignored data store inside vislab-common; referenced by each repo's config.
```

## Components

### External toolboxes (installed, not vendored)
- **gx2** — generalized chi-square distribution. github.com/abhranildas/gx2
- **IntClassNorm** — integrate & classify normal distributions (`classify_normals`, `quad2fun`);
  depends on gx2. github.com/abhranildas/IntClassNorm

Both are installed via the MATLAB **Add-On Explorer / File Exchange**. Project `setup.m` scripts only
*verify* they are installed — they are never added as source paths or bundled.

### vislab-common (this repo, a sibling folder next to each project)
The single home for resources shared across projects: the `+vislab` code package and the `data/` store.
The code is one MATLAB namespace package, `vislab`, with three
subpackages (call as `vislab.<subpackage>.<function>`):

| Subpackage | Call as | Purpose | Used by |
|---|---|---|---|
| `+vislab/+lib` | `vislab.lib.*` | Optics (OTF), CSF, steerable/DoG/LoG filters, noise, downsample, patch/contrast normalization, colour conversion, sample statistics, image math | all |
| `+vislab/+nat_stat_bayes` | `vislab.nat_stat_bayes.*` | Natural-scene-statistics + Bayesian-observer toolkit: PCA/efficient-coding transforms, CDF & adaptive-histogram bin learning, likelihood-ratio decision variables (power, spot, edge, border, spatial) | all |
| `+vislab/+psychframework` | `vislab.psychframework.*` | Psychtoolbox experiment harness (trial/interval/feedback, session I/O) | camouflage, texture-seg |

Only genuinely cross-project code lives here. Project-specific code (e.g. the texture-segmentation
grouping algorithm, GTR generation) stays in its own repo, and may be promoted here later if it turns
out to be shared. A project's own local `+lib` (`lib.*`) is a separate, project-scoped namespace.

### Project repos
- **camouflage_detection** — camouflage/target detection: edge-power ideal observer + PTB experiments.
- **texture-segmentation** — Geisler & Das segmentation paper: discrimination/grouping experiments + models.
- **texture-learning** — Geisler proximity paper: proximity-proxy training of texture-discrimination
  decision variables, applied to GTR segmentation.

### data/ (shared data store, inside vislab-common)
Natural images (`CPS natural images/`), texture sheets (`textures/`), the colour transforms, and large
derived data (e.g. natural-image CDFs). Too large for git (gitignored); each repo's `config.m` points at
it via a single data-root path (`../vislab-common/data`).

## Consumption model

- **vislab-common = a sibling folder** next to each project (one shared copy, not vendored inside
  any repo). It contains the `+vislab` package, so `setup.m` finds `../vislab-common/+vislab` and puts
  `vislab-common` (the package's parent) on the path (so `vislab.*` resolves); it auto-clones the repo
  there if it's missing (needs git + network) — so a standalone project clone works after running `setup`.
- **IntClassNorm + gx2 = installed toolboxes** (see above).
- **data = shared store** at `vislab-common/data`, referenced by config; gitignored (not on GitHub).

## Adding a new project
1. Ensure `vislab-common` sits next to the repo (each `setup.m` auto-fetches it if missing).
2. Copy the `setup.m` / `config.m` pattern (path bootstrap + toolbox verification + data root).
3. Put only project-specific code in the repo; call shared code as `vislab.lib.*` / `vislab.nat_stat_bayes.*`.
