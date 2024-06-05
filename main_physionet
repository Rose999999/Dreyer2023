clc; clearvars; close all; warning off all;
rng('default');
%% Compare raw and aligned features on MI
%% Leave-one subject-out
%% need to enable covariancetoolbox

mAcc=cell(1,2); mTime=cell(1,2);
for ds=2:2
    %% make data
    dataFolder=['./bcilecture/physionet/'];
    files=dir([dataFolder 'A*.mat']);
    Ref=load([dataFolder 'Resting.mat']); % break time for all subjects
    XRaw=[]; yAll=[]; XAlignE=[]; XAlignR=[];XAlignErest=[];
    for s=1:10
        s
        load([dataFolder files(s).name]);
        size(Xnew)
        XRaw=cat(4,XRaw,Xnew);
        size(XRaw)
        ynew=permute(ynew,[2,1]);
        yAll=cat(2,yAll,ynew);
        size(ynew);
        size(yAll);
        nTrials=length(ynew);
        Bt=Ref.ref(:,:,(s-1)*45+1:s*45);
        RtE=mean(covariances(Xnew),3); % reference state, Euclidean space
        RtR=mean(covariances(Bt),3);% reference state, Riemmanian space
        sqrtRtE=RtE^(-1/2); sqrtRtR=RtR^(-1/2);
        size(sqrtRtE)
        XR=nan(size(Xnew,1),size(Xnew,2),nTrials);
        XE=nan(size(Xnew,1),size(Xnew,2),nTrials);
        Xrest=nan(size(Bt,1),size(Bt,2),45);
        Xwork=nan(size(Xnew,1),size(Xnew,2),nTrials);%target work status
        for j=1:nTrials 
            XR(:,:,j)=sqrtRtR*Xnew(:,:,j);
            XE(:,:,j)=sqrtRtE*Xnew(:,:,j);
            Xwork(:,:,j)=sqrtRtR*Xnew(:,:,j);
        end
        for j=1:45 
            Xrest(:,:,j)=sqrtRtR*Bt(:,:,j);
        end
        size(XE)
        XAlignE=cat(3,XAlignE,XE); XAlignR=cat(3,XAlignR,XR);XAlignErest=cat(3,XAlignErest,Xrest);
        XEtask=permute(XAlignE,[3,1,2]);%第三维放到第一维源域任务态
        XRrest=permute(XAlignErest,[3,1,2]);%源域静息态
        Xwork=permute(Xwork,[3,1,2]);%目标域任务态
        %save(['./bcilecture/MI2classcrop/work/workT' num2str(s) '.mat'],'Xwork','ynew');
    end
    XRrest=repmat(XRrest,1,1,2);

    %save('./bcilecture/MI2classcrop/work/workStotal.mat','XEtask','yAll');
    %save('./bcilecture/MI2classcrop/work/restingStotal.mat','XRrest','yAll');
    
    Accs=cell(1,length(files));
    times=cell(1,length(files));
    
    for t=1:10  %  target user
        t
        yt=yAll((t-1)*nTrials+1:t*nTrials);
        ys=yAll([1:(t-1)*nTrials t*nTrials+1:end]);
        XtRaw=XRaw(:,:,(t-1)*nTrials+1:t*nTrials);
        XsRaw=XRaw(:,:,[1:(t-1)*nTrials t*nTrials+1:end]);
        XtAlignE=XAlignE(:,:,(t-1)*nTrials+1:t*nTrials);
        XsAlignE=XAlignE(:,:,[1:(t-1)*nTrials t*nTrials+1:end]);
        XtAlignR=XAlignR(:,:,(t-1)*nTrials+1:t*nTrials);
        XsAlignR=XAlignR(:,:,[1:(t-1)*nTrials t*nTrials+1:end]);
        
           
        %% CSP+LDA
        %raw trials
        tic
        [fTrain,fTest]=CSPfeature(XsRaw,ys,XtRaw);
        LDA = fitcdiscr(fTrain,ys);
        yPred=predict(LDA,fTest);
        yPred=yPred';
        yact=[];
        for i=1:45
            yact(i)=yPred(i)+yPred(i+45)+yPred(i+90);
            if(yact(i)>1)
                yact(i)=1;
            else
                yact(i)=0;
            end
        end
        ytnew=yt(1:45);
        Accs{t}(3)=100*mean(mean(ytnew==yact));
        times{t}(3)=toc;
        
        % align trials
        tic
        [fTrain,fTest]=CSPfeature(XsAlignE,ys,XtAlignR);
        LDA = fitcdiscr(fTrain,ys);
        yPred=predict(LDA,fTest);
        size(yPred)
        yPred=yPred';
        yact=[];
        for i=1:45
            yact(i)=yPred(i)+yPred(i+45)+yPred(i+90);
            if(yact(i)>1)
                yact(i)=1;
            else
                yact(i)=0;
            end
        end
        ytnew=yt(1:45);
        Accs{t}(4)=100*mean(mean(ytnew==yact));
        times{t}(4)=toc;
        Accs{t}(5)=t;
    end
    mAcc{ds}=[]; mTime{ds}=[];
    for t=1:length(files)
        mAcc{ds}=cat(1,mAcc{ds},Accs{t});
        mTime{ds}=cat(1,mTime{ds},times{t});
    end
    
    mAcc{ds}=cat(1,mAcc{ds},mean(mAcc{ds}));
    mTime{ds}=cat(1,mTime{ds},mean(mTime{ds}));
    mAcc{ds}
    disp("***")
    mTime{ds}
    
end
save('MIall.mat','mAcc','mTime');
