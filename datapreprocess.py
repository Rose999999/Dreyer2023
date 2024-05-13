from mne.io import concatenate_raws, read_raw_gdf
import os
import scipy.io as io
from scipy import signal
from scipy.signal import resample
import numpy as np
from pyriemann.utils.covariance import covariances
from pyriemann.utils.mean import mean_covariance
from sklearn.base import BaseEstimator, TransformerMixin
from scipy.linalg import fractional_matrix_power

path = 'D:/matlab2019a/EA-master/BCI Database/Signals/DATA C/'
files = os.listdir('D:/matlab2019a/EA-master/BCI Database/Signals/DATA C/')
from scipy.signal import resample


fs = 512
re_fs = 250
Fstop1 = 8
Fstop2 = 30
MI_duration = 3
b, a = signal.butter(6, [2.0 * Fstop1 / fs, 2.0 * Fstop2 / fs], 'bandpass')  # 5阶巴特沃斯滤波器

save_file = 'D:/matlab2019a/EA-master/datadryerC/'
if not os.path.exists(save_file):
    os.makedirs(save_file)

xrest=[]
for u in range(6):
    # if '.' in f:
    #     continue
    if(u==39 or u==58):
        continue
    u=u+81   #C
    #u=u+60   #B
    p = path + f'C{u+1}/'
    
    t_x = []
    t_y = []
    for i in range(2,6):
        if not os.path.exists(p+f'C{u+1}_R{i+1}_onlineT.gdf'):
            continue

        
        raw_data = read_raw_gdf(p+f'C{u+1}_R{i+1}_onlineT.gdf',preload=False)
        data = raw_data.get_data()
        data = data[np.concatenate([np.arange(11),np.arange(16,32)]),:]
        #data = data[np.concatenate([np.arange(11),[17,18,20,21,23,24,25,26,28,29,31]]),:]#[np.concatenate([np.arange(11),np.arange(16,32)]),:]
        
        data = signal.filtfilt(b, a, data, axis=-1)
        data = resample(data, round(data.shape[-1] / fs * re_fs),axis=-1)
        for l,t in zip(raw_data.annotations.description,raw_data.annotations.onset):
            if l=='769' or l=='770':
                t_x.append(data[None,:,round(re_fs*(t+0.5)):round(re_fs*(t+0.5+MI_duration))])
                t_y.append(int(l)-769)
                xrest.append(data[None,:,round(re_fs*(t+5)):round(re_fs*(t+6))])
    t_x = np.concatenate(t_x)#160*27*750
    print(t_x.shape)   
    t_y = np.array(t_y)

    t_x *= 1e5
    t_x1=t_x[:,:,0:500]
    t_x2=t_x[:,:,125:625]
    t_x3=t_x[:,:,250:750]
    print(t_x1.shape)  
    t_xnew=np.concatenate((t_x1,t_x2,t_x3),axis=0)
    print(t_xnew.shape)
    print(t_y.shape)
    t_y=t_y.reshape(1,160)
    t_ynew=t_y
    t_ynew=np.concatenate((t_ynew,t_y),axis=1)
    t_ynew=np.concatenate((t_ynew,t_y),axis=1)
    t_xnew=t_xnew.transpose([1,2,0])
    print(u,'x_train',t_x.shape,t_y.shape,t_x.mean(),t_x.std())
    io.savemat(save_file+f'A{u+1}.mat', {'Xnew': t_xnew, 'ynew': t_ynew})
xrest = np.concatenate(xrest) 
xrest=xrest.transpose([1,2,0])
io.savemat(save_file+f'Resting.mat', {'ref': xrest})
