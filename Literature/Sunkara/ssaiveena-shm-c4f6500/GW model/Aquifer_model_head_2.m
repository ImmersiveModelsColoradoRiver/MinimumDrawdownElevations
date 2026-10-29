function [h,data] = Aquifer_model_head_2(areaNS,rainfall_CA2,i,h,demand_NS_CA,PE_CA2)
%Aquifer sub-model
%average initial head for may is 7.21
%Max head for may is 8.6089
Area2 =areaNS;% (10.7*10^9);
Sy2 = 0.048;
Qpmax = 200;
r = [0.12,0.19];
alpha = [0.07,0.1];
%calculation of rainfall recharge in the command area
if mod(i,12)>1 && mod(i,12)<=5
    rainfall_recharge(i) = r(2)* rainfall_CA2*0.001/Sy2;
else
    rainfall_recharge(i) = r(1)*rainfall_CA2*0.001/Sy2;
end

if mod(i,12)>1 && mod(i,12)<=5
    alpha_s(i) = alpha(2);
else
    alpha_s(i) = alpha(1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%satisfying demands of the command area
%update storage GW based on rainfall recharge and demands in the command
%area

if i>1
h(i) =  h(i-1)+rainfall_recharge(i)-((min(Qpmax,demand_NS_CA) *10^6)/(Sy2*Area2))- alpha_s(i)*h(i-1);
else
h(i) =4.84;
end

data = min(Qpmax,demand_NS_CA);
end
