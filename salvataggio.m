%procedura che permette di memorizzare le immagini relafive ai grafici.
%E' possibile salvare le immagini in formato matlab e jpg.
function salvataggio(fig, titoli, Ngraf)

    [sel,ok] = listdlg('Name','Salvataggio',...
    'PromptString',{'Seleziona i grafici che desideri salvare'},...
    'ListString',titoli,'InitialValue',1:Ngraf,'OKString','Salva','CancelString','Non Salvare',...
    'listsize',[200 100]);
    if(ok)
        [tag,path]=uiputfile({'cartella'});
        if isequal(tag,0) || isequal(path,0)
            disp('User pressed cancel')
        else
            path=strcat(path,tag);
            for i=1:length(sel)
                destinazione=strcat(path,titoli(sel(i)));
                display(destinazione);
                dest2=strcat(destinazione,'.fig');
                savefig(fig(i),dest2{1});
                saveas(fig(i),destinazione{1},'jpg');
            end
        end
    end
end