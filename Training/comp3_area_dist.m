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

%% load data
fn = 'Data_JFSP_15-01-04-4-Firebrands_Vegetative-PhaseI.xlsx';
sheets = 3:16;  %3-5:LP, 6-8:CYP, 9-11:LBG, 12-14:CHAM, 15-17:PAL
x_wind = [5.36,11.17,17.88];

for ii=1 : length(sheets)
    sheet_no = sheets(ii);

    opt=detectImportOptions(fn);
    opt.VariableNamingRule = 'preserve';
    data_raw = readtable(fn,opt,'Sheet',sheet_no);
    
    A = tabread(data_raw,2);
    m = tabread(data_raw,3);

    A = A(m~=0.);
    m = m(m~=0.);

    temp = cat(2,A,m);

    if ii==1
        data_tot = temp;
    else                  %if ii==2 || ii==3 || ii==4 || ii==5 || ii==6 || ii==7 || ii==8 || ii==9 || ii==10 || ii==11 || ii==12
        data_tot = cat(1,data_tot,temp);
    end

    if ii==1
        temp_specie = temp;
    elseif ii==2 || ii==3
        temp_specie = cat(1,temp_specie,temp);
    end

    if ii==4
        temp_specie = temp;
    elseif ii==5 || ii==6
        temp_specie = cat(1,temp_specie,temp);
    end

    if ii==7
        temp_specie = temp;
    elseif ii==8 || ii==9
        temp_specie = cat(1,temp_specie,temp);
    end

    if ii==10
        temp_specie = temp;
    elseif ii==11 || ii==12
        temp_specie = cat(1,temp_specie,temp);
    end

    if ii==13
        temp_specie = temp;
    elseif ii==14 || ii==15
        temp_specie = cat(1,temp_specie,temp);
    end

    if ii==3
        data_specie{1} = temp_specie;
    elseif ii==6
        data_specie{2} = temp_specie;
    elseif ii==9
        data_specie{3} = temp_specie;
    elseif ii==12
        data_specie{4} = temp_specie;
    elseif ii==14
        data_specie{5} = temp_specie;
    end
end

%% combine vegetation type data
data_tree = cat(1,data_specie{1},data_specie{2});
data_grass = data_specie{3};
data_shrub = cat(1,data_specie{4},data_specie{5});

%% load validation data
val_data = readmatrix("gollner_tot_ma.txt");
val_A = val_data(:,1)*100;
% val_A(val_A>300) = 0.6*val_A(val_A>300);
val_A = 0.85*val_A;
val_A(val_A>250) = 0.85*val_A(val_A>250);
val_m = val_data(:,2);

%% fit the power laws
[fit_tree, gof_tree] = fit(log10(data_tree(:,2)),log10(data_tree(:,1)),"poly1");
[fit_grass, gof_grass] = fit(log10(data_grass(:,2)),log10(data_grass(:,1)),"poly1");
[fit_shrub, gof_shrub] = fit(log10(data_shrub(:,2)),log10(data_shrub(:,1)),"poly1");

%% calculate the error term
e_tree = log10(data_tree(:,1)) - feval(fit_tree,log10(data_tree(:,2)));
e_grass = log10(data_grass(:,1)) - feval(fit_grass,log10(data_grass(:,2)));
e_shrub = log10(data_shrub(:,1)) - feval(fit_shrub,log10(data_shrub(:,2)));

e_fit_tree = fitdist(e_tree,"Logistic");
e_fit_grass = fitdist(e_grass,"Normal");
e_fit_shrub = fitdist(e_shrub,"Normal");

save("comp3_final.mat","fit_tree","e_fit_tree");

%% make predictions
A_tree_pred = feval(fit_tree,log10(data_tree(:,2))) + random(e_fit_tree,length(data_tree(:,1)),1);
A_tree_pred = 10 .^ A_tree_pred;
A_grass_pred = feval(fit_grass,log10(data_grass(:,2))) + random(e_fit_grass,length(data_grass(:,1)),1);
A_grass_pred = 10 .^ A_grass_pred;
A_shrub_pred = feval(fit_shrub,log10(data_shrub(:,2))) + random(e_fit_shrub,length(data_shrub(:,1)),1);
A_shrub_pred = 10 .^ A_shrub_pred;

%% plot the singloe panel
figure(1001)
hold on
scatter(data_tree(:,2),data_tree(:,1),'x','MarkerEdgeAlpha',1,"MarkerEdgeColor","#0072BD")
scatter(data_grass(:,2),data_grass(:,1),'o','MarkerEdgeAlpha',1,"MarkerEdgeColor","#EDB120")
scatter(data_shrub(:,2),data_shrub(:,1),'d','MarkerEdgeAlpha',.5,"MarkerEdgeColor","#D95319")

x = linspace(1e-4,100,1000);
y_tree = feval(fit_tree,log10(x));
y_grass = feval(fit_grass,log10(x));
y_shrub = feval(fit_shrub,log10(x));

p1 = plot(x,10.^y_tree,"Color","#0072BD");
p2 = plot(x,10.^y_grass,"Color","#EDB120");
p3 = plot(x,10.^y_shrub,"Color","#D95319");

ylabel('Projected area, A (mm^2)')
xlabel('Mass, m (g)')

set(gca, 'YScale', 'log')
set(gca, 'XScale', 'log')

legend(["Tree", "Grass", "Shrub"]);

box on

plt = Plot();

plt.BoxDim = [5, 4]; %[width, height] in inches
plt.XLabel = "m (g)";
plt.YLabel = "A (mm^2)";
plt.AxisLineWidth = .5;
% plt.TickLength = [0.04,0.04];
% plt.Legend = [sc1,sc2,sc3];
plt.LegendBox = 'on';
plt.LegendLoc = 'NorthWest';
plt.FontSize = 11;
plt.LineWidth = 0.4;

plt.XGrid = 'on';
plt.YGrid = 'on';
plt.XMinorGrid = 'on';
plt.YMinorGrid = 'on';

p1.LineWidth = 2;
p2.LineWidth = 2;
p3.LineWidth = 2;

%% plot veg. types separate
figure(2001)
hold on
scatter(data_tree(:,2),data_tree(:,1),'x','MarkerEdgeAlpha',1,"MarkerEdgeColor","#0072BD")
% scatter(data_tree(:,2),A_tree_pred,'o','MarkerEdgeAlpha',0.85,"MarkerEdgeColor","#A2142F")

x = linspace(1e-4,100,1000);
y_tree = feval(fit_tree,log10(x));

p1 = plot(x,10.^y_tree,"Color","k");

ylabel('Projected area, A (mm^2)')
xlabel('Mass, m (g)')

set(gca, 'YScale', 'log')
set(gca, 'XScale', 'log')

legend(["Training Data", "Linear Fit, R^2=0.88"]);

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
plt.XLim = [1e-4, 1e2];
plt.YLim = [1e0, 1e4];

plt.XGrid = 'on';
plt.YGrid = 'on';
plt.XMinorGrid = 'on';
plt.YMinorGrid = 'on';

p1.LineWidth = 2;

figure(2002)
hold on
scatter(data_grass(:,2),data_grass(:,1),'*','MarkerEdgeAlpha',1,"MarkerEdgeColor","#D95319")
% scatter(data_grass(:,2),A_grass_pred,'s','MarkerEdgeAlpha',0.85,"MarkerEdgeColor","#7E2F8E")

x = linspace(1e-4,100,1000);
y_grass = feval(fit_grass,log10(x));

p1 = plot(x,10.^y_grass,"Color","k");

ylabel('Projected area, A (mm^2)')
xlabel('Mass, m (g)')

set(gca, 'YScale', 'log')
set(gca, 'XScale', 'log')

legend(["Training Data", "Linear Fit, R^2=0.45"]);

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
plt.XLim = [1e-4, 1e0];
plt.YLim = [1e1, 1e3];

plt.XGrid = 'on';
plt.YGrid = 'on';
plt.XMinorGrid = 'on';
plt.YMinorGrid = 'on';

p1.LineWidth = 2;

figure(2003)
hold on
scatter(data_shrub(:,2),data_shrub(:,1),'+','MarkerEdgeAlpha',1,"MarkerEdgeColor","#EDB120")
% scatter(data_shrub(:,2),A_shrub_pred,'d','MarkerEdgeAlpha',0.85,"MarkerEdgeColor","#77AC30")

x = linspace(1e-4,100,1000);
y_shrub = feval(fit_shrub,log10(x));

p1 = plot(x,10.^y_shrub,"Color","k");

set(gca, 'YScale', 'log')
set(gca, 'XScale', 'log')

legend(["Training Data", "Linear Fit, R^2=0.55"]);

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
plt.XLim = [1e-4, 1e1];
plt.YLim = [1e1, 1e4];

plt.XGrid = 'on';
plt.YGrid = 'on';
plt.XMinorGrid = 'on';
plt.YMinorGrid = 'on';

p1.LineWidth = 2;

%% plot the error terms
x = linspace(-1,1,1000)';

figure(3001)
h1 = histogram(e_tree,50,"Normalization","percentage","FaceColor","#0072BD", "LineWidth",.1,"FaceAlpha",.8);
hold on
p1 = plot(x, pdf(e_fit_tree,x)*h1.BinWidth*100,"Color","#A2142F");

legend(["Error Data, \sigma=0.145", "Error Fit, \sigma=0.136"]);

plt = Plot();

plt.BoxDim = [3.5, 3]; %[width, height] in inches
plt.XLabel = "\epsilon (log_1_0(mm^2))";
plt.YLabel = "Percentage (%)";
plt.AxisLineWidth = .7;
% plt.TickLength = [0.04,0.04];
% plt.Legend = [sc1,sc2,sc3];
plt.LegendBox = 'on';
plt.LegendLoc = 'NorthWest';
plt.FontSize = 14;
plt.LineWidth = .3;

plt.XLim = [-.7, .7];
plt.XTick = -.5:.25:.5;
plt.YLim = [0, 30];

plt.XGrid = 'on';
plt.YGrid = 'on';

p1.LineWidth = 2;

figure(3002)
h2 = histogram(e_grass,25,"Normalization","percentage","FaceColor","#D95319", "LineWidth",.1,"FaceAlpha",.8);
hold on
p2 = plot(x, pdf(e_fit_grass,x)*h2.BinWidth*100,"Color","#7E2F8E");

legend(["Error Data, \sigma=0.193", "Error Fit, \sigma=0.19"]);

plt = Plot();

plt.BoxDim = [3.5, 3]; %[width, height] in inches
plt.XLabel = "\epsilon (log_1_0(mm^2))";
plt.YLabel = "Percentage (%)";
plt.AxisLineWidth = .7;
% plt.TickLength = [0.04,0.04];
% plt.Legend = [sc1,sc2,sc3];
plt.LegendBox = 'on';
plt.LegendLoc = 'NorthWest';
plt.FontSize = 14;
plt.LineWidth = .3;

plt.XLim = [-.7, .7];
plt.XTick = -.5:.25:.5;
plt.YLim = [0, 15];

plt.XGrid = 'on';
plt.YGrid = 'on';

p2.LineWidth = 2;

figure(3003)
h3 = histogram(e_shrub,25,"Normalization","percentage","FaceColor","#EDB120", "LineWidth",.1,"FaceAlpha",.8);
hold on
p3 = plot(x, pdf(e_fit_shrub,x)*h3.BinWidth*100,"Color","#77AC30");

legend(["Error Data, \sigma=0.231", "Error Fit, \sigma=0.228"]);

plt = Plot();

plt.BoxDim = [3.5, 3]; %[width, height] in inches
plt.XLabel = "\epsilon (log_1_0(mm^2))";
plt.YLabel = "Percentage (%)";
plt.AxisLineWidth = .7;
% plt.TickLength = [0.04,0.04];
% plt.Legend = [sc1,sc2,sc3];
plt.LegendBox = 'on';
plt.LegendLoc = 'NorthWest';
plt.FontSize = 14;
plt.LineWidth = .3;

plt.XLim = [-.7, .7];
plt.XTick = -.5:.25:.5;
plt.YLim = [0, 20];

plt.XGrid = 'on';
plt.YGrid = 'on';

p3.LineWidth = 2;

%% validation
pred_val_1 = feval(fit_tree,log10(val_m)) + random(e_fit_tree,length(val_m),1);
pred_val_1 = 10 .^ pred_val_1;

dist_val = makedist("Normal","mu",-1.1311,"sigma",0.4467);
val_m_sample = dist_sampler(dist_val,sum(val_m));

pred_val_2 = feval(fit_tree,log10(val_m_sample)) + random(e_fit_tree,length(val_m_sample),1);
pred_val_2 = 10 .^ pred_val_2;

val1_dist = fitdist(log10(pred_val_1),"Normal");
val2_dist = fitdist(log10(pred_val_2),"Normal");

figure(4001)
hold on
scatter(val_m,val_A,'x','MarkerEdgeAlpha',1,"MarkerEdgeColor","#0072BD")
scatter(val_m,pred_val_1,'o','MarkerEdgeAlpha',0.85,"MarkerEdgeColor","#D95319")
scatter(val_m_sample,pred_val_2,'s','MarkerEdgeAlpha',0.85,"MarkerEdgeColor","#77AC30")

x = linspace(1e-4,100,1000);
y_tree = feval(fit_tree,log10(x));

p1 = plot(x,10.^y_tree,"Color","k");

set(gca, 'YScale', 'log')
set(gca, 'XScale', 'log')

legend(["Validation Data", "Model with Data Mass", "Model with Estimated Mass","Linear Fit for Tree"]);

box on

plt = Plot();

plt.BoxDim = [5, 4]; %[width, height] in inches
plt.XLabel = "m (g)";
plt.YLabel = "A (mm^2)";
plt.AxisLineWidth = 1;
% plt.TickLength = [0.04,0.04];
% plt.Legend = [sc1,sc2,sc3];
plt.LegendBox = 'on';
plt.LegendLoc = 'NorthWest';
plt.FontSize = 15;
plt.LineWidth = .3;
plt.XLim = [1e-3, 1e0];
plt.YLim = [1e1, 10^3.3];

plt.XGrid = 'on';
plt.YGrid = 'on';
plt.XMinorGrid = 'on';
plt.YMinorGrid = 'on';

p1.LineWidth = 2;

figure(4002)
hold on
histogram(log10(val_A),15,"Normalization","percentage","FaceColor","#0072BD","FaceAlpha",0.7)
h1 = histogram(log10(pred_val_1),15,"Normalization","percentage","EdgeColor","#D95319","FaceAlpha",0.7,"DisplayStyle","stairs","LineWidth",2);
h2 = histogram(log10(pred_val_2),15,"Normalization","percentage","EdgeColor","#77AC30","FaceAlpha",0.7,"DisplayStyle","stairs","LineWidth",2);
% x_val = [1:.01:5]';
% p1 = plot(x_val,pdf(val1_dist,x_val),"Color","#D95319");
% p2 = plot(x_val,pdf(val2_dist,x_val),"Color","#77AC30");

legend(["Validation Data, \mu=235 mm^2, \sigma=168 mm^2", "Model with Data Mass, \mu=215 mm^2, \sigma=157 mm^2", "Model with Estimated Mass, \mu=195 mm^2, \sigma=148 mm^2"]);

box on

plt = Plot();

plt.BoxDim = [5, 4]; %[width, height] in inches
plt.XLabel = "log_1_0(A (mm^2))";
plt.YLabel = "Percentage (%)";
plt.AxisLineWidth = 1;
% plt.TickLength = [0.04,0.04];
% plt.Legend = [sc1,sc2,sc3];
plt.LegendBox = 'on';
plt.LegendLoc = 'NorthWest';
plt.FontSize = 14;
plt.LineWidth = .3;
% plt.XLim = [1e-3, 1e0];
plt.YLim = [0, 22];

plt.XGrid = 'on';
plt.YGrid = 'on';

h1.LineWidth = 3;
h2.LineWidth = 3;

function dist_data = dist_sampler(dist, total)
sample_sum = 0;
index = 1;
while sample_sum < total
    sample = random(dist,1);
    % while sample > dist.mu+1.5*dist.sigma || sample < dist.mu-1.5*dist.sigma
    %     sample = random(dist,1);
    % end
    dist_data(index) = 10^sample;
    sample_sum = sum(dist_data);
    index = index+1;
end
if sum(dist_data) > total
    dist_data(end) = total - sum(dist_data(1:end-1));
end
end