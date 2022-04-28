classdef revampfinalapp_file < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                     matlab.ui.Figure
        valueofdtLabel               matlab.ui.control.Label
        dtLabel                      matlab.ui.control.Label
        valueofFrequencyLabel        matlab.ui.control.Label
        FrequencyLabel               matlab.ui.control.Label
        LPNormalizedCutoffEditField  matlab.ui.control.NumericEditField
        LPNormalizedCutoffEditFieldLabel  matlab.ui.control.Label
        FilterOrderSlider            matlab.ui.control.Slider
        FilterOrderSliderLabel       matlab.ui.control.Label
        PlottoShowButtonGroup        matlab.ui.container.ButtonGroup
        FilteredButton               matlab.ui.control.RadioButton
        FFTButton                    matlab.ui.control.RadioButton
        RawButton                    matlab.ui.control.RadioButton
        PlotDataButton               matlab.ui.control.Button
        Lamp                         matlab.ui.control.Lamp
        RecordingTimeProgressGauge   matlab.ui.control.Gauge
        RecordingTimeProgressLabel   matlab.ui.control.Label
        StartRecordingButton         matlab.ui.control.Button
        RecordingTime                matlab.ui.control.DiscreteKnob
        RecordingTimeKnobLabel       matlab.ui.control.Label
        UIAxes                       matlab.ui.control.UIAxes
    end

    
    properties (Access = private)
        ArduinoStuff;
        
        SerialData; 
    end
    
    properties (Access = public)
        RecordedData
        F %Lab303 Frequency 
        dt %derivative of t / average change of t
        filterOrder
        cutOffFreq
    end

    methods (Access = private)
        function LineColor = LineColor(app,ColorInput)
            switch ColorInput
                case "Black"
                    LineColor = 'k-';
                case "Red"
                    LineColor = 'r-';
                case "Blue"
                    LineColor = 'b-';
                case "Yellow"
                    LineColor = 'y-';
            end
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            app.SerialData = serialport("/dev/cu.usbmodem14101",9600);
        end

        % Close request function: UIFigure
        function UIFigureCloseRequest(app, event)
            delete(app)
            clearvars
        end

        % Callback function: StartRecordingButton, UIFigure
        function UIFigureButtonDown(app, event)
              %REVISING CALLBACK FUNCTION FOR RECORD BUTTON (Lab 3 Phase 3 Filtering
            %Data)
            % Recording Data From Arduino for set recording time 
            app.Lamp.Color = 'green';
            RecTime = str2num(app.RecordingTime.Value);
            Timeset = 0;
            counter = 1;   
            RecData = [];
            Data = [];
            serialobj = app.SerialData;
            tic
            TimeVec = [];
            while toc <= RecTime
                TimeVec = [TimeVec; toc];
                data = strsplit(readline(serialobj));
                data = str2num(data(2));
                Data = [Data; data];
                %RecData(counter,:) = str2num(char(Data));
                counter = counter + 1;
                %drawnow limitrate
                app.RecordingTimeProgressGauge.Value = (toc/RecTime)*100;
            end
            %V = length(RecData)/RecTime;
            %TimeVec = linspace(0,RecTime,V);
            
            times = TimeVec(:);  
            %computing dt  
            dt = times - circshift(times,1);   %create differences between times
                                               % t(n+1) - t(n)                                            
            % dt(0) = dt(1); %override the first element of dt (to equal second element)
            dt = mean(dt); %takes average of of time differences 
            dt = abs(dt)
            F = 1/dt %frequency = 1/dt
            
            app.valueofFrequencyLabel.Text = num2str(F,'%10.2e\n') %saving F as app property
            app.valueofdtLabel.Text = num2str(dt,'%10.2e\n') %saving dt as app property
            app.F = F; %takes our local variable (F) and records it to a global
                      % variable accessible everywhere
            app.dt = app.dt;
            app.cutOffFreq = 0.5;
            app.filterOrder = 1;
            
            app.Lamp.Color = 'red';
            pause(3)
            app.Lamp.Color = 'black';
            app.RecordingTimeProgressGauge.Value = 0;
 
            RecData = [TimeVec Data];
            app.RecordedData = RecData;
            
            assignin('base','RecData',RecData);
            assignin('base','TimeVec',TimeVec);
            assignin('base','times',times);
            assignin('base','RecTime',RecTime);
            assignin('base','Data',Data);
            assignin('base','filterOrder',app.filterOrder);
            assignin('base','cutOffFreq',app.cutOffFreq);
            
            clear serialobj

        end

        % Button pushed function: PlotDataButton
        function PlotDataButtonPushed(app, event)
            % REVISING FOR LAB 3 PHASE 3 FILTERING DATA
            if app.RawButton.Value == true
                %plot the raw data (B 1)
                plot(app.UIAxes,app.RecordedData(:,1),app.RecordedData(:,2),'r');
            end
            if app.FFTButton.Value == true
                %plot the FFT data (B 2)
                photofft = myfft(app.RecordedData(:,2)); %calling myfft function from external script    
                n = length(app.RecordedData(:,2)); %both columns should be same length so 1 or 2
                fshift = (-n/2:n/2-1)*(app.F/n); %produces a vector of frequencies for plotting
                plot(app.UIAxes,fshift,photofft,'r'); %plotting data of the fast fourier transformation function
            end
            if app.FilteredButton.Value == true
                %plot the filtered data (B 3)
                
                photofilter = myfilter(app.RecordedData(:,2),app.filterOrder,app.cutOffFreq); %calling myfilter function from external script 
                plot(app.UIAxes,app.RecordedData(:,1),photofilter,'r');
            end       
        end

        % Callback function
        function SaveToExcelButtonPushed(app, event)
            
            Labels = ["Temperature" , "Humidity" , "Time"];
            xlswrite('Temerature_and_Humidity_Data.xlsx',Labels,'Sheet 1','B1:D1')
            xlsWrite('Temerature_and_Humidity_Data.xlsx',app.RecordedData(:,1),'Sheet 1','B1:B100')
            xlsWrite('Temerature_and_Humidity_Data.xlsx',app.RecordedData(:,2),'Sheet 1','C1:C100')
            xlsWrite('Temerature_and_Humidity_Data.xlsx',app.RecordedData(:,3),'Sheet 1','D1:D100')
            
        end

        % Value changed function: LPNormalizedCutoffEditField
        function LPNormalizedCutoffEditFieldValueChanged(app, event)
            value = app.LPNormalizedCutoffEditField.Value;
                
            app.cutOffFreq = abs(value);
            
            
        end

        % Value changed function: FilterOrderSlider
        function FilterOrderSliderValueChanged(app, event)
            value = app.FilterOrderSlider.Value;
            app.filterOrder = round(value);
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 733 586];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @UIFigureCloseRequest, true);
            app.UIFigure.ButtonDownFcn = createCallbackFcn(app, @UIFigureButtonDown, true);

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, 'Recorded Data')
            xlabel(app.UIAxes, 'Time')
            ylabel(app.UIAxes, 'Temperature and Humidity')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.Position = [248 139 433 269];

            % Create RecordingTimeKnobLabel
            app.RecordingTimeKnobLabel = uilabel(app.UIFigure);
            app.RecordingTimeKnobLabel.HorizontalAlignment = 'center';
            app.RecordingTimeKnobLabel.Position = [66 407 90 22];
            app.RecordingTimeKnobLabel.Text = 'Recording Time';

            % Create RecordingTime
            app.RecordingTime = uiknob(app.UIFigure, 'discrete');
            app.RecordingTime.Items = {'5', '10', '15', '20'};
            app.RecordingTime.Position = [80 444 60 60];
            app.RecordingTime.Value = '15';

            % Create StartRecordingButton
            app.StartRecordingButton = uibutton(app.UIFigure, 'push');
            app.StartRecordingButton.ButtonPushedFcn = createCallbackFcn(app, @UIFigureButtonDown, true);
            app.StartRecordingButton.Position = [71 83 100 22];
            app.StartRecordingButton.Text = 'Start Recording';

            % Create RecordingTimeProgressLabel
            app.RecordingTimeProgressLabel = uilabel(app.UIFigure);
            app.RecordingTimeProgressLabel.HorizontalAlignment = 'center';
            app.RecordingTimeProgressLabel.Position = [50 219 141 22];
            app.RecordingTimeProgressLabel.Text = 'Recording Time Progress';

            % Create RecordingTimeProgressGauge
            app.RecordingTimeProgressGauge = uigauge(app.UIFigure, 'circular');
            app.RecordingTimeProgressGauge.Position = [59 256 120 120];

            % Create Lamp
            app.Lamp = uilamp(app.UIFigure);
            app.Lamp.Position = [190 77 35 35];
            app.Lamp.Color = [0 0 0];

            % Create PlotDataButton
            app.PlotDataButton = uibutton(app.UIFigure, 'push');
            app.PlotDataButton.ButtonPushedFcn = createCallbackFcn(app, @PlotDataButtonPushed, true);
            app.PlotDataButton.Position = [199 500 100 22];
            app.PlotDataButton.Text = 'Plot Data';

            % Create PlottoShowButtonGroup
            app.PlottoShowButtonGroup = uibuttongroup(app.UIFigure);
            app.PlottoShowButtonGroup.Title = 'Plot to Show';
            app.PlottoShowButtonGroup.Position = [309 445 123 106];

            % Create RawButton
            app.RawButton = uiradiobutton(app.PlottoShowButtonGroup);
            app.RawButton.Text = 'Raw';
            app.RawButton.Position = [11 60 46 22];
            app.RawButton.Value = true;

            % Create FFTButton
            app.FFTButton = uiradiobutton(app.PlottoShowButtonGroup);
            app.FFTButton.Text = 'FFT';
            app.FFTButton.Position = [11 38 43 22];

            % Create FilteredButton
            app.FilteredButton = uiradiobutton(app.PlottoShowButtonGroup);
            app.FilteredButton.Text = 'Filtered';
            app.FilteredButton.Position = [11 16 62 22];

            % Create FilterOrderSliderLabel
            app.FilterOrderSliderLabel = uilabel(app.UIFigure);
            app.FilterOrderSliderLabel.HorizontalAlignment = 'right';
            app.FilterOrderSliderLabel.Position = [566 445 66 22];
            app.FilterOrderSliderLabel.Text = 'Filter Order';

            % Create FilterOrderSlider
            app.FilterOrderSlider = uislider(app.UIFigure);
            app.FilterOrderSlider.Limits = [1 5];
            app.FilterOrderSlider.ValueChangedFcn = createCallbackFcn(app, @FilterOrderSliderValueChanged, true);
            app.FilterOrderSlider.Position = [524 496 150 3];
            app.FilterOrderSlider.Value = 1;

            % Create LPNormalizedCutoffEditFieldLabel
            app.LPNormalizedCutoffEditFieldLabel = uilabel(app.UIFigure);
            app.LPNormalizedCutoffEditFieldLabel.HorizontalAlignment = 'right';
            app.LPNormalizedCutoffEditFieldLabel.Position = [448 528 120 22];
            app.LPNormalizedCutoffEditFieldLabel.Text = 'LP Normalized Cutoff';

            % Create LPNormalizedCutoffEditField
            app.LPNormalizedCutoffEditField = uieditfield(app.UIFigure, 'numeric');
            app.LPNormalizedCutoffEditField.ValueChangedFcn = createCallbackFcn(app, @LPNormalizedCutoffEditFieldValueChanged, true);
            app.LPNormalizedCutoffEditField.Position = [582 528 100 22];

            % Create FrequencyLabel
            app.FrequencyLabel = uilabel(app.UIFigure);
            app.FrequencyLabel.Position = [336 104 62 22];
            app.FrequencyLabel.Text = 'Frequency';

            % Create valueofFrequencyLabel
            app.valueofFrequencyLabel = uilabel(app.UIFigure);
            app.valueofFrequencyLabel.Position = [413 104 114 22];
            app.valueofFrequencyLabel.Text = '(value of Frequency)';

            % Create dtLabel
            app.dtLabel = uilabel(app.UIFigure);
            app.dtLabel.Position = [354 77 25 22];
            app.dtLabel.Text = 'dt';

            % Create valueofdtLabel
            app.valueofdtLabel = uilabel(app.UIFigure);
            app.valueofdtLabel.Position = [431 77 68 22];
            app.valueofdtLabel.Text = '(value of dt)';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = ENGR131phase3lab3

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end