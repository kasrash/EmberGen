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
%% load the model components
load("Components\comp1_final.mat");
load("Components\comp2_final.mat");
load("Components\comp3_final.mat");

%% calculate the yield (comp1)
yield = feval(sf,[u,mc]);
m_fb = (yield/100) * m_burn; %total madd of firebrands

%% calculate the mass distribution (comp2)
if veg == "tree"
    mu = feval(mu_t,u);
    sigma = feval(sigma_t,u);
elseif veg == "grass"
    mu = feval(mu_g,u);
    sigma = feval(sigma_g,u);
elseif veg == "shrub"
    mu = feval(mu_s,u);
    sigma = feval(sigma_s,u);
end

m_dist = makedist("Normal","mu",mu,"sigma",sigma);

%% generate firebrands
m_gen = dist_sampler(m_dist, m_fb);

%% calculate the area of the brands
if veg == "tree"
    A_gen_final = feval(fit_tree,log10(m_gen)) + random(e_fit_tree,length(m_gen),1);
elseif veg == "grass"
    A_gen_final = feval(fit_grass,log10(m_gen)) + random(e_fit_grass,length(m_gen),1);
elseif veg == "shrub"
    A_gen_final = feval(fit_shrub,log10(m_gen)) + random(e_fit_shrub,length(m_gen),1);
end

A_gen = 10.^A_gen_final;

end

function dist_data = dist_sampler(dist, total)
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