%ricava_matrice_restante permette di ottenere la matrice meno un dato
%insieme di indici. Nel metodo simca viene utilizzata per ottenere la
%matrice dei dati meno quelli della categoria in esame.

function [matr]=ricava_matrice_restante(matrice, indici)
    [rowM,~]=size(matrice);
    matr=[];
    for j=1:rowM
        id=1;
        k=indici(1);   
        aus=1;
        while(aus)
            if(j==k)
                break;
            end
            if(k==indici(length(indici)))
                aus=0;
            else
                id=id+1;
                k=indici(id);
            end
        end
        if(~aus)
            matr=[matr;matrice(j,:)];
        end
    end


end