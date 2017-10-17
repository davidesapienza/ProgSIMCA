%Cross Validation. Implementa i metodi di cancellazione, con i campioni
%rimasti calcola il modello, la media e deviazione standard, poi cerca di
%classificare i campioni rimasti fuori e tutti quelli delle altre due
%categorie.
function [specificity, sensitivity, accuracy]=cross_validation(matrice, dati, DimSplit, npc, procedura, preproc, fit)

    
    [n,~]=size(dati);
    %terminologia:
    %vp:veri positivi
    %vn:veri negativi
    %fp:falsi positivi
    %fn:falsi negativi
    vp=0;
    vn=0;
    fp=0;
    fn=0;
    %Specificity:     Abilità nell'identificare i negativi.
    %            specificity = \frac{TN}{TN+FP}
    %Sensitivity:     Abilità nell'identificare i positivi.
    %            specificity = \frac{TP}{TP+FN}
    %accuracy = \frac{TP+TN}{TP+TN+FP+FN}
    specificity = 0;
    sensitivity = 0;
    accuracy = 0;
    %se non calcolo in fit (quindi implementa LOO o Venetian Blinds)
    if(fit==false)
        for i=1:DimSplit
            daticv=dati;
            campioni_tolti=[];
            %devo togliere sempre la i-esima riga (campione) di ogni split
            id=i;
            %passo mi indica quante righe ho già tolto
            passo=0;
            while(id<=n)
                campioni_tolti=[campioni_tolti; daticv(id-passo,:)];
                if(id==1)
                    daticv=daticv(2:n,:);
                elseif(id==n)
                    daticv=daticv(1:n-passo-1,:);
                else
                    daticv=[daticv(1:(id-1-passo),:);daticv((id+1-passo):(n-passo),:)];
                end
                passo=passo+1;
                id=id+DimSplit;
            end

            %in daticv ottengo i miei dati originali meno i campioni_tolti
            %adesso su questi devo calcolare media e dev standard che mi
            %serviranno dopo, e devo preprocessarli.
            [daticv,media,dev]=preprocessing(daticv, preproc);
            %trovo il rango che utilizzerò per la pca 
            %serve per calcolare gli autovalori da utilizzare in reslim
            rango=rank(daticv);       
            [r,~]=size(daticv);
            if(rango<npc)
                display('attenzione rango inferiore a npc');
                [~, loadings, autovalori, ~]=pca_model(daticv,rango,procedura);
                [~, ~, autovalori1, ~]=pca_model(daticv,rango,procedura);
            else
                [~, loadings, autovalori, ~]=pca_model(daticv,npc,procedura);
                [~, ~, autovalori1, ~]=pca_model(daticv,rango,procedura);
            end
            %soglie di confidenza
            qlimit = reslim(npc,autovalori1,95);
            tlimit = tsqlim(r,npc,95);
            
            %quindi il test set adesso è composto da:
            %campioni_tolti -> che contengono i campioni della classe
            %matrice -> che contiene tutti gli altri  

            %con campioni_tolti ottengo:
            %   veri positivi e falsi negativi
            %con matrice ottengo:
            %   falsi positivi e veri negativi
            
            %centro e scalo i campioni_tolti con la media e dev appena
            %calcolati
            [row,~]=size(campioni_tolti);
            campioni_tolti=campioni_tolti-ones(row,1)*media;
            if(preproc==2)
                campioni_tolti=campioni_tolti./(ones(row,1)*dev);
            end
            %Pareto Scaling
            if(preproc==3)
                campioni_tolti=campioni_tolti./(ones(row,1)*(sqrt(dev)));
            end

            %analizzo i campioni_tolti

            lambda=diag(autovalori)^-1;
            for j=1:row
                tnew=campioni_tolti(j,:)*loadings';
                enew=campioni_tolti(j,:)-tnew*loadings;
                t=tnew*lambda*tnew';
                q=enew*enew';
                T2=(t/tlimit).^2;
                Q=(q/qlimit).^2;
                %Radice quadrata((t2/tlim).^2 + (q/qlim).^2) < = radice quadrata (2)
                if(sqrt(T2 + Q) <= sqrt(2))
                    vp=vp+1;
                else
                    fn=fn+1;
                end
            end

            %analizzo matrice
            [row,~]=size(matrice);
            matrice=matrice-ones(row,1)*media;
            if(preproc==2)
                matrice=matrice./(ones(row,1)*dev);
            end
            %Pareto Scaling
            if(preproc==3)
                matrice=matrice./(ones(row,1)*(sqrt(dev)));
            end
            
            for j=1:row
                tnew=matrice(j,:)*loadings';
                enew=matrice(j,:)-tnew*loadings;
                t=tnew*lambda*tnew';
                q=enew*enew';
                T2=(t/tlimit).^2;
                Q=(q/qlimit).^2;
                %Radice quadrata((t2/tlim).^2 + (q/qlim).^2) < = radice quadrata (2)
                if(sqrt(T2 + Q) <= sqrt(2))
                    fp=fp+1;
                else
                    vn=vn+1;
                end
            end
        end

        specificity = (vn / (vn+fp));
        sensitivity = (vp / (vp+fn));
        accuracy = ((vp+vn) / (vp+vn+fp+fn));
    
    else
        %nel caso in cui fit==true
        rango=rank(dati);
        [n,~]=size(dati);
        [~, loadings, autovalori, ~]=pca_model(dati,npc,procedura);
        [~, ~, autovalori1, ~]=pca_model(dati,rango,procedura);
        qlimit = reslim(npc,autovalori1,95);
        tlimit = tsqlim(n,npc,0.95);
        lambda=diag(autovalori)^-1;
        %analizzo i dati
        [row,~]=size(dati);
        for j=1:row
            tnew=dati(j,:)*loadings';
            enew=dati(j,:)-tnew*loadings;
            t=tnew*lambda*tnew';
            q=enew*enew';
            T2=(t/tlimit).^2;
            Q=(q/qlimit).^2;
            %Radice quadrata((t2/tlim).^2 + (q/qlim).^2) < = radice quadrata (2)
            if(sqrt(T2 + Q) <= sqrt(2))
                vp=vp+1;
            else
                fn=fn+1;
            end
        end

        %analizzo matrice
        [row,~]=size(matrice);
        for j=1:row
            tnew=matrice(j,:)*loadings';
            enew=matrice(j,:)-tnew*loadings;
            t=tnew*lambda*tnew';
            q=enew*enew';
            T2=(t/tlimit).^2;
            Q=(q/qlimit).^2;
            %Radice quadrata((t2/tlim).^2 + (q/qlim).^2) < = radice quadrata (2)
            if(sqrt(T2 + Q) <= sqrt(2))
                fp=fp+1;
            else
                vn=vn+1;
            end
        end
        specificity = (vn / (vn+fp));
        sensitivity = (vp / (vp+fn));
        accuracy = ((vp+vn) / (vp+vn+fp+fn)); 
    end
end