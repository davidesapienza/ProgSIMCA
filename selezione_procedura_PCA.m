%selezione_procedura_PCA permette di selezionare la procedura con cui
%calcolare il modello PCA.
function [procedura] = selezione_procedura_PCA() 
    
    procedura=0;
    modalita={'eigs';'svds'};
    status=false;
    while (~status)
        [Selection,ok] = listdlg('SelectionMode','single',...
                    'Name','Selezione procedura',...
                    'PromptString','Seleziona la procedura desiderata',...
                    'ListString',modalita,'InitialValue',1,...
                    'listsize',[200 100]);
        if(~ok)
            button = questdlg('Attenzione! sicuri di voler terminare la procedura?','Exit','Sì','No','No');
            if(strcmp(button,'Sì')) 
                return;
            end
        else
            status=true;
        end
    end
    
    procedura=Selection;
end