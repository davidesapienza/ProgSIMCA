function [scelta] = selezione_preprocessing() 
    scelta=0;
    modalita={'Mean Centering';'Autoscaling';'Pareto Scaling'};
    status=false;
    while (~status)
        [Selection,ok] = listdlg('SelectionMode','single',...
                    'Name','Selezione preprocessing',...
                    'PromptString','Seleziona le operazioni di preprocessing desiderate',...
                    'ListString',modalita,'InitialValue',1,...
                    'listsize',[200 100]);
        if(~ok)
            button = questdlg('Attenzione! sicuri di voler terminare la procedura?','Exit','Sì','No','No');
            if(strcmp(button,'Sì')) 
                return;
            %altrimenti richiedi
            else
                status=false;
            end
        else
            status=true;
        end
    end
    scelta=Selection;
end