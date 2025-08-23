%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EmberGen: A Data-Driven Firebrand Generation Model        %
% This code trains the component 1: yield of the model      %
%                                                           %
% Developed by: Kasra Shamsaei, University of Nevada, Reno  %
% Email: kshamsaei@unr.edu                                  %
% Last revision: 1/13/2025                                  %
% Changlog: N/A                                             %
%                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc;
clear all;
close all;

load("comps/comp3_final.mat")

%% load the validation data
df24 = readmatrix(""); %path to data, not publicly available
df45 = readmatrix(""); %path to data, not publicly available
m_df24 = df24(:,2);
m_df45 = df45(:,2);
A_df24 = df24(:,1);
A_df45 = df45(:,1);
u_df = [0, 0];
mc_df = [10, 18];
m_burn = [4, 17] * 1000;

%% test
[m_gen24, A_gen24] = generation_model(u_df(1),mc_df(1),m_burn(1));
[m_gen45, A_gen45] = generation_model(u_df(2),mc_df(2),m_burn(2));

%% plot the generation masses
figure(45) 
histogram(log10(m_df45),15,"Normalization","percentage","BinWidth",0.3,"FaceColor","#1f77b4")
hold on
histogram(log10(m_gen45),15,"Normalization","percentage","BinWidth",0.3,"FaceColor","#ff7f0e")

legend(["True, \mu=0.21 g, \sigma=0.18 g","Model, \mu=0.3 g, \sigma=0.15 g"])
grid on
box on

plt = Plot();

plt.BoxDim = [3.5, 3]; %[width, height] in inches
plt.XLabel = "log_{10}(m (g))";
plt.YLabel = "Percentage (%)";
plt.YLim = [0,35];
% plt.YLim = [0, 1.4];
plt.AxisLineWidth = .7;
% plt.TickLength = [0.04,0.04];
% plt.Legend = [sc1,sc2,sc3];
plt.LegendBox = 'on';
plt.LegendLoc = 'NorthWest';
plt.FontSize = 14;
plt.LineWidth = .3;

% figure(452) 
% h = histogram(m_gen45,"Normalization","percentage","BinWidth",0.2);
% values = h.Values;
% bins = h.BinEdges;
% hold on
% histogram(m_df45,"Normalization","percentage","BinWidth",0.2)
% legend(["Modeled", "True"])
% xlabel('m')
% grid on
% box on
% ylabel('PDF')

figure(24) 
histogram(log10(m_df24),15,"Normalization","percentage","BinWidth",0.3,"FaceColor","#1f77b4")
hold on
histogram(log10(m_gen24),15,"Normalization","percentage","BinWidth",0.3,"FaceColor","#ff7f0e")

legend(["True, \mu=0.1 g, \sigma=0.16 g","Model, \mu=0.16 g, \sigma=0.13 g"])
grid on
box on

plt = Plot();

plt.BoxDim = [3.5, 3]; %[width, height] in inches
plt.XLabel = "log_{10}(m (g))";
plt.YLabel = "Percentage (%)";
plt.YLim = [0,30];
% plt.YLim = [0, 1.4];
plt.AxisLineWidth = .7;
% plt.TickLength = [0.04,0.04];
% plt.Legend = [sc1,sc2,sc3];
plt.LegendBox = 'on';
plt.LegendLoc = 'NorthWest';
plt.FontSize = 14;
plt.LineWidth = .3;

% figure(242)
% histogram(m_gen24,"Normalization","percentage","BinWidth",0.2)
% hold on
% histogram(m_df24,"Normalization","percentage","BinWidth",0.2)
% legend(["Modeled", "True"])
% xlabel('m')
% grid on
% box on
% ylabel('PDF')

%% plot the generation projected area
figure(145) 
histogram(log10(A_df45),15,"Normalization","percentage","BinWidth",0.2,"FaceColor","#1f77b4")
hold on
histogram(log10(A_gen45),15,"Normalization","percentage","BinWidth",0.2,"FaceColor","#ff7f0e")

legend(["True, \mu=167 mm^2, \sigma=133 mm^2","Model, \mu=133 mm^2, \sigma=119 mm^2"])
grid on
box on

plt = Plot();

plt.BoxDim = [3.5, 3]; %[width, height] in inches
plt.XLabel = "log_{10}(A (mm^2))";
plt.YLabel = "Percentage (%)";
plt.YLim = [0,37];
% plt.YLim = [0, 1.4];
plt.AxisLineWidth = .7;
% plt.TickLength = [0.04,0.04];
% plt.Legend = [sc1,sc2,sc3];
plt.LegendBox = 'on';
plt.LegendLoc = 'NorthWest';
plt.FontSize = 14;
plt.LineWidth = .3;

% figure(1452) 
% histogram(A_gen45,"Normalization","percentage","BinWidth",100)
% hold on
% histogram(A_df45,"Normalization","percentage","BinWidth",100)
% legend(["Modeled", "True"])
% xlabel('A')
% grid on
% box on
% ylabel('PDF')

figure(124) 
histogram(log10(A_df24),15,"Normalization","percentage","BinWidth",0.2,"FaceColor","#1f77b4")
hold on
histogram(log10(A_gen24),15,"Normalization","percentage","BinWidth",0.2,"FaceColor","#ff7f0e")
legend(["Modeled", "True"])
xlabel('Log_1_0(A)')
grid on
box on
ylabel('PDF')

legend(["True, \mu=166 mm^2, \sigma=126 mm^2","Model, \mu=195 mm^2, \sigma=184 mm^2"])
grid on
box on

plt = Plot();

plt.BoxDim = [3.5, 3]; %[width, height] in inches
plt.XLabel = "log_{10}(A (mm^2))";
plt.YLabel = "Percentage (%)";
plt.YLim = [0,35];
% plt.YLim = [0, 1.4];
plt.AxisLineWidth = .7;
% plt.TickLength = [0.04,0.04];
% plt.Legend = [sc1,sc2,sc3];
plt.LegendBox = 'on';
plt.LegendLoc = 'NorthWest';
plt.FontSize = 14;
plt.LineWidth = .3;

% figure(1242)
% histogram(A_gen24,"Normalization","percentage","BinWidth",100)
% hold on
% histogram(A_df24,"Normalization","percentage","BinWidth",100)
% legend(["Modeled", "True"])
% xlabel('A')
% grid on
% box on
% ylabel('PDF')

figure(3000)
x = linspace(1e-4,100,1000);
y_tree = feval(fit_tree,log10(x));

hold on
scatter(m_df24,A_df24,'x','MarkerEdgeAlpha',1, "MarkerEdgeColor","#1f77b4")
scatter(m_gen24,A_gen24,'o','MarkerEdgeAlpha',.85,"MarkerEdgeColor","#ff7f0e")
p1 = plot(x,10.^y_tree,"Color","k");

ylabel('Projected area, A (mm^2)')
xlabel('Mass, m (g)')

set(gca, 'YScale', 'log')
set(gca, 'XScale', 'log')

legend(["Data", "Prediction", "Linear Fit"]);

box on

plt = Plot();

plt.BoxDim = [3.5, 3]; %[width, height] in inches
plt.XLabel = "m_0 (g)";
plt.YLabel = "A_0 (mm^2)";
plt.AxisLineWidth = .7;
% plt.TickLength = [0.04,0.04];
% plt.Legend = [sc1,sc2,sc3];
plt.LegendBox = 'on';
plt.LegendLoc = 'NorthWest';
plt.FontSize = 14;
plt.LineWidth = .3;
plt.XLim = [1e-3, 1e1];
plt.YLim = [1e1, 1e3];

plt.XGrid = 'on';
plt.YGrid = 'on';
plt.XMinorGrid = 'on';
plt.YMinorGrid = 'on';

p1.LineWidth = 2;

figure(3010)
hold on
scatter(m_df45,A_df45,'x','MarkerEdgeAlpha',1,"MarkerEdgeColor","#1f77b4")
scatter(m_gen45,A_gen45,'o','MarkerEdgeAlpha',.85,"MarkerEdgeColor","#ff7f0e")
p1 = plot(x,10.^y_tree,"Color","k");

ylabel('Projected area, A (mm^2)')
xlabel('Mass, m (g)')

set(gca, 'YScale', 'log')
set(gca, 'XScale', 'log')

legend(["Data", "Prediction", "Linear Fit"]);

box on

plt = Plot();

plt.BoxDim = [3.5, 3]; %[width, height] in inches
plt.XLabel = "m_0 (g)";
plt.YLabel = "A_0 (mm^2)";
plt.AxisLineWidth = .7;
% plt.TickLength = [0.04,0.04];
% plt.Legend = [sc1,sc2,sc3];
plt.LegendBox = 'on';
plt.LegendLoc = 'NorthWest';
plt.FontSize = 14;
plt.LineWidth = .3;
plt.XLim = [1e-3, 1e1];
plt.YLim = [1e1, 1e3];

plt.XGrid = 'on';
plt.YGrid = 'on';
plt.XMinorGrid = 'on';
plt.YMinorGrid = 'on';

p1.LineWidth = 2;


function [m_gen, A_gen] = generation_model(u, mc, m_burn)
%% load the model components
load("comps\comp1_final.mat");
load("comps\comp2_final.mat");
load("comps\comp3_final.mat");

%% calculate the yield (comp1)
yield = feval(sf,[u,mc]);
m_fb = (yield/100) * m_burn; %total madd of firebrands

%% calculate the mass distribution (comp2)
mu = feval(mu_t,u);
sigma = feval(sigma_t,u);
m_dist = makedist("Normal","mu",mu,"sigma",sigma);

%% generate firebrands
m_gen = dist_sampler(m_dist, m_fb);

%% calculate the area of the brands
A_gen_final = feval(fit_tree,log10(m_gen)) + random(e_fit_tree,length(m_gen),1);
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