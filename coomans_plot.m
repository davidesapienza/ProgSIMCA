% coomans_plot permette di graficare insieme due modelli, mostrando i dati
% in esame come vengono classificati: se classificati appartenenti ad una
% categoria, ad entrambe, o a nessuna.

function [fig,titoli,idG]=coomans_plot(Modello, Dati)
    color={'white','blue','red','black'};
    idG=1;
    fig=[];
    titoli=[];
    if (Modello(1).NCat==1)
        idG=0;
        return
    else
        
        base=Modello(1);
        %recupero i dati che mi servono: il numero di campioni per ogni
        %categoria, l'insieme di indici per ogni categoria.
        sizes=zeros(1,length(Dati.Class));
        indici=[];
        for i=1:length(Dati.Class)
            IDCampioni=zeros(Dati.n);
            id=1;
            for j=1:Dati.n
                if(strcmp(Dati.ClassRow(j,1),Dati.Class(i)))
                    IDCampioni(id)=j;
                    id=1+id;
                end
            end
            %rimuovo gli zero
            sizes(i)=length(IDCampioni(IDCampioni~=0));
            indici=[indici;IDCampioni(IDCampioni~=0)];   
        end
        
        %inizializzo due vettori q1 e q2, mantengono i punti proiettati sui
        %due modelli in esame.
        [npunti,~]=size(Dati.matrice);
        q1=zeros(1,npunti);
        q2=zeros(1,npunti);
        %due for: uno per le ascisse e uno per le ordianate. (per graficare
        %tutti i modelli).
        for i=1:(base.NCat-1)
            %ricavo i q di tutti a dati proiettandoli nel modello i-esimo
            [q1]=ricava_q_rid(Modello(i),Dati);
            q1lim=Modello(i).qlimit;
            %devo confrontarlo con il secondo modello
            for j=(i+1):(base.NCat)
                %ricavo i q di tutti a dati proiettandoli nel modello i-esimo
                [q2]=ricava_q_rid(Modello(j),Dati);
                q2lim=Modello(j).qlimit;
                %adesso ho i dati dei due modelli e posso graficare coomans
                
                %dovrei graficarli per classi separati
                fig(idG)=figure;
                titoli{idG}=['Coomans plot ',base.Class(i),'vs',base.Class(j)];
                idG=idG+1;
                hold on;
                xlim('auto');
                ylim('auto');
                idaus=1;
                for k=1:length(sizes)
                    next=idaus+sizes(k)-1;
                    scatter(q1(idaus:next),q2(idaus:next),5,color{k+1});
                    
                    LabelCorrenti=Dati.LabelRow(indici(idaus:next),:);
                    LabelCorrenti=cellstr(LabelCorrenti);
                    dx = (max(q1(idaus:next))-min(q1(idaus:next)))*0.02;
                    dy = (max(q2(idaus:next))-min(q2(idaus:next)))*0.02;
                    text(q1(idaus:next)+dx, q2(idaus:next)+dy, LabelCorrenti);
                    idaus=next+1;
                end
                plot([sqrt(2),sqrt(2)],ylim,'k--');
                plot(xlim,[sqrt(2),sqrt(2)],'k--');
                xlabel(['Model cat',base.Class(i)]);
                ylabel(['Model cat',base.Class(j)]);
                legend(Dati.Class);
                title(['Coomans plot ',base.Class(i),'vs',base.Class(j)]);
                hold off;
                message = 'Dopo aver preso visione del grafico premere OK';
                questdlg(message,'Continua','Ok','Ok');
            end
        end

        %ogni campione lo proietto sia nel modello 1 che 2, utilizzo dati Qrid e uso i limiti di Q 
    end
    idG=idG-1;
end

function [qrid]=ricava_q_rid(M,Dati)
    [n,m]=size(Dati.matrice);
    %preprocesso i dati
    matricepre=Dati.matrice-ones(n,1)*M.media;
    %Autoscaling
    if(M.preproc==2)
        matricepre=matricepre./(ones(n,1)*M.dev);
    %Pareto Scaling
    elseif(M.preproc==3)
        matricepre=matricepre./(ones(n,1)*(sqrt(M.dev)));
    end
    qrid=[];
    for i=1:length(Dati.Class)

        IDCampioni=zeros(n);
        id=1;
        for j=1:n
            if(strcmp(Dati.ClassRow(j,1),Dati.Class(i)))
                IDCampioni(id)=j;
                id=1+id;
            end
        end
        %rimuovo gli zero
        daticat=matricepre(IDCampioni(IDCampioni~=0),:);
        [ndat,~]=size(daticat); 
        for j=1:ndat
            tnew=daticat(j,:)*M.loadings';
            enew=daticat(j,:)-tnew*M.loadings;
            q=enew*enew';
            qrid=[qrid,(q/M.qlimit)];
        end
    end
end