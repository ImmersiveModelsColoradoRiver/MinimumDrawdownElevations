import numpy as np
import matplotlib.pyplot as plt

#################################################################
# data to plot Ratio of area under irrigation from surface water to groundwater
n_groups = 3
means_obs = (1.03, 0.12, 3.56) #define data

# create plot
fig, ax = plt.subplots()
index = [0.25,0.5,0.75]#np.arange(n_groups)
bar_width = 0.15
opacity = 0.7

rects1 = plt.bar(index, means_obs, bar_width,
alpha=opacity,
color='black',
label='Observed')

plt.xlabel('Year')
plt.ylabel('Ratio of area under irrigation\n from surface water to groundwater')
#plt.title('Scores by person')
plt.xticks(index, ('2001-2002', '2002-2003', '2005-2006'))
plt.legend()

plt.tight_layout()
plt.savefig('validc.svg')
####################################################################################
n_groups = 3
means_shm2 = (6.08, 3.02, 26.07) #define data
means_shm3 = (6.08, 3.02, 24.82)

# create plot
fig, ax = plt.subplots()
index = [0.25,0.65,1.05]#np.arange(n_groups)
bar_width = 0.15
opacity = 0.7

rects2 = plt.bar(index, means_shm2, bar_width,
alpha=opacity,
color='#1F78B5',
label='SHM 2')

rects2 = plt.bar(index + np.repeat(bar_width,3), means_shm3, bar_width,
alpha=opacity,
color='#33A12B',
label='SHM 3')
#1F78B5 blue
#33A12B green
plt.xlabel('Year')
plt.ylabel('Ratio of volume utilized from\n surface water to groundwater use in irrigation')
#plt.title('Scores by person')
plt.xticks(index + np.repeat(bar_width,3)/2, ('2001-2002', '2002-2003', '2005-2006'))
plt.legend()

plt.tight_layout()
plt.savefig('validd.svg')
