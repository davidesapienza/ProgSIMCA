%preprocessing effettua il preprocessing dei dati passati in input, secondo
%tre operazioni: mean centering, autoscaling, pareto scaling
function [Datipre, media, dev]=preprocessing (Dati, preproc)
    [np, mp]=size(Dati);
    %Mean Centering
    media=mean(Dati);
    Datipre=Dati-ones(np,1)*media;
    dev=std(Datipre);
    %Autoscaling
    if(preproc==2)
        Datipre=Datipre./(ones(np,1)*dev);
    end
    %Pareto Scaling
    if(preproc==3)
        Datipre=Datipre./(ones(np,1)*(sqrt(dev)));
    end

end