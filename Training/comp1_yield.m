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
clear
close all
clc

%% Load Data
data = readmatrix(""); %path to data, not publicly available

x = data(:,1);
y = data(:,2);
z = data(:,3);

%% validation data

data_val = readmatrix(""); %path to data, not publicly available

x_val = data_val(:,1);
y_val = data_val(:,2);
z_val = data_val(:,3);

data_val2 = readmatrix(""); %path to data, not publicly available

x_val2 = data_val2(:,1);
y_val2 = data_val2(:,2);
z_val2 = data_val2(:,3);

%% fit the surface
% [sf, gof, opt] = fit([x', y'],z','p00 + p10*x + p01*y + p20*x*y');%'p00 + p10*x + p01*y + p20*x^2');
[sf, gof, opt] = fit([x', y'],z','a*(x^b)+c*y+d+e*x*y');%'p00 + p10*x + p01*y + p20*x^2');

%% plotting
figure(1);
s = plot(sf,'XLim',[0,6], 'YLim', [3,44]);
colormap turbo
s.EdgeColor = 'none';
s.FaceAlpha = 0.8;
c = colorbar;
c.TickLength = 0.02;
c.FontName = 'Helvetica';
c.FontSize = 14;
c.LineWidth = 1.2;
c.Label.String = "Y (%)";
c.Limits = [0, 10];
hold on
sc1 = scatter3(x,y,z,'filled','MarkerFaceColor','k','DisplayName','Training Data [41]');
sc2 = scatter3(x_val,y_val,z_val,'filled','MarkerFaceColor','b','DisplayName','Validation Data [40]');
sc3 = scatter3(x_val2,y_val2,z_val2,'filled','MarkerFaceColor','r','DisplayName','Validation Data [19]');

legend([sc1,sc2,sc3])

plt = Plot();

plt.BoxDim = [5, 4]; %[width, height] in inches
plt.XLabel = "U (m s^-^1)";
plt.YLabel = "M (%)";
plt.ZLabel = "Y (%)";
plt.XLim = [0,6];
plt.YLim = [3, 44];
plt.ZLim = [0,10];
plt.AxisLineWidth = 1;
plt.TickLength = [0.04,0.04];
% plt.Legend = [sc1,sc2,sc3];
plt.LegendBox = 'on';
plt.LegendLoc = 'NorthWest';
plt.FontSize = 14;


save("comp1_final.mat","sf")

%% validation
z_train_pred = sf(x',y');
z_val_pred = sf(x_val', y_val');
z_val_pred2 = sf(x_val2', y_val2');
Rsq2 = 1 - sum((z_val - z_val_pred').^2)/sum((z_val - mean(z_val)).^2)

res_train =  z' - z_train_pred;
res_val = z_val' - z_val_pred;
res_val2 = z_val2' - z_val_pred2;

figure(2)
sc1 = scatter3(x,y,res_train,'filled','MarkerFaceColor','k','DisplayName','Training Data [41]');
hold on
sc2 = scatter3(x_val,y_val,res_val,'filled','MarkerFaceColor','b','DisplayName','Validation Data [40]');
sc3 = scatter3(x_val2,y_val2,res_val2,'filled','MarkerFaceColor','r','DisplayName','Validation Data [19]');

for ii=1 : length(res_train)
    plot3([x(ii) x(ii)], [y(ii) y(ii)], [0, res_train(ii)],'k-')
end

for ii=1 : length(res_val)
    plot3([x_val(ii) x_val(ii)], [y_val(ii) y_val(ii)], [0, res_val(ii)],'b-')
end

for ii=1 : length(res_val2)
    plot3([x_val2(ii) x_val2(ii)], [y_val2(ii) y_val2(ii)], [0, res_val2(ii)],'r-')
end

[X_sf, Y_sf] = meshgrid(0:0.1:6, 3:0.1:44); % Create a grid for X and Y
Z_sf = zeros(size(X_sf)); % Z values are all zeros to create the plane at z = 0
surf(X_sf, Y_sf, Z_sf, 'FaceColor', [0.8 0.8 0.8], 'EdgeColor', 'none', 'FaceAlpha', 0.5); % Grey color with transparency

legend([sc1,sc2,sc3])

plt = Plot();

plt.BoxDim = [5, 4]; %[width, height] in inches
plt.XLabel = "U (m s^-^1)";
plt.YLabel = "M (%)";
plt.ZLabel = "Residual (%)";
plt.XLim = [0,6];
plt.YLim = [3, 44];
plt.ZLim = [-5, 3];
plt.AxisLineWidth = 1;
plt.TickLength = [0.04,0.04];
% plt.Legend = [sc1,sc2,sc3];
plt.LegendBox = 'on';
plt.LegendLoc = 'NorthWest';

plt.FontSize = 14;

