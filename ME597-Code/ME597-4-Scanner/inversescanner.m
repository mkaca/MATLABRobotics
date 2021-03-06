function [m] = inversescanner(M,N,x,y,theta,meas_phi,meas_r,rmax,alpha,beta)
% Calculates the inverse measurement model for a laser scanner
% Identifies three regions, the first where no new information is
% available, the second where objects are likely to exist and the third
% where objects are unlikely to exist

% Range finder inverse measurement model
for i = 1:M
    for j = 1:N
        % Find range and bearing to the current cell
        % where r corresponds to distance from robot to current
        % cell that is being looked at 
        r = sqrt((i-x)^2+(j-y)^2);
        phi = mod(atan2(j-y,i-x)-theta+pi,2*pi)-pi;
        
        % MN: NOTE: you cannot simply do inverse tan and expect the 
        % MN: angle to be from the robot eyes to the cell. You must subtract the robot's heading (theta)
        % MN: add pi to keep it in the range of 0 to pi, take the modulo so
        % MN: you don't get weird multiples of 2*pi and then subtract pi
        % MN: again to correct the range
        
        % Find the applicable range measurement 
        [meas_cur,k] = min(abs(phi-meas_phi));

        % If out of range, or behind range measurement, or outside of field
        % of view, no new information is available
        if (r > min(rmax, meas_r(k)+alpha/2) || (abs(phi-meas_phi(k))>beta/2))
            m(i,j) = 0.5;

        % If the range measurement was in this cell, likely to be an object
        elseif ((meas_r(k)< rmax) && (abs(r-meas_r(k))<alpha/2))
             m(i,j) = 0.6;
        
        % If the cell is in front of the range measurement, likely to be
        % empty
        elseif (r < meas_r(k)) 
            m(i,j) = 0.4;
        end
    end
end
