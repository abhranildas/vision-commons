function SessionData = run_experiment(ExpSettings, hooks)
% vislab.psychframework.RUN_EXPERIMENT  Shared Psychtoolbox experiment runner.
%   SessionData = vislab.psychframework.run_experiment(ExpSettings, hooks)
%
%   Generic session -> level -> trial loop shared by the lab's Psychtoolbox
%   experiments (camouflage_detection, texture-segmentation). It owns the
%   boilerplate that was duplicated across repos -- screen setup, the level/trial
%   loop, per-level save, and teardown -- while every domain-specific phase is
%   supplied as a callback in `hooks`, so the harness never needs to know what the
%   stimuli are or how a response is scored.
%
%   ExpSettings (struct) must provide:
%     .bgPixValGamma  - background grey level (gamma space) for the window.
%   Optional:
%     .screenNumber   - display index (default max(Screen('Screens'))).
%     .textSize       - default text size in points (default 60).
%
%   hooks (struct of function handles) -- REQUIRED:
%     .load_session(ExpSettings) -> S
%         Prepare this session's stimuli/settings and return the session struct S.
%         S must provide  .nTrials  and  .level_list  (vector of level indices to
%         run). The harness sets S.window before the loop and copies
%         ExpSettings.bgPixValGamma into S if absent. S.bFovea defaults to true.
%     .level_start(S, level)                  - shown before each level's trials.
%     .fixation(S, trial, level)              - fixation interval.
%     .stimulus(S, trial, level)              - stimulus interval.
%     .response(S, trial, level) -> [resp,rt] - response interval.
%     .feedback(S, resp, trial, level)        - feedback.
%     .save_level(S, responses, level)        - persist a completed level.
%   hooks -- OPTIONAL (skipped if absent), e.g. an EyeLink layer:
%     .session_pre(S) -> S   before the level loop (eye-tracker setup)
%     .session_post(S)       after the loop (stop/close/download)
%     .level_pre(S, level)   before each level (drift correction)
%     .level_post(S, level)  after each level (stop recording)
%     .trial_pre(S, trial, level)          before each trial (start recording, TRIALID)
%     .trial_post(S, trial, level, resp)   after each trial (TRIAL_RESULT)
%     .level_end(S, responses, level)      inter-level display (default: "End of the block")
%
%   Returns SessionData with .response and .rt (nTrials x max(level) matrices).
%
%   Replaces the per-repo runExperiment/runSession/runLevel/runTrial launchers
%   (kept for now; superseded -- see each repo's CLEANUP.md).

    require_hooks(hooks, {'load_session','level_start','fixation','stimulus', ...
                          'response','feedback','save_level'});

    close all;
    sca;
    PsychDefaultSetup(2);
    Screen('Preference', 'SkipSyncTests', 1);
    rng('shuffle');

    if isfield(ExpSettings, 'screenNumber') && ~isempty(ExpSettings.screenNumber)
        screenNumber = ExpSettings.screenNumber;
    else
        screenNumber = max(Screen('Screens'));
    end

    [window, windowRect] = Screen('OpenWindow', screenNumber, ExpSettings.bgPixValGamma);
    LoadIdentityClut(window);
    ExpSettings.monitorSizePix = windowRect(3:4);

    S = hooks.load_session(ExpSettings);
    S.window = window;
    if ~isfield(S, 'bgPixValGamma'), S.bgPixValGamma = ExpSettings.bgPixValGamma; end
    if ~isfield(S, 'bFovea'),        S.bFovea = true; end

    textSize = 60;
    if isfield(ExpSettings, 'textSize'), textSize = ExpSettings.textSize; end
    Screen('TextSize', window, textSize);
    Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

    if isfield(hooks, 'session_pre'), S = hooks.session_pre(S); end

    nTrials = S.nTrials;
    levels  = S.level_list(:)';
    response = zeros(nTrials, max(levels));
    rt       = zeros(nTrials, max(levels));

    for level = levels
        if isfield(hooks, 'level_pre'), hooks.level_pre(S, level); end
        hooks.level_start(S, level);

        for trial = 1:nTrials
            [response(trial, level), rt(trial, level)] = vislab.psychframework.run_trial(S, hooks, trial, level);
        end

        hooks.save_level(S, response(:, level), level);

        if isfield(hooks, 'level_end')
            hooks.level_end(S, response(:, level), level);
        else
            default_level_end(S);
        end

        if isfield(hooks, 'level_post'), hooks.level_post(S, level); end
    end

    if isfield(hooks, 'session_post'), hooks.session_post(S); end

    SessionData.response = response;
    SessionData.rt = rt;
end

function require_hooks(hooks, names)
    for i = 1:numel(names)
        if ~isfield(hooks, names{i}) || ~isa(hooks.(names{i}), 'function_handle')
            error('psychframework:run_experiment:missingHook', ...
                'hooks.%s is required and must be a function handle.', names{i});
        end
    end
end

function default_level_end(S)
    Screen('FillRect', S.window, S.bgPixValGamma);
    Screen('TextSize', S.window, 25);
    DrawFormattedText(S.window, 'End of the block', 'center', 'center');
    Screen('Flip', S.window);
    WaitSecs(1);
end
