%Procedura Simca_create_model per la creazione di un modello per la 
%classificazione dei dati.
%Parametri:
%   Nessun parametro verrà passato preliminariamente alla procedura, 
%   ma verrà richiesto eventualmente di inserirli passo passo.
%Ritorna:
%   Il modello creato

%Author:
%Natalia Orlandi
%Davide Sapienza

function [Modello, Return] = Simca_create_model()

    %il ciclo esterno serve per ricreare da capo il modello
    ripetidacapo=true;
    while(ripetidacapo)
        ripetidacapo=false;
        Return=false;
        %fase iniziale di caricamento dei dati del training set
        FileName=caricamento_trainingSet();
        if(FileName == 0)
            clear Modello;
            Modello=0;
            return;
        end
        S=load(FileName);

        %ricava tutte le label delle righe
        M.ClassRow=S.data_tr.class{1};
        M.LabelRow=S.data_tr.label{1};
        M.LabelRowCell=cellstr(M.LabelRow);
        %identifica le tre categorie
        M.Class = unique(M.ClassRow);
        %trasforma i nomi delle categoire in char array
        M.ClassRow = num2str(M.ClassRow(:));
        M.Class = num2str(M.Class(:));
        
        %1- selezione delle categorie da utilizzare per la creazione del
        %modello (da 1 ad N).
        M.categorie=selezione_categorie(M.Class);
        if(M.categorie == 0)
            clear Modello;
            Modello=0;
            return;
        end
        %numero categorie selezionate
        M.NCat=length(M.categorie); 

        %2- selezione delle operazioni di preprocessing (sempre svolte per 
        %categorie). Le combinazioni possibili sono: Mean Centering, 
        %Autoscaling (centramento e scaling),Pareto scaling (centramento e 
        %scaling).
        %fase di preprocessing:
        %   Mean Centering: si trova la media per categoria,
        %                   e la si sottrae alla matrice dei dati.
        %   Autoscaling:    si effettua il centramento e si dividono i dati
        %                   per la deviazione standard.
        %   Pareto Scaling: si effettua il centramento e si dividono i dati
        %                   per la radice quadrata della deviazione standard.
        M.preproc=selezione_preprocessing();
        if(M.preproc == 0)
            clear Modello;
            Modello=0;
            return;
        end

        %3- selezione della procedura da utilizzare tra svds e eigs per
        %la decomposizione della matrice dei dati preprocessata nei tre 
        %contributi di Scores, Loadings, Residui.
        procedura=selezione_procedura_PCA();
        if(procedura == 0)
            clear Modello;
            Modello=0;
            return;
        end

        %5- selezione della Cross Validation che si vuole effettuare:
        %Leave More Out o Leave One Out.
        CVOp=selezione_CV();
        if(CVOp == 0)
            clear Modello;
            Modello=0;
            return;
        end

        %recupero tutta la matrice dei dati (tutte le categorie)
        M.matrice=S.data_tr.data;
        [M.n, M.m]=size(S.data_tr.data);
        titolo='matrice totale';
        %rappresentazione grafica
        [ret, M.Xaxs]=rappresentazione_grafica_dataset(M.matrice, titolo, M.LabelRow);
        if(ret==0)
            clear Modello;
            Modello=0;
            return
        end
        %per ognuna delle categorie selezionate per costruire i modelli.
        for i=1:M.NCat
            ripeticat=true;
            %questo while serve in caso in cui l'utente voglia costruire da
            %capo il modello per tale categoria, visualizzando da capo
            %scree plot e plot di cv
            while(ripeticat)
                ripeticat=false;
                
                %idG è indice per le immagini
                %fig contiene le figure
                %titoli contiene i nomi dei grafici
                fig=[];
                titoli=[];
                idG=1;
                
                %recupero gli indici degli elementi corrispondenti alla 
                %categoria selezionata
                M.IDCampioni=zeros(M.n);
                id=1;
                for j=1:M.n
                    if(strcmp(M.ClassRow(j,1),M.Class(M.categorie(i))))
                        M.IDCampioni(id)=j;
                        M.MyLabelCell(id)=M.LabelRowCell(j);
                        M.MyLabel(id,:)=M.LabelRow(j,:);
                        id=1+id;
                    end
                end
                %rimuovo gli zero
                M.indici=M.IDCampioni(M.IDCampioni~=0);
                %recupero i dati
                M.Dati=S.data_tr.data(M.indici,:);
                M.Datipre=M.Dati;
                %mostriamo una rappresentazione grafica del dataset (la
                %sola categoria)
                titolo=strcat('matrice categoria ',M.Class(M.categorie(i)));
                [ret, M.Xaxs]=rappresentazione_grafica_dataset(M.Datipre, titolo, M.MyLabel,  M.Xaxs);
                if(ret==0)
                    return
                    clear Modello;
                    Modello=0;
                end
                [M.np, M.mp]=size(M.Datipre);

                %operazioni di preprocessing
                [M.Datipre,M.media,M.dev]=preprocessing(M.Datipre, M.preproc);
                %contruisco il modello
                M.Npc=rank(M.Datipre);
                [M.scores, M.loadings, M.autovalori, M.Explvar]=pca_model(M.Datipre,M.Npc, procedura);
                
                %scree plot
                fig(idG)=figure;
                titoli{idG}='Scree_ExplVar';
                idG=idG+1;
                subplot(2,1,1);
                hold on;
                plot(1:M.Npc,M.autovalori,'o-','MarkerSize',6,'MarkerFace','b');
                xlabel('Principal Component Number');
                ylabel('Eigenvalues');
                hold off;

                subplot(2,1,2);
                hold on;
                axis([0 M.Npc M.Explvar(1) 100]);
                plot(1:M.Npc,M.Explvar,'o-','MarkerSize',6,'MarkerFace','b');
                xlabel('Principal Component Number');
                ylabel('Cumulative Variance Captured (%)');
                hold off;
                message = 'Dopo aver preso visione del grafico premere OK';
                questdlg(message,'Continua','Ok','Ok');
                
                %se la scelta è leave more out, allora si chiede la dimensione
                %dello split per tale categoria. altrimenti la dimensione
                %dello split è il numero di righe.
                M.DimSplit=M.np;
                if(CVOp==1)
                    M.DimSplit=richiesta_split(M.Class(M.categorie(i)), M.np);
                    
                    if(M.DimSplit == 0)
                        clear Modello;
                        Modello=0;
                        return;
                    end
                end

                %in matr lasciamo tutti i campioni M.matrice meno quelli della categoria
                %in esame
                [matr]=ricava_matrice_restante(M.matrice, M.indici);
                %questi dati non vengono ancora preprocessati: tale
                %operazione verrà svolta solo dentro alla cross validation
                
                %mi preparo del lavoro successivo: tolgo la media della
                %categoria e divido per la dev o sqrt(dev).
                %questi dati mi serviranno solo per graficare Q e T2
                %non per la cross validation
                [naus,~]=size(matr);
                matrpre=matr;
                matrpre=matrpre-ones(naus,1)*M.media;
                if(M.preproc==2)
                    matrpre=matrpre./(ones(naus,1)*M.dev);
                end
                %Pareto Scaling
                if(M.preproc==3)
                    matrpre=matrpre./(ones(naus,1)*(sqrt(M.dev)));
                end
                
                %ora si lancia la cross validation per ogni numero di PC che va da
                %uno al rango della matrice.

                %questo è un numero di riferimento. se Npc=11, ho 12 righe e
                %DimSplit=4, allora tolgo una riga ogni split. quindi 3 righe. 
                %la matrice che ottengo sarà una matrice con 9 righe, quindi non
                %posso impostare un numero di pc superiore al numero di righe. al
                %massimo sarà 9
                %il meno uno è perchè, essendo che si scala la matrice, il
                %numero del rango al massimo sarà 8 (con 12 righe): uno in
                %meno perchè si scala (da 9 a 8 quindi)
                max_pc=M.np-ceil(M.np/M.DimSplit)-1;
                M.specificity=zeros(1,max_pc); 
                M.sensitivity=zeros(1,max_pc);
                M.efficiency=zeros(1,max_pc);
                M.accuracy=zeros(1,max_pc);
                for j=1:max_pc
                    %alla cross validation però passo solo i dati originali
                    %quindi Dati e matr, non quelli pretrattati
                    [M.specificity(j), M.sensitivity(j), M.accuracy(j)]=cross_validation(matr, M.Dati, M.DimSplit, j, procedura, M.preproc, false);
                    M.efficiency(j)=sqrt(M.specificity(j)* M.sensitivity(j));
                end
                M.specificityf=zeros(1,max_pc); 
                M.sensitivityf=zeros(1,max_pc);
                M.efficiencyf=zeros(1,max_pc);
                M.accuracyf=zeros(1,max_pc);
                for j=1:max_pc
                    %qui invece posso passare i dati pretrattati.
                    %tanto in fit vengono utilizzati tutti
                    [M.specificityf(j), M.sensitivityf(j), M.accuracyf(j)]=cross_validation(matrpre, M.Datipre, M.DimSplit, j, procedura, M.preproc, true);
                    M.efficiencyf(j)=sqrt(M.specificityf(j)* M.sensitivityf(j));
                end
                fig(idG)=figure;
                titoli{idG}='Sensitivity_Specificity';
                idG=idG+1;
                subplot(2,1,1);
                hold on;
                title('Cross Validation');
                xlabel('Number of PC');
                ylabel('Misure statistiche in CV');
                plot(1:max_pc,M.sensitivity,'o-','MarkerSize',6,'MarkerFace','b');
                plot(1:max_pc,M.specificity,'o-','MarkerSize',6,'MarkerFace','r');
                plot(1:max_pc,M.accuracy,'o-','MarkerSize',6,'MarkerFace','g');
                plot(1:max_pc,M.efficiency,'o-','MarkerSize',6,'MarkerFace','y');
                hold off;
                legend('Sensitivity', 'Specificity', 'Accuracy', 'Efficiency');
                legend('show');
                
                subplot(2,1,2);
                hold on;
                title('Fit');
                xlabel('Number of PC');
                
                ylabel('Misure statistiche in fit');
                plot(1:max_pc,M.sensitivityf,'o-','MarkerSize',6,'MarkerFace','b');
                plot(1:max_pc,M.specificityf,'o-','MarkerSize',6,'MarkerFace','r');
                plot(1:max_pc,M.accuracyf,'o-','MarkerSize',6,'MarkerFace','g');
                plot(1:max_pc,M.efficiencyf,'o-','MarkerSize',6,'MarkerFace','y');
                hold off;
                legend('Sensitivity_fit', 'Specificity_fit', 'Accuracy_fit', 'Efficiency_fit');
                legend('show');
                message = 'Dopo aver preso visione del grafico premere OK';
                questdlg(message,'Continua','Ok','Ok');
                %selezione del numero di PC per tale categoria per la creazione del
                %modello   
                risceltapc=true;
                %idGaus mi serve per tenere l'indice di dove sono arrivato,
                %serve nel caso in cui l'utente riscelga il numero di PC
                idGaus=idG;
                while(risceltapc)
                    risceltapc=false;
                    idG=idGaus;
                    M.Npcpca=selezione_numero_PC(M.Datipre, M.Class(M.categorie(i)));
                    if(M.Npcpca==0)
                        clear Modello;
                        Modello=0;
                        return
                    end
                    %creazione del modello
                    [M.scores, M.loadings, M.autovalori, M.Explvar]=pca_model(M.Datipre,M.Npcpca, procedura);
                    [~, ~, M.autovalori1, ~]=pca_model(M.Datipre,rank(M.Datipre), procedura);
                    M.qlimit = reslim(M.Npcpca,M.autovalori1,95);
                    M.tlimit = tsqlim(M.np,M.Npcpca,95);
                    %adesso mostro tutti i grafici: scores, loadings, residui, T2, Q, 
                    %sensitivity, specificity, ecc.
                    M.matricepre=M.matrice;
                    M.matricepre=M.matricepre-ones(M.n,1)*M.media;
                    if(M.preproc==2)
                        M.matricepre=M.matricepre./(ones(M.n,1)*M.dev);
                    end
                    %Pareto Scaling
                    if(M.preproc==3)
                        M.matricepre=M.matricepre./(ones(M.n,1)*(sqrt(M.dev)));
                    end
                    [ret, fig1, titoli1, Ngrafici]=visualizza_grafici(M.matricepre, M.Datipre, ...
                                                       M.scores, M.loadings, M.autovalori, M.autovalori1, M.Npcpca, ...
                                                        M.categorie(i), idG, M.ClassRow, M.Class, M.categorie, M.NCat, ...
                                                        M.MyLabel, M.LabelRow, M.Xaxs);
                    if(ret==0)
                        clear Modello;
                        Modello=0;
                        return
                    end
                    
                    fig=[fig,fig1(idG:Ngrafici)];

                    while (idG<=Ngrafici)
                       titoli{idG}=titoli1{idG};
                       idG=idG+1;
                    end
                    
                    salvataggio(fig, titoli, Ngrafici);
                    %poi dovrei chiedergli se vuole cambiare NPC per tale categoria, o
                    %passare alla successiva.
                    [passo]=selezione_passo_successivo();
                    if(passo==0)
                        clear Modello;
                        Modello=0;
                        return;
                    elseif(passo==1)
                        risceltapc=true;
                    elseif(passo==2)
                        ripeticat=true;
                    end
                end
            end
            Modello(i)=M;
        end
        %qui mostra coomans_plot
        fig=[];
        titoli=[];
        Ngrafici=0;
        [fig,titoli,Ngrafici]=coomans_plot(Modello,Modello(1));
        if(Ngrafici~=0)
            salvataggio(fig, titoli, Ngrafici);
        end
        [opfinale]=selezione_ultimo_passo();
        if(opfinale==0)
            clear Modello;
            Modello=0;
            return;
        elseif(opfinale==1 || opfinale==2)
            %salva
            message = 'Salvare il modello?';
            button = questdlg(message,'Salvataggio modello','Yes','No','Yes');
            if(strcmp(button,'Yes')) 
                [tag,path]=uiputfile({'cartella'});
                if isequal(tag,0) || isequal(path,0)
                    disp('User pressed cancel')
                    %se l'utente ci ha ripensato premendo cancel.
                    clear Modello;
                    Modello=0;
                else
                    path=strcat(path,tag,'.mat');
                    save(path, 'Modello');
                end
            else
                %l'utente ci ha ripensato e non salva, allora cancello il
                %modello e lo setto a zero --> non da errore, perchè se ha
                %selezionato scarta, lo cancella e ok, 
                %se invece ha premuto riparti, modello viene di nuovo
                %cancellato, quindi perde lo zero e ok.
                clear Modello;
                Modello=0;
            end
            
            if (opfinale==2)
                ripetidacapo=true;
                clear Modello;
            end
        elseif(opfinale==3)
            clear Modello;
            ripetidacapo=true;
        else
            clear Modello;
            Modello=0;
        end
        Return=true;
    end
end
    
    
    