%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%adding all the folders and subfolders to path
clear
clc
addpath(genpath(pwd))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%code for connecting all submodels for the three defined SHMs%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%load('Data.mat') %data file is not shared due to restrictions from the data provider
%Users may contact the author for data file (Sai Veena: saiveena26@gmail.com)

Q2 = Data.Q(25:1104,4)*214185*0.001;%select 1968 june to 2013 May
Q2_month = sum(reshape(Q2,2,[]));%fortnight data converted to monthly

n_year  = 45;%number of year of simulation

%load rainfall data
load('rainfall_CA2_hist') %original data from 1901 to 2015
rainfall_CA2 = FN_dataf(1619:2626+24*3);%extract data from 1968 to 2013
rainfall_CA2_month = sum(reshape(rainfall_CA2,2,[]));

%load potential evaporation data
load('PE_CA_hist.mat')
PE_CA2 = FN_PE(419:1426+24*3);%extract data from 1968 to 2013
PE_CA2_month = sum(reshape(PE_CA2,2,[]));

%run model for SHM1
result = eval_objs_GW_Recipient_CLD1(Q2_month,n_year,rainfall_CA2_month,PE_CA2_month);
save resultcld1 result

%run model for SHM2
result = eval_objs_GW_Recipient_CLD2(Q2_month,n_year,rainfall_CA2_month,PE_CA2_month);
save resultcld2 result

%run model for SHM3
result = eval_objs_GW_Recipient_CLD3(Q2_month,n_year,rainfall_CA2_month,PE_CA2_month);
save resultcld3 result
