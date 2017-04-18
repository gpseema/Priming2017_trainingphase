rand('state',sum(100*clock));

close all;
clear all;
clc;

disp('MAIN');

%% initialize

Settings.Vpn = input('Participant: ');

Settings.StimSize = 350;
Settings.SquareSize = round(Settings.StimSize/50);
Settings.FrameSize= Settings.StimSize+2*Settings.SquareSize;
frame_im = ones(Settings.FrameSize);

Settings.StimDuration = 200;
Settings.Fixation.Size  = 10;
Settings.Fixation.DurationRed = 1000;
Settings.Fixation.DurationGreen = 1000;
Settings.Feedback.Duration = 500;
Settings.ITI = 1000;

Settings.Mapping =  1; % stimulus-response mapping (0,1)    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 

Settings.Background.Greyvalue = 128;
Settings.Writing.Colour = 60;

Settings.Black = 0 ;
Settings.White = 255;
Settings.Red = [255 0 0];
Settings.Grey= [0 0 255];

Settings.Fixation.Colour = [255 0 0];
Settings.Fixation.ColourWaitForKeyPress = [0 255 0];
Settings.FrameWidth=40;
Settings.FontSize= 12;

Settings.rootdir = 'S:\AG\AG-Hesselmann-XT-Home\hesselmg\BACKUP31102011\BERLIN 2011\Studenten 2011-2013\Seema\Source Code'; % adjust rootdir

KbName('UnifyKeyNames');

EscapeKey = 27;
SpaceKey = 32;
ReturnKey = 13;

Settings.Key1 = KbName('a'); 
Settings.Key2 = KbName('l');

% little script for getting key codes    
% FlushEvents;  RestrictKeysForKbCheck([]);
% WaitSecs(0.5); mykey = 1;
% while mykey
%     [keyIsDown, secs, keyCode] = KbCheck;
%     if keyIsDown
%         mykey = 0;
%         disp(min(find(keyCode)));
%         break;
%     end
%     WaitSecs(.01); %It is a good habit not to poll as fast as possible
% end

size_xy = 612; % 612/462 old experiment

% ________________________________________________________________________

% design specification

Settings.numberoftrials = 128;

mymapping = zeros(1,108);
mycatchtrials = randperm(108);
mycatchtrials = mycatchtrials(1:12);
mymapping(mycatchtrials) = 1;

Settings.CatchTrial = [zeros(1,20) mymapping]; % the first 20 trials are "normal" trials (1) with the correct stim-resp mapping, the next 108 trials contain 12 catch trials (0)

%% START

try
    %% result & log files
    d_t= datestr(now,'ddmm_HHMM');

    %% Screen etc.
    echo off;
    HideCursor;
    AssertOpenGL;
    KbName('UnifyKeyNames');
    escapeKey = KbName('ESCAPE');
    
    screens=Screen('Screens');
    screenNumber=max(screens);

    [w, wRect]=Screen('OpenWindow', screenNumber, Settings.Background.Greyvalue);

    Screen(w,'BlendFunction',GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    x = wRect(3);
    y = wRect(4);

    ypos = y/2; % center
    xpos = x/2; % center
  
    [xmm ymm]= Screen('DisplaySize', w);

    Results.ExperimentStart = GetSecs;
    Results.ExperimentScript = mfilename('fullpath');
    
    %% Settings
    Settings.Stimuli.CenterXY = [xpos,ypos];

    Frametime=1/60; % Screen('GetFlipInterval',w,50); % or just set to 0.0167
    Results.Frametime=Frametime;
    Refreshrate=1/Frametime;
    Results.Refreshrate=Refreshrate;
    
    %% Display first message and get screen details
    Screen('TextFont',w, 'Arial');
    Screen('TextSize',w, Settings.FontSize);
    [nx, ny, bbox] = DrawFormattedText(w, 'Please wait...', x/2 , Settings.Stimuli.CenterXY(2) , Settings.Writing.Colour);
    Screen('Flip',w);

    FrameTexture=Screen('MakeTexture', w, frame_im*255, 0, 0, 0, 0, 0);
    
    % load the two "effects" stimuli
    
    % read 2 shined images (dummy "effects")
    MyTextures = cell(40,1);
    for i = 1:2
        MyTextures{i}=Screen('MakeTexture', w, imread(fullfile(Settings.rootdir,'images',['sf30grey_new' num2str(i) '.tif'])), 0, 0, 0, 0, 0);
    end    
        
    %% make empty grey texture for contrast modulation of CFS masks (and
    %% the no prime condition too)
    grey_wo_frame = ones(Settings.StimSize)*215;         
    GreyTexture=Screen('MakeTexture', w, grey_wo_frame, 0, 4, 0, 0, 0);

    %% Hz Message
    [nx, ny, bbox] = DrawFormattedText(w, ['Resolution: ' num2str(wRect(3)) ' x ' num2str(wRect(4)) '\n\n \n\nScreen Hertz: ' num2str(Refreshrate)], x/2 , Settings.Stimuli.CenterXY(2) , Settings.Writing.Colour);

    Screen('Flip',w);
    WaitSecs(0.5);    
    FlushEvents;  RestrictKeysForKbCheck([SpaceKey]);
    while 1
        [keyIsDown, secs, keyCode] = KbCheck;
        if keyIsDown
            break; %Ends the while loop
        end
        % WaitSecs(.01); % It is a good habit not to poll as fast as possible
    end

    % _________________________________________________________________________
    %% TRIAL LOOP START

    mytrialnum = 0; myresponses = 0;
    
    while 1

%        % _______________________MINI BLOCK INSTRUCTION START____________________________
%          
% %       if ~isempty(find([0 32 96 160 224 288 352 384 448 512 576 640]==mytrialnum))
%            
%        if ~mod(mytrialnum,64)
% 
%             myalpha = Settings.StimAlpha(1); % could become specific !! #################################
%           
%             if mytrialnum == 384
%                 block_counter = 2;
%             end
%                                            
%             if (mytrialnum == 0) || (mytrialnum == 384)
%             myinstructionfile = fullfile(Settings.rootdir,['Instruktion - ' num2str(instruction_sets(Settings.Instruction,block_counter)) 'red.bmp']);
%             else
%             myinstructionfile = fullfile(Settings.rootdir,['Instruktion - ' num2str(instruction_sets(Settings.Instruction,block_counter)) '.bmp']);                
%             end
%             
%             myinstructionimage = imread(myinstructionfile);
%             myinstructiontexture = Screen('MakeTexture', w, myinstructionimage, 0, 0, 0, 0, 0);            
%             
%             Screen('FillRect', w, Settings.Background.Greyvalue, wRect);            
%             Screen('DrawTexture', w, myinstructiontexture,[], recter(Settings.StimSize, [xpos(Settings.NonDomEye) ypos], [x y]), [], [], 1);
%             Screen('DrawTexture', w, myinstructiontexture,[], recter(Settings.StimSize, [xpos(Settings.DomEye) ypos], [x y]), [], [], 1);
%                         
%             Screen('Flip', w);
% 
%             WaitSecs(0.5);
% 
%             FlushEvents;  RestrictKeysForKbCheck([StartKey]);
% 
%             while 1
%                 [keyIsDown, secs, keyCode] = KbCheck;
%                 if keyIsDown
%                     break; % Ends the while loop
%                 end
%                 % WaitSecs(.01); % It is a good habit not to poll as fast as possible
%             end 
% 
%         end
% 
%         % _______________________MINI BLOCK INSTRUCTION STOP_____________________________

mytrialnum = mytrialnum + 1;

% display red fixation on grey background

Screen('FillRect', w, Settings.Background.Greyvalue, wRect);
Screen('DrawTexture', w, FrameTexture,[], recter(Settings.FrameSize, [xpos ypos], [x y]), [], [], 1);
Screen('DrawTexture', w, GreyTexture,[], recter(Settings.StimSize, [xpos ypos], [x y]), [], [], 1);
makefix_single(xpos,ypos,Settings.Fixation.Size,Settings.Fixation.Colour,w);  
Screen('Flip',w);

WaitSecs(Settings.Fixation.DurationRed/1000);

% display green fixation on grey background

Screen('FillRect', w, Settings.Background.Greyvalue, wRect);
Screen('DrawTexture', w, FrameTexture,[], recter(Settings.FrameSize, [xpos ypos], [x y]), [], [], 1);
Screen('DrawTexture', w, GreyTexture,[], recter(Settings.StimSize, [xpos ypos], [x y]), [], [], 1);
makefix_single(xpos,ypos,Settings.Fixation.Size,Settings.Fixation.ColourWaitForKeyPress,w);
[FlipStart, StimOnset] = Screen('Flip',w);

Results.StimOnset(mytrialnum) = StimOnset;

% wait for key press
      RT = NaN; secs = NaN; keyCode = NaN;
      
      FlushEvents;  RestrictKeysForKbCheck([Settings.Key1 Settings.Key2 EscapeKey]);
      stop = GetSecs + Settings.Fixation.DurationGreen/1000;
            while GetSecs < stop
                [keyIsDown, secs, keyCode] = KbCheck;
                if keyIsDown              
                    RT = secs - StimOnset;
                    myresponses = myresponses + 1;                    
                    break; 
                end
         %      WaitSecs(.01); %It is a good habit not to poll as fast as possible
            end

Results.ResponseCounter(mytrialnum) = myresponses;
Results.ResponseRT(mytrialnum) = RT; Results.ResponseKey{mytrialnum} = KbName(min(find(keyCode)));
Results.ResponseOnset(mytrialnum) = secs;            
      
if keyCode(EscapeKey)
   break; % abort program
end

% if button was pressed, present a stimulus ("effect")

if keyCode(Settings.Key1) && Settings.Mapping == 0
Screen('FillRect', w, Settings.Background.Greyvalue, wRect);
Screen('DrawTexture', w, FrameTexture,[], recter(Settings.FrameSize, [xpos ypos], [x y]), [], [], 1);

if Settings.CatchTrial(myresponses)
Screen('DrawTexture', w, MyTextures{2},[], recter(Settings.StimSize, [xpos ypos], [x y]), [], [], 1);
else
Screen('DrawTexture', w, MyTextures{1},[], recter(Settings.StimSize, [xpos ypos], [x y]), [], [], 1);
end

Screen('Flip',w);
WaitSecs(Settings.StimDuration/1000);
end

if keyCode(Settings.Key1) && Settings.Mapping == 1
Screen('FillRect', w, Settings.Background.Greyvalue, wRect);
Screen('DrawTexture', w, FrameTexture,[], recter(Settings.FrameSize, [xpos ypos], [x y]), [], [], 1);

if Settings.CatchTrial(myresponses)
Screen('DrawTexture', w, MyTextures{1},[], recter(Settings.StimSize, [xpos ypos], [x y]), [], [], 1);
else
Screen('DrawTexture', w, MyTextures{2},[], recter(Settings.StimSize, [xpos ypos], [x y]), [], [], 1);
end

Screen('Flip',w);
WaitSecs(Settings.StimDuration/1000);
end

if keyCode(Settings.Key2) && Settings.Mapping == 0
Screen('FillRect', w, Settings.Background.Greyvalue, wRect);
Screen('DrawTexture', w, FrameTexture,[], recter(Settings.FrameSize, [xpos ypos], [x y]), [], [], 1);

if Settings.CatchTrial(myresponses)
Screen('DrawTexture', w, MyTextures{1},[], recter(Settings.StimSize, [xpos ypos], [x y]), [], [], 1);
else
Screen('DrawTexture', w, MyTextures{2},[], recter(Settings.StimSize, [xpos ypos], [x y]), [], [], 1);
end

Screen('Flip',w);
WaitSecs(Settings.StimDuration/1000);
end

if keyCode(Settings.Key2) && Settings.Mapping == 1
Screen('FillRect', w, Settings.Background.Greyvalue, wRect);
Screen('DrawTexture', w, FrameTexture,[], recter(Settings.FrameSize, [xpos ypos], [x y]), [], [], 1);

if Settings.CatchTrial(myresponses)
Screen('DrawTexture', w, MyTextures{2},[], recter(Settings.StimSize, [xpos ypos], [x y]), [], [], 1);
else
Screen('DrawTexture', w, MyTextures{1},[], recter(Settings.StimSize, [xpos ypos], [x y]), [], [], 1);
end

Screen('Flip',w);
WaitSecs(Settings.StimDuration/1000);
end
       
% display empty screen
Screen('FillRect', w, Settings.Background.Greyvalue, wRect);
Screen('DrawTexture', w, FrameTexture,[], recter(Settings.FrameSize, [xpos ypos], [x y]), [], [], 1);
Screen('DrawTexture', w, GreyTexture,[], recter(Settings.StimSize, [xpos ypos], [x y]), [], [], 1);
Screen('Flip',w);

% check whether participant catches the catch trial !
% timeout: ITI

% wait for key press
      RT2 = NaN; secs = NaN; keyCode = NaN;
      
      FlushEvents;  RestrictKeysForKbCheck([SpaceKey EscapeKey]);
      stop = GetSecs + Settings.ITI/1000;
            while GetSecs < stop
                [keyIsDown, secs, keyCode] = KbCheck;
                if keyIsDown              
                    RT2 = secs - StimOnset;                                 
                    break; 
                end
         %      WaitSecs(.01); %It is a good habit not to poll as fast as possible
            end

Results.ResponseRT2(mytrialnum) = RT2;            
            
if keyCode(EscapeKey)
   break; % abort program
end

while GetSecs < stop % loop until ITI timeout
end

% if there is a catch trial and no RT2 = negative feedback!

if not(isnan(RT))
if Settings.CatchTrial(myresponses) && isnan(RT2)
Screen('FillRect', w, Settings.Background.Greyvalue, wRect);
Screen('DrawTexture', w, FrameTexture,[], recter(Settings.FrameSize, [xpos ypos], [x y]), [], [], 1);
Screen('DrawTexture', w, GreyTexture,[], recter(Settings.StimSize, [xpos ypos], [x y]), [], [], 1);
[nx, ny, bbox] = DrawFormattedText(w, 'FAIL TO CATCH!', x/2 , Settings.Stimuli.CenterXY(2) , Settings.Red);
Screen('Flip',w);
WaitSecs(Settings.Feedback.Duration/1000);
end
end
                        
if myresponses == Settings.numberoftrials break; end; % end of experiment

disp(mytrialnum);

end % TRIAL LOOP

Screen('FillRect', w, Settings.Background.Greyvalue, wRect);
Screen('DrawTexture', w, FrameTexture,[], recter(Settings.FrameSize, [xpos ypos], [x y]), [], [], 1);
Screen('DrawTexture', w, GreyTexture,[], recter(Settings.StimSize, [xpos ypos], [x y]), [], [], 1);
[nx, ny, bbox] = DrawFormattedText(w, 'ENDE', x/2 , Settings.Stimuli.CenterXY(2) , Settings.Writing.Colour);
Screen('Flip',w);

WaitSecs(1);

    % _____________________________________________________________________

    Results.ExperimentStop = GetSecs;
    Results.Mapping = Settings.Mapping;
    Results.CatchTrial = Settings.CatchTrial;
    save([Settings.rootdir '\Results\Results_' num2str(Settings.Vpn) '_' d_t ], 'Results');
    save([Settings.rootdir '\Results\Settings_' num2str(Settings.Vpn) '_' d_t ], 'Settings');
    save([Settings.rootdir '\Results\Workspace_' num2str(Settings.Vpn) '_' d_t ]);
    RestrictKeysForKbCheck([]);
    Screen('CloseAll');
    ShowCursor;
  
    % ________________ NEW JAVA CLEANER

    javaaddpath(which('MatlabGarbageCollector.jar'));
    jheapcl;
    fprintf('java maxMemory: %3.2fMB\n',java.lang.Runtime.getRuntime.maxMemory/(1024*1024));
    fprintf('java totalMemory: %3.2fMB\n',java.lang.Runtime.getRuntime.totalMemory/(1024*1024));
    fprintf('java freeMemory: %3.2fMB\n',java.lang.Runtime.getRuntime.freeMemory/(1024*1024));
catch

    Results.ExperimentStop = GetSecs;
    Results.Mapping = Settings.Mapping;
    Results.CatchTrial = Settings.CatchTrial;
    save([Settings.rootdir '\Results\Results_' num2str(Settings.Vpn) '_' d_t ], 'Results');
    save([Settings.rootdir '\Results\Settings_' num2str(Settings.Vpn) '_' d_t ], 'Settings');
    save([Settings.rootdir '\Results\Workspace_' num2str(Settings.Vpn) '_' d_t ]);
    RestrictKeysForKbCheck([]);
    Screen('CloseAll');
    ShowCursor;
    psychrethrow(psychlasterror);

    % ________________ NEW JAVA CLEANER

    javaaddpath(which('MatlabGarbageCollector.jar'));
    jheapcl;
    fprintf('java maxMemory: %3.2fMB\n',java.lang.Runtime.getRuntime.maxMemory/(1024*1024));
    fprintf('java totalMemory: %3.2fMB\n',java.lang.Runtime.getRuntime.totalMemory/(1024*1024));
    fprintf('java freeMemory: %3.2fMB\n',java.lang.Runtime.getRuntime.freeMemory/(1024*1024));
end


