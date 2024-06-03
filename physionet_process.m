
%% --------------------- MI Data -----------------------
%%4,6,8,10,12,14
dataFolder='D:/matlab2019a/eeg-motor-movementimagery-dataset-1.0.0/files/';
%%dir('D:\matlab2019a\eeg-motor-movementimagery-dataset-1.0.0\files\S001\S001R08.edf')
files=dir([dataFolder 'S*']);
length(files)
for s=79:79
    s
    if(s==88||s==92||s==100||s==104)
        continue
    else
        Xnew=[];
        ynew=[];
        datapath=fullfile('D:/matlab2019a/eeg-motor-movementimagery-dataset-1.0.0/files/',files(s).name)
        datapath=fullfile(datapath,'/')
        eegfiles=dir([datapath '*.edf']);
        length(eegfiles)
        for filek = [4,8,12]%T1 left T2 right
            [EEG, h] = sload([datapath eegfiles(filek).name]);
            %EEG = pop_biosig([datapath eegfiles(filek).name]);
            %EEG = eeg_checkset(EEG);
            %EEG = pop_reref(EEG,[]);
            %EEG = EEG.data';
            index=[34,4,11,18,51,10,9,8,12,13,14,36,5,6,7,19,20,21,53,32,3,2,1,17,16,15,49];
            %index=[34, 2, 3, 4, 5, 6, 8, 9, 10, 11, 12, 13, 14, 16, 17, 18, 19, 20, 50, 51, 52, 58];
            %EEG=EEG(:,index);
            %disp(h.EVENT.CodeDesc);
            for i=1:size(EEG,2)
                EEG(isnan(EEG(:,i)),i)=nanmean(EEG(:,i));
            end
            b=fir1(50,2*[4 40]/h.SampleRate);
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
            y=[zeros(length(ids1),1); ones(length(ids2),1)];
            ids=[ids1; ids2];
            X=[];
            size(ids);
            for i=length(ids):-1:1
                X(:,:,i)=EEG(ids(i)+0*h.SampleRate:ids(i)+4*h.SampleRate-1,:)';
            end
            [~,index]=sort(ids);
            y=y(index); X=X(:,:,index);
            size(X);
            Xnew=cat(3,Xnew,X);
            ynew=cat(1,ynew,y);
        end
    end
    %save(['./bcilecture/MI4classnew2/A' num2str(s,'%03d') '.mat'],'Xnew','ynew');
end
