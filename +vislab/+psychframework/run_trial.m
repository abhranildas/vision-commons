function [response, rt] = run_trial(S, hooks, trial, level)
% vislab.psychframework.RUN_TRIAL  One trial: fixation -> stimulus -> response -> feedback.
%   [response, rt] = vislab.psychframework.run_trial(S, hooks, trial, level)
%
%   Runs the four trial phases via the caller's hooks, optionally wrapped by
%   trial_pre / trial_post (e.g. an EyeLink start-recording / trial-result layer).
%   Called by vislab.psychframework.run_experiment; see its help for the hooks contract.
%
%   Returns the trial response and reaction time from hooks.response.

    if isfield(hooks, 'trial_pre'), hooks.trial_pre(S, trial, level); end

    hooks.fixation(S, trial, level);
    hooks.stimulus(S, trial, level);
    [response, rt] = hooks.response(S, trial, level);
    hooks.feedback(S, response, trial, level);

    if isfield(hooks, 'trial_post'), hooks.trial_post(S, trial, level, response); end
end
