% Simple Perturb & Observe (P&O) MPPT Simulation
clear; clc; close all;

%% 1. Simulation Parameters
total_steps = 100;
delta_V = 0.5;          % Perturbation step size (Volts)
V_old = 10;             % Initial panel voltage guess (Volts)
P_old = 0;              % Initial panel power (Watts)

% Arrays to store results for plotting
v_history = zeros(1, total_steps);
p_history = zeros(1, total_steps);

%% 2. Simulation Loop
for k = 1:total_steps
    
    % --- Simulate the Solar Panel Environment ---
    % We will use a mock function that returns power based on voltage.
    % The peak (MPP) of this imaginary panel is at exactly 18 Volts.
    P_current = mock_solar_panel(V_old);
    
    % Store data for plotting later
    v_history(k) = V_old;
    p_history(k) = P_current;
    
    % --- Core P&O MPPT Algorithm ---
    delta_P = P_current - P_old;
    
    if delta_P > 0
        % If power increased, keep moving in the same direction
        if V_old > v_history(max(1, k-1))
            V_new = V_old + delta_V;
        else
            V_new = V_old - delta_V;
        end
    else
        % If power decreased, reverse the direction
        if V_old > v_history(max(1, k-1))
            V_new = V_old - delta_V;
        else
            V_new = V_old + delta_V;
        end
    end
    
    % For the very first step, force a positive direction change
    if k == 1
        V_new = V_old + delta_V;
    end
    
    % Update states for the next iteration
    P_old = P_current;
    V_old = V_new;
end

%% 3. Plotting the Tracking Behavior
figure('Position', [100, 100, 900, 400]);

% Plot 1: Voltage convergence over time
subplot(1,2,1);
plot(v_history, 'LineWidth', 2, 'Color', '#0072BD');
grid on; hold on;
yline(18, '--r', 'True MPP (18V)', 'LineWidth', 1.5);
xlabel('Algorithm Iterations');
ylabel('Panel Voltage (V)');
title('Voltage Tracking Over Time');

% Plot 2: Power optimization over time
subplot(1,2,2);
plot(p_history, 'LineWidth', 2, 'Color', '#D95319');
grid on; hold on;
xlabel('Algorithm Iterations');
ylabel('Extracted Power (W)');
title('Power Output Optimization');

%% 4. Mock PV Panel Characteristic Function
function Power = mock_solar_panel(V)
    % A simple mathematical parabola to simulate a P-V curve.
    % Maximum power occurs at V = 18V where Power = 100W.
    Power = -0.5 * (V - 18)^2 + 100;
    if Power < 0, Power = 0; end % Power cannot be negative
end
% hello
