%visualizza_grafici permette di visualizzare i seguenti grafici:
%scores e loadings
%residui
%contributi sui campioni, e sulle colonne
%T^2 e Q
%contribution plot
%T2ridotto contro Qridotto

function [ret, fig, titoli, idG]=visualizza_grafici(matricepre, Datipre, scores, loadings, autovalori, autovalori1, Npcpca, idCat, idG, ClassRow, Class, categorie, NCat, MyLabel, LabelRow, Xaxs)
    ret=0;
    fig=[];
    titoli=[];
    color={'white','blue','red','black'};
    col={'b','r','k'};
    [np,mp]=size(Datipre);
    [n,m]=size(matricepre);
    %si chiede quali PC si vuole graficare: servono per scores e loadings;
    prompt={['Inserire le Componenti Principali da graficare',char(10),...
        'Asse X (componenti da graficare separate da spazi):'],...
        'Asse Y (componenti da graficare separate da spazi):'};
    if(Npcpca==1)
        defAns={'1','1'};
    else
        defAns={'1','2'};
    end
    status=false;
    while (~status)
        status=true;
        answer = inputdlg(prompt,'PC plot',1,defAns);
        if (isempty(answer))
            status=false;
            button = questdlg('Attenzione! sicuri di voler terminare la procedura?','Uscita','Sì','No','No');
            if(strcmp(button,'Sì')) 
                return;
            end
            answer={'-1'};
        end
        %se è stato inserito qualcosa nella PC
        if(status)
            PCX=str2num(answer{1});
            PCY=str2num(answer{2});
            PCX=floor(PCX);
            PCY=floor(PCY);
            if ((length(PCX)~=length(PCY))||(max([PCX,PCY])>Npcpca)||(min([PCX,PCY])<1))
                status=false;
            end

            %setto il numero di grafici pari al numero di coppie
            %PCX e PCY
            nGraphics=length(PCX);
        end
    end
    
    %mostro i plot degli scores e loadings
    idNPC=1;
    while idNPC~=nGraphics+1
        %grafichiamo gli score e i loadings
        name=strcat('Scores',num2str(PCX(idNPC)),'v',num2str(PCY(idNPC)));
        fig(idG)=figure;
        titoli{idG}=name;
        idG=idG+1;
        hold on;

        %prendo gli indici degli elementi appartenenti al campione i-esimo
        %se per caso l'utente ha scelto una sola PC, allora scattera gli score con
        %assi x e y uguali alla pc1
        scatter(scores(:,PCX(idNPC)),scores(:,PCY(idNPC)),5,color{idCat+1});
        %setto lo shift dove andare a scriverle
        dx = (max(scores(:,PCX(idNPC)))-min(scores(:,PCX(idNPC))))*0.02;
        dy = (max(scores(:,PCY(idNPC)))-min(scores(:,PCY(idNPC))))*0.02; % displacement so the text does not overlay the data points
        cellNomiCamp=cellstr(MyLabel);
   
        text(scores(:,PCX(idNPC))+dx, scores(:,PCY(idNPC))+dy, cellNomiCamp);
        xlabel(['PC',num2str(PCX(idNPC))]);
        ylabel(['PC',num2str(PCY(idNPC))]);
        xlim('auto');
        ylim('auto');
        plot([0 0],xlim,'k--');
        plot(ylim,[0 0],'k--');
        title('scores plot');
        hold off;
        message = 'Dopo aver preso visione del grafico premere OK';
        questdlg(message,'Continua','Ok','Ok');
        %grafico i loadings con Xaxs.
        name=strcat('Loadings',num2str(PCX(idNPC)),'e',num2str(PCY(idNPC)),'vsRT');
        fig(idG)=figure;
        titoli{idG}=name;
        idG=idG+1;
        
        hold all;
        %setto lo shift dove andare a scriverle
        plot(Xaxs, loadings(PCX(idNPC),:));
        plot(Xaxs, loadings(PCY(idNPC),:));
        xlabel('Retenction Time');
        ylabel(['PC',num2str(PCX(idNPC)),' e PC',num2str(PCY(idNPC))]);
        legend(strcat('PC',num2str(PCX(idNPC))),strcat('PC',num2str(PCY(idNPC))));
        legend('show');
        title('loadings plot');
        hold off;
        message = 'Dopo aver preso visione del grafico premere OK';
        questdlg(message,'Continua','Ok','Ok');
        
        idNPC=idNPC+1;
    end
    
    
    %altri dati che mi serviranno dopo
    Mnew=scores*loadings;
    residui=Datipre-Mnew;
    %calcoliamo T2 e Q
    lambda=diag(autovalori)^-1;
    T=scores*lambda*scores';
    T=diag(T);
    Q=zeros(np,1);
    for j=1:np                        
        Q(j)=residui(j,:)*residui(j,:)';
    end
    %soglie di confidenza
    qlimit = reslim(Npcpca,autovalori1,95);

    tlimit = tsqlim(np,Npcpca,95);
    %calcolo T2ridotto e Qridotto
    Trid=T/tlimit;
    Qrid=Q/qlimit;
   
    fig(idG)=figure;
    titoli{idG}='Matrice_Residui';
    idG=idG+1;
    
    plot(residui,'.');
    set(gca,'XTick',1:np,'XTickLabel', MyLabel,...
                        'XTickLabelRotation', -45);
    %Non so quanto senso abbia mostrare questo grafico.. 
    %in ogni caso la legenda la tolgo

    message = 'Dopo aver preso visione del grafico premere OK';
    questdlg(message,'Continua','Ok','Ok');

    fig(idG)=figure;
    titoli{idG}='Somme_Residui_Var_Camp';
    idG=idG+1;
    %residui sulle variabili (sommo i contributi per colonna al quadrato)
    %corrisponde a fare: colonna trasposta per colonna
    
    %in alternativa, forse: sum(diag(colonna per colonna trasposta))
    for i=1:mp
        arrayVar(i)=residui(:,i)'*residui(:,i);
    end
    subplot(2,1,1);
    hold on;
    bar(1:mp,arrayVar,col{idCat});
    title('residui sulle variabili');
    hold off;
    %residui sui campioni (sonno il contributo al quadtrato)
    %corrisponde a fare riga i-esima * riga i-esima trasposta.
    %tale valore è la somma dei quadrati
    for i=1:np
        arrayCamp(i)=residui(i,:)*residui(i,:)'; 
    end                    
    subplot(2,1,2);
    hold on;
    bar(1:np,arrayCamp,col{idCat});
    plot(xlim,[qlimit,qlimit],'k--');
    title('residui sui campioni');
    set(gca,'XTick',1:np,'XTickLabel', MyLabel,...
                        'XTickLabelRotation', -45);
    hold off; 
    message = 'Dopo aver preso visione del grafico premere OK';
    questdlg(message,'Continua','Ok','Ok');
    
    fig(idG)=figure;

    titoli{idG}='T2_Q';
    idG=idG+1;
    %provo a graficare score*loadings che credo siano t^2              
    subplot(2,1,1);
    hold on;

    bar(1:np,T,col{idCat});
    plot(xlim,[tlimit,tlimit],'k--');
    title('T^2'); 
    set(gca,'XTick',1:np,'XTickLabel', MyLabel,...
                        'XTickLabelRotation', -45);
    hold off; 
    
    subplot(2,1,2);
    hold on;
    bar(1:np,Q,col{idCat});
    plot(xlim,[qlimit,qlimit],'k--');
    title('Q'); 
    set(gca,'XTick',1:np,'XTickLabel', MyLabel,...
                        'XTickLabelRotation', -45);
    hold off;                  
    message = 'Dopo aver preso visione del grafico premere OK';
    questdlg(message,'Continua','Ok','Ok');
    
    %grafico i contribution plot se l'utente lo desidera
    message = 'Si desidera visualizzare il contribution plot?';
    button=questdlg(message,'Continua','Yes','No','Yes');
    if(strcmp(button,'Yes')) 
        statusext=false;
    %altrimenti richiedi
    else
         statusext=true;
    end
    %se è stato scelto yes allora
    while(~statusext)
        opzioni=[];
        for i=1:length(MyLabel(:,1))
            opzioni=[opzioni, num2str(i), '-', MyLabel(i,:), char(10)];
        end
        prompt={['Inserire i campioni che si desidera analizzare:',char(10)...
            opzioni,...
            'Identificativo numerico: (N°campioni separati da spazi):']};
        defAns={'1'};
        status=false;
        while(~status)
            status=true;

            answer = inputdlg(prompt,'Contribution plot',1,defAns);
            if (isempty(answer))
                status=false;
                button = questdlg('Attenzione! sicuri di voler terminare la procedura?','Uscita','Sì','No','No');
                if(strcmp(button,'Sì')) 
                    return;
                end

                answer={'-1'};
            end
            %se è stato inserito qualcosa nella lista dei campioni
            if(status)
                campione=str2num(answer{1});
                campione=floor(campione);
                campione=unique(campione);
                if ((max(campione)>length(MyLabel(:,1)))||(min(campione)<1))
                    status=false;
                    message = 'Attenzione, hai inserito un identificativo sbagliato!';
                    uiwait (errordlg(message,'Error'));
                end

                %altrimenti 
                nGraphics=length(campione);
            end 
        end
        idC=1;
        %finchè ho dei grafici li faccio
        while idC~=nGraphics+1
            
            contrQ=zeros(1,m);
            contrT=zeros(1,m);
%             %tcon,i=ti lambda^(-1/2) Pk' = xi Pk lambda^(-1/2) Pk'
%             %tconi,k=score(i,:)*lambda^(-1/2)*dati(i,k)*loadings(k)
            lambda1=diag((autovalori.^(-1/2)));
            for j=1:m
                contrQ(j)=sign(residui(campione(idC),j))*(residui(campione(idC),j)^2);
                contrT(j)=scores(campione(idC),:)*lambda1*Datipre(idC,j)*loadings(:,j); 
            end
            
            %qui faccio il Contribution plot per il campione idC-esimo
            fig(idG)=figure;

            titoli{idG}=['Contribution plot ',MyLabel(campione(idC),:)];
            idG=idG+1;
            subplot(2,1,1);
            hold on;

            bar(Xaxs,contrT,col{idCat});
            title(['Contribution Plot del campione ',MyLabel(campione(idC),:)]); 
            xlabel('Retenction Time');
            ylabel('Contribution of T^2');
            hold off; 
           
            subplot(2,1,2);
            hold on;
            bar(Xaxs,contrQ,col{idCat});
            title(['Contribution Plot del campione ',MyLabel(campione(idC),:)]); 
            xlabel('Retenction Time');
            ylabel('Contribution of Q');
            hold off;

            message = 'Dopo aver preso visione del grafico premere OK';
            questdlg(message,'Continua','Ok','Ok');
            idC=idC+1;
        end
        %qui chiedo se desidera farne altri
        message = 'Si desidera visualizzare altri contribution plot?';
        button=questdlg(message,'Continua','Yes','No','Yes');
        if(strcmp(button,'Yes')) 
            statusext=false;
        %altrimenti richiedi
        else
             statusext=true;
        end
    end
    
    %T2rid vs Qrid
    ripeti=true;
    limiteq=-1;
    limitet=-1;
    %indice che mi dice quanti grafici sto facendo (impostando limiti
    %diversi)
    idtvsq=1;
    while(ripeti)
        ripeti=false;
        fig(idG)=figure;
        titoli{idG}=strcat('T2ridvsQrid',num2str(idtvsq));
        idtvsq=idtvsq+1;
        idG=idG+1;
        hold on;    
        %PROIETTO tutta la matrice (compresi i campioni della categoria in
        %esame
        for i=1:length(Class)
            
            %memorizzo i dati da graficare. 
            %avrò quindi 1 vettore per la categoria per le x e tre per le
            %y
            x=[];
            y=[];
            IDCampioni=zeros(n);
            id=1;
            for j=1:n
                if(strcmp(ClassRow(j,1),Class(i)))
                    IDCampioni(id)=j;
                    id=1+id;
                end
            end
            %rimuovo gli zero
            indici=IDCampioni(IDCampioni~=0);
            dati=matricepre(indici,:);
            LabelCorrenti=LabelRow(indici,:);
            LabelCorrenti=cellstr(LabelCorrenti);
            [ndat,~]=size(dati);
            indici=[]; 
            for j=1:ndat
                tnew=dati(j,:)*loadings';
                enew=dati(j,:)-tnew*loadings;
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
                        indici=[indici;j];
                    end
                    %altrimenti non è da graficare
                else
                    x=[x;T2];
                    y=[y;Q];
                    indici=[indici;j];
                end
            end 
            %qui la scatter
            dx = (max(x)-min(x))*0.02;
            dy = (max(y)-min(y))*0.02;  
            scatter(x,y,5,color{i+1});
            text(x+dx, y+dy, LabelCorrenti(indici,:));
        end

        xlabel('T^2rid');
        ylabel('Qrid');
        legend(Class);
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
    %ho finito di mostrare i grafici, quindi torno all'ultimo (tolgo
    %l'ultimo incremento).
    idG=idG-1;    
    ret=1;
end