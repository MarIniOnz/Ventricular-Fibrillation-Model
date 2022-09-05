clc
clear

%% The user can decide their own pacing period when running the program

disp('Choose your AV node pacing period by inserting the following numbers:');
fprintf('1. 200 ms \n2. 750 ms\n3. Choose your own pace!\n');
choice = input('Which will be your chosen option? ','s');
option = str2num(choice);

% Set the pace period that will be used for the exercise
switch option
    case 1
        pace_period = 200; % ms
    case 2
        pace_period = 750; % ms
    case 3
        p_period_chosen = input('Which will be your pace (ms)? ','s');
        pace_period = str2num(p_period_chosen);
    otherwise
        error('It was either 1, 2 or 3, come on! :(')
end

%% Data


t_ex= 70; % Duration of excited state (ms).
t_mean_rp = 250; % Mean total refractory period (ms).
std_rp = 100; % Standard deviation of total refractory period (ms).
t_rel_refract = 50; % Duration of the relative refractory period (ms).

time_step = 2; % Time step increment (ms).
max_time = 1700; % End of computations' time (ms).

% Here we can determine the moments that the AV node is going to try to
% become excited (if not in the absolute refractory period).
pacemaking = [0:pace_period:max_time, max_time+time_step ];

% Auxiliary variable to advance in the pacemaking variable.
done_pace = 1;

% Time elapsed (ms) from entering refractory, the position refers to the #
% of neighbours required for the cell to be excited again (that is way the
% first position is a NaN: we would not be in the relative refractory
% period anymore.

time_elapsed=[NaN,50,20,12,8,6,4,2];

% Time vector
time0 = 0 : time_step : max_time;

% Initialization of main variables.
H_state = zeros(50);
S_duration = zeros(50);

% Update state for next iteration
H1_state = zeros(50);
 
% Calculation of the matrix of Refractory periods depending on the mean and
% standard deviation and using a random distribution thanks to the randn
% command.
Ref_Period = t_mean_rp + std_rp *randn(size(H_state));

% Set-up for the video
writerObj = VideoWriter(['Ventricule_Model_' num2str(pace_period) 'ms.avi']);
writerObj.FrameRate = 30;
open(writerObj)
figure(1)

% Main loop of the program

for k = 1:length(time0) % k time-points calculated with time_step difference
    for i= 1:50 % Rows
        for j=1:50 % Columns
            change_ex=0; % Boolean variable for relative ref. period
            
            % A function was created to calculate the neighboring excited
            % cells per element of the matrix.
            num_excited=num_excit(i,j,H_state); 
           
            % Which is the element situation?
            switch H_state(i,j)
                
                case 0 % Quiescent state
                    if num_excited>=1 
                        
                        % If there is any neighboring element excited, it
                        % will be excited.
                        H1_state(i,j)=3;
                        S_duration(i,j)=0;
                        
                    else % It can be quiescent for as long as it is not excited by another element
                        S_duration(i,j)=S_duration(i,j)+time_step;
                    end
                    
                case 3 % Excited state
                    if S_duration(i,j)>t_ex 
                       
                        % If it surpasses the excitation time, it will
                        % switch its stage.
                        H1_state(i,j)=2;
                        S_duration(i,j)=0;
                        
                    else % It continues being in this state if not.
                        S_duration(i,j)=S_duration(i,j)+time_step;
                    end
                    
                case 2 % Absolute refractory state
                    if S_duration(i,j)<(Ref_Period(i,j)-t_rel_refract)
                        
                        % We have to take into account that the relative
                        % refractory period is fixed, so if we subtract it
                        % from the Total, we will get the Absolute one.
                        S_duration(i,j)=S_duration(i,j)+time_step;
                        
                    else % If it surpasses that time, it switches to rel.
                        S_duration(i,j)=0;
                        H1_state(i,j)=1;
                    end
                    
                case 1 % Relative refractory state
                    if num_excited >=2
                    % If there is at least 2 excited neighboring elements,
                    % something may happen (see the Table in the document)
                        
                        if time_elapsed(num_excited)<=S_duration(i,j)
                           
                            % In the vector that we created time_elapsed,
                            % every position of number of excited neighbors
                            % correspond to the time needed for a change
                            % depending on that number.
                            change_ex=1;  
                            % Boolean var. saying there is a change towards excitement                           
                        end
                    end
                    
                    if S_duration(i,j)>=t_rel_refract && change_ex==0
                        
                        % If there were no excited neighbors, there can
                        % still be a change (towards quiescent) if the 
                        % relative refractory period has been surpassed.
                        S_duration(i,j)=0;
                        H1_state(i,j)=0;
                        
                    elseif change_ex==1
                        
                        % If there was a change towards excitement, the
                        % H_state is update so.
                        S_duration(i,j)=0;
                        H1_state(i,j)=3;
                        
                    else
                        S_duration(i,j)=S_duration(i,j)+time_step;
                    end
            end
            
            % AV node pacemaking activity. For only (1,13) element.
            if (k-1)*time_step >= pacemaking(done_pace) && i==1 && j==13
                
                % If we have reached a time when there should be pacemaking
                % activity, we check whether it can be activated.
                done_pace = done_pace+1;
                
                if ~(H_state(i,j)==2) % If not absolute refractory.
                    H1_state(i,j)= 3;
                    S_duration(i,j)=0;
                end
            end
        end
    end
    
% We update the state of the heart matrix after all positions have been
% computed
H_state=H1_state;

% Plot of the heart representation
drawnow % So it can be seen as an animated graph
pcolor(H_state); caxis([0  3]), axis ('square');
title(['Ventricular fibrillation model T= ' num2str(time0(k))])
xlabel(['AV node pacing period = ' num2str(pace_period) ' (ms)']);

% Write each frame of the plot into our video
frame = getframe(figure(1));
writeVideo(writerObj,frame);

if time0(k)==(750+190)
k;
end

if time0(k)==200
k;
end


end

close(writerObj)
    