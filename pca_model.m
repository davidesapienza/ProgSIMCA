%pca_model permette di costruire il modello secondo una procedura scelta e
%passata in input.
function [scores, loadings, autovalori, Explvar]=pca_model(Dati, Npc, procedura)
    
    [n,~]=size(Dati);
    if procedura==1
        %Metodo: eigenvalue of covariance matrix
        [V, D]=eigs((Dati'*Dati)./n,Npc);
        % V autovettori = loadings  D eigenvalues
        autovalori=diag(D);
        Explvar = 100.*(diag(D)/sum(diag(D)));
        %scores
        scores=Dati*V;
        %loading
        loadings =V;
        

    elseif procedura==2
        % Metodo: svd
        [U, S, V]= svds(Dati,Npc);
        % V = loadings
        autovalori =(diag(S).^2)./(n-1);
        %scores
        scores = U*S;
        %loadings
        loadings =  V;
        Explvar =100.*( autovalori/sum(autovalori));   
    end
    for j=2:Npc
        Explvar(j)=Explvar(j)+Explvar(j-1);
    end
    
    [~,maxind] = max(abs(loadings), [], 1);
    [d1, d2] = size(loadings);
    colsign = sign(loadings(maxind + (0:d1:(d2-1)*d1)));
    loadings = bsxfun(@times, loadings, colsign);
    scores = bsxfun(@times, scores, colsign);
    loadings=loadings';
end