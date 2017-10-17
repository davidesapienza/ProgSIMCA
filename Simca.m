%Procedura Simpa per la classificazione dei dati.
%Parametri:
%   Nessun parametro verrà passato preliminariamente alla procedura, 
%   ma verrà richiesto eventualmente di inserirli passo passo.

%Author:
%Natalia Orlandi
%Davide Sapienza

function Simca()

    Modello=0;
    %1- prima scelta: Creazione di un modello o 
    %                 Classificazione di dati di test.
    %in questo modo ci sono due rami differenti di esecuzione.
    Operazioni={'Creazione modello', 'Classificazione di dati'};
    [Selection,ok] = listdlg('SelectionMode','single',...
            'Name','Selezione Operazione','PromptString',...
            'Seleziona l''operazione',...
            'ListString',Operazioni,...
            'InitialValue',1,...
            'listsize',[200 100]); 
    scelta=0;
    if(ok)
        if(Selection==1)
            scelta=1;
        elseif(Selection==2)
            scelta=2;
        end
    end
    
    %inizializzo modello = 0. Se inizio il test ed il modello sarà 
    %ancora = a 0, allora deve caricare un modello precedentemente 
    %generato. Altrimenti, utilizza il modello risultante dal ramo di 
    %Simca_create_model().
    
    %solo se l'utente lo specifica esce e termina la procedura.
    while(scelta)
        %diverso ramo di esecuzione in base alla scelta effettuata
        switch scelta
            %Ramo Creazione modello:  chiama Simca_create_model()
            case 1
                clear Modello
                [Modello, ret]=Simca_create_model();
                %se il modello non è stato terminato o non salvato allora
                %reimposta modello a 0;
                if(length(Modello)>1)
                    aus=0;
                elseif(isfield(Modello, 'ClassRow')==1)
                   aus=0;
                else
                    aus=1;
                end
%               %stampa messaggio di conferma
                if (ret==0 || aus)
                    messaggio='Il modello è stato scartato';
                elseif(~aus)
                    messaggio='Il modello è stato salvato';
                end
                questdlg(messaggio,'Continua','Ok','Ok');
                %Scelta prossimo passo:
                %    -Creazione altro modello (indipendentemente se quello precedente è
                %     stato salvato o meno) - si riparte dalla scelta delle categorie
                %    -Inizio fase di test (si passerebbe a Simca_test_model() passando 
                %     il modello creato).
                %    -Terminazione procedura.  
                status=false;
                while (~status)
                    Operazioni={'Creazione nuovo modello', 'Classificazione di dati', 'Uscita'};
                    [Selection,ok] = listdlg('SelectionMode','single',...
                            'Name','Selezione Operazione','PromptString',...
                            'Seleziona l''operazione',...
                            'ListString',Operazioni,...
                            'InitialValue',1,...
                            'listsize',[200 100]); 
                    scelta=0;
                    status=true;
                    if(ok)
                        if(Selection==1)
                           scelta=1;
                        elseif(Selection==2)
                           scelta=2;
                        end
                    elseif (scelta==0)
                        message = 'Si è scelto di terminare la procedura. Continuare?';
                        button = questdlg(message,'Exit','Yes','No','No');
                        if(strcmp(button,'Yes')) 
                            return;
                        %altrimenti richiedi
                        else
                             status=false;
                        end
                    end
                end
            
            %Ramo testing modello:  chiama Simca_test_model()
            case 2
                %controllo dellavariabile Modello (se 0 o contine
                %effettivamente un modello).
                if(length(Modello)>1)
                    aus=0;
                elseif(isfield(Modello, 'ClassRow')==1)
                    aus=0;
                else
                    aus=1;
                end
                %in base al controllo precedente chima il test sul modello
                %oppure richiederà di inserirne uno già realizzato.
                if(aus)
                    Simca_test_model();
                else
                    Simca_test_model(Modello);
                end
                %Scelta prossimo passo:
                %    -Creazione altro modello 
                %    -Inizio altro test (altra classificazione). 
                %    -Terminazione procedura.
                status=false;
                while (~status)
                    Operazioni={'Creazione nuovo modello', 'Classificazione di dati', 'Uscita'};
                    [Selection,ok] = listdlg('SelectionMode','single',...
                            'Name','Selezione Operazione','PromptString',...
                            'Seleziona l''operazione',...
                            'ListString',Operazioni,...
                            'InitialValue',1,...
                            'listsize',[200 100]);  
                    scelta=0;
                    status=true;
                    if(ok)
                        if(Selection==1)
                            scelta=1;
                        elseif(Selection==2)
                            scelta=2;
                        end
                    elseif (scelta==0)
                        message = 'Si è scelto di terminare la procedura. Continuare?';
                        button = questdlg(message,'Exit','Yes','No','No');
                        if(strcmp(button,'Yes')) 
                            return;
                        %altrimenti richiedi
                        else
                             status=false;
                        end
                    end
                end
        end
    end
end