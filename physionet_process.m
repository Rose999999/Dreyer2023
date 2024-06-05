
%% --------------------- MI Data -----------------------
%%4,6,8,10,12,14
dataFolder='D:/matlab2019a/eeg-motor-movementimagery-dataset-1.0.0/files/';
%%dir('D:\matlab2019a\eeg-motor-movementimagery-dataset-1.0.0\files\S001\S001R08.edf')
files=dir([dataFolder 'S*']);
length(files)
j=1;
ref=[];
for s=1:109
    s
    if(s==88||s==89||s==92||s==100||s==104||s==106)
        continue
    else
        Xnew=[];
        ynew=[];
        datapath=fullfile('D:/matlab2019a/eeg-motor-movementimagery-dataset-1.0.0/files/',files(s).name)
        datapath=fullfile(datapath,'/')
        eegfiles=dir([datapath '*.edf']);
        length(eegfiles);
        for filek = [4,8,12]%T2 open and close both fists or both feet
            [EEG, h] = sload([datapath eegfiles(filek).name]);
            index1=[34,4,11,18,51,10,9,8,12,13,14,36,5,6,7,19,20,21,53,32,3,2,1,17,16,15,49];
            EEG=EEG(:,index1);
            for i=1:size(EEG,2)
                EEG(isnan(EEG(:,i)),i)=nanmean(EEG(:,i));
            end
            b=fir1(50,2*[8 30]/h.SampleRate);
            EEG=filter(b,1,EEG);
            if isequal(h.EVENT.CodeDesc(2),cellstr('T1'))
                ids1=h.EVENT.POS(h.EVENT.TYP==2); % must according to h.EVENT.CodeDesc
                ids2=h.EVENT.POS(h.EVENT.TYP==3); % must according to h.EVENT.CodeDesc
            elseif isequal(h.EVENT.CodeDesc(2),cellstr('T2'))
                ids1=h.EVENT.POS(h.EVENT.TYP==3); % must according to h.EVENT.CodeDesc
                ids2=h.EVENT.POS(h.EVENT.TYP==2); % must according to h.EVENT.CodeDesc
            else
                disp('err');
            end
            y=[ones(length(ids1),1)*0; ones(length(ids2),1)*1];
            ids=[ids1; ids2];
            X=[];
            disp("aaaa");
            size(ids);
            for i=length(ids):-1:1
                X(:,:,i)=EEG(ids(i)+0*h.SampleRate:ids(i)+4*h.SampleRate-1,:)';
            end
            [~,index]=sort(ids);
            y=y(index); X=X(:,:,index);
            size(X);
            Xnew=cat(3,Xnew,X);
            ynew=cat(1,ynew,y);
            [idsnew,indexnew]=sort(ids);
            tmp=[]; 
            if(idsnew(15)>19000)
                idsnew(15)=idsnew(14);
            end
            for i=1:15
                tmp(:,:,i)=EEG(idsnew(i)+round(4.25*h.SampleRate):idsnew(i)+round(5.8125*h.SampleRate)-1,:)';
            end
            ref=cat(3,ref,tmp);
            disp(size(ynew))
        end
        X1=Xnew(:,1:500,:);
        X2=Xnew(:,71:570,:);
        X3=Xnew(:,141:640,:);
        Xnew=cat(3,X1,X2);
        Xnew=cat(3,Xnew,X3);
        y=ynew(:,1);
        ynew=cat(1,ynew,y(:,1));
        ynew=cat(1,ynew,y(:,1));
        save(['./bcilecture/physionet/A' num2str(j,'%03d') '.mat'],'Xnew','ynew');
        j=j+1;
    end
end
save('./bcilecture/physionet/Resting.mat','ref');
