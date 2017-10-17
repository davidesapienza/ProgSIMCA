%get_coeff_bonta mi ritorna i parametri della classificazione dei dati.
%prende il modello da utilizzare per la classificazione , i dati della
%classe e i campioni delle altre categorie.
function [sensitivity, specificity, accuracy]=get_coeff_bonta(model,dati,matr, tlimit, qlimit)

    vp=0;
    vn=0;
    fp=0;
    fn=0;
    specificity = 0;
    sensitivity = 0;
    accuracy = 0;
    lambda=diag(model.autovalori)^-1;
    [row,~]=size(dati);
    for j=1:row
        tnew=dati(j,:)*model.loadings';
        enew=dati(j,:)-tnew*model.loadings;
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
    [row,~]=size(matr);
    for j=1:row
        tnew=matr(j,:)*model.loadings';
        enew=matr(j,:)-tnew*model.loadings;
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