%% Initiate Screen

classdef ExperimentScreen < handle
    
    properties
        
        viewing_distance = 57;
        background_color = [127, 127, 127, 255];
        isBlend = true;
        isSkipSyncTests = 1;
        rect = []
        blend_source_factor = "GL_SRC_ALPHA";
        blend_destination_factor = "GL_ONE_MINUS_SRC_ALPHA";
        
        origin SpatialUnit
        
        no
        pointer
        dimensions_in_pix double
        dimensions_in_cm double
        center double
        frame_rate double
        ppd double
        flip_times
        
    end
    
    methods
        
        function scr = ExperimentScreen(viewing_distance,background_color,isBlend,isSkipSyncTests,rect,blend_source_factor,blend_destination_factor)
            
            if nargin > 0
                
                scr.viewing_distance = viewing_distance;
                scr.background_color = background_color;
                scr.isBlend = isBlend;
                scr.isSkipSyncTests = isSkipSyncTests;
                scr.rect = rect;
                scr.blend_source_factor = blend_source_factor;
                scr.blend_destination_factor = blend_destination_factor;
                
            end
            
            
            scr.PsychSetUp();
            scr = scr.open_window();
            scr.ppd = scr.get_ppd();
            
        end
        
        function PsychSetUp(scr)
            
            PsychDefaultSetup(1);
            commandwindow;
            Screen('Preference', 'SkipSyncTests',scr.isSkipSyncTests);
            
        end
        
        function scr = open_window(scr)
            
            screens = Screen('Screens');
            scr.no = max(screens);
            PsychImaging('PrepareConfiguration');
            PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible');
            scr.pointer = PsychImaging('OpenWindow', scr.no, scr.background_color,scr.rect);
            if scr.isBlend
                Screen('BlendFunction', scr.pointer, char(scr.blend_source_factor), char(scr.blend_destination_factor));
            end
            [width_in_pix, height_in_pix] = Screen('WindowSize', scr.pointer); % sz in px
            [width_in_cm, height_in_cm] = Screen('DisplaySize', scr.no);
            scr.dimensions_in_pix = [width_in_pix, height_in_pix];
            scr.dimensions_in_cm = [width_in_cm, height_in_cm];
            
            [x_center, y_center] = RectCenter([0,0,width_in_pix, height_in_pix]);
            scr.center = uint64([x_center; y_center]);
            scr.frame_rate = FrameRate(scr.pointer);
            
        end
        
        function ppd = get_ppd(scr)
            
            x_ppd = scr.viewing_distance*tan(pi/180)/(scr.dimensions_in_cm(1)/(10*scr.dimensions_in_pix(1)));
            y_ppd = scr.viewing_distance*tan(pi/180)/(scr.dimensions_in_cm(2)/(10*scr.dimensions_in_pix(2)));
            ppd = [x_ppd,y_ppd];
            
        end
        
        function pix = dva2pix(scr,dva)
            
            pix = round(scr.ppd(1)*dva);
            
        end
        
        function dva = pix2dva(scr,pix)
            
            dva = pix/scr.ppd(1);
            
        end
        
        function scr = flip(scr)
            
            [VBLTimestamp, StimulusOnsetTime, FlipTimestamp, Missed, ~] = Screen('Flip',scr.pointer);
            
            scr.flip_times = struct('start_execution',VBLTimestamp,'estimated_onset',StimulusOnsetTime,'end_execution',FlipTimestamp,'isMissed',Missed);
            
        end        
        
        function scr = draw(scr,obj,varargin)
            
              obj.draw(scr,varargin{:});
            
        end
        
        function t = time(scr)
            
            t = scr.flip_times.estimated_onset;
            
        end
        
        function scr = set_origin(scr,org,unit)
            
            if nargin < 3; unit = 'dva'; end
            if isrow(org); org = org'; end
            scr.origin = SpatialUnit(scr,org,unit);
            scr.origin.absolute = scr.center + scr.origin.pix;
            
        end        
        
        
        function tbl = get_table_of_parameters(scr)
            
            tbl = table(scr.viewing_distance,scr.background_color,scr.isSkipSyncTests,...
                scr.dimensions_in_pix,scr.dimensions_in_cm,...
                scr.frame_rate,scr.ppd,scr.isBlend,scr.blend_source_factor,scr.blend_destination_factor,...
                'VariableNames',{'viewing_distance','background_color','isSkipSyncTests',...
                'dimensions_in_pix','dimensions_in_cm',...
                'frame_rate','pixels_per_degree','isBlend','blend_source_factor','blend_destination_factor'...
                });
            
        end

        
    end
    
end