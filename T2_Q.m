
function [ret, fig, titoli, idG]=T2_Q(matrice, Datipre, scores, loadings, autovalori, autovalori1, Npcpca, idCat, idG, LabelRow, LabelClass, categorie, NCat)
    ret=0;
    color={'white','blue','red','black'};
    col={'b','r','k'};
    
    [ns,~]=size(scores);
    [~,ml]=size(loadings);
    
    Mnew=scores*loadings;
%     display('Mnew');
%     display(size(Mnew));
    residui=Datipre-Mnew;
     %calcoliamo T2 e Q
    lambda=diag(autovalori)^-1;
    T=scores*lambda*scores';
    T=diag(T);
    display(T);
    Q=zeros(ns,1);
    for j=1:ns                        
        Q(j)=residui(j,:)*residui(j,:)';
    end
    %soglie di confidenza
    qlimit = reslim(Npcpca,autovalori1,95);
    tlimit = tsqlim(ns,Npcpca,95);
    %calcolo T2ridotto e Qridotto
    Trid=T/tlimit;
    Qrid=Q/qlimit;
    
      
    
    fig(idG)=figure;

    titoli{idG}='T2_Q';
    idG=idG+1;
    %provo a graficare score*loadings che credo siano t^2              
    subplot(2,1,1);
    hold on;

    bar(1:ns,T,col{idCat});

    title('T^2');              
    hold off;        
    subplot(2,1,2);
    hold on;
    bar(1:ns,Q,col{idCat});

    hold off;
    title('Q');                   
    message = 'Dopo aver preso visione del grafico premere OK';
    questdlg(message,'Continua','Ok','Ok');
    
    fig(idG)=figure;
    titoli{idG}='T2vsQ';
    idG=idG+1;
    hold on;
    scatter(T,Q,5,color{idCat+1});
    xlabel('T^2');
    ylabel('Q');
    legend(LabelClass(idCat));
    legend('show');
    display(qlimit);
    display(tlimit);
    plot([tlimit,tlimit],ylim,'k--');
    plot(xlim,[qlimit,qlimit],'k--');
    hold off;
    message = 'Dopo aver preso visione del grafico premere OK';
    questdlg(message,'Continua','Ok','Ok');

    %%%%%%
    [n,m]=size(matrice);
    %recupero gli indici degli elementi corrispondenti alla 
    %categoria selezionata
    fig(idG)=figure;
    titoli{idG}='T2vsQ_due';
    idG=idG+1;
    hold on;
    for i=1:NCat
        IDCampioni=zeros(n);
        id=1;
        for j=1:n
            if(strcmp(LabelRow(j,1),LabelClass(categorie(i))))
                IDCampioni(id)=j;
                id=1+id;
            end
        end
        %rimuovo gli zero
        indici=IDCampioni(IDCampioni~=0);
        dati=matrice(indici,:);
        [ndat,mdat]=size(dati);
        for j=1:ndat
            tnew=dati(j,:)*loadings';
            enew=dati(j,:)-tnew*loadings;
            t=tnew*lambda*tnew';
            q=enew*enew';
            T2=(t/tlimit).^2;
            Q=(q/qlimit).^2;
            
            scatter(t,q,5,color{categorie(i)+1});
            
        end
    end
    xlabel('T^2');
    ylabel('Q');
    legend(LabelClass(idCat));
    legend('show');
    plot([tlimit,tlimit],ylim,'k--');
    plot(xlim,[qlimit,qlimit],'k--');
    hold off;
    message = 'Dopo aver preso visione del grafico premere OK';
    questdlg(message,'Continua','Ok','Ok');
    %%ricava_matrice_restante(matrice, indici)

    
    %ho finito di mostrare i grafici, quindi torno all'ultimo (tolgo
    %l'ultimo incremento).
    idG=idG-1;
    ret=1;
    
end