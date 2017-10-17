%seleziona_numero_PC permette di selezionare il numero di componenti
%principali per la costruzione del modello.
function [Npcpca]=selezione_numero_PC (Datipre, Class)

    Npcpca=0;
    stringa= strcat('Inserisci il numero di PC per la categoria ', Class);
    stringa= strcat(stringa,':');
    prompt = {stringa};
    dlg_title = 'Numero PC';
    num_lines = 1;
    defaultans = {num2str(rank(Datipre))};
    status=false;
    while (~status)
        status=true;
        answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
        if(isempty(answer))
            status=false;
            button = questdlg('Attenzione! sicuri di voler terminare la procedura?','Exit','Sì','No','No');
            if(strcmp(button,'Sì')) 
                return;
            end
        elseif(strcmp(answer,'') || strcmp(answer,'0'))
            status=false;
            message = ['Attenzione! campo non valido!' ...
                    char(10) ...
                    'è necessario inserire il numero maggiore di zero' ...
                    char(10) ];
            uiwait(warndlg(message,'Messaggio'));
        %se il numero è maggiore di range.
        elseif(str2num(answer{:})>rank(Datipre))
            status=false;
            message = ['Attenzione! campo non valido!' ...
                    char(10) ...
                    'è necessario inserire il numero < o = a' ...
                    defaultans ];
            uiwait(warndlg(message,'Messaggio'));
        
        end
    end
    Npcpca=str2num(answer{:});
    Npcpca=floor(Npcpca);

end