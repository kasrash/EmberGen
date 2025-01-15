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

%% load data
fn = 'Data_JFSP_15-01-04-4-Firebrands_Vegetative-PhaseI.xlsx';
sheets = 3:16;  %3-5:LP, 6-8:CYP, 9-11:LBG, 12-14:CHAM, 15-17:PAL
x_wind = [5.36,11.17,17.88]';

for ii=1 : length(sheets)
    sheet_no = sheets(ii);

    opt=detectImportOptions(fn);
    opt.VariableNamingRule = 'preserve';
    data_raw = readtable(fn,opt,'Sheet',sheet_no);
    
    dist = tabread(data_raw,7);
    A = tabread(data_raw,2);
    m = tabread(data_raw,3);

    dist = dist(m~=0.);
    A = A(m~=0.);
    m = m(m~=0.);

    temp = cat(2,A,m,dist);
    %temp = sortrows(temp,1);

    if ii==1
        data_l_t = temp;
    elseif ii==2
        data_m_t = temp;
    elseif ii==3
        data_h_t = temp;
    elseif ii==4
        data_l_t = cat(1,data_l_t,temp);
    elseif ii==5
        data_m_t = cat(1,data_m_t,temp);
    elseif ii==6
        data_h_t = cat(1,data_h_t,temp);
    elseif ii==7
        data_l_g = temp;
    elseif ii==8
        data_m_g = temp;
    elseif ii==9
        data_h_g = temp;
    elseif ii==10
        data_l_s = temp;
    elseif ii==11
        data_m_s = temp;
    elseif ii==12
        data_h_s = temp;
    elseif ii==13
        data_l_s = cat(1,data_l_s,temp);
    elseif ii==14
        data_m_s = cat(1,data_m_s,temp);
    end
end

%% aggregate based on wind speed; 1=tree, 2=grass, 3=shrub
data_l{1} = data_l_t; data_l{2} = data_l_g; data_l{3} = data_l_s;
data_m{1} = data_m_t; data_m{2} = data_m_g; data_m{3} = data_m_s;
data_h{1} = data_h_t; data_h{2} = data_h_g; data_h{3} = data_h_s;

data_tot{1} = data_l; data_tot{2} = data_m; data_tot{3} = data_h; 

%% burnout
x_wind = [5.36,11.17,17.88]';
for ww=1 : 3
    u_inf = x_wind(ww);
    
    temp1_data = data_tot{ww};
    for ss=1 : 3
        if ss==1
            delta_z = 6;
        elseif ss==2
            delta_z = 0.2;
        elseif ss==3
            delta_z = .8;
        end
        temp2_data = temp1_data{ss};

        A = temp2_data(:,1);
        m = temp2_data(:,2);
        dist = temp2_data(:,3);
    
        m_init = zeros(size(m));
        A_init = zeros(size(A));
        for ii=1 : length(m)
            if ss == 2
                [m_i,A_i,~] = D0_kasra(u_inf,delta_z,A(ii),m(ii));
            else
                [m_i,A_i,~] = D0_kasra(u_inf,delta_z,A(ii),m(ii));
            end
            m_init(ii) = m_i;
            A_init(ii) = A_i;
        end
        if ss==2
            mean(m_init)
            m_init(m_init>0.5) = 0.025;
        end
        temp_init_specie{ss} = cat(2,A_init,m_init);
    end
    data_tot_init{ww} = temp_init_specie;
end

%% seperate specie init data
for ss=1 : 3
    data_l_init = data_tot_init{1}{ss};
    data_m_init = data_tot_init{2}{ss};
    data_h_init = data_tot_init{3}{ss};

    dist_l_init = fitdist(log10(data_l_init(:,2)),"Normal");
    dist_m_init = fitdist(log10(data_m_init(:,2)),"Normal");
    dist_h_init = fitdist(log10(data_h_init(:,2)),"Normal");

    dist_l = fitdist(log10(data_l{ss}(:,2)),"Normal");
    dist_m = fitdist(log10(data_m{ss}(:,2)),"Normal");
    dist_h = fitdist(log10(data_h{ss}(:,2)),"Normal");

    %%record
    mus{ss} = [dist_l_init.mean, dist_m_init.mean, dist_h_init.mean]';
    sigmas{ss} = [dist_l_init.std, dist_m_init.std, dist_h_init.std]';
    mus_org{ss} = [dist_l.mean, dist_m.mean, dist_h.mean]';
    sigmas_org{ss} = [dist_l.std, dist_m.std, dist_h.std]';
   
    %plotting
    figure(ss)
    hold on
    bw = .12;
    h1 = histogram(log10(data_l_init(:,2)),"BinWidth",bw,"Normalization","percentage","FaceColor","#0072BD", "LineWidth",.1,"FaceAlpha",.55);
    h2 = histogram(log10(data_m_init(:,2)),"BinWidth",bw,"Normalization","percentage","FaceColor","#D95319", "LineWidth",.1,"FaceAlpha",.55);
    h3 = histogram(log10(data_h_init(:,2)),"BinWidth",bw,"Normalization","percentage","FaceColor","#EDB120", "LineWidth",.1,"FaceAlpha",.55);
    x = [-4:.1:2]';
    y = pdf(dist_l_init,x);
    p1 = plot(x,y*h1.BinWidth*100,"LineWidth",2, "Color", '#0072BD');
    y = pdf(dist_l,x);
    % plot(x,y,"--","LineWidth",2, "Color", '#0072BD')
    y = pdf(dist_m_init,x);
    p2 = plot(x,y*h2.BinWidth*100,"LineWidth",2, "Color", '#D95319');
    y = pdf(dist_m,x);
    % plot(x,y,"--","LineWidth",2, "Color", '#D95319')
    y = pdf(dist_h_init,x);
    p3 = plot(x,y*h3.BinWidth*100,"LineWidth",2, "Color", '#EDB120');
    y = pdf(dist_h,x);
    % plot(x,y,"--","LineWidth",2, "Color", '#EDB120')

    legend(["5.36 m/s","11.17 m/s", "17.88 m/s"])
    grid on

    plt = Plot();

    plt.BoxDim = [3.5, 3]; %[width, height] in inches
    plt.XLabel = "log_{10}(m_0 (g))";
    plt.YLabel = "Percentage (%)";
    if ss == 2
        plt.XLim = [-3.2,-.6];
        plt.YLim = [0, 17];
    else
        plt.XLim = [-3,1];
        plt.YLim = [0, 16];
    end
    plt.AxisLineWidth = .7;
    % plt.TickLength = [0.04,0.04];
    % plt.Legend = [sc1,sc2,sc3];
    plt.LegendBox = 'on';
    plt.LegendLoc = 'NorthWest';
    plt.FontSize = 14;
    plt.LineWidth = .3;
    % plt.XMinorGrid = 'on';
    % plt.YMinorGrid = 'on';
    plt.YTick = 0:2:16;

    p1.LineWidth = 2;
    p2.LineWidth = 2;
    p3.LineWidth = 2;

end

%% line fit to mean and std
mu_t = fit(x_wind,mus{1},"poly1");
mu_g = fit(x_wind,mus{2},"poly1");
mu_s = fit(x_wind,mus{3},"poly1");

sigma_t = fit(x_wind,sigmas{1},"poly1");
sigma_g = fit(x_wind,sigmas{2},"poly1");
sigma_s = fit(x_wind,sigmas{3},"poly1");

save("comp2_final.mat","mu_t","sigma_t");

x = [3:.1:21];

figure(1001)
hold on
plot(x_wind,mus{1},"o","LineWidth",2, "Color", '#0072BD')
plot(x_wind,mus{2},"o","LineWidth",2, "Color", '#D95319')
plot(x_wind,mus{3},"o","LineWidth",2, "Color", '#EDB120')

plot(x, feval(mu_t,x),"LineWidth",2, "Color", '#0072BD')
plot(x, feval(mu_g,x),"LineWidth",2, "Color", '#D95319')
plot(x, feval(mu_s,x),"LineWidth",2, "Color", '#EDB120')

legend(["Tree, R^2=0.88","Grass, R^2=0.48","Shrub, R^2=0.8"])

grid on

plt = Plot();

plt.BoxDim = [5, 4]; %[width, height] in inches
plt.XLabel = "U (m s^-^1)";
plt.YLabel = "\fontsize{20}\fontname{Helvetica}\mu";
plt.XLim = [3,21];
% plt.YLim = [3, 44];
plt.AxisLineWidth = 1;
% plt.TickLength = [0.04,0.04];
% plt.Legend = [sc1,sc2,sc3];
plt.LegendBox = 'on';
plt.LegendLoc = 'NorthWest';
plt.FontSize = 17;
plt.XTick = 3:3:21;

figure(2001)
hold on
plot(x_wind,sigmas{1},"o","LineWidth",2, "Color", '#0072BD')
plot(x_wind,sigmas{2},"o","LineWidth",2, "Color", '#D95319')
plot(x_wind,sigmas{3},"o","LineWidth",2, "Color", '#EDB120')

plot(x, feval(sigma_t,x),"LineWidth",2, "Color", '#0072BD')
plot(x, feval(sigma_g,x),"LineWidth",2, "Color", '#D95319')
plot(x, feval(sigma_s,x),"LineWidth",2, "Color", '#EDB120')

lh = legend(["Tree, R^2=0.97","Grass, R^2=0.85","Shrub,_{}R^2=0.9"]);

grid on

plt = Plot();

plt.BoxDim = [5, 4]; %[width, height] in inches
plt.XLabel = "U (m s^-^1)";
plt.YLabel = "\fontsize{20}\fontname{Helvetica}\sigma";
plt.XLim = [3,21];
plt.YLim = [0.3, 0.65];
plt.AxisLineWidth = 1;
% plt.TickLength = [0.04,0.04];
% plt.Legend = [sc1,sc2,sc3];
plt.LegendBox = 'on';
plt.LegendLoc = 'NorthEast';
plt.FontSize = 17;
plt.XTick = 3:3:21;

%% validation
val_m_4ms = readmatrix("gollner_4ms.txt");
val_m_4ms = log10(val_m_4ms);

mu_org_t = fit(x_wind,mus_org{1},"poly1");
sigma_org_t = fit(x_wind,sigmas_org{1},"poly1");

mu_val = feval(mu_t,4);
mu_org_val = -1.6; %feval(mu_org_t,4);
sigma_val = feval(sigma_t,4);
sigma_org_val = 0.736; %feval(sigma_org_t,4);

dist_val = makedist("Normal","mu",mu_val,"sigma",sigma_val);
dist_org_val = makedist("Normal","mu",mu_org_val,"sigma",sigma_org_val);

true_pd = fitdist(val_m_4ms,"Normal");

x_val = -5:.1:2;
y_val = pdf(dist_val,x_val);
y_org_val = pdf(dist_org_val,x_val);
y_true = pdf(true_pd,x_val);

figure(3333)
h1 = histogram(val_m_4ms,"Normalization","percentage","FaceColor","#0072BD","FaceAlpha",0.7);
hold on
p3 = plot(x_val,y_true*h1.BinWidth*100,"Color","#0072BD","LineWidth",2);
p1 = plot(x_val,y_val*h1.BinWidth*100,"k-","LineWidth",2);
p2 = plot(x_val,y_org_val*h1.BinWidth*100,"k--","LineWidth",2);

legend(["Validation Data","Validation Data Fit, \mu=0.167 g, \sigma=0.159 g","Model with Burnout, \mu=0.146 g, \sigma=0.172 g", "Model without Burnout, \mu=0.107 g, \sigma=0.387 g"])
grid on

plt = Plot();

plt.BoxDim = [5, 4]; %[width, height] in inches
plt.XLabel = "log_{10}(m (g))";
plt.YLabel = "Percentage (%)";
% plt.XLim = [3,20];
plt.XLim = [-4, 1];
plt.YLim = [0, 38];
plt.AxisLineWidth = 1;
% plt.TickLength = [0.04,0.04];
% plt.Legend = [sc1,sc2,sc3];
plt.LegendBox = 'on';
plt.LegendLoc = 'NorthWest';
plt.LineWidth = .3;
plt.FontSize = 17;

p1.LineWidth = 2;
p2.LineWidth = 2;
p3.LineWidth = 2;
