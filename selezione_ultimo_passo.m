%selezione_ultimo_passo permette la scelta del passo finale della procedura
%di Simca_create_model.
function [successivo]=selezione_ultimo_passo()

    successivo=0;
    stringa={'salva il modello ed esci',...
            'salva il modello e ricrearne un altro',...
            'scarta e ricrea il modello',...
            'scarta ed esci'};
    status=false;
    while (~status)
        [Selection,ok] = listdlg('SelectionMode','single',...
                'Name','Prossimo passo','PromptString',...
                'Seleziona prossimo passo','ListString',stringa,...
                'InitialValue',1,...
                'listsize',[200 100]);
        if(ok)
            if(isempty(Selection))
                message = 'Warning! Non hai selezionato nessun passo'; 
                uiwait(warndlg(message,'!!Warning!!'));
            else
                status=true;
            end
        else
            %chiede conferma di voler uscire dalla procedura
            button = questdlg('Attenzione! sicuri di voler terminare la procedura?','Exit','Yes','No','No');
            if(strcmp(button,'Yes')) 
                return;
            %altrimenti richiedi
            end
        end
    end
    successivo=Selection;
end
