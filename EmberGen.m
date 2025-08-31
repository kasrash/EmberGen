%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EmberGen: A Data-Driven Firebrand Generation Model                                      %
% This code generates firebrands given the input parameters and saves them as a .csv file %
%                                                                                         %
% Developed by: Kasra Shamsaei, University of Nevada, Reno                                %
% Email: kshamsaei@unr.edu                                                                %
% Last revision: 08/31/2025                                                                %
% Changlog: N/A                                                                           %
%                                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc;
clear all;
close all;


%% Inputs - Change as needed
U = 3;  % wind speed (m/s)
MC = 15; % Fuel moisture content (%)
MFC = 5000; % Mass of fuel consumed (g)
VT = "tree"; % vegetation type: "tree", "grass", or "shrub"
outFile = "test.csv"; % output file path and name. The first column is firebrand mass (g) and the second column is its projected area (mm2).

%% run the model
[m_gen, A_gen] = generation_model(U, MC, MFC, VT);
writematrix([m_gen', A_gen], outFile);

%% Model Functions - do not edit
function [m_gen, A_gen] = generation_model(u, mc, m_burn, veg)
%% calculate the yield (comp1)
yield = 3.45*u^0.52 - 0.067*mc + 0.8976; %based on Eq. 1 in the paper
m_fb = (yield/100) * m_burn; %total mass of firebrands (g)

%% calculate the mass distribution (comp2) - based on Table 2 in the paper
if veg == "tree"
    mu = 0.0216*u - 1.217;
    sigma = 0.001*u + 0.444;
elseif veg == "grass"
    mu = 0.0114*u - 1.079;
    sigma = -0.0021*u + 0.4;
elseif veg == "shrub"
    mu = 0.0217*u - 1.347;
    sigma = -0.0063*u + 0.6;
end

m_dist = makedist("Normal","mu",mu,"sigma",sigma); % create the mass distribution

%% generate firebrands
m_gen = dist_sampler(m_dist, m_fb); % sample from the above-created mass distribution

%% calculate the area of the brands - based on Table 3 in the paper
if veg == "tree"
    A_gen_log = 0.56.*log10(m_gen') + 2.803 + random("Normal",0,0.136, length(m_gen),1);
elseif veg == "grass"
    A_gen_log = 0.311.*log10(m_gen') + 2.48 + random("Normal",0,0.136, length(m_gen),1);
elseif veg == "shrub"
    A_gen_log = 0.352.*log10(m_gen') + 2.75 + random("Normal",0,0.228, length(m_gen),1);
end

A_gen = 10.^A_gen_log; % convert to non-log scale

end

function dist_data = dist_sampler(dist, total)
% function to sample from distribution until the toal samples mass reaches the
% total mass.
% dist: a distribution to sample from
% total: total mass of the firebrands as determined from Component 1
% dis_data: realizations of firebrands mass as sampled from the
% distribution
%%%%%
sample_sum = 0;
index = 1;
while sample_sum < total
    sample = random(dist,1);
    dist_data(index) = 10^sample;
    sample_sum = sum(dist_data);
    index = index+1;
end
if sum(dist_data) > total
    dist_data(end) = total - sum(dist_data(1:end-1));
end
end