function battleship2()
fig = figure;
ax1 = axes('Position',[0 0 1 1],'Visible','off'); %organizing main layout
board1 = axes('Position',[0.05 0.05 0.35 0.35]);
board2 = axes('Position',[0.05 0.55 0.35 0.35]);
board2.ButtonDownFcn = @shoot;

axes(board2); %layout for enemy board
xlim([0 8]);
ylim([0 8]);
board2.YTick = 0:8;
board2.XTick = 0:8;
set(gca, 'XTickLabel', []);
set(gca, 'YTickLabel', []);
text((0:7) + 0.5, 8.5*ones(1,8), {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'}); %relabeling the axes while keeping the grid
text(-0.5*ones(1,8), (0:7) + 0.5, strsplit(num2str(8:-1:1))); %numbering the y axis backwards and off the tick
title2 = title('Enemy board');
title2.Position = [4 9];
whitebg([0.2 0.7 0.8]);
set(gcf,'Color','w');
grid on

axes(board1); %same process for the player board
xlim([0 8]);
ylim([0 8]);
board1.YTick = 0:8;
board1.XTick = 0:8;
set(gca, 'XTickLabel', []);
set(gca, 'YTickLabel', []);
text((0:7) + 0.5, 8.5*ones(1,8), {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'}, 'center');
text(-0.5*ones(1,8), (0:7) + 0.5, strsplit(num2str(8:-1:1)));
title1 = title('Your board');
title1.Position = [4 9];
grid on

axes(ax1);
bv = 3;
boatvalue = uicontrol('Style', 'text'); %text edit that changes with the value of the slider
boatvalue.Units = 'normalized';
boatvalue.Position = [0.7 0.46 0.04 0.1];
boatvalue.FontSize = 25;
boatvalue.String = num2str(bv);
boatvalue.BackgroundColor = 'w';

boatnum = uicontrol('Style', 'slider'); %slider value that lets you decide how many boats you want to play with 
boatnum.Units = 'normalized';
boatnum.Position = [0.5 0.44 0.17 0.03];
boatnum.Min = 1;
boatnum.Max = 7;
boatnum.Value = 3;
boatnum.SliderStep = [0.1667 0.1667*2]; %0.1429 is 1/7, so max is 7 boats.
boatnum.Callback = {@slidervalue, boatvalue}; %callback to slidervalue function, will use the variable boatvalue

tslider1 = text(0.5, 0.5, 'Number of boats'); %title on slider
tslider2 = text(0.695, 0.45, 'boats'); %units for slider count

boatbutton1 = uicontrol('Style', 'pushbutton'); %layout for pushbutton 1
boatbutton1.Units = 'normalized';
boatbutton1.Position = [0.5 0.25 0.2 0.1];
boatbutton1.String = 'Buoy: 1 units';
boatbutton1.Callback = @button1; %callback to function button 1

boatbutton2 = uicontrol('Style', 'pushbutton'); %same process for the next three boat buttons
boatbutton2.Units = 'normalized';
boatbutton2.Position = [0.72 0.25 0.2 0.1];
boatbutton2.String = 'Submarine: 2 units';
boatbutton2.Callback = @button2;

boatbutton3 = uicontrol('Style', 'pushbutton');
boatbutton3.Units = 'normalized';
boatbutton3.Position = [0.5 0.12 0.2 0.1];
boatbutton3.String = 'Battleship: 3 units';
boatbutton3.Callback = @button3;

boatbutton4 = uicontrol('Style', 'pushbutton');
boatbutton4.Units = 'normalized';
boatbutton4.Position = [0.72 0.12 0.2 0.1];
boatbutton4.String = 'Aircraft carrier: 4 units';
boatbutton4.Callback = @button4;

readytoplay = uicontrol('Style', 'pushbutton'); %this is the begin button once the boats are set.  it is invisible
readytoplay.Units = 'normalized';               %until set to visible through another function
readytoplay.Position = [0.61 0.01 0.2 0.1];
readytoplay.String = 'Board Complete';
readytoplay.Callback = @begingame;
readytoplay.Visible = 'off';

instmsg{1} = 'Choose the number of boats.';
instmsg{2} = 'Click on the boat you would like to add.';
instmsg{3} = 'Use arrow keys to orient it.';
instmsg = text(0.55, 0.8, instmsg);

boatsplaced = 0; %setting initial data to 0 in figure data for number of boats palced
setappdata(fig, 'boatsplaced', boatsplaced); 

newboatlength = 0; %initializing boat length also
setappdata(fig, 'newboatlength', newboatlength);

boatskilled = 0; %initializing how many boats player 1 killed
setappdata(fig, 'boatskilled', boatskilled);

p1boatskilled = 0; %initializing how many boats the computer killed
setappdata(fig, 'p1boatskilled', p1boatskilled);

turn = 1; %initializing which turn it is
setappdata(fig, 'turn', turn);

fig.KeyPressFcn = @rotate; %when a key is pressed, it will go to the rotate callback funtion
borient = [0 1]; %variables to help with orientation and rotation
rot = [0 -1; 1 0];

axes(board1)
hold on
newboat = quiver(4, 4, 0, 0); %quiver plot initialized with a length of 0, used for each new boat placed 
newboat.LineWidth = 10;
newboat.ShowArrowHead = 'on';
newboat.Color = 'b';

boats = struct; %to store all the data from newboat as to the positions of the boats

p1board = zeros(8); %matrix representation of the board, will get filled as player places boats on screen
computerboard = zeros(8); %matrix representation of computer's board, will get filled when comp places on screen
axes(ax1)
hold on
boardcomp{1} = 'Great!  Now click on any'; %text that gives instructions that will appear on screen later
boardcomp{2} = 'spot on the enemy board';
boardcomp{3} = 'to make a shot.';
boardcomplete =  text(0.42, 0.8, boardcomp);
boardcomplete.Units = 'normalized';
boardcomplete.FontSize = 20;
boardcomplete.Visible = 'off';

newmsg = text(0.6, 0.8, ''); %message will be updated with number of boats killed
hold off

    function slidervalue(~, ~, boatvalue) %edits the text as the slider GUI is being used
        newbv = round(get(boatnum, 'Value'));
        set(boatvalue, 'String', num2str(newbv));
    end 

    function button1(~, ~) %pushbutton that calls for a boat of length 1 to be placed
        boatsplaced = getappdata(fig, 'boatsplaced');
        boatsplaced = boatsplaced + 1; %increasing the number of boats that were placed 
        setappdata(fig, 'boatsplaced', boatsplaced);
        setappdata(fig, 'newboatlength', 1);   %length of boat is 1 for this button      
        
        if boatsplaced == round(get(boatnum, 'Value')); %checking if selected number of boats is at limit, will disable other buttons if so
            boatbutton1.Enable = 'off';
            boatbutton2.Enable = 'off';
            boatbutton3.Enable = 'off';
            boatbutton4.Enable = 'off';
        end 
    end

    function button2(~, ~) %button 2 does the same as button 1, but for a boat of length 2
        boatsplaced = getappdata(fig, 'boatsplaced');
        boatsplaced = boatsplaced + 1;
        setappdata(fig, 'boatsplaced', boatsplaced);
        setappdata(fig, 'newboatlength', 2);  
        
        if boatsplaced == round(get(boatnum, 'Value')); %anothrr check to see if the selected number of boats has been exceeded
            boatbutton1.Enable = 'off';
            boatbutton2.Enable = 'off';
            boatbutton3.Enable = 'off';
            boatbutton4.Enable = 'off';
        end   
    end

    function button3(~, ~) %same for button3, with a boat of length 3
        boatsplaced = getappdata(fig, 'boatsplaced');
        boatsplaced = boatsplaced + 1;
        setappdata(fig, 'boatsplaced', boatsplaced);
        setappdata(fig, 'newboatlength', 3);  
        
        if boatsplaced == round(get(boatnum, 'Value'));
            boatbutton1.Enable = 'off';
            boatbutton2.Enable = 'off';
            boatbutton3.Enable = 'off';
            boatbutton4.Enable = 'off';
        end
    end

    function button4(~, ~) %same for button 4, with a length of 4
        boatsplaced = getappdata(fig, 'boatsplaced');
        boatsplaced = boatsplaced + 1;
        setappdata(fig, 'boatsplaced', boatsplaced);
        setappdata(fig, 'newboatlength', 4);  
        
        if boatsplaced == round(get(boatnum, 'Value'));
            boatbutton1.Enable = 'off';
            boatbutton2.Enable = 'off';
            boatbutton3.Enable = 'off';
            boatbutton4.Enable = 'off';
        end
    end

    function rotate(~, eventdata) %this will rotate the boat upon right or left arrow key
        newboatlength = getappdata(fig, 'newboatlength');
        newboatso = newboatlength * borient; %new boat size and orientation, borient was defined much earlier
        axes(board1)
        hold on
        newboat.UData = newboatso(1); %setting newboat quiver plot data for u and v vectors (magnitude)
        newboat.VData = newboatso(2);
        
        switch eventdata.Key
            case 'rightarrow'
                borient = borient*rot; %rotates the boat right (90 deg) when right arrow is clicked.
                newboatso = newboatlength*borient;
                newboat.UData = newboatso(1); %this data is saved back into newboat (therefore displayed too)
                newboat.VData = newboatso(2);
                
            case 'leftarrow' %rotates the boat 90 deg left when left arrow is clicked
                borient = borient*-rot;
                newboatso = newboatlength*borient;
                newboat.UData = newboatso(1);
                newboat.VData = newboatso(2); %saves data
                
            case 'return'
                boats(boatsplaced).i = newboat.UData; %when enter is clicked, the final u and v data is saved into a structure
                boats(boatsplaced).j = newboat.VData; %this keeps the data permanenet.  data is indexed by number of boats placed
                
                if newboat.VData == 0; %realigning the boats to be centered on the grid based on their u and v vectors
                    newboat.XData = 4; 
                    newboat.YData = 4.5;
                elseif newboat.UData == 0;
                    newboat.XData = 4.5;
                    newboat.YData = 4;
                end
                               
                fig.KeyPressFcn = @place; %now, the keyboard will be used 
                %to place the boat elsewhere.  redefining the callback for key press function      
        end
        
        function place(~, eventdata) %this is that place function
            switch eventdata.Key;
                case 'uparrow';
                    newboat.YData = newboat.YData + 1; %adjusts newboat with x and y data for position
                case 'downarrow';
                    newboat.YData = newboat.YData - 1; %use arrow keys to do this
                case 'rightarrow'
                    newboat.XData = newboat.XData + 1;
                case 'leftarrow'
                    newboat.XData = newboat.XData -1;
                case 'return'
                    boats(boatsplaced).x = newboat.XData; %when enter is pressed, this data is saved into the boat structure again for permanence
                    boats(boatsplaced).y = newboat.YData;
                    boatx = [boats(boatsplaced).x boats(boatsplaced).x+boats(boatsplaced).i];
                    boaty = [boats(boatsplaced).y boats(boatsplaced).y+boats(boatsplaced).j];
                    plot(boatx, boaty, 'LineWidth', 10, 'Color', 'b'); %permamnently plotting this boat on the axes
                    
                    length = getappdata(fig, 'newboatlength');
                    boatxy = zeros(length, 2); 
                    
                    signu = sign(newboat.UData);
                    signv = sign(newboat.VData);
                    
                    if signu > 0 || signv > 0; %adding these points into the matrix representation of the board
                        boatxy(:, 1) = round(linspace(boatx(1) + signu, boatx(2), length)); %slight adjustments are made to account for the mismatch of grid space to vector number
                        boatxy(:, 2) = round(linspace(boaty(1) + signv, boaty(2), length));
                    elseif signu < 0 || signv < 0; %when u or v is negative, then all the vectors are slightly shifted lower.  this accounts for that
                        boatxy(:, 1) = round(linspace(boatx(1), boatx(2) - signu, length));
                        boatxy(:, 2) = round(linspace(boaty(1), boaty(2) - signv, length));
                    end
                    
                    p1board(9 - boatxy(:, 2), boatxy(:, 1)) = boatsplaced; %adding these into the p1board matrix 
     
                    fig.KeyPressFcn = @rotate;  %resetting the keypressfcn to rotating a boat as our work with placement is done, ready for the next boat                  
            end
        end
        if boatsplaced == get(boatnum, 'value')
            readytoplay.Visible = 'on'; %the begin play button will only show once all boats are placed
        end
    end
    function begingame(~, ~) %sets up enemy board
        instmsg.Visible = 'off';
        readytoplay.Visible = 'off';
        readytoplay.Enable = 'off';
        cboats = randi([1 4], 1, boatsplaced); %generates a random length of boat for the same number of boats as placed
        for i = 1:boatsplaced
            startx = randi([1 4]); %places boats in the matrix with the same value as their boat number
            endx = startx + cboats(i) - 1;
            computerboard(startx:endx, randi([1 8])) = i;
        end
        boatbutton1.Visible = 'off'; %turns all used buttons off
        boatbutton2.Visible = 'off';
        boatbutton3.Visible = 'off';
        boatbutton4.Visible = 'off';
        boatnum.Visible = 'off';
        boardcomplete.Visible = 'on';
        boatvalue.Visible = 'off';
        tslider1.Visible = 'off';
        tslider2.Visible = 'off';
        
        axes(ax1)
        hold on
        totalboatcount = text(0.8, 0.95, [num2str(get(boatnum, 'value')) ' boat(s) total']); %displays total number of boats at the top
        totalboatcount.Units = 'normalized';
        hold off
        
        axes(board2);
    end
    function shoot(~, ~) %captures every shot made by your mouse click
        boardcomplete.Visible = 'off';
        axes(board2)
        hold on
        shotpoint = get(gca, 'CurrentPoint'); %gets data from the point
        shotpointx = ceil(shotpoint(1, 1)); %rounds your point to the next highest number
        shotpointx1s = [shotpointx - 0.5 shotpointx - 0.5];
        shotpointx2s = [shotpointx - 1 shotpointx];
        shotpointy = ceil(shotpoint(1, 2));
        shotpointy1s = [shotpointy - 1 shotpointy];
        shotpointy2s = [shotpointy - 0.5 shotpointy - 0.5]; %adding them to matrices so we can plot them
        
        computerboard(shotpointx, shotpointy) = -1 * computerboard(shotpointx, shotpointy); %matrix value will be negative if a boat is shot
        if computerboard(shotpointx, shotpointy) < 0 %if it is negative, plot it red
            plot(shotpointx1s, shotpointy1s, shotpointx2s, shotpointy2s, 'LineWidth', 7, 'Color', 'r');
            shootval = -1*computerboard(shotpointx, shotpointy); %look for any remaining boats with original boatvalue
            A = computerboard == shootval;
            if sum(A) <= 0; %check to see if the complete boat has been shot (all of the boat's values should be gative)
                axes(ax1)
                hold on
                newmsg.String = 'You killed a boat!'; %if all the boat has been killed, display that message
                hold off
                
                boatskilled = getappdata(fig, 'boatskilled');
                boatskilled = boatskilled + 1; %add 1 to the total boats killed count
                setappdata(fig, 'boatskilled', boatskilled);  
                if boatskilled == boatsplaced %check to see if you killed every boat.  if so, display that you win
                    newmsg.String = 'You killed all boats! You win.';
                end
            end      
        else %if you didn't hit a boat, plot it white and display and empty message
            plot(shotpointx1s, shotpointy1s, shotpointx2s, shotpointy2s, 'LineWidth', 7, 'Color', 'w');
            newmsg.String = ' ';
        end
        
        pause(2) %pause 2 seconds while the computer "thinks"
        
        cmoves = zeros(64, 2); %computer will choose a point from a matrix of every possible point
        mat1 = ones(8, 1);
        mat2 = transpose(1:8);
        cmoves(:, 1) = [mat1; 2*mat1; 3*mat1; 4*mat1; 5*mat1; 6*mat1; 7*mat1; 8*mat1];
        cmoves(:, 2) = [mat2; mat2; mat2; mat2; mat2; mat2; mat2; mat2];
 
        shuffledArray = cmoves(randperm(size(cmoves,1)),:); %shuffle up all the options
        
        cmovespotx = shuffledArray(turn, 1); %picks them going down the list in using the turn as a guide
        cmovespotx1s = [cmovespotx - 0.5 cmovespotx - 0.5]; %this avoids repeating a spot
        cmovespotx2s = [cmovespotx - 1 cmovespotx];
        cmovespoty = shuffledArray(turn, 2);
        cmovespoty1s = [cmovespoty - 1 cmovespoty];
        cmovespoty2s = [cmovespoty - 0.5 cmovespoty - 0.5];
        
        turn = getappdata(fig, 'turn'); %adds one to the turn so the next move is a different spot.  
        turn = turn + 1;
        setappdata(fig, 'turn', turn); 
        
        p1board(cmovespotx, cmovespoty) = -1 * p1board(cmovespotx, cmovespoty);
        
        if p1board(cmovespotx, cmovespoty) < 0 %same comparison to see if the computer killed any of the player's boats
            axes(board1);
            hold on
            plot(cmovespotx1s, cmovespoty1s, cmovespotx2s, cmovespoty2s, 'LineWidth', 7, 'Color', 'r');
            hold off
            shootval2 = -1*p1board(cmovespotx, cmovespoty);
            B = p1board == shootval2;
            if sum(B) <= 0;
                axes(ax1)
                hold on
                newmsg.String = 'Your enemy killed a boat!';
                hold off
                
                p1boatskilled = getappdata(fig, 'p1boatskilled');
                p1boatskilled = p1boatskilled + 1;
                setappdata(fig, 'p1boatskilled', p1boatskilled);  
                if p1boatskilled == boatsplaced;
                    newmsg.String = 'All your boats were killed. You lose.';
                end
            end      
        else %if it didn't hit a boat, plot it white and display no message
            axes(board1) 
            hold on
            plot(cmovespotx1s, cmovespoty1s, cmovespotx2s, cmovespoty2s, 'LineWidth', 7, 'Color', 'w');
            hold off
            newmsg.String = ' ';
        end 
    end
end





