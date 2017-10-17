
% si richiede la dimensione dello split.
% vengono passati il nome della categoria in esame e il range (numero
% righe) della matrice (campioni della categoria) in esame.

function [DimSplit] = richiesta_split(nomeCat, range) 
    
    DimSplit=0;
    stringa= strcat('Inserisci la dimensione dello split per la categoria ', nomeCat);
    stringa= strcat(stringa,':');
    prompt = {stringa};
    dlg_title = 'Dimensione split';
    num_lines = 1;
    defaultans = {num2str(range)};
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
        elseif(str2num(answer{:})>range)
            status=false;
            message = ['Attenzione! campo non valido!' ...
                    char(10) ...
                    'è necessario inserire il numero < o = a' ...
                    num2str(range) ];
            uiwait(warndlg(message,'Messaggio'));
        end
    end
    DimSplit=str2num(answer{:});
    DimSplit=floor(DimSplit);
end