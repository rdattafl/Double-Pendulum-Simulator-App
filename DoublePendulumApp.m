classdef DoublePendulumApp < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                      matlab.ui.Figure
        UIAxes                        matlab.ui.control.UIAxes
        GoGButton                     matlab.ui.control.Button
        L1Label                       matlab.ui.control.Label
        L2Label                       matlab.ui.control.Label
        M1Label                       matlab.ui.control.Label
        M2Label                       matlab.ui.control.Label
        Theta1Label                   matlab.ui.control.Label
        Theta2Label                   matlab.ui.control.Label
        M1Slider                      matlab.ui.control.Slider
        M2Slider                      matlab.ui.control.Slider
        DoublePendulumSimulatorLabel  matlab.ui.control.Label
        TypeinvalueLabel              matlab.ui.control.Label
        L1EditField                   matlab.ui.control.NumericEditField
        TypeinvalueLabel_3            matlab.ui.control.Label
        M1EditField                   matlab.ui.control.NumericEditField
        TypeinvalueLabel_4            matlab.ui.control.Label
        M2EditField                   matlab.ui.control.NumericEditField
        L1TextArea                    matlab.ui.control.TextArea
        L2TextArea                    matlab.ui.control.TextArea
        TypeinvalueLabel_2            matlab.ui.control.Label
        L2EditField                   matlab.ui.control.NumericEditField
        Theta2Knob                    matlab.ui.control.Knob
        Theta1Knob                    matlab.ui.control.Knob
        DirectionsTextArea            matlab.ui.control.TextArea
        TypeinvalueLabel_5            matlab.ui.control.Label
        Theta2EditField               matlab.ui.control.NumericEditField
        TypeinvalueLabel_6            matlab.ui.control.Label
        Theta1EditField               matlab.ui.control.NumericEditField
        ResetRButton                  matlab.ui.control.Button
    end

   
    properties (Access = private)
       L1 = 4; % Initial pendulum string lengths
       L2 = 4;
       
       Theta1 = 0; % Initial starting angles of the two pendulum bobs (in degrees)
       Theta2 = 0;
       
       M1center = [4*sin(0),-4*cos(0)]; % Initial coordinates for centers of masses M1 and M2
       M2center = [4*sin(0)+4*sin(0),-4*cos(0)-4*cos(0)]; 
       
       m1 = 2; %Initial mass values for M1, M2
       m2 = 2;
       M1Radius = 2*sqrt(2)/pi; % Initial radii of masses M1, M2
       M2Radius = 2*sqrt(2)/pi; 
       
       M1Xcoord = 0+2*sqrt(2)/pi*cos(linspace(0,2*pi,1000)); %x-,y-coordinates of pendulum bobs' perimeters
       M1Ycoord = -4+2*sqrt(2)/pi*sin(linspace(0,2*pi,1000));
       M2Xcoord = 0+2*sqrt(2)/pi*cos(linspace(0,2*pi,1000));
       M2Ycoord = -8+2*sqrt(2)/pi*sin(linspace(0,2*pi,1000));

    end
    
    methods (Access = private)
        
        function createPlot(app)
            
            % Create the plot that will be shown to the user.
            L = plot(app.UIAxes,[0,app.M1center(1)],[0,app.M1center(2)],[app.M1center(1),app.M2center(1)], ...
                [app.M1center(2),app.M2center(2)],'LineWidth',2,'Color',[0,0,0]);
            
            % Define the x- and y-coordinates of the circles defining M1 and M2. 
            app.M1Xcoord = app.M1center(1)+app.M1Radius*cos(linspace(0,2*pi,1000));
            app.M1Ycoord = app.M1center(2)+app.M1Radius*sin(linspace(0,2*pi,1000));
            app.M2Xcoord = app.M2center(1)+app.M2Radius*cos(linspace(0,2*pi,1000));
            app.M2Ycoord = app.M2center(2)+app.M2Radius*sin(linspace(0,2*pi,1000));
            
            % Create two circles (these will be the pendulum bobs) using the patch function and write them to the variables M1 and M2.
            M1 = patch(app.UIAxes,app.M1Xcoord,app.M1Ycoord,'r','EdgeColor','r');
            M2 = patch(app.UIAxes,app.M2Xcoord,app.M2Ycoord,'b','EdgeColor','b');
        end
    
    end
    
    methods (Static)
        
        function dTheta = ODESolver(t,y,app)
            % Create the function ODESolver that will be invoked by the parent function ODEInvoker.
            
            % Define the matrix of first-order differential equations that will be invoked by ODEInvoker.
            dTheta = zeros(4,1);
            dTheta(1) = y(3);
            dTheta(2) = y(4);

            % Helper functions used to define entries dTheta(3) and dTheta(4).
            a1 = app.L2/app.L1*(app.m2/(app.m1+app.m2))*cos((y(1)-y(2)));
            a2 = app.L1/app.L2*cos((y(1)-y(2)));
            f1 = -app.L2/app.L1*(app.m2/(app.m1+app.m2))*((y(4))^2)*sin((y(1)-y(2)))-...
                9.8/app.L1*sin(y(1));
            f2 = app.L1/app.L2*((y(3))^2)*sin((y(1)-y(2)))-9.8/app.L2*sin(y(2));
            
            dTheta(3) = (f1-a1*f2)/(1-a1*a2);
            dTheta(4) = (-a2*f1+f2)/(1-a1*a2);
        end
        
    end
    

    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            % Create the initial figure and axes that will be shown to the user.
            createPlot(app)
        end

        % Value changed function: L1EditField
        function L1EditFieldValueChanged(app, event)
            % Respond to a typed value of L1 by changing the first string's length 
            % and the positions of M1 and M2 on the axes.
            app.L1 = app.L1EditField.Value;
            app.L1TextArea.Value = num2str(app.L1);
            app.M1center = [app.L1*sin(app.Theta1),-app.L1*cos(app.Theta1)];
            app.M2center = [app.L1*sin(app.Theta1)+app.L2*sin(app.Theta2) 
                -app.L1*cos(app.Theta1)-app.L2*cos(app.Theta2)];
            createPlot(app);
        end

        % Value changed function: L2EditField
        function L2EditFieldValueChanged(app, event)
            % Respond to a typed value of L2 by changing the second string's length 
            % and the position of M2 on the axes.
            app.L2 = app.L2EditField.Value;
            app.L2TextArea.Value = num2str(app.L2);
            app.M2center = [app.L1*sin(app.Theta1)+app.L2*sin(app.Theta2), ... 
                -app.L1*cos(app.Theta1)-app.L2*cos(app.Theta2)];
            createPlot(app)
        end

        % Value changed function: M1EditField
        function M1EditFieldValueChanged(app, event)
            % Respond to a typed value of M1 by changing the M1 text box's value, the first bob's size, as well as the axes itself.
            app.m1 = app.M1EditField.Value;
            app.M1Radius = 2*sqrt(app.m1)/pi;
            app.M1Slider.Value = app.m1;
            createPlot(app)
        end

        % Value changed function: M2EditField
        function M2EditFieldValueChanged(app, event)
            % Respond to a typed value of M2 by changing the M2 text box's value, the second bob's size, as well as the axes itself.
            app.m2 = app.M2EditField.Value;
            app.M2Radius = 2*sqrt(app.m2)/pi;
            app.M2Slider.Value = app.m2;
            createPlot(app)
        end

        % Value changed function: Theta1EditField
        function Theta1EditFieldValueChanged(app, event)
            % Respond to a typed value of Theta1 by changing the value of the Theta1 text box, as well as the positions of 
            % M1 and M2 on the axes.
            app.Theta1 = app.Theta1EditField.Value;
            app.Theta1Knob.Value = app.Theta1;
            app.M1center = [app.L1*sin(app.Theta1),-app.L1*cos(app.Theta1)];
            app.M2center = [app.L1*sin(app.Theta1)+app.L2*sin(app.Theta2), ... 
                -app.L1*cos(app.Theta1)-app.L2*cos(app.Theta2)];
            createPlot(app);
        end

        % Value changed function: Theta2EditField
        function Theta2EditFieldValueChanged(app, event)
            % Respond to a typed value of Theta2 by changing the value of the Theta2 text box, as well as the position of 
            % M2 on the axes.
            app.Theta2 = app.Theta2EditField.Value;
            app.Theta2Knob.Value = app.Theta2;
            app.M2center = [app.L1*sin(app.Theta1)+app.L2*sin(app.Theta2), ... 
                -app.L1*cos(app.Theta1)-app.L2*cos(app.Theta2)];
            createPlot(app);
        end

        % Value changing function: M1Slider
        function M1SliderValueChanging(app, event)
            % While the slider is changing, change the value of M1 in the text box, 
            % and make the size of M1 dynamically change on the axes as well.
            app.m1 = event.Value;
            app.M1EditField.Value = app.m1;
            app.M1Radius = 2*sqrt(app.m1)/pi;
            createPlot(app)
        end

        % Value changing function: M2Slider
        function M2SliderValueChanging(app, event)
            % While the slider is changing, change the value of M2 in the text box, 
            % and make the size of M2 dynamically change on the axes as well.
            app.m2 = event.Value;
            app.M2EditField.Value = app.m2;
            app.M2Radius = 2*sqrt(app.m2)/pi;
            createPlot(app)
        end

        % Value changing function: Theta1Knob
        function Theta1KnobValueChanging(app, event)
            % While the knob is moving, change the value of Theta1 in the text box, 
            % and make the positions of M1 and M2 dynamically change on the axes as well.
            app.Theta1 = event.Value;
            app.Theta1EditField.Value = app.Theta1;
            app.M1center = [app.L1*sin(app.Theta1),-app.L1*cos(app.Theta1)];
            app.M2center = [app.L1*sin(app.Theta1)+app.L2*sin(app.Theta2), ... 
                -app.L1*cos(app.Theta1)-app.L2*cos(app.Theta2)];
            createPlot(app)
            hold(app.UIAxes,'off')
        end

        % Value changing function: Theta2Knob
        function Theta2KnobValueChanging(app, event)
            % While the knob is moving, change the value of Theta2 in the text box, 
            % and make the positions of M2 dynamically change on the axes as well.
            app.Theta2 = event.Value;
            app.Theta2EditField.Value = app.Theta2;
            app.M2center = [app.L1*sin(app.Theta1)+app.L2*sin(app.Theta2), ... 
                -app.L1*cos(app.Theta1)-app.L2*cos(app.Theta2)];
            createPlot(app)
            hold(app.UIAxes,'off')
        end

        % Button pushed function: GoGButton
        function GoGButtonPushed(app, event)
            % Solve the double pendulum differential equations for the given parameters by invoking ODE45, 
            % with the call of ODESolver, to generate the numerical solutions of the double pendulum.
            [t,y] = ode45(@ODESolver,[0,20000],[app.Theta1,app.Theta2,0,0],[],app.L1,app.L2,app.m1,app.m2);
            
            % Trace the paths of the two pendulum bobs.
            for ii = 1:length(y)
                %Create the plot elements path1 and path2 that will trace the motion of the two bobs on the axes.
                path1 = plot(app.UIAxes,app.L1*sin(y(1:ii,1)),-app.L1*cos(y(1:ii,1)),'r-');
                hold(app.UIAxes,'on')
                path2 = plot(app.UIAxes,app.L1*sin(y(1:ii,1))+app.L2*sin(y(1:ii,2)),-app.L1*cos(y(1:ii,1))-app.L2*cos(y(1:ii,2)),'b-');
                
                % Change the values of Theta1 and Theta2, as well as the positions of M1 and M2, with each iteration of the for loop.
                app.Theta1 = y(ii,1);
                app.Theta2 = y(ii,2);
                app.M1center = [app.L1*sin(app.Theta1),-app.L1*cos(app.Theta1)];
                app.M2center = [app.L1*sin(app.Theta1)+app.L2*sin(app.Theta2), ...
                    -app.L1*cos(app.Theta1)-app.L2*cos(app.Theta2)];
               
                % Invoke the createPlot() function that draws the current axes iterations and then apply
                % the hold off function so that only the most current iteration of the pendulum bobs are 
                % drawn on the screen.
                createPlot(app)
                drawnow limitrate
                hold(app.UIAxes,'off')
            end
        end

        % Close request function: UIFigure
        function UIFigureCloseRequest(app, event)
            % Delete the app when red X button is clicked.
            delete(app)
        end

        % Key press function: UIFigure
        function UIFigureKeyPress(app, event)
            % Create a set of switch-case statements so that the "R" and "G" button presses 
            % trigger the Reset and Go functionalities, respectively.
            key = event.Key;
            switch lower(key)
                case 'r'
                    ResetRButtonPushed(app,event)
                case 'g'
                    GoGButtonPushed(app,event)
            end
        end

        % Button pushed function: ResetRButton
        function ResetRButtonPushed(app, event)
            % Revert axes back to its original form.
            
            % Clear the axes so that no axes children and/or graphics objects remain visible.
            cla(app.UIAxes)
            
            % Redefine the initial Theta1, Theta2, M1center, and M2center values. 
            app.Theta1 = 0; 
            app.Theta2 = 0;
            app.M1center = [app.L1*sin(app.Theta1),-app.L1*cos(app.Theta1)];
            app.M2center = [app.L1*sin(app.Theta1)+app.L2*sin(app.Theta2), ...
                -app.L1*cos(app.Theta1)-app.L2*cos(app.Theta2)];
            
            % Plot the new, original axes and wait for further user input. 
            createPlot(app)
            pause
        end
    end

    % App initialization and construction
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure
            app.UIFigure = uifigure;
            app.UIFigure.Color = [0.9412 0.9412 0.9412];
            app.UIFigure.Position = [100 100 659 504];
            app.UIFigure.Name = 'UI Figure';
            app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @UIFigureCloseRequest, true);
            app.UIFigure.KeyPressFcn = createCallbackFcn(app, @UIFigureKeyPress, true);

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            app.UIAxes.FontName = 'Comic Sans MS';
            app.UIAxes.FontSize = 11;
            app.UIAxes.FontWeight = 'bold';
            app.UIAxes.XLim = [-20 20];
            app.UIAxes.YLim = [-20 20];
            app.UIAxes.Box = 'on';
            app.UIAxes.BoxStyle = 'full';
            app.UIAxes.XAxisLocation = 'origin';
            app.UIAxes.XTick = [-20 -16 -12 -8 -4 0 4 8 12 16 20];
            app.UIAxes.XTickLabel = {'-20'; '-16'; '-12'; '-8'; '-4'; '0'; '4'; '8'; '12'; '16'; '20'};
            app.UIAxes.YAxisLocation = 'origin';
            app.UIAxes.YTick = [-20 -16 -12 -8 -4 0 4 8 12 16 20];
            app.UIAxes.YTickLabel = {'-20'; '-16'; '-12'; '-8'; '-4'; '0'; '4'; '8'; '12'; '16'; '20'};
            app.UIAxes.Clipping = 'off';
            app.UIAxes.Position = [1 72 382 336];

            % Create GoGButton
            app.GoGButton = uibutton(app.UIFigure, 'push');
            app.GoGButton.ButtonPushedFcn = createCallbackFcn(app, @GoGButtonPushed, true);
            app.GoGButton.BackgroundColor = [0 1 0];
            app.GoGButton.FontWeight = 'bold';
            app.GoGButton.Position = [240 37 100 23];
            app.GoGButton.Text = 'Go (G)';

            % Create L1Label
            app.L1Label = uilabel(app.UIFigure);
            app.L1Label.FontAngle = 'italic';
            app.L1Label.Position = [391 377 25 22];
            app.L1Label.Text = 'L1:';

            % Create L2Label
            app.L2Label = uilabel(app.UIFigure);
            app.L2Label.FontAngle = 'italic';
            app.L2Label.Position = [391 347 25 22];
            app.L2Label.Text = 'L2:';

            % Create M1Label
            app.M1Label = uilabel(app.UIFigure);
            app.M1Label.FontAngle = 'italic';
            app.M1Label.Position = [391 315 26 22];
            app.M1Label.Text = 'M1:';

            % Create M2Label
            app.M2Label = uilabel(app.UIFigure);
            app.M2Label.FontAngle = 'italic';
            app.M2Label.Position = [391 262 26 22];
            app.M2Label.Text = 'M2:';

            % Create Theta1Label
            app.Theta1Label = uilabel(app.UIFigure);
            app.Theta1Label.FontAngle = 'italic';
            app.Theta1Label.Position = [382 200 46 22];
            app.Theta1Label.Text = 'Theta1:';

            % Create Theta2Label
            app.Theta2Label = uilabel(app.UIFigure);
            app.Theta2Label.FontAngle = 'italic';
            app.Theta2Label.Position = [383 103 46 22];
            app.Theta2Label.Text = 'Theta2:';

            % Create M1Slider
            app.M1Slider = uislider(app.UIFigure);
            app.M1Slider.Limits = [2 20];
            app.M1Slider.ValueChangingFcn = createCallbackFcn(app, @M1SliderValueChanging, true);
            app.M1Slider.Position = [418 325 131 3];
            app.M1Slider.Value = 2;

            % Create M2Slider
            app.M2Slider = uislider(app.UIFigure);
            app.M2Slider.Limits = [2 20];
            app.M2Slider.ValueChangingFcn = createCallbackFcn(app, @M2SliderValueChanging, true);
            app.M2Slider.Position = [418 272 131 3];
            app.M2Slider.Value = 2;

            % Create DoublePendulumSimulatorLabel
            app.DoublePendulumSimulatorLabel = uilabel(app.UIFigure);
            app.DoublePendulumSimulatorLabel.HorizontalAlignment = 'center';
            app.DoublePendulumSimulatorLabel.FontSize = 18;
            app.DoublePendulumSimulatorLabel.FontWeight = 'bold';
            app.DoublePendulumSimulatorLabel.Position = [197 464 247 25];
            app.DoublePendulumSimulatorLabel.Text = 'Double Pendulum Simulator';

            % Create TypeinvalueLabel
            app.TypeinvalueLabel = uilabel(app.UIFigure);
            app.TypeinvalueLabel.HorizontalAlignment = 'right';
            app.TypeinvalueLabel.Position = [501 377 78 22];
            app.TypeinvalueLabel.Text = 'Type in value:';

            % Create L1EditField
            app.L1EditField = uieditfield(app.UIFigure, 'numeric');
            app.L1EditField.Limits = [4 10];
            app.L1EditField.ValueChangedFcn = createCallbackFcn(app, @L1EditFieldValueChanged, true);
            app.L1EditField.Position = [594 377 43 22];
            app.L1EditField.Value = 4;

            % Create TypeinvalueLabel_3
            app.TypeinvalueLabel_3 = uilabel(app.UIFigure);
            app.TypeinvalueLabel_3.HorizontalAlignment = 'right';
            app.TypeinvalueLabel_3.Position = [558 315 78 22];
            app.TypeinvalueLabel_3.Text = 'Type in value:';

            % Create M1EditField
            app.M1EditField = uieditfield(app.UIFigure, 'numeric');
            app.M1EditField.Limits = [2 20];
            app.M1EditField.ValueChangedFcn = createCallbackFcn(app, @M1EditFieldValueChanged, true);
            app.M1EditField.Position = [598 294 39 22];
            app.M1EditField.Value = 2;

            % Create TypeinvalueLabel_4
            app.TypeinvalueLabel_4 = uilabel(app.UIFigure);
            app.TypeinvalueLabel_4.HorizontalAlignment = 'right';
            app.TypeinvalueLabel_4.Position = [558 262 78 22];
            app.TypeinvalueLabel_4.Text = 'Type in value:';

            % Create M2EditField
            app.M2EditField = uieditfield(app.UIFigure, 'numeric');
            app.M2EditField.Limits = [2 20];
            app.M2EditField.ValueChangedFcn = createCallbackFcn(app, @M2EditFieldValueChanged, true);
            app.M2EditField.Position = [598 241 39 22];
            app.M2EditField.Value = 2;

            % Create L1TextArea
            app.L1TextArea = uitextarea(app.UIFigure);
            app.L1TextArea.Editable = 'off';
            app.L1TextArea.HorizontalAlignment = 'right';
            app.L1TextArea.Position = [416 379 61 19];
            app.L1TextArea.Value = {'4'};

            % Create L2TextArea
            app.L2TextArea = uitextarea(app.UIFigure);
            app.L2TextArea.Editable = 'off';
            app.L2TextArea.HorizontalAlignment = 'right';
            app.L2TextArea.Position = [416 349 61 19];
            app.L2TextArea.Value = {'4'};

            % Create TypeinvalueLabel_2
            app.TypeinvalueLabel_2 = uilabel(app.UIFigure);
            app.TypeinvalueLabel_2.HorizontalAlignment = 'right';
            app.TypeinvalueLabel_2.Position = [501 347 78 22];
            app.TypeinvalueLabel_2.Text = 'Type in value:';

            % Create L2EditField
            app.L2EditField = uieditfield(app.UIFigure, 'numeric');
            app.L2EditField.Limits = [4 10];
            app.L2EditField.ValueChangedFcn = createCallbackFcn(app, @L2EditFieldValueChanged, true);
            app.L2EditField.Position = [594 347 43 22];
            app.L2EditField.Value = 4;

            % Create Theta2Knob
            app.Theta2Knob = uiknob(app.UIFigure, 'continuous');
            app.Theta2Knob.Limits = [-3.14 3.14];
            app.Theta2Knob.ValueChangingFcn = createCallbackFcn(app, @Theta2KnobValueChanging, true);
            app.Theta2Knob.MinorTicks = [-3.14 -3.09 -3.04 -2.99 -2.94 -2.89 -2.84 -2.79 -2.74 -2.69 -2.64 -2.59 -2.54 -2.49 -2.44 -2.39 -2.34 -2.29 -2.24 -2.19 -2.14 -2.09 -2.04 -1.99 -1.94 -1.89 -1.84 -1.79 -1.74 -1.69 -1.64 -1.59 -1.54 -1.49 -1.44 -1.39 -1.34 -1.29 -1.24 -1.19 -1.14 -1.09 -1.04 -0.99 -0.94 -0.89 -0.84 -0.79 -0.74 -0.69 -0.64 -0.59 -0.54 -0.49 -0.44 -0.39 -0.34 -0.29 -0.24 -0.19 -0.14 -0.0899999999999999 -0.04 0.00999999999999979 0.0599999999999996 0.11 0.16 0.21 0.26 0.31 0.36 0.41 0.46 0.51 0.56 0.61 0.66 0.71 0.76 0.81 0.86 0.91 0.96 1.01 1.06 1.11 1.16 1.21 1.26 1.31 1.36 1.41 1.46 1.51 1.56 1.61 1.66 1.71 1.76 1.81 1.86 1.91 1.96 2.01 2.06 2.11 2.16 2.21 2.26 2.31 2.36 2.41 2.46 2.51 2.56 2.61 2.66 2.71 2.76 2.81 2.86 2.91 2.96 3.01 3.06 3.11];
            app.Theta2Knob.Position = [454 44 60 60];

            % Create Theta1Knob
            app.Theta1Knob = uiknob(app.UIFigure, 'continuous');
            app.Theta1Knob.Limits = [-3.14 3.14];
            app.Theta1Knob.ValueChangingFcn = createCallbackFcn(app, @Theta1KnobValueChanging, true);
            app.Theta1Knob.MinorTicks = [-3.14 -3.09 -3.04 -2.99 -2.94 -2.89 -2.84 -2.79 -2.74 -2.69 -2.64 -2.59 -2.54 -2.49 -2.44 -2.39 -2.34 -2.29 -2.24 -2.19 -2.14 -2.09 -2.04 -1.99 -1.94 -1.89 -1.84 -1.79 -1.74 -1.69 -1.64 -1.59 -1.54 -1.49 -1.44 -1.39 -1.34 -1.29 -1.24 -1.19 -1.14 -1.09 -1.04 -0.99 -0.94 -0.89 -0.84 -0.79 -0.74 -0.69 -0.64 -0.59 -0.54 -0.49 -0.44 -0.39 -0.34 -0.29 -0.24 -0.19 -0.14 -0.0899999999999999 -0.04 0.00999999999999979 0.0599999999999996 0.11 0.16 0.21 0.26 0.31 0.36 0.41 0.46 0.51 0.56 0.61 0.66 0.71 0.76 0.81 0.86 0.91 0.96 1.01 1.06 1.11 1.16 1.21 1.26 1.31 1.36 1.41 1.46 1.51 1.56 1.61 1.66 1.71 1.76 1.81 1.86 1.91 1.96 2.01 2.06 2.11 2.16 2.21 2.26 2.31 2.36 2.41 2.46 2.51 2.56 2.61 2.66 2.71 2.76 2.81 2.86 2.91 2.96 3.01 3.06 3.11];
            app.Theta1Knob.Position = [454 141 60 60];

            % Create DirectionsTextArea
            app.DirectionsTextArea = uitextarea(app.UIFigure);
            app.DirectionsTextArea.Editable = 'off';
            app.DirectionsTextArea.FontSize = 9.5;
            app.DirectionsTextArea.BackgroundColor = [0.9412 0.9412 0.9412];
            app.DirectionsTextArea.Position = [11 410 626 49];
            app.DirectionsTextArea.Value = {'Directions: Click and drag the Theta1 and Theta2 knobs to move the pendulum bobs where you would like and use the slider to change the masses of the bobs. In addition, you can type in any length value for L1 and L2 between 4 and 10, any mass value for M1 and M2 from 2 to 8, or any degree measure for Theta1 and Theta2 from -3.14 to 3.14 as well. Afterwards, click "Go", then watch the double pendulum swing across your screen!! (Make sure to click on the grey part of the figure window so that the buttons "R" and "G" can be pressed.)'};

            % Create TypeinvalueLabel_5
            app.TypeinvalueLabel_5 = uilabel(app.UIFigure);
            app.TypeinvalueLabel_5.HorizontalAlignment = 'right';
            app.TypeinvalueLabel_5.Position = [556 82 78 22];
            app.TypeinvalueLabel_5.Text = 'Type in value:';

            % Create Theta2EditField
            app.Theta2EditField = uieditfield(app.UIFigure, 'numeric');
            app.Theta2EditField.Limits = [-3.14 3.14];
            app.Theta2EditField.ValueChangedFcn = createCallbackFcn(app, @Theta2EditFieldValueChanged, true);
            app.Theta2EditField.Position = [596 61 39 22];

            % Create TypeinvalueLabel_6
            app.TypeinvalueLabel_6 = uilabel(app.UIFigure);
            app.TypeinvalueLabel_6.HorizontalAlignment = 'right';
            app.TypeinvalueLabel_6.Position = [557 179 78 22];
            app.TypeinvalueLabel_6.Text = 'Type in value:';

            % Create Theta1EditField
            app.Theta1EditField = uieditfield(app.UIFigure, 'numeric');
            app.Theta1EditField.Limits = [-3.14 3.14];
            app.Theta1EditField.ValueChangedFcn = createCallbackFcn(app, @Theta1EditFieldValueChanged, true);
            app.Theta1EditField.Position = [597 158 39 22];

            % Create ResetRButton
            app.ResetRButton = uibutton(app.UIFigure, 'push');
            app.ResetRButton.ButtonPushedFcn = createCallbackFcn(app, @ResetRButtonPushed, true);
            app.ResetRButton.BackgroundColor = [1 0 0];
            app.ResetRButton.FontWeight = 'bold';
            app.ResetRButton.Position = [38 36 100 23];
            app.ResetRButton.Text = 'Reset (R)';
        end
    end

    methods (Access = public)

        % Construct app
        function app = DoublePendulumApp

            % Create and configure components
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