function [m_i,A_i,D_i] = D0_HMRE(u_inf,delta_z,A,m)   
% First try at firebrand time of flight calculation
% Assumptions:
% particle fly with air (uy=0)
% terminal velocity is contant and based on D0
rho_char = 300;     %char density [kg/m^3]
rho_air = 1.18;     %air density [kg/m^3]
mu = 1.846e-5;      %air viscosity [Ns/m^2]
alpha = 2.058e-5;   %thermal diffusivity [m^2/s]
g = 9.81;           %gravity [m^2/s]
Y = 0.233;          %air mass fraction
r_O = 1.5;          %products to reactants
A = A*1e-6;         %convert area from mm2 to m2
m = m*1e-3;         %convert mass from g to kg
Dab = 1.84e-5;      %gas diff.
nu = 1.564e-5;
Pr = 0.707;
B = Y / r_O;

D_f = (4/pi)*m./(rho_char*A);

U = u_inf; %[m/s]
D_guess = D_f;
resid = 1;

counter = 1;
while resid >=0.0001
    %calc. n
    Re = U*D_guess*rho_air./mu;
    if Re < 4000.
        C = 0.683;
        n = 0.466;
    else
        C = 0.193;
        n = 0.618;
    end

    %calc flow speed
    C_d = Cd_cyl(Re);
    u_z = sqrt((pi/2)*(rho_char/rho_air)*D_f*g/C_d);  %terminal velocity

    t = delta_z/u_z;
    u_y = 0.;
    
    U = sqrt((u_inf-u_y)^2+u_z^2);   %incident velocity

    D_i = (D_f^(2-n) + (2-n)*((4/3)*(rho_air/rho_char)*C*Dab*((U/nu)^n)*(Pr^(1/3))*log(1+B))*t)^(1/(2-n));
    
    resid = abs(D_i-D_guess);
    D_guess = D_i;
    counter = counter+1;
end

if counter == 100 || counter == 99
    counter
end

m_i = ((D_i/D_f)^3) * m * 1e3;
A_i = ((D_i/D_f)^2) * A *1e6;  %reports back in mm^2
D_i = D_i*1e3;  %reports back in mm

if isnan(m_i)
    m_i = 1e-3;
end
