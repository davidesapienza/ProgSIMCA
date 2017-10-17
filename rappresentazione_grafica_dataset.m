%questo metodo permette di avere una rappresentazione grafica preliminare
%dei dati. nelle ascisse inserisce valori di retention time.
function [ret, Xaxs_ret]=rappresentazione_grafica_dataset(Datipre, titolo, label, Xaxs)
    ret=0;
    [n,m]=size(Datipre);
    if (nargin == 3)
        Xaxs_ret=0;
        statusext=false;
        while(~statusext)
            status=false;
            while (~status)
                message = ['Caricare il file dell''asse x',char(10)...
                            '(riferimento al Retention time)'];

                button = questdlg(message,'Caricamento','Yes','Yes');
                if(strcmp(button,'Yes'))
                    %Messaggio di warning con le indicazioni del file, il file
                    %deve contenere data_tr.data e data_tr.class..
                    message = ['Attenzione! è necessario inserire un file dei dati che contenga' ...
                                char(10) ...
                                'i valori corrispondenti dell''asse x' ...
                                char(10)];
                    uiwait(warndlg(message,'!!Attenzione!!'));

                    %carica il file.
                    [FileName,PathName] = uigetfile('*.mat','Seleziona il file dei dati');
                    status=true;

                    if(isequal(PathName,0))
                        status=false;
                        message = 'Attenzione, nessun file selezionato!';
                        uiwait (errordlg(message,'Error'));

                    else
                        [pathstr,name,ext] = fileparts(FileName);
                        if(~strcmp(ext,'.mat'))
                            status=false;
                            message = ['Attenzione, estensione file errata!'];
                            uiwait (errordlg(message,'Error'));
                        end
                    end
                else
                    %chiede conferma di voler uscire dalla procedura
                    button = questdlg('Attenzione! sicuri di voler terminare la procedura?','Exit','Yes','No','No');
                    if(strcmp(button,'Yes')) 
                        return;
                    %altrimenti richiedi
                    else
                         status=false;
                    end
                end
           

            end

            S=load(FileName);

            variableInfo = who('-file', FileName);
            if(ismember('xaxs', variableInfo)) % returns true
                Xaxs=S.xaxs;
                [nx,mx]=size(Xaxs);
                if(nx~=1)
                    status=false;
                    message = ['Attenzione, il file deve contenere un vettore;'...
                                char(10) 'deve corrispondere all''asse x'];
                    uiwait (errordlg(message,'Error'));
                elseif(mx~=m)
                    status=false;
                    message = ['Attenzione, il file deve contenere un vettore'...
                                char(10) 'di dimensioni pari al numero di colonne della matrice dei dati'];
                    uiwait (errordlg(message,'Error'));
                else
                    statusext=true;
                end
            else
                status=false;
                message = ['Attenzione, file errato!'...
                            char(10) 'Il file deve contenere il campo xaxs!'];
                uiwait (errordlg(message,'Error'));
            end
        end
    end
    
    Xaxs_ret=Xaxs;
    figure  
    hold on;
    soglia=17;
    if(n>soglia)
        n_graph=ceil(n/soglia);
    else
        n_graph=1;
    end
    
    idx_aus=1;                 
    for i=1:n_graph
        subplot(n_graph,1,i);
        
        if(soglia<(n-idx_aus))
            plot(Xaxs,Datipre(idx_aus:(i*soglia),:));
            ylabel('Intensity');
            xlabel('Retention time');
            legend(label(idx_aus:(i*soglia),:));
            idx_aus=idx_aus+soglia;
        else
            plot(Xaxs,Datipre(idx_aus:end,:));
            ylabel('Intensity');
            xlabel('Retention time');
            legend(label(idx_aus:end,:));
        end
        legend('show');
        if(i==1)
            title(titolo);
        end
    end
   
    hold off;
    message = 'Dopo aver preso visione del grafico premere OK';
    questdlg(message,'Continua','Ok','Ok');
    
    ret=1;

end