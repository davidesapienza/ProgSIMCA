%selezione_CV() permette di selezionare il metodo di cancellazione per la
%cross validazione.

function [CVOp] = selezione_CV()
    
    CVOp=0;
    modalita={'Venetian Blinds (LMO)';'Leave One Out'};
    status=false;
    while (~status)
        [Selection,ok] = listdlg('SelectionMode','single',...
                    'Name','Selezione Cross Validation',...
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
    
    CVOp=Selection;
end