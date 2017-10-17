%Procedura Simca_test_model per la classificazione dei dati
%Parametri:
%   Il modello creato da Simca_create_model
%   o nessun parametro (verrà caricato durante l'esecuzione)

%Author:
%Natalia Orlandi
%Davide Sapienza

function Simca_test_model(Model)

    color={'white','blue','red','black'};

    %1- Controllo che il modello sia stato passato.
    %     Se non è stato passato allora si da la possibilità di caricarlo.
    if nargin == 0
        statusext=false;
        while(~statusext)
            status=false;
            while (~status)
                message = ['Attenzione! Nessun modello passato in input..' char(10) 'è necessario caricare un modello'];
                uiwait (errordlg(message,'Error'));
                [FileName,PathName] = uigetfile('*.mat','Seleziona il modello da utilizzare');
                status=true;
                if(isequal(PathName,0))
                    status=false;
                    message = 'Attenzione, nessun file selezionato!';
                    uiwait (errordlg(message,'Error'));
                    button = questdlg('Si desidera terminare l''esecuzione procedura?','Exit','Yes','No','No');
                    if(strcmp(button,'Yes')) 
                        return;
                    %altrimenti richiedi
                    else
                         status=false;
                    end
                else
                    [pathstr,name,ext] = fileparts(FileName);
                    if(~strcmp(ext,'.mat'))
                        status=false;
                        message = ['Attenzione, estensione file errata!'];
                        uiwait (errordlg(message,'Error'));
                    end
                end
            end
            %carica il file, e controlla i campi.
            S=load(FileName);
            variableInfo = who('-file', FileName);
            if(ismember('Modello', variableInfo)) % returns true
                Model=S.Modello;
                statusext=true;
            else
                FileName=0;
                status=false;
                message = ['Attenzione, file errato!'...
                            char(10) 'Il file deve contenere il campo "Modello"'];
                uiwait (errordlg(message,'Error'));
            end
        end        
    end
    
    %carica il file del test set
    FileName=caricamento_testSet();
    if(FileName == 0)
        return;
    end
 
    S=load(FileName);
    %ricava tutte le label delle righe
    R.ClassRow=S.data_ts.class{1};
    R.LabelRow=S.data_ts.label{1};
    R.LabelRowCell=cellstr(R.LabelRow);
    %identifica le tre categorie
    R.Class = unique(R.ClassRow);
    %trasforma i nomi delle categoire in char array
    R.ClassRow = num2str(R.ClassRow(:));
    R.Class = num2str(R.Class(:));

    R.matrice=S.data_ts.data;
    [R.n,R.m]=size(R.matrice);
    titolo='matrice totale';
    %rappresenta i dati secondo il retencion time
    [ret, R.Xaxs]=rappresentazione_grafica_dataset(R.matrice, titolo, R.LabelRow);
    if(ret==0)
        return
    end
    
    %datibon mantiene i dati di specificity, sensitivity, efficiency e
    %accuracy.
    R.datibon=[];
    
    %2-inizio classificazione
    %itera per ogni modello di categoria a disosizione.
    for i=1:length(Model)
        %indice per i grafici che dovranno poi essere salvati..
        idG=1;
        fig=[];
        titoli=[];
        %pretratto tutta la matrice con la media e la dev della categoria
        %del modello i-esimo
        %così è già fatto per tutti
        R.matricepre=R.matrice-ones(R.n,1)*Model(i).media;
        if(Model(i).preproc==2)
            R.matricepre=R.matricepre./(ones(R.n,1)*Model(i).dev);
        end
        %Pareto Scaling
        if(Model(i).preproc==3)
            R.matricepre=R.matricepre./(ones(R.n,1)*(sqrt(Model(i).dev)));
        end
        
        %recupero i dati appartenenti al primo modello creato
        
        R.IDCampioni=zeros(R.n);
        id=1;
        for j=1:R.n
            %compara la riga con la categoria del modello i-esimo
            if(strcmp(R.ClassRow(j,1),Model(i).Class(Model(i).categorie(i))))
                R.IDCampioni(id)=j;
                R.MyLabelCell(id)=R.LabelRowCell(j);
                R.MyLabel(id,:)=R.LabelRow(j,:);
                id=1+id;
            end
        end
        %rimuovo gli zero
        R.indici=R.IDCampioni(R.IDCampioni~=0);
        %recupero i dati della categoria del modello i-esimo
        R.Dati=R.matricepre(R.indici,:);
        titolo=strcat('matrice categoria ',Model(i).Class(Model(i).categorie(i)));
        [ret, R.Xaxs]=rappresentazione_grafica_dataset(R.Dati, titolo, R.MyLabel, R.Xaxs);
        if(ret==0)
            return
        end
        %recupero la matrice restante
        [matr]=ricava_matrice_restante(R.matricepre, R.indici);
        
        
        [nd,~]=size(R.Dati);
        [nmat,~]=size(matr);
        
        message = strcat('Si mostra il grafico con il modello della categoria ',Model(i).Class(Model(i).categorie(i)));
        questdlg(message,'Continua','Ok','Ok');
        ripeti=true;
        limiteq=-1;
        limitet=-1;
        idtvsq=1;
        while(ripeti)
            ripeti=false;
            fig(idG)=figure;
            titoli{idG}=strcat('T2ridvsQrid',num2str(idtvsq));
            display(titoli{idG});
            idtvsq=idtvsq+1;
            idG=idG+1;
            hold on;
            %proietto tutta la matrice (compresi i campioni della categoria in
            %esame
            for j=1:length(R.Class)
                %memorizzo i dati da graficare.. altrimenti se lo faccio passo
                %passo faccio fatica a settare i colori in legend
                %avrò quindi 1 vettore per la categoria per le x e tre per le
                %y
                x=[];
                y=[];
                IDCampioni=zeros(R.n);
                id=1;
                for k=1:R.n
                    if(strcmp(R.ClassRow(k,1),R.Class(j)))
                        IDCampioni(id)=k;
                        id=1+id;
                    end
                end
                %rimuovo gli zero
                indici=IDCampioni(IDCampioni~=0);
                dati=R.matricepre(indici,:);
                LabelCorrenti=R.LabelRow(indici,:);
                LabelCorrenti=cellstr(LabelCorrenti);
                [ndat,~]=size(dati);
                indici=[]; 
                lambda=diag(Model(i).autovalori)^-1;
                qlimit = reslim(Model(i).Npcpca,Model(i).autovalori1,95);
                tlimit = tsqlim(Model(i).np,Model(i).Npcpca,95);
                %proietta i campioni del test set nel modello in esame
                %(i-esimo)
                for k=1:ndat
                    tnew=dati(k,:)*Model(i).loadings';
                    enew=dati(k,:)-tnew*Model(i).loadings;
                    t=tnew*lambda*tnew';
                    q=enew*enew';

                    T2=(t/tlimit);
                    Q=(q/qlimit);
                    %introduco il caso in cui l'utente voglia uno zoom dei
                    %dati.
                    %se il limite è -1 vuol dire che non c'è filtraggio
                    if(limiteq~=-1 || limitet~=-1)
                        %vuol dire che l'utente ha selezionato almeno un limite
                        %da usare

                        %solo se T2 rispetta il suo limite e Q il suo, allora
                        %graficali
                        if(T2<=limitet && Q<=limiteq)
                            x=[x;T2];
                            y=[y;Q];
                            indici=[indici;k];
                        end
                        %altrimenti non è da graficare
                    else
                        x=[x;T2];
                        y=[y;Q];
                        indici=[indici;k];
                    end
                end 
                %qui la scatter
                dx = (max(x)-min(x))*0.02;
                dy = (max(y)-min(y))*0.02;  
                scatter(x,y,5,color{j+1});
                text(x+dx, y+dy, LabelCorrenti(indici,:));
            end
            xlabel('T^2rid');
            ylabel('Qrid');
            legend(R.Class);
            legend('show');
            %per disegnare un quarto di cerchio
            tlinspace = linspace(0,0.5*pi,128);
            x = [0 cos(tlinspace)*sqrt(2) 0];
            y = [0 sin(tlinspace)*sqrt(2) 0];
            plot(x,y,'k--');
            hold off;
            message = 'Dopo aver preso visione del grafico premere OK';
            questdlg(message,'Continua','Ok','Ok');

            %qui devo richiedere se vuole lo zoom o no e se sì quali limiti
            %imporre
            message = 'Si desidera effettuare uno zoom del grafico appena mostrato?';
            button=questdlg(message,'Zoom','Yes','No','Yes');
            if(strcmp(button,'Yes'))
                prompt={['Inserire i limiti per il grafico',char(10),...
                'Limite di T2:'],...
                'Limite di Q:'};
                defAns={'2','2'};
                num_lines = 1;
                status=false;
                while (~status)
                    status2=true;
                    status=true;
                    answer = inputdlg(prompt,'Limiti per il plot',num_lines,defAns);
                    if (isempty(answer))
                        button = questdlg('Attenzione! sicuri di voler annullare l''operazione?','Termina','Sì','No','No');
                        if(strcmp(button,'Sì')) 
                            %non fa niente, non rimposta riparti a true e andrà
                            %avanti
                            status2=false;
                        else
                            %solo se dice di no allora richiedi
                            status=false;
                        end

                        answer={'-1'};
                    end
                    %se è stato inserito qualcosa nella PC
                    if(status && status2)
                        limitet=str2num(answer{1});
                        limiteq=str2num(answer{2});
                        limitet=floor(limitet);
                        limiteq=floor(limiteq);
                        if ((min([limitet,limitet])<sqrt(2)))
                            status=false;
                            message = 'Warning! Si sta scegliendo un limite più piccolo della soglia di classificazione!'; 
                            uiwait(warndlg(message,'!!Warning!!'));
                        else
                            %ok allora ridisegna grafico
                            ripeti=true;
                        end

                    end
                end
            end
        end
        [R.sensitivity, R.specificity, R.accuracy]=get_coeff_bonta(Model(i),R.Dati,matr, tlimit, qlimit);
        R.efficiency=sqrt(R.specificity* R.sensitivity);
        R.datibon=[R.datibon;[R.sensitivity, R.specificity, R.accuracy, R.efficiency]];

        salvataggio(fig, titoli, idG-1);
    end
    
    fig=[];
    titoli=[];
    Ngrafici=0;
    [fig,titoli,Ngrafici]=coomans_plot(Model,R);
    idG=Ngrafici+1;
    fig(idG) = figure;
    titoli{idG} = 'Bonta'' del modello';
    set(fig(idG), 'Position', [500, 400, 350, 200]);
    t = uitable(fig(idG),'Data',R.datibon,'Position',[10 100 335 85]);
    t.ColumnName = {'Sensitivity','Specificity','Accuracy','Efficiency'};
    message = 'Dopo aver preso visione dei dati premere OK';
    questdlg(message,'Continua','Ok','Ok');
    
    salvataggio(fig, titoli, idG);
    message = 'Salvare i dati di test?';
    button = questdlg(message,'Salvataggio','Yes','No','Yes');
    if(strcmp(button,'Yes')) 
        [tag,path]=uiputfile({'cartella'});
        if isequal(tag,0) || isequal(path,0)
            disp('User pressed cancel')
        else
            path=strcat(path,tag,'.mat');
            Dati=R;
            save(path, 'Dati');
        end
    end
end