# Lab vision-science code: architecture

How the lab's texture / camouflage projects, the shared `vision-commons` library, the external
toolboxes, and the shared data store fit together. This document lives in `vision-commons` (the shared
hub) and is referenced from each project's README.

## Dependency graph

```
   gx2  ────────────►  IntClassNorm  ─────────────────────────────────────┐
   (add-on toolbox)    (add-on toolbox: classify_normals, quad2fun)        │  used by the model code of
                                                                           ▼  all project repos
                         vision-commons  (sibling folder)
                           +vislib          general vision / numerical utilities
                           +nat_stat_bayes  natural-scene-stats + Bayesian-observer DVs
                           +psychframework  Psychtoolbox experiment harness
                                 │  on the MATLAB path via each project's setup.m
             ┌───────────────────┼────────────────────────────┐
             ▼                   ▼                             ▼
   camouflage_detection   texture-segmentation         texture-learning
   (edge-power detection;  (Geisler & Das seg. paper;   (Geisler proximity paper;
    PTB experiments)        PTB experiments + models)    proximity-trained DVs + segmentation)

   global_data/  (natural images, texture sheets, large CDFs) — external store,
                 referenced by each repo's config; NOT in any code repo.
```

## Components

### External toolboxes (installed, not vendored)
- **gx2** — generalized chi-square distribution. github.com/abhranildas/gx2
- **IntClassNorm** — integrate & classify normal distributions (`classify_normals`, `quad2fun`);
  depends on gx2. github.com/abhranildas/IntClassNorm

Both are installed via the MATLAB **Add-On Explorer / File Exchange**. Project `setup.m` scripts only
*verify* they are installed — they are never added as source paths or bundled.

### vision-commons (this repo, a sibling folder next to each project)
The single home for code shared across projects. MATLAB namespace packages (call as `pkg.function`):

| Package | Purpose | Used by |
|---|---|---|
| `+vislib` | Optics (OTF), CSF, steerable/DoG/LoG filters, noise, downsample, patch/contrast normalization, colour conversion, sample statistics, image math | all |
| `+nat_stat_bayes` | Natural-scene-statistics + Bayesian-observer toolkit: PCA/efficient-coding transforms, CDF & adaptive-histogram bin learning, likelihood-ratio decision variables (power, spot, edge, border) | all |
| `+psychframework` | Psychtoolbox experiment harness (trial/interval/feedback, session I/O) | camouflage, texture-seg |

Only genuinely cross-project code lives here. Project-specific code (e.g. the texture-segmentation
grouping algorithm, GTR generation) stays in its own repo, and may be promoted here later if it turns
out to be shared.

### Project repos
- **camouflage_detection** — camouflage/target detection: edge-power ideal observer + PTB experiments.
- **texture-segmentation** — Geisler & Das segmentation paper: discrimination/grouping experiments + models.
- **texture-learning** — Geisler proximity paper: proximity-proxy training of texture-discrimination
  decision variables, applied to GTR segmentation.

### global_data (external data store)
Natural images (`CPS natural images/`), texture sheets (`textures/`), and large derived data (e.g.
natural-image CDFs). Too large for git; each repo's `config.m` points at it via a single data-root path.

## Consumption model

- **vision-commons = a sibling folder** next to each project (one shared copy, not vendored inside
  any repo). Each project's `setup.m` finds `../vision-commons`, and auto-clones it there if it's
  missing (needs git + network) — so a standalone project clone works after running `setup`.
- **IntClassNorm + gx2 = installed toolboxes** (see above).
- **global_data = external**, referenced by config; not in git.

## Adding a new project
1. Ensure `vision-commons` sits next to the repo (each `setup.m` auto-fetches it if missing).
2. Copy the `setup.m` / `config.m` pattern (path bootstrap + toolbox verification + data root).
3. Put only project-specific code in the repo; call shared code as `vislib.*` / `nat_stat_bayes.*`.
