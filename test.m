dataFolder=['./highdata/data3/work/'];
files=dir([dataFolder 'workT*.mat']);
yAll=[];XAlignR=[];nTrials=432;
for s=1:length(files)
        s
        disp([dataFolder files(s).name]);
        load([dataFolder files(s).name]);
        ynew=permute(ynew,[2,1]);
        yAll=cat(1,yAll,ynew);
        Xwork=permute(Xwork,[2,3,1]);
        XAlignR=cat(3,XAlignR,Xwork);
end
for t=1:length(files)    %  target user
        t
        yt=yAll((t-1)*nTrials+1:t*nTrials);
        ys=yAll([1:(t-1)*nTrials t*nTrials+1:end]);
        %XtAlignE=XAlignE(:,:,(t-1)*nTrials+1:t*nTrials);
        %XsAlignE=XAlignE(:,:,[1:(t-1)*nTrials t*nTrials+1:end]);
        XtAlignR=XAlignR(:,:,(t-1)*nTrials+1:t*nTrials);
        XsAlignR=XAlignR(:,:,[1:(t-1)*nTrials t*nTrials+1:end]);
        
        %% mdRm
        % raw covariance matrices
       
        
        %align covariance matrices
        tic
        covTest=covariances(XtAlignR);
        covTrain=covariances(XsAlignR);
        yPred = mdm(covTest,covTrain,ys);
        %yPred=yPred';
        yact=[];
        for i=1:144
            yact(i)=yPred(i)+yPred(i+144)+yPred(i+288);
            if(yact(i)>1)
                yact(i)=1;
            else
                yact(i)=0;
            end
        end
        ytnew=yt(1:144);
        yact=yact';
        Accs{t}(2)=100*mean(mean(ytnew==yact));
        times{t}(2)=toc;
        
        
        %% CSP+LDA

        
        % align trials
        tic
        [fTrain,fTest]=CSPfeature_multi(XsAlignR,ys,XtAlignR);
        LDA = fitcdiscr(fTrain,ys);
        yPred=predict(LDA,fTest);
        size(yPred)
        yPred=yPred';
        yact=[];
        for i=1:144
            yact(i)=yPred(i)+yPred(i+144)+yPred(i+288);
            if(yact(i)>1)
                yact(i)=1;
            else
                yact(i)=0;
            end
        end
        ytnew=yt(1:144);
        yact=yact';
        Accs{t}(4)=100*mean(mean(ytnew==yact));
        times{t}(4)=toc;
end

ds=2;
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
