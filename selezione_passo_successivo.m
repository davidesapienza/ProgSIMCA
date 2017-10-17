%selezione_passo_successivo permette di selezionare il passointermedio
%della procedura simca_create_model
function [successivo]=selezione_passo_successivo()

    successivo=0;
    stringa={'riscegli un numero di PC',...
            'ritorna alla visualizzazione di scree plot',...
            'passa alla prossima categoria'};
    status=false;
    while (~status)
        [Selection,ok] = listdlg('SelectionMode','single',...
                'Name','Prossimo passo','PromptString',...
                'Seleziona prossimo passo','ListString',stringa,...
                'InitialValue',3,...
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
