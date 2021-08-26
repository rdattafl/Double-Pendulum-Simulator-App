function dTheta = ODESolver(t,y,L1,L2,m1,m2)
% Create the function ODESolver that will be invoked by the parent function ODEInvoker.
dTheta = zeros(4,1);
dTheta(1) = y(3);
dTheta(2) = y(4);

a1 = L2/L1*(m2/(m1+m2))*cos((y(1)-y(2))*pi/180);
a2 = L1/L2*cos((y(1)-y(2))*pi/180);
f1 = -L2/L1*(m2/(m1+m2))*(y(4)^2)*sin((y(1)-y(2))*pi/180)-...
    32/L2*sin(y(1)*pi/180);
f2 = L1/L2*(y(3)^2)*sin((y(1)-y(2))*pi/180)-32/L2*sin(y(2)*pi/180);

dTheta(3) = (f1-a1*f2)/(1-a1*a2);
dTheta(4) = (-a2*f1+f2)/(1-a1*a2);
end