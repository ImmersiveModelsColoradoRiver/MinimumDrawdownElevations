function [ Withdrawal_Limits_R ] = Blue_water_withdrawals(Q2)
%Q1 and Q2 are FN flows in donor and recipient basins 

%step1: converting FN flows to monthly flows
%Q_R = sum(reshape(Q2,2,[])); 

%step2: getting mean monthly values
MMF_R = mean(reshape(Q2,12,[]),2);

%step 3: calculation of mean annual flow 
MAF_R = mean(sum(reshape(Q2,12,[])));

%step 4: 
%low range of uncertainty for withdrawal is chosen
%if high range is required EWF - 0.15 instead of EWF + 0.15

for i = 1:12
    if MMF_R(i)> 0.8*MAF_R
        EWF_R(i) = 0.3;
    elseif MMF_R(i)<0.4*MAF_R
        EWF_R(i) = 0.6;
    else
        EWF_R(i) = 0.45;
    end
end
Withdrawal_Limits_R  = (1 -(EWF_R + 0.15)).*MMF_R';
end

