%selezione categorie su cui creare il modello. (un modello per ogni
%categoria).
function [categorie] = selezione_categorie(LabelClass) 
    categorie=0;
    len_lista=length(LabelClass);
    status=false;
    while (~status)
        [Selection,ok] = listdlg('Name','Selezione Categoria','PromptString',...
                'Seleziona le categorie da graficare','ListString',LabelClass,...
                'InitialValue',1:len_lista,...
                'listsize',[200 100]);
        if(ok)
            if(isempty(Selection))
                message = 'Warning! Non hai selezionato nessuna categoria'; 
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
    categorie=Selection;
end