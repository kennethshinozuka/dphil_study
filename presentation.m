
%%
%% Kenneth Shinozuka
%% 

function presentation()
% clean up
clear all;
clc;

[~, ~, keyCode] = KbCheck(-3);

KbName('UnifyKeyNames'); % converts operating specific keynames to universal keyname
escape = KbName('ESCAPE');
space = KbName('space');
    
isMEG = false;

% stimuli and stimulus parameters
% hccode = 1;
% lccode = 2;

% images = {
%    { 'images/dot_center.png', hccode }
%    { 'images/dot_left.png', hccode }
%    { 'images/dot_right.png', hccode }
%    };

num_targets = 3;
iindex  = 1 : num_targets;
iwidth  = 1200; % image
iheight = 800;
twidth  = 50; % target (circle)
theight = 50;
tcode   = 4;
nrepeat = 1000; %3; % image sequence

targetcol = [0 0 0];

% read run info
subject = input('subject id: ', 's');
stage = input('stage #: ', 's'); 
% scanno  = input('scan number: ');  % Commented this out since we're not
                                     % doing multiple scans per participant
logfile = ['logs/' subject '_NBBPA_' stage '.mat'];

if stage == 'baseline_feedback'
    idisplay = 3;
    nrepeat = 30;
elseif stage == 'baseline_no_feedback'
    idisplay = 0.5;
    nrepeat = 20;
elseif stage == 'adaptation'
    idisplay = 3;
    nrepeat = 15;
elseif stage == 'after-effets'
    idisplay = 0.5;
    nrepeat = 15;
elseif stage == 'de-adaptation'
    idisplay = 3;
    nrepeat = 20;
elseif stage == 'retention'
    idisplay = 0.5;
    nrepeat = 20;
else
    error('Incorrect input.');
end

trial_length = 3.0;
twait        = 0.5;
%isi          = 3.0;
rest_time    = 30.0;

% configure PTB
Screen('Preference', 'SkipSyncTests', 2);
Screen('Preference', 'Verbosity', 0);
PsychDefaultSetup(2);

% initialisation
background_colour         = [0.4 0.4 0.4];
fontcol                   = [0 0 0];

psc_screen                = max(Screen('Screens'));
[psc_window, psc_winrect] = PsychImaging('OpenWindow', psc_screen, background_colour, [0 0 500 500]);
[psc_x0, psc_y0]          = RectCenter(psc_winrect);

Screen('TextFont',  psc_window, 'Arial');
Screen('TextSize',  psc_window, 80);
Screen('TextColor', psc_window, fontcol);
%Screen('BlendFunction', psc_window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% irectangle = CenterRectOnPointd([0 0 iwidth iheight], psc_x0, psc_y0);

initRandom();
mtrigger = @(t)t;
if isMEG
    Datapixx('Open');
    Datapixx('StopAllSchedules');
    Datapixx('EnableVideoLcd3D60Hz');
    % Datapixx('RegWrRd');
    Datapixx('SetDoutValues', 0);
    Datapixx('RegWrRd');
    
    mtrigger = @sendTrigger;
end

% prelude
% HideCursor(psc_screen);

DrawFormattedText(psc_window, 'Please get ready', 'center', 'center');
% Screen('FillRect', psc_window, [256, 0, 0]);
Screen('Flip', psc_window);
WaitSecs(2);

if keyCode(escape) % end the experiment
    save(fullfile([fileName '.mat']), 'log');
    sca;
    Screen('CloseAll')
end

% waitSpaceBar();

irecord = {};

% sequence
for k = 1 : nrepeat
  
  iindex = shuffleVector(iindex); irecord{k} = iindex;
  DrawFormattedText(psc_window, '+', 'center', 'center');
  Screen('Flip', psc_window);
  WaitSecs(2);

  for i = iindex
    
    target_x_range  = [0.5*psc_x0 psc_x0 1.5*psc_x0];
    rand_index      = randi([1 3]);
    target_x        = target_x_range(rand_index);
    
    trectangle      = CenterRectOnPointd([0 0 twidth theight], target_x, psc_y0);
      
%     Screen(...
%        'DrawTextures', ...
%        psc_window, ...
%        Screen('MakeTexture', psc_window, imread(images{i}{1})), ...
%        [], ...
%        irectangle);
%     mtrigger(images{i}{2});
    
    Screen('FillOval', psc_window, [0 0 256], trectangle);
    WaitSecs(twait);
    DrawFormattedText(psc_window, 'Go', psc_x0, psc_y0 + 150);
    if strcmp(stage, 'baseline_no_feedback') | strcmp(stage, 'after-effects') | strcmp(stage, 'retention')
        Screen('Flip', psc_window);
    end
    mtrigger(tcode);
    WaitSecs(trial_length-twait);
    
    %WaitSecs(isi);
    
    if mod(k, 20) == 0 & (stage == 'de-adaptation' | stage == 'retention')
        DrawFormattedText('Rest', psc_window, 'center', 'center');
        Screen('Flip', psc_window);
        pause(rest_time);
    end
  end
    
  if k < nrepeat
    KbPressWait;
    sca;
  end
end

% finalise
if isMEG
    Datapixx('Close');
end

save(logfile, 'irecord');
clear all;
sca;
end