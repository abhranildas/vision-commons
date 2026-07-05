% PSYCHFRAMEWORK  Shared Psychtoolbox experiment harness for the Geisler-lab repos.
%
%   A domain-agnostic session -> level -> trial loop, factored out of the
%   duplicated launchers in camouflage_detection and texture-segmentation
%   (runCamouflageExperiment/runSession/runTrial and runExperiment/runLevel/
%   runTrial). The harness owns the shared boilerplate; each project supplies its
%   stimulus/response/feedback logic as callbacks, so nothing camouflage- or
%   texture-specific lives here.
%
%   Functions:
%     run_experiment - open the screen, load the session (via a hook), run the
%                      levels in S.level_list, save each, tear down.
%     run_trial      - one trial: fixation -> stimulus -> response -> feedback,
%                      with optional trial_pre/trial_post wrappers.
%
%   Usage (each repo writes a thin adapter that wires its existing interval
%   functions as hooks and calls run_experiment):
%
%     hooks.load_session = @(E) my_load(E);   % returns S with .nTrials, .level_list
%     hooks.level_start  = @(S,l)     ...;
%     hooks.fixation     = @(S,t,l)   ...;
%     hooks.stimulus     = @(S,t,l)   ...;
%     hooks.response     = @(S,t,l)   ...;    % -> [response, rt]
%     hooks.feedback     = @(S,r,t,l) ...;
%     hooks.save_level   = @(S,resp,l)...;
%     % optional: session_pre/post, level_pre/post, trial_pre/post, level_end
%     %           (e.g. an EyeLink layer, gated by S.bFovea)
%     data = vislab.psychframework.run_experiment(ExpSettings, hooks);
%
%   See run_experiment.m for the full hooks contract. The harness fixes the
%   original's rt-matrix indexing bug (it stored rt(level,level)); everything
%   else is behaviour-preserving.
