function [result] = eval_objs_GW_Recipient_CLD1(Q2,n,rainfall_CA2,PE_CA2)

%load the input data
load('Demand_NSDam_FN.mat')
Demand_NSDam_FN = sum(reshape(Demand_NSDam_FN,2,[])); %converting fortnightly to monthly data 
load('maxrelease.mat')
maxrelease = max(reshape(maxrelease,2,[]));
load('Demand_delta.mat') %load delta demand data
live_storage_r2  = 5733;

%the commandarea is changed with time and hence the recharge is calculated
%at every timestep based on rainfall
load('area_NS.mat') %load data for changing area with time

%replicate the data for the desired number of years
Demand_NS = Demand_NSDam_FN;
maxrelease = repmat(maxrelease,1,n);
Demand_delta = repmat(Demand_delta',1,n);
sum_annual_deficit2 = 0;

areaNS = reshape(repmat(areaNS(1:n),1,12)',[],1);

%assigning variables for reliability calculations and storage volumes
V2=zeros(1,12*n);
ef_const = zeros(1,12*n);
Q = Q2;

%S_GW is the storage of groundwater which the upper limit is the MaxGW
%storage
%the storages will be on both the basins 
%S_GW1 for donor and S_GW2 for recipient 
h = zeros(1,12*n);

for i=1:12*n  %24 as it is a  fortnightly model
     %1. Add supply to reservoir volume
     if i~=1
        V2(i)=V2(i-1)+Q2(i);
     else
        V2(i)=-2135+Q2(i);
     end

    demand_delta_actual(i) = min(V2(i), Demand_delta(i));
    deficit_delta(i) = Demand_delta(i) - demand_delta_actual(i);
    V2(i)               = max(0,V2(i) - demand_delta_actual(i));
    water_use(i)=0;
 %  remove the demands in  both basins
    demand_NS_actual(i) = min(V2(i), Demand_NS(i));
    demand_NS_actual(i) = min(806*2,demand_NS_actual(i));%806 is the capacity of both the canals
    canal_cap(i) = demand_NS_actual(i);
    deficit2(i)         = Demand_NS(i)- demand_NS_actual(i);
    V2(i)               = max(0,V2(i) - demand_NS_actual(i));
         
%threshold is set to 95% of live capacity
%the releases should be tracked and should not be greater than the inflows
%for donor basin and the maximum releases for recipient basin
    release2(i)         = max(V2(i) - 0.95*live_storage_r2, 0);
    V2(i)               = V2(i) - release2(i);

    storage2_post_release(i)= V2(i);
    %checking for flood failure measures
     floodcheck2(i)          = release2(i)+water_use(i);
end
%%%%%%%%
%defining bluewater withdrawal to compare with the maximumlimits or the
%freshwater planetary boundaries
blue_water_withdrawal_donor2 = Q2 - release2-water_use;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%defining reliability for blue_water_withdrawal
[ Withdrawal_Limits_R ] = Blue_water_withdrawals( Q2 );
wwe =  blue_water_withdrawal_donor2-repmat(Withdrawal_Limits_R,1,n);
 
    result.release = floodcheck2;
    result.deficit =  deficit2;
    result.storage = V2;
    result.GW = h;
    result.annualdeficit = sum_annual_deficit2;
    result.waterwithdrawal  = wwe;
    result.waterwithdrawallimits  = repmat(Withdrawal_Limits_R,1,n);
    result.Q = Q2;
    result.canal  =release2+water_use;
    result.bww = blue_water_withdrawal_donor2;
    result.demand = Q2-Demand_delta-Demand_NS(1:540);

