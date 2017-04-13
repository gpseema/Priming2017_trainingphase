rand('state',sum(100*clock));

close all;
clear all;
clc;

disp('MAIN');

%% initialize

Settings.Vpn = input('Participant: ');

Settings.StimSize = 350;
Settings.StimDuration = 200;
Settings.Fixation.Size  = 10;
Settings.Fixation.Duration = 1000;
Settings.ITI = 1000;

Settings.Instruction =  1; % stimulus-response mapping (0,1)    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 

Settings.Background.Greyvalue = 128;
Settings.Writing.Colour = 60;

Settings.Black = 0 ;
Settings.White = 255;
Settings.Grey= [0 0 255];

Settings.Fixation.Colour = [255 0 0];
Settings.Fixation.ColourWaitForKeyPress = [0 255 0];
Settings.FrameWidth=40;
Settings.FontSize= 12;

Settings.rootdir = 'S:\AG\AG-Hesselmann-XT-Home\hesselmg\BACKUP31102011\BERLIN 2011\Studenten 2011-2013\Seema\Source Code'; % adjust rootdir

EscapeKey = 27;
StartKey = 32;
ReturnKey = 13;

Settings.Key1 = 37; % left
Settings.Key2 = 40; % down

size_xy = 612; % 612/462 old experiment

% ________________________________________________________________________

% design specification

Settings.numberoftrials = 5;

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
    [nx, ny, bbox] = DrawFormattedText(w, 'Please wait while stimuli \n\n \n\nare being created.', x/4 , Settings.Stimuli.CenterXY(2) , Settings.Writing.Colour);
    Screen('Flip',w);

    % load the two "effects"
    
    % read 2 shined images
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
    FlushEvents;  RestrictKeysForKbCheck([StartKey]);
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

% display question mark on grey background

Screen('FillRect', w, Settings.Background.Greyvalue, wRect);
makefix_single(xpos,ypos,Settings.Fixation.Size,Settings.Fixation.ColourWaitForKeyPress,w);
[FlipStart, StimOnset] = Screen('Flip',w);

Results.StimOnset(mytrialnum) = StimOnset;

% wait for key press
      RT = NaN; secs = NaN; keyCode = NaN;
      
      FlushEvents;  RestrictKeysForKbCheck([Settings.Key1 Settings.Key2 EscapeKey]);
      stop = GetSecs + Settings.Fixation.Duration/1000;
            while GetSecs < stop
                [keyIsDown, secs, keyCode] = KbCheck;
                if keyIsDown              
                    RT = secs - StimOnset;
                    myresponses = myresponses + 1;                    
                    break; 
                end
         %      WaitSecs(.01); %It is a good habit not to poll as fast as possible
       end

Results.ResponseRT(mytrialnum) = RT; Results.ResponseKey{mytrialnum} = KbName(min(find(keyCode)));
Results.ResponseOnset(mytrialnum) = secs;            
      
if keyCode(EscapeKey)
   break; % abort program
end

% Screen('DrawTexture', w, myprimetexture,[], recter(Settings.StimSize, [xpos(Settings.NonDomEye) ypos], [x y]), [], [], 1);

WaitSecs(1);
       
% display empty screen with fixation cross
Screen('FillRect', w, Settings.Background.Greyvalue, wRect);
makefix_single(xpos,ypos,Settings.Fixation.Size,Settings.Fixation.Colour,w);  
Screen('Flip',w);

WaitSecs(1);

Results.mystimulus(mytrialnum) = mytrialnum;



if myresponses == Settings.numberoftrials break; end; % end of experiment

disp(mytrialnum);

end % TRIAL LOOP

    Screen('FillRect', w, Settings.Background.Greyvalue, wRect);
    Screen('Flip', w);

    % _____________________________________________________________________

    Results.ExperimentStop = GetSecs;
    Results.Instruction = Settings.Instruction;
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
    Results.Instruction = Settings.Instruction;
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


