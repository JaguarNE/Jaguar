global class Assegna {

    public Assegna(Vettura v){
    }
	/*GETASSEGNAZIONIREPARTO*************************************************************************
        Metodo per prendere lo stato di tutte le macchine assegnate al reparto dell'utente
    ***********************************************************************************************/
    @RemoteAction
    global static List<Wrapper.Auto> getAssegnazioniReparto(String di, String df, String targa){
        List<Wrapper.Auto> assegnazioni;
        List<NE__Order__c> vetture;
        List<NE__Order__c> avs;
        String qtarga='';
        if (!String.isBlank(targa)) {
        	qtarga += 'AND Targa__c =\''+targa+'\''; 
        }
        try{
            assegnazioni=new List<Wrapper.Auto>();
            System.debug('di: '+di+' df: '+df);
            DateTime dataInizio=datetime.newInstance(Integer.valueOf(di.substring(6,10)),Integer.valueOf(di.substring(3,5)),Integer.valueOf(di.substring(0,2)),02,00,00);
            DateTime dataFine=datetime.newInstance(Integer.valueOf(df.substring(6,10)),Integer.valueOf(df.substring(3,5)),Integer.valueOf(df.substring(0,2)),23,59,00);
            System.debug('di:'+dataInizio+' df:'+dataFine);
            User utente=[SELECT Id,Name,Reparto__c FROM User WHERE id=:UserInfo.getUserId()];
            System.debug('Reparto: '+utente.Reparto__c);
            vetture=new List<NE__Order__c>();
            if(!String.isBlank(utente.Reparto__c)) {
            	String query ='SELECT Id,Name,Data_Richiesta__c,Codice_Modello__c,Colore_Esterno__c,Colore_Interno__c,Targa__c,Modello__c,Km__c,Data_assegnazione_a_reparto__c FROM NE__Order__c WHERE NE__AccountId__c=\''+utente.Reparto__c+'\' AND Stato__c=\'170\' AND Flusso__c=\'Approvvigionamento\' AND Data_assegnazione_a_reparto__c<=:dataFine '+qtarga;
            	System.debug('QUERY: '+ query);
            	/*vetture=[SELECT Id,Name,Data_Richiesta__c,Codice_Modello__c,Colore_Esterno__c,Colore_Interno__c,Targa__c,Modello__c,Km__c,Data_assegnazione_a_reparto__c 
            			 FROM NE__Order__c 
            			 WHERE NE__AccountId__c=:utente.Reparto__c
            			 AND Stato__c='170'
            			 AND Flusso__c='Approvvigionamento'
            			 AND Data_assegnazione_a_reparto__c<=:dataFine]; */
            	vetture = Database.query(query);
            }
            else {
            	String query ='SELECT Id,Name,Data_Richiesta__c,Codice_Modello__c,Colore_Esterno__c,Colore_Interno__c,Targa__c,Modello__c,Km__c,Data_assegnazione_a_reparto__c FROM NE__Order__c WHERE Stato__c=\'170\' AND Flusso__c=\'Approvvigionamento\' AND Data_assegnazione_a_reparto__c<=:dataFine '+qtarga;
            	System.debug('QUERY: '+ query);
            	/*
            	vetture=[SELECT Id,Name,Data_Richiesta__c,Codice_Modello__c,Colore_Esterno__c,Colore_Interno__c,Targa__c,Modello__c,Km__c,Data_assegnazione_a_reparto__c 
            			 FROM NE__Order__c
            			 WHERE Stato__c='170'
            			 AND Flusso__c='Approvvigionamento'
            			 AND Data_assegnazione_a_reparto__c<=:dataFine];*/
    			 vetture = Database.query(query);
            }
            System.debug('assegnazioni: '+vetture);
            List<String> idVetture=new List<String>();
            for(NE__Order__c vettura:vetture)
                idVetture.add(vettura.Id);
            System.debug('Lista id Vetture: '+idVetture);
            //Map<Id,Vettura__c> cars=new Map<Id,Vettura__c>([SELECT Id,Name,Data_Richiesta__c,Codice_Modello__c,Colore_Esterno__c,Colore_Interno__c,Targa__c,Modello__c FROM Vettura__c WHERE Id in:idVetture]);
            avs=[SELECT NE__AccountId__c,NE__Parent_Order__c,AssegnazioneId__c, Luogo_consegna_stato_uso__c, AssegnazioneId__r.Fine_Assegnazione__c,AssegnazioneId__r.Inizio_Assegnazione__c,NE__AccountId__r.Name,Id,Name,Inizio_Assegnazione__c,Fine_Assegnazione__c,Tipo_Assegnatario__c,NE__Asset_Configuration__c,Targa__c,Modello__c,Manutenzione_straordinaria__c
                                                FROM NE__Order__c 
                                                WHERE NE__Parent_Order__c in:idVetture 
                                                AND Tipo_Assegnatario__c!='Reparto' 
                                                AND ((Inizio_Assegnazione__c>=:dataInizio AND Fine_Assegnazione__c<=:dataFine) OR (Inizio_Assegnazione__c<=:dataInizio AND Fine_Assegnazione__c>=:dataInizio) OR (Inizio_Assegnazione__c<=:dataFine AND Fine_Assegnazione__c>=:dataFine) OR (Inizio_Assegnazione__c<=:dataInizio AND Fine_Assegnazione__c>=:dataFine))
                                                AND Prenotata__c=false
                                                AND Stato__c!='1080'
                                                ORDER BY Modello__c];
                                                
            List<NE__Order__c> tutteAssegnazioni = [SELECT Fine_Assegnazione__c, Luogo_consegna_stato_uso__c, Tipo_Assegnatario__c,Stato__c,NE__Parent_Order__c FROM NE__Order__c WHERE (Stato__c =:'1050' OR Stato__c =:'1060' OR Stato__c =:'1055' OR Stato__c =:'1045' OR Stato__c =:'1030' OR Stato__c =:'1020' OR Stato__c =:'1070')  ORDER BY Fine_Assegnazione__c ASC];           
            Map<String,List<NE__Order__c>> mappa = new  Map<String,List<NE__Order__c>>();
            List<NE__Order__c> assegnazioniPerID = new List<NE__Order__c>();
            
            for (NE__Order__c o : tutteAssegnazioni) {
            	if (mappa.containsKey(o.NE__Parent_Order__c)) {
            		List<NE__Order__c> presenti = mappa.get(o.NE__Parent_Order__c);
            		presenti.add(o);
            		mappa.put(o.NE__Parent_Order__c,presenti);
            	} else {
            		List<NE__Order__c> daAggiungere = new List<NE__Order__c>();
            		daAggiungere.add(o);
            		mappa.put(o.NE__Parent_Order__c,daAggiungere);
            	}            	
            }
            			
            System.debug('Assegnazioni: '+avs);
            //for sulle auto assegnate a Account diversi da Reparto (avs)
            for(NE__Order__c car:vetture){
                Wrapper.Auto vettura=new Wrapper.Auto(car);
                DateTime giornataIn=dataInizio;
                DateTime giornataFi=dataInizio; 
                System.debug('Giornata corrente:'+giornataIn);
                //scorro tutti i giorni da data inizio a data fine
                List<Wrapper.Assegnazione> manutenzioneInAssegnazione=new List<Wrapper.Assegnazione>();
                List<NE__Order__c> assegn = mappa.get(car.Id);            
                while(giornataIn.date()<=dataFine.date()){
                    Wrapper.Assegnazione ass=new Wrapper.Assegnazione(giornataIn.date().format(),'Disponibile',null);
                    ass.statoColor='color-swatch-disp';
                    System.debug('GIORNATA IN: '+giornataIn);
                    ass.luogoConsegna = verificaStatoPrecedente(car.Id,giornataIn,assegn); 
                    System.debug('LUOGO CONSEGNA: '+ass.luogoConsegna);
                        //se è l'ultimo giorno aggiorno l'ora
                    if(car.Data_assegnazione_a_reparto__c.date()<=giornataIn.date()){
	                    for(NE__Order__c av:avs){
	                        if(giornataIn.date()==av.Fine_Assegnazione__c.date()){
	                            Time t=Time.newInstance(Integer.valueOf(df.substring(10,12)),Integer.valueOf(df.substring(13,15)),Integer.valueOf(df.substring(16,18)), 0);
	                            giornataFi=datetime.newInstance(giornataIn.date(),t);
	                            giornataFi=giornataFi.addHours(1); 
	                            System.debug('Time:'+t+' Giornata Fine:'+giornataFi);
	                        }
	                        System.debug('Data Inizio:'+av.Inizio_Assegnazione__c+' Data Fine:'+av.Fine_Assegnazione__c+' GiornataIn:'+giornataIn.date()+' GiornafaFi:'+giornataFi.date());
	                        
	                        if(av.NE__Parent_Order__c==car.Id && av.Inizio_Assegnazione__c.date()<=giornataIn.date() && av.Fine_Assegnazione__c.date()>=giornataFi.date()){
	                            ass.stato=av.Tipo_Assegnatario__c;
	                            ass.assegnatario=av.NE__AccountId__r.Name;
	                            ass.luogoConsegna = av.Luogo_consegna_stato_uso__c; //assegno luogo consegna
	                            if(av.Tipo_Assegnatario__c=='Manutentore'){
	                            	if(av.Manutenzione_straordinaria__c){
	                            		/*if(av.Fine_Assegnazione__c.date()>=giornataIn.date() && av.Inizio_Assegnazione__c.date()<=giornataFi.date()){*/
	                            			Wrapper.Assegnazione temp=new Wrapper.Assegnazione();
	                            			temp.giorno=giornataIn.date().format();
	                            			temp.assegnatario=av.NE__AccountId__r.Name;
	                            			temp.stato=av.Tipo_Assegnatario__c;
	                            			temp.statoColor='color-swatch-inman';
	                            			manutenzioneInAssegnazione.add(temp);
	                            		/*}else
	                                		ass.statoColor='color-swatch-inman';*/
	                            	}else
	                            		ass.statoColor='color-swatch-inman';
	                            }else{if(av.Tipo_Assegnatario__c=='Trasportatore')
	                            			ass.statoColor='color-swatch-tras';
	                            		else
	                                		ass.statoColor='color-swatch-ass';
	                            }
	                        }  
	                    }
                    }else{
                    	ass.statoColor='color-swatch-black';
                    	ass.stato='Non Assegnata A Reparto';
                    	ass.assegnatario=null;
                    	ass.luogoConsegna = null;
                    }
                    vettura.assegnazioni.add(ass);
                    giornataIn=giornataIn.addDays(1);
                    giornataFi=giornataFi.addDays(1);
                    System.debug('Assegnazioni auto temp:'+vettura.assegnazioni);
                    
                }
                System.debug('DateDoppie:'+manutenzioneInAssegnazione);
                for(Integer i=0;i<vettura.assegnazioni.size();i++)
                	for(Integer j=0;j<manutenzioneInAssegnazione.size();j++){
                		if(vettura.assegnazioni.get(i).giorno==manutenzioneInAssegnazione.get(j).giorno && vettura.assegnazioni.get(i).statoColor=='color-swatch-ass'){
                			manutenzioneInAssegnazione.get(j).statoColor='color-swatch-inass';
                			vettura.assegnazioni.set(i,manutenzioneInAssegnazione.get(j));
                		}
						if(vettura.assegnazioni.get(i).giorno==manutenzioneInAssegnazione.get(j).giorno && vettura.assegnazioni.get(i).statoColor=='color-swatch-disp')
                			vettura.assegnazioni.set(i,manutenzioneInAssegnazione.get(j));
                		
                	}
                System.debug('Assegnazioni Auto: '+vettura.assegnazioni);
                assegnazioni.add(vettura);
            }
            System.debug('Response:'+assegnazioni);
            return assegnazioni;
        }
        catch(Exception ecc){
            System.debug('Errore getAssegnazioni: '+ecc.getMessage()+ ' at line: '+ecc.getLineNumber()+' stack trace: '+ecc.getStackTraceString());
            GestioneLog.creaLog('Assegna','getAssegnazioniReparto',ecc.getLineNumber(),ecc.getMessage(),ecc.getStackTraceString(),ecc.getTypeName(),'INPUT -> di: '+di+' df: '+df,'vetture: '+vetture+' avs: '+avs,'assegnazioni: '+assegnazioni);
            return  null;
        }
    }
   
    /*GETDISPONIBILITAMANUTENZIONE*************************************************************************
        Metodo restituisce le date di disponibilita per una manutenzione
    ***********************************************************************************************/
    @RemoteAction
    global static List<Wrapper.Assegnazione> getDisponibilitaManutenzione (String targa){
    	List<Wrapper.Assegnazione> disponibilita;
    	List<NE__Order__c> assegnazioni;
    	try{
    		System.debug('Targa:'+targa);
    		disponibilita=new List<Wrapper.Assegnazione>();
    		Time t1=Time.newinstance(02,00,00,00);
    		Time t2=Time.newinstance(23,59,00,00);
    		DateTime dataInizio=DateTime.newInstance(date.today(),t1);
    		DateTime dataFine=DateTime.newInstance(date.today().addDays(30),t2);
    		System.debug('Data Inizio Ricerca:'+dataInizio+' Data Fine Ricerca:'+dataFine);
    		assegnazioni=[SELECT NE__AccountId__c,NE__Parent_Order__c,AssegnazioneId__c,AssegnazioneId__r.Fine_Assegnazione__c,AssegnazioneId__r.Inizio_Assegnazione__c,NE__AccountId__r.Name,Id,Name,Inizio_Assegnazione__c,Fine_Assegnazione__c,Tipo_Assegnatario__c,NE__Asset_Configuration__c,Targa__c,Modello__c
                                                FROM NE__Order__c 
                                                WHERE NE__Parent_Order__r.Targa__c=:targa 
                                                AND Tipo_Assegnatario__c!='Reparto' 
                                                AND ((Inizio_Assegnazione__c>=:dataInizio AND Fine_Assegnazione__c<=:dataFine) OR (Inizio_Assegnazione__c<=:dataInizio AND Fine_Assegnazione__c>=:dataInizio) OR (Inizio_Assegnazione__c<=:dataFine AND Fine_Assegnazione__c>=:dataFine) OR (Inizio_Assegnazione__c<=:dataInizio AND Fine_Assegnazione__c>=:dataFine))
                                                AND Prenotata__c=false
                                                AND Stato__c!='1080'];
            System.debug('Assegnazioni:'+assegnazioni);
            DateTime giornataIn=dataInizio;
            while(giornataIn.date()<=dataFine.date()){
            	Wrapper.Assegnazione ass=new Wrapper.Assegnazione(giornataIn.date().format(),'Disponibile',null);	
            	for(NE__Order__c av:assegnazioni){
            		System.debug('Ass:'+av);
            		if(av.Inizio_Assegnazione__c.date()<=giornataIn.date() && av.Fine_Assegnazione__c.date()>=giornataIn.date()){
            			System.debug('--->Occupato');
            			ass.stato='Occupata';
            			ass.assegnatario=av.NE__AccountId__r.Name;
            		}
            	}
            disponibilita.add(ass);
            giornataIn=giornataIn.addDays(1);
            }
    		return disponibilita;
    	}catch(Exception ecc){
            System.debug('Errore getDisponibilitaAssegnazione: '+ecc.getMessage()+ ' at line: '+ecc.getLineNumber()+' stack trace: '+ecc.getStackTraceString());
            GestioneLog.creaLog('Assegna','getDisponibilitaAssegnazione',ecc.getLineNumber(),ecc.getMessage(),ecc.getStackTraceString(),ecc.getTypeName(),'INPUT -> Targa: '+targa,'','');
            return  null;
        } 
    	
    }
    
    /*GETDISPONIBILITAMANUTENZIONE*************************************************************************
        Metodo restituisce le date di disponibilita per una manutenzione AGGIORNATO
    ***********************************************************************************************/
    @RemoteAction 
    global static List<String> getDisponibilitaManutenzioneAggiornato (String targa){
    	List<String> dateOccupate = new List<String>();
    	List<NE__Order__c> assegnazioni;
    	try{
    		assegnazioni = [SELECT NE__AccountId__c,NE__Parent_Order__c,AssegnazioneId__c,AssegnazioneId__r.Fine_Assegnazione__c,AssegnazioneId__r.Inizio_Assegnazione__c,NE__AccountId__r.Name,Id,Name,Inizio_Assegnazione__c,Fine_Assegnazione__c,Tipo_Assegnatario__c,NE__Asset_Configuration__c,Targa__c,Modello__c
                            FROM NE__Order__c 
                            WHERE NE__Parent_Order__r.Targa__c=:targa 
                            AND Tipo_Assegnatario__c!='Reparto'
                            AND Prenotata__c=false                            
                            AND Stato__c!='1080' ];
            for (NE__Order__c ass : assegnazioni) {
            	Datetime dataAssegnazione = ass.Inizio_Assegnazione__c;            	
            	while(dataAssegnazione.date() <= ass.Fine_Assegnazione__c.date()){
            		String dataStringa = String.valueOf(dataAssegnazione);            		
            		dataStringa = dataStringa.substring(8,10)+'/'+dataStringa.substring(5,7)+'/'+ dataStringa.substring(0,4);            		
            		dateOccupate.add(dataStringa);
            		dataAssegnazione = dataAssegnazione.addDays(1);             		
            	}
            } 
            System.debug('DATA OCCUPATE PER TARGA '+targa+' :'+dateOccupate);
            return dateOccupate;
    		
    	}catch(Exception ecc){
            System.debug('Errore getDisponibilitaAssegnazione: '+ecc.getMessage()+ ' at line: '+ecc.getLineNumber()+' stack trace: '+ecc.getStackTraceString());
            GestioneLog.creaLog('Assegna','getDisponibilitaAssegnazione',ecc.getLineNumber(),ecc.getMessage(),ecc.getStackTraceString(),ecc.getTypeName(),'INPUT -> Targa: '+targa,'','');
            return  null;
        }
    	
    }
    
    /*GETMACCHINEDISPONIBILI*************************************************************************
        Metodo per prendere lo stato di tutte le macchine assegnate ad un reparto(anche in base all'ora.minuti.secondi)
        formato date atteso gg/mm/aaaaoo:mm:ss
    ***********************************************************************************************/
    
        @RemoteAction
        global static List<Wrapper.Auto> getMacchineDisponibili(String di, String df){
        	List<Wrapper.Auto> assegnazioni;
        	List<NE__Order__c> vettureAssegnate;
        	List<NE__Order__c> vettureIndisponibili;
        	try{
	            assegnazioni=new List<Wrapper.Auto>();
	            System.debug('di: '+di+' df: '+df);
	            DateTime dataInizio=datetime.newInstance(Integer.valueOf(di.substring(6,10)),Integer.valueOf(di.substring(3,5)),Integer.valueOf(di.substring(0,2)),Integer.valueOf(di.substring(10,12)),Integer.valueOf(di.substring(13,15)),Integer.valueOf(di.substring(16,18)));
	            DateTime dataFine=datetime.newInstance(Integer.valueOf(df.substring(6,10)),Integer.valueOf(df.substring(3,5)),Integer.valueOf(df.substring(0,2)),Integer.valueOf(df.substring(10,12)),Integer.valueOf(df.substring(13,15)),Integer.valueOf(df.substring(16,18)));
	            System.debug('di:'+dataInizio+' df:'+dataFine);
	            User utente=[SELECT Id,Name,Reparto__c,ProfileId FROM User WHERE id=:UserInfo.getUserId()];
	            System.debug('Reparto: '+utente.Reparto__c);
	            
	            //Modifica F.P.
	            Boolean isAdmin = false;
	            List<Profile> profiliAmministratore = [SELECT Id,Name FROM Profile WHERE Name LIKE: Label.CCP_perc_adm];
	            for (Profile p : profiliAmministratore) {
	            	if (utente.ProfileId == p.Id) {
	            		isAdmin = true;
	            		break;
	            	}
	            }
	            
	            if (!isAdmin) {
	       
		             vettureAssegnate=[SELECT Derivative_description_Vista__c,Model_description_Vista__c,Model_code_Vista__c,Id,Name,Modello__c,Tipo_Assegnatario__c,Inizio_Assegnazione__c,Fine_Assegnazione__c,NE__AccountId__r.Name,Targa__c,Km__c 
		            									   FROM NE__Order__c
		            									   WHERE NE__AccountId__c=:utente.Reparto__c
		            									   AND Stato__c=:'170' 
		            									   AND Flusso__c=:'Approvvigionamento'
		            									   AND Data_assegnazione_a_reparto__c<=:dataInizio];	
	            } else {
	            	vettureAssegnate=[SELECT Derivative_description_Vista__c,Model_description_Vista__c,Model_code_Vista__c,Id,Name,Modello__c,Tipo_Assegnatario__c,Inizio_Assegnazione__c,Fine_Assegnazione__c,NE__AccountId__r.Name,Targa__c,Km__c 
		            									   FROM NE__Order__c
		            									   WHERE Stato__c=:'170' 
		            									   AND Flusso__c=:'Approvvigionamento'
		            									   AND Data_assegnazione_a_reparto__c<=:dataInizio];
	            }
	            System.debug('Assegnazioni: '+vettureAssegnate);
	            List<String> idAssegnate=new List<String>();
	            for(NE__Order__c vettura:vettureAssegnate)
	                idAssegnate.add(vettura.Id);
	            vettureIndisponibili=[SELECT NE__Parent_Order__c
	            										  FROM NE__Order__c
	            										  WHERE NE__Parent_Order__c in:idAssegnate
	            										  AND Tipo_Assegnatario__c!='Reparto' 
	            										  AND ((Inizio_Assegnazione__c>=:dataInizio AND Fine_Assegnazione__c<=:dataFine) OR (Inizio_Assegnazione__c<=:dataInizio AND Fine_Assegnazione__c>=:dataInizio) OR (Inizio_Assegnazione__c<=:dataFine AND Fine_Assegnazione__c>=:dataFine) OR (Inizio_Assegnazione__c<=:dataInizio AND Fine_Assegnazione__c>=:dataFine))
	            										  AND Prenotata__c=false
	            										  AND Stato__c!='1080'];
	            System.debug('Auto Indisponibili:'+vettureIndisponibili);
	            List<String> idIndisponibili=new List<String>();
	            for(NE__Order__c vettura:vettureIndisponibili)
	                idIndisponibili.add(vettura.NE__Parent_Order__c);
	            for(NE__Order__c va:vettureAssegnate){
	            	Boolean disp=true;
	            	for(NE__Order__c vi:vettureIndisponibili)
	            		if(va.Id==vi.NE__Parent_Order__c)
	                		disp=false;
	                if(disp){
	                	System.debug('Auto disponibile:'+va);
	                	Wrapper.Auto assegnazione=new Wrapper.Auto(va);
	                	assegnazioni.add(assegnazione);
	                }
        		}   	
				System.debug('Lista auto disponibili:'+assegnazioni);
	            return assegnazioni;
        	}
	        catch(Exception ecc){
	            System.debug('Errore getAssegnazioni: '+ecc.getMessage()+ ' at line: '+ecc.getLineNumber()+' stack trace: '+ecc.getStackTraceString());
	            GestioneLog.creaLog('Assegna','getMacchineDisponibili',ecc.getLineNumber(),ecc.getMessage(),ecc.getStackTraceString(),ecc.getTypeName(),'INPUT -> di: '+di+' df: '+df,'vettureAssegnate: '+vettureAssegnate+' vettureIndisponibili: '+vettureIndisponibili,'assegnazioni: '+assegnazioni);
	            return  null;
	        }
    	}
    /*GETLISTAAUTO*************************************************************************
        Metodo per avere una lista di tutte le auto
    ***********************************************************************************************/
    
        @RemoteAction
        global static List<NE__Order__c> getListaAuto(){
        	List<NE__Order__c> vettureAssegnate;
        	try{
        		User utente=[SELECT Id,Name,Reparto__c FROM User WHERE id=:UserInfo.getUserId()];
        		DateTime oggi=DateTime.now();
        		/*if(!String.isBlank(utente.Reparto__c)){
        			
        		}else{*/
        			vettureAssegnate=[SELECT Derivative_description_Vista__c,Model_description_Vista__c,Model_code_Vista__c,Id,Name,Modello__c,Tipo_Assegnatario__c,Inizio_Assegnazione__c,Fine_Assegnazione__c,NE__AccountId__r.Name,Targa__c 
	            									   FROM NE__Order__c
	            									   WHERE Stato__c=:'170' 
	            									   AND Flusso__c=:'Approvvigionamento'
	            									   AND NE__Parent_Order__c=:''
	            									   AND Data_assegnazione_a_reparto__c<=:oggi];
        		//}
        			
	            return vettureAssegnate;
        	}catch(Exception ecc){
	            System.debug('Errore getListaAuto: '+ecc.getMessage()+ ' at line: '+ecc.getLineNumber()+' stack trace: '+ecc.getStackTraceString());
	            GestioneLog.creaLog('Assegna','getListaAuto',ecc.getLineNumber(),ecc.getMessage(),ecc.getStackTraceString(),ecc.getTypeName(),'','','');
	            return  null;
	        }
        }
     /*GETDISPONIBILITAIMMEDIATA*************************************************************************
        metodo che data la targa dell'auto controlla se in questo preciso istante è disponibile o assegnata
    ***********************************************************************************************/
    
        @RemoteAction
        global static Boolean getDisponibilitaImmediata(String idVettura,String dat){
        	List<NE__Order__c> avs=new List<NE__Order__c>();
        	DateTime oggi;
        	try{
        	if(String.isBlank(dat))
        		oggi=DateTime.now();
        	else
        		oggi=DateTime.newInstance(Integer.valueOf(dat.substring(6,10)),Integer.valueOf(dat.substring(3,5)),Integer.valueOf(dat.substring(0,2)),23,00,00);
        	System.debug('Data attuale'+oggi);
        	avs=[SELECT NE__AccountId__c,NE__Parent_Order__c,AssegnazioneId__c,AssegnazioneId__r.Fine_Assegnazione__c,AssegnazioneId__r.Inizio_Assegnazione__c,NE__AccountId__r.Name,Id,Name,Inizio_Assegnazione__c,Fine_Assegnazione__c,Tipo_Assegnatario__c,NE__Asset_Configuration__c,Targa__c,Modello__c
                                                FROM NE__Order__c 
                                                WHERE NE__Parent_Order__c=:idVettura 
                                                AND Tipo_Assegnatario__c!='Reparto' 
                                                AND (Inizio_Assegnazione__c<=:oggi AND Fine_Assegnazione__c>=:oggi)
                                                AND Prenotata__c=false
                                                AND Stato__c!='1060'
                                                AND Stato__c !='1080'];
        	System.debug('Assegnazioni disponibilita immediata:'+avs);
        	if(avs.size()>0)
        		return false;
        	else 
        		return true;
        	}catch(Exception ecc){
	            System.debug('getDisponibilitaImmediata: '+ecc.getMessage()+ ' at line: '+ecc.getLineNumber()+' stack trace: '+ecc.getStackTraceString());
	            GestioneLog.creaLog('Assegna','getDisponibilitaImmediata',ecc.getLineNumber(),ecc.getMessage(),ecc.getStackTraceString(),ecc.getTypeName(),'INPUT -> idVettura: '+idVettura,'','');
	            return false;
	        }
        }	
        
        
    /*GETMACCHINEDISPONIBILI*************************************************************************************************
        Restituisce le macchine disponibli per le date inserite 
        FORMATO DATE gg/mm/aaaaoo:mm:ss
    ************************************************************************************************************************/
   /* @RemoteAction
    global static List<NE__Order__c> getMacchineDisponibili(String di, String df){
        try{
            List<Auto> macchine=getAssegnazioniReparto2(di,df);
            System.debug('Assegnazione a reparto:'+macchine);
            List<NE__Order__c> vetture=new List<NE__Order__c>();
            for(Auto macchina:macchine){
                Boolean disp=true;
                for(Assegnazione ass:macchina.assegnazioni){
                    //System.debug('macchina: '+macchina.macchina.Modello__c+' data: '+ass.giorno+' stato: '+ass.stato);
                    if(ass.stato!='Disponibile')
                        disp=false;
                }
                //System.debug('macchina: '+macchina.macchina.Modello__c+' disponibile: '+disp);
                if(disp)
                    vetture.add(macchina.macchina);
            }
            System.debug('macchine disponibili: '+vetture);
            return vetture;
        }
        catch(Exception ecc){
            System.debug('Errore getMacchineDisponibili: '+ecc.getMessage()+ ' at line: '+ecc.getLineNumber()+' stack trace: '+ecc.getStackTraceString());
            return null;
        }
    }
    */
    /*GETELENCOCLIENTI*************************************************************************************************
        Restituisce l'elenco dei clienti 
    ************************************************************************************************************************/
    @RemoteAction
	global static List<Account> getElencoClienti (String nome,String cognome,String codice,String partitaIVA,String azienda){
		List<Account> account;
		try{
			System.debug('Nome:'+nome+' Cognome:'+cognome+' Codice:'+codice+' PartitaIVA:'+partitaIVA+' Azienda:'+azienda);
			RecordType r=[SELECT Id FROM RecordType WHERE Name =:'Cliente'];
			String query='SELECT Id,Nome__c,Cognome__c,Codice_Fiscale__c,Data_di_Nascita__c,NE__Type__c,Partita_IVA__c,BillingCity,BillingCountry,BillingPostalCode,BillingState,BillingStreet,Nome_Azienda__c FROM Account WHERE RecordTypeId=\''+String.escapeSingleQuotes(r.Id)+'\' AND Name!=\'fakeaccount\'';
			if(!String.isBlank(nome))
				query=query+' AND Nome__c=\''+String.escapeSingleQuotes(nome)+'\'';	
			if(!String.isBlank(cognome))
				query=query+' AND Cognome__c=\''+String.escapeSingleQuotes(cognome)+'\'';
			if(!String.isBlank(codice))
				query=query+' AND Codice_Fiscale__c LIKE \'%'+String.escapeSingleQuotes(codice)+'%\' AND NE__Type__c=\'Privato\'';
			if(!String.isBlank(partitaIVA))
				query=query+' AND Partita_IVA__c LIKE \'%'+String.escapeSingleQuotes(partitaIVA)+'%\' AND NE__Type__c=\'Azienda\'';
			if(!String.isBlank(azienda))
				query=query+' AND Nome_Azienda__c LIKE \'%'+String.escapeSingleQuotes(azienda)+'%\'';
			System.debug('Query:'+query);
			account=new List<Account>();
			account=Database.query(query);
			System.debug('Risultato query:'+account);
			return account;							
		}catch(Exception ecc){
            System.debug('Elenco Clienti: '+ecc.getMessage()+ ' at line: '+ecc.getLineNumber()+' stack trace: '+ecc.getStackTraceString());
            GestioneLog.creaLog('Assegna','getElencoClienti',ecc.getLineNumber(),ecc.getMessage(),ecc.getStackTraceString(),ecc.getTypeName(),'INPUT -> Nome:'+nome+' Cognome:'+cognome+' Codice:'+codice+' PartitaIVA:'+partitaIVA,'account: '+account,'');
            return null;
        }
	}
    
     /*INSERTACCOUNT*************************************************************************************************
        Inserisce un cliente
    ************************************************************************************************************************/
    @RemoteAction
	global static String insertAccount(String acc){
		Account accou;
		try{
			System.debug('Stringa JSON:'+acc);
			accou=(Account)JSON.deserialize(acc,Account.Class);
			if(accou.NE__Type__c=='Azienda')
            {
				accou.Name=accou.Nome_Azienda__c;
            }

            else if(accou.NE__Type__c=='RAC')
            {
                accou.Name=accou.Nome_Azienda__c;
            }			

            else
            {
				accou.Name=accou.Nome__c+' '+accou.Cognome__c;
            }
			upsert accou;
            
			return String.valueOF(accou.Id);
		}catch(Exception ecc){
            System.debug('Elenco Clienti: '+ecc.getMessage()+ ' at line: '+ecc.getLineNumber()+' stack trace: '+ecc.getStackTraceString());
            GestioneLog.creaLog('Assegna','insertAccount',ecc.getLineNumber(),ecc.getMessage(),ecc.getStackTraceString(),ecc.getTypeName(),'INPUT -> acc: '+acc,'accou: '+accou,'');
            return null;
        }
	}
		
	/*GETACCOUNT*************************************************************************
        Metodo che restituisce i dati di un cliente
    ***********************************************************************************************/
    
        @RemoteAction
        global static Account getAccount(String diCliente){
	        Account acc;
	        try{  
		        System.debug('IdCLiente:'+diCliente);
		        acc=[SELECT Id,Name,Cognome__c,Nome__c,Data_di_Nascita__c,Provincia_di_Nascita__c,Comune_di_Nascita__c,
		        	 BillingCity,BillingCountry,BillingPostalCode,BillingState,BillingStreet,
		        	 Codice_Fiscale__c,Partita_IVA__c,Numero_Patente__c,Allegato_patente_id__c,Email__c,
		        	 Telefono__c,Tipo_Cliente_I_livello__c,Tipo_Cliente_II_livello__c,Tipologia_Cliente__c,Note__c,
		        	 Data_di_Nascita_text__c,Data_scadenza_patente_text__c,Nome_Azienda__c,Black_List__c
		        	 FROM Account
		        	 WHERE Id=:diCliente];
		        System.debug('Account:'+acc);
		       	return acc;
	        }
	        catch(Exception ecc){
	            System.debug('Elenco Clienti: '+ecc.getMessage()+ ' at line: '+ecc.getLineNumber()+' stack trace: '+ecc.getStackTraceString());
	            GestioneLog.creaLog('Assegna','getAccount',ecc.getLineNumber(),ecc.getMessage(),ecc.getStackTraceString(),ecc.getTypeName(),'INPUT -> idCliente: '+diCliente,'acc: '+acc,'');
	            return null;
	        }
        }

        @RemoteAction
        global static String insertSedeConsegna(String sc)
        {
            Sede_di_consegna__c sedeCons;
            try{
                System.debug('Stringa JSON:'+sc);
                sedeCons=(Sede_di_consegna__c)JSON.deserialize(sc,Sede_di_consegna__c.Class);
                
                    sedeCons.Name=sedeCons.name;
                
                upsert sedeCons;

                getSede(sedeCons.Id);
                System.debug('@@@@@sedeCons.Id: '+sedeCons.Id);
                System.debug('@@@@@getSede: '+getSede(sedeCons.Id));
                
                return String.valueOF(sedeCons.Id);
                }

                catch(Exception ecc)
                {
                        System.debug('Elenco Clienti: '+ecc.getMessage()+ ' at line: '+ecc.getLineNumber()+' stack trace: '+ecc.getStackTraceString());
                        GestioneLog.creaLog('Assegna','insertSedeConsegna',ecc.getLineNumber(),ecc.getMessage(),ecc.getStackTraceString(),ecc.getTypeName(),'INPUT -> Sede consegna: '+sc,'sedeCons: '+sedeCons,'');
                        return null;
                }
        }

        @RemoteAction
        global static Sede_di_consegna__c getSede(String id){
            Sede_di_consegna__c sede;             
                
                sede=[SELECT Cap__c,Citta__c,Cliente__c,Id,Indirizzo__c,Name,Provincia__c,Telefono__c FROM Sede_di_consegna__c WHERE Id =: Id];
                System.debug('sede: '+sede);
                return sede;    
        } 
        
        /*GETLISTAACCOUNT*************************************************************************
        Metodo che restituisce i la lista degli account
    ***********************************************************************************************/
    
        @RemoteAction
        global static List<Account> getListaAccount(){
        	List<Account> clienti;
        	try{
        		List<String> tr=new List<String>();
        		List<RecordType> tipiRecord=[SELECT Id,Name FROM RecordType WHERE Name = 'Cliente'];
        		for(RecordType r:tipiRecord)
        			tr.add(r.id);
        		clienti=[SELECT Id,Name,Cognome__c,Nome__c,Data_di_Nascita__c,Provincia_di_Nascita__c,Comune_di_Nascita__c,
		        	 BillingCity,BillingCountry,BillingPostalCode,BillingState,BillingStreet,
		        	 Codice_Fiscale__c,Partita_IVA__c,Numero_Patente__c,Allegato_patente_id__c,Email__c,
		        	 Telefono__c,Tipo_Cliente_I_livello__c,Tipo_Cliente_II_livello__c,Tipologia_Cliente__c,Note__c,
		        	 Data_di_Nascita_text__c,Data_scadenza_patente_text__c
		        	 FROM Account
		        	 WHERE RecordTypeId IN:tr AND Name!='fakeaccount' AND Black_List__c=:false];
		        return clienti;
        	}catch(Exception ecc){ 
	            System.debug('getListaAccount: '+ecc.getMessage()+ ' at line: '+ecc.getLineNumber()+' stack trace: '+ecc.getStackTraceString());
	            GestioneLog.creaLog('Assegna','getListaAccount',ecc.getLineNumber(),ecc.getMessage(),ecc.getStackTraceString(),ecc.getTypeName(),'','','');
	            return null;
	        }
        }
        
    /*GETLISTADEALER*************************************************************************
        Metodo che restituisce la lista dei Delaer
    ***********************************************************************************************/
    
        @RemoteAction
        global static List<Account> getListaDealer(){
        	List<Account> clienti;
        	try{
        		List<String> tr=new List<String>();
        		List<RecordType> tipiRecord=[SELECT Id,Name FROM RecordType WHERE Name = 'Manutentore'];
        		for(RecordType r:tipiRecord)
        			tr.add(r.id);
        		clienti=[SELECT Id,Name,Cognome__c,Nome__c,Data_di_Nascita__c,Provincia_di_Nascita__c,Comune_di_Nascita__c,
		        	 BillingCity,BillingCountry,BillingPostalCode,BillingState,BillingStreet,
		        	 Codice_Fiscale__c,Partita_IVA__c,Numero_Patente__c,Allegato_patente_id__c,Email__c,
		        	 Telefono__c,Tipo_Cliente_I_livello__c,Tipo_Cliente_II_livello__c,Tipologia_Cliente__c,Note__c,
		        	 Data_di_Nascita_text__c,Data_scadenza_patente_text__c
		        	 FROM Account
		        	 WHERE RecordTypeId IN:tr AND Name!='fakeaccount'];
		        return clienti;
        	}catch(Exception ecc){
	            System.debug('getListaDealer: '+ecc.getMessage()+ ' at line: '+ecc.getLineNumber()+' stack trace: '+ecc.getStackTraceString());
	            GestioneLog.creaLog('Assegna','getListaDealer',ecc.getLineNumber(),ecc.getMessage(),ecc.getStackTraceString(),ecc.getTypeName(),'','','');
	            return null;
	        }
        }
        
        /*GETLISTATRASPORTATORI*************************************************************************
        Metodo che restituisce la lista dei Trasportatori
    ***********************************************************************************************/
    
        @RemoteAction
        global static List<Account> getListaTrasportatori(){
        	List<Account> clienti;
        	try{
        		List<String> tr=new List<String>();
        		List<RecordType> tipiRecord=[SELECT Id,Name FROM RecordType WHERE Name = 'Trasportatore'];
        		for(RecordType r:tipiRecord)
        			tr.add(r.id);
        		clienti=[SELECT Id,Name,Cognome__c,Nome__c,Data_di_Nascita__c,Provincia_di_Nascita__c,Comune_di_Nascita__c,
		        	 BillingCity,BillingCountry,BillingPostalCode,BillingState,BillingStreet,
		        	 Codice_Fiscale__c,Partita_IVA__c,Numero_Patente__c,Allegato_patente_id__c,Email__c,
		        	 Telefono__c,Tipo_Cliente_I_livello__c,Tipo_Cliente_II_livello__c,Tipologia_Cliente__c,Note__c,
		        	 Data_di_Nascita_text__c,Data_scadenza_patente_text__c
		        	 FROM Account
		        	 WHERE RecordTypeId IN:tr AND Name!='fakeaccount'];
		        return clienti;
        	}catch(Exception ecc){
	            System.debug('getListaTrasportatori: '+ecc.getMessage()+ ' at line: '+ecc.getLineNumber()+' stack trace: '+ecc.getStackTraceString());
	            GestioneLog.creaLog('Assegna','getListaTrasportatori',ecc.getLineNumber(),ecc.getMessage(),ecc.getStackTraceString(),ecc.getTypeName(),'','','');
	            return null;
	        }
        }
        
         /*GETLISTAVERIFICATORI*************************************************************************
        	Metodo che restituisce la lista dei Verificatori per chiudere lo stato d'uso
    	***********************************************************************************************/
    
       @RemoteAction
        global static List<User> getListaVerificatori(){
        	List<User> verificatori;
        	try{
        		Profile profilo=[SELECT Id FROM Profile WHERE Name=:Label.CCP_VerifierProfile];
        		System.debug('Profilo:'+profilo);
        		verificatori=[SELECT Id,Name FROM User WHERE ProfileId=:profilo.Id];
        		System.debug('Lista Verificatori:'+verificatori);
        		return verificatori;
        	}catch(Exception ecc){
	            System.debug('getListaVerificatori: '+ecc.getMessage()+ ' at line: '+ecc.getLineNumber()+' stack trace: '+ecc.getStackTraceString());
	            GestioneLog.creaLog('Assegna','getListaVerificatori',ecc.getLineNumber(),ecc.getMessage(),ecc.getStackTraceString(),ecc.getTypeName(),'','','VERIFICATORI:'+verificatori);
	            return null;
	        }
        }
        
    /*INSERTASSEGNAZIONE*************************************************************************
        Metodo che crea una nuova richiesta di assegnazione
    ***********************************************************************************************/
    
        @RemoteAction
        global static String insertAssegnazione(String idAccount,String idMacchina,String datain,String orain,String dataf,String oraf,String finalita,String descrizione, String luogo, String mese, String rata){
	        try{
	        	System.debug('IdAccount:'+idAccount+' idMacchina:'+idMacchina+' datain:'+datain+' orain:'+orain+' dataf:'+dataf+'oraf:'+oraf);
	        	NE__Order__c macchina=[SELECT targa__c,Modello__c,Marca__c,NE__ServAccId__c FROM NE__Order__c WHERE id=:idMacchina];
	        	NE__Order__c assegnazione=new NE__Order__c();
	        	String tipoRecord=String.valueOf(Schema.SObjectType.NE__Order__c.RecordTypeInfosByName.get('Assegnazione').RecordTypeId);
	        	assegnazione.NE__AccountId__c=idAccount;
	        	assegnazione.NE__Parent_Order__c=idMacchina;
	        	assegnazione.RecordTypeId=tipoRecord;
	        	if(!String.isBlank(finalita)) {
	        		assegnazione.Finalita_uso_assegnazione__c=finalita;
	        		if (finalita.equals('Assegnazione Lease Car')) {
	        			assegnazione.MeseAssegnazioneLeaseCar__c = mese;
	        			assegnazione.RataLeaseCar__c = Decimal.valueOf(rata);
	        		}
	        	}   		
	        		
	        	if(!String.isBlank(descrizione))
	        		assegnazione.Descrizione_assegnazione__c=descrizione;
	        	assegnazione.Modello__c=macchina.Modello__c;
	        	assegnazione.Marca__c=macchina.Marca__c;
	        	assegnazione.Flusso__c='Assegnazione';
	        	assegnazione.Inizio_Assegnazione__c=DateTime.newInstance(Integer.valueOf(datain.substring(6,10)),Integer.valueOf(datain.substring(3,5)),Integer.valueOf(datain.substring(0,2)),Integer.valueOf(orain.substring(0,2)),Integer.valueOf(orain.substring(3,5)),Integer.valueOf(orain.substring(6,8)));
	        	assegnazione.Fine_Assegnazione__c=DateTime.newInstance(Integer.valueOf(dataf.substring(6,10)),Integer.valueOf(dataf.substring(3,5)),Integer.valueOf(dataf.substring(0,2)),Integer.valueOf(oraf.substring(0,2)),Integer.valueOf(oraf.substring(3,5)),Integer.valueOf(oraf.substring(6,8)));
	        	assegnazione.Tipo_assegnazione__c=Label.CCP_handling_assignment;
	        	assegnazione.Luogo_consegna_stato_uso__c = luogo;
	        	//assegnazione.Richiesta_Fine_Assegnazione__c=DateTime.newInstance(Integer.valueOf(dataf.substring(6,10)),Integer.valueOf(dataf.substring(3,5)),Integer.valueOf(dataf.substring(0,2)),Integer.valueOf(oraf.substring(0,2)),Integer.valueOf(oraf.substring(3,5)),Integer.valueOf(oraf.substring(6,8)));
	        	//assegnazione.Richiesta_Inizio_Assegnazione__c=DateTime.newInstance(Integer.valueOf(datain.substring(6,10)),Integer.valueOf(datain.substring(3,5)),Integer.valueOf(datain.substring(0,2)),Integer.valueOf(orain.substring(0,2)),Integer.valueOf(orain.substring(3,5)),Integer.valueOf(orain.substring(6,8)));
	        	assegnazione.Stato__c='1010';    
	        	     	
	        	insert assegnazione;
	        	macchina.NE__ServAccId__c=idAccount;
	        	update macchina;
	        	System.debug('Assegnazione:'+assegnazione);
	        	Boolean risultatoProcesso=Approvazione.avviaProcess(assegnazione.Id);
				System.debug('Processo Approvazione:'+risultatoProcesso);
	        	return assegnazione.Id;
	        }catch(Exception ecc){
	            System.debug('insertAssegnazione: '+ecc.getMessage()+ ' at line: '+ecc.getLineNumber()+' stack trace: '+ecc.getStackTraceString());
	            GestioneLog.creaLog('Assegna','insertAssegnazione',ecc.getLineNumber(),ecc.getMessage(),ecc.getStackTraceString(),ecc.getTypeName(),'INPUT -> idAccount: '+idAccount+' idMacchina:'+idMacchina,'INPUT -> datain:'+datain+' orain:'+orain+' dataf:'+dataf+' oraf:'+oraf,'');
	            return null;
	        }
        }
        
        /*INSERTMANUTENZIONE*************************************************************************
        	Metodo che crea una nuova richiesta di manutenzione
    	***********************************************************************************************/
    
        @RemoteAction
        global static String insertManutenzione(String idAccount,String idMacchina,String idAssegnazione,String datain,String orain,String dataf,String oraf,Boolean straordinaria){
	        try{
	        	System.debug('IdAccount:'+idAccount+' idMacchina:'+idMacchina+' datain:'+datain+' orain:'+orain+' dataf:'+dataf+'oraf:'+oraf);
	        	NE__Order__c macchina=[SELECT targa__c,Modello__c,Marca__c,NE__ServAccId__c FROM NE__Order__c WHERE id=:idMacchina];
	        	NE__Order__c manutenzione=new NE__Order__c();
	        	String tipoRecord=String.valueOf(Schema.SObjectType.NE__Order__c.RecordTypeInfosByName.get('Assegnazione').RecordTypeId);
	        	manutenzione.NE__AccountId__c=idAccount;		//Manutentore
	        	manutenzione.NE__Parent_Order__c=idMacchina;	//Macchina
	        	//manutenzione.AssegnazioneId__c=idAssegnazione;	//Assegnazione(in caso di manutenzione durante periodo di assegnazione)
	        	//nel caso di manutenzione durante la vendita idAssegnazione sarà diverso da null
	        	if(!idAssegnazione.equals('')){
	        		manutenzione.Flusso__c='Vendite';
	        	}
	        	else{manutenzione.Flusso__c='Assegnazione';}
	        	manutenzione.Modello__c=macchina.Modello__c;
	        	manutenzione.Manutenzione_straordinaria__c=straordinaria;
	        	manutenzione.RecordTypeId=tipoRecord;
	        	manutenzione.Inizio_Assegnazione__c=DateTime.newInstance(Integer.valueOf(datain.substring(6,10)),Integer.valueOf(datain.substring(3,5)),Integer.valueOf(datain.substring(0,2)),Integer.valueOf(orain.substring(0,2)),Integer.valueOf(orain.substring(3,5)),Integer.valueOf(orain.substring(6,8)));
	        	manutenzione.Fine_Assegnazione__c=DateTime.newInstance(Integer.valueOf(dataf.substring(6,10)),Integer.valueOf(dataf.substring(3,5)),Integer.valueOf(dataf.substring(0,2)),Integer.valueOf(oraf.substring(0,2)),Integer.valueOf(oraf.substring(3,5)),Integer.valueOf(oraf.substring(6,8)));
	        	
	        	manutenzione.Stato__c='1070';
	        	manutenzione.Tipo_assegnazione__c=Label.CCP_maintenance_assignment;
	        	manutenzione.manutenzioneRichiestaDaPortale__c = true;
	        	System.debug('RECORD MANUTENZIONE:'+manutenzione);
	        	insert manutenzione;	        	
	        	return manutenzione.Id;
	        }catch(Exception ecc){
	            System.debug('insertManutenzione: '+ecc.getMessage()+ ' at line: '+ecc.getLineNumber()+' stack trace: '+ecc.getStackTraceString());
	            GestioneLog.creaLog('Assegna','insertManutenzione',ecc.getLineNumber(),ecc.getMessage(),ecc.getStackTraceString(),ecc.getTypeName(),'INPUT -> idAccount: '+idAccount+' idMacchina:'+idMacchina+' idAssegnazioe:'+idAssegnazione,'INPUT -> datain:'+datain+' orain:'+orain+' dataf:'+dataf+' oraf:'+oraf,'');
	            return null;
	        }
        }        

        /*INSERTSTAZIONAMENTO*************************************************************************
        Metodo che crea una nuova richiesta di assegnazione per Trasporto/Stazinamento
    	***********************************************************************************************/
    
        @RemoteAction
        global static String insertStazionamento(String idCliente,String idMacchina,String jsonStazionamento){
	        try{
	        	System.debug('IdAccount:'+idCliente+' idMacchina:'+idMacchina+' jsonTrasporto:'+jsonStazionamento);
	        	NE__Order__c macchina=[SELECT targa__c,Modello__c,Marca__c,NE__ServAccId__c FROM NE__Order__c WHERE id=:idMacchina];
	        	NE__Order__c assegnazione=(NE__Order__c)JSON.deserialize(jsonStazionamento,NE__Order__c.class);
	        	String tipoRecord=String.valueOf(Schema.SObjectType.NE__Order__c.RecordTypeInfosByName.get('Assegnazione').RecordTypeId);
	        	assegnazione.NE__AccountId__c=idCliente;
	        	assegnazione.NE__Parent_Order__c=idMacchina;
	        	assegnazione.RecordTypeId=tipoRecord;
	        	assegnazione.Modello__c=macchina.Modello__c;
	        	assegnazione.Marca__c=macchina.Marca__c;
	        	assegnazione.Flusso__c='Assegnazione';
	        	assegnazione.Tipo_assegnazione__c=Label.CCP_parking_assignment;
	        	assegnazione.Stato__c='1030'; 	
	        	//inserisco lo stesso valore di luogo trasporto in luogo consegna
	        	assegnazione.Luogo_consegna_stato_uso__c = assegnazione.Luogo_trasporto_stazionamento__c;
	        	insert assegnazione;
	        	macchina.NE__ServAccId__c=idCliente;
	        	update macchina;
	        	System.debug('Assegnazione per Stazionamento:'+assegnazione);
	        	return assegnazione.Id;
	        }catch(Exception ecc){
	            System.debug('insertStazionamento: '+ecc.getMessage()+ ' at line: '+ecc.getLineNumber()+' stack trace: '+ecc.getStackTraceString());
	            GestioneLog.creaLog('Assegna','insertStazionamento',ecc.getLineNumber(),ecc.getMessage(),ecc.getStackTraceString(),ecc.getTypeName(),'INPUT -> idCliente: '+idCliente+' idMacchina:'+idMacchina+' jsonStazionamento:'+jsonStazionamento,'','');
	            return null;
	        }
        }
        /*INSERTTRASPORTO*************************************************************************
        Metodo che crea una nuova richiesta di assegnazione per Trasporto/Stazinamento
    	***********************************************************************************************/
    
        @RemoteAction
        global static String insertTrasporto(String idTrasportatore,String idMacchina,String jsonTrasporto){
	        try{
	        	System.debug('IdAccount:'+idTrasportatore+' idMacchina:'+idMacchina+' jsonTrasporto:'+jsonTrasporto);
	        	NE__Order__c macchina=[SELECT targa__c,Modello__c,Marca__c,NE__ServAccId__c FROM NE__Order__c WHERE id=:idMacchina];
	        	NE__Order__c assegnazione=(NE__Order__c)JSON.deserialize(jsonTrasporto,NE__Order__c.class);
	        	String tipoRecord=String.valueOf(Schema.SObjectType.NE__Order__c.RecordTypeInfosByName.get('Assegnazione').RecordTypeId);
	        	assegnazione.NE__AccountId__c=idTrasportatore;
	        	assegnazione.NE__Parent_Order__c=idMacchina;
	        	assegnazione.RecordTypeId=tipoRecord;
	        	assegnazione.Modello__c=macchina.Modello__c;
	        	assegnazione.Marca__c=macchina.Marca__c;
	        	assegnazione.Flusso__c='Assegnazione';
	        	assegnazione.Tipo_assegnazione__c=Label.CCP_transfer_assignment;
	        	assegnazione.Stato__c='1030'; 
	        	//inserisco lo stesso valore di luogo trasporto in luogo consegna
	        	assegnazione.Luogo_consegna_stato_uso__c = assegnazione.Luogo_trasporto_stazionamento__c;
	        	insert assegnazione;
	        	macchina.NE__ServAccId__c=idTrasportatore;
	        	update macchina;
	        	System.debug('Assegnazione per Trasporto:'+assegnazione);
	        	return assegnazione.Id;
	        }catch(Exception ecc){
	            System.debug('insertTrasporto: '+ecc.getMessage()+ ' at line: '+ecc.getLineNumber()+' stack trace: '+ecc.getStackTraceString());
	            GestioneLog.creaLog('Assegna','insertTrasporto',ecc.getLineNumber(),ecc.getMessage(),ecc.getStackTraceString(),ecc.getTypeName(),'INPUT -> idTrasportatore: '+idTrasportatore+' idMacchina:'+idMacchina,'INPUT -> jsonTrasporto:'+jsonTrasporto,'');
	            return null;
	        }
        }
        
         /*ASSEGNATRASPORTATORE*************************************************************************
        Metodo che assegna una vettura a Trasporto/Stazinamento
    	***********************************************************************************************/
    
        @RemoteAction
        global static Boolean assegnaTrasportatore(String jsonTrasporto){
	        try{
	        	NE__Order__c assegnazione=(NE__Order__c)JSON.deserialize(jsonTrasporto,NE__Order__c.class);
	        	assegnazione.Stato__c='1060';
	        	update assegnazione;
	        	return true;
	        }catch(Exception ecc){
	            System.debug('assegnaTrasportatore: '+ecc.getMessage()+ ' at line: '+ecc.getLineNumber()+' stack trace: '+ecc.getStackTraceString());
	            GestioneLog.creaLog('Assegna','assegnaTrasportatore',ecc.getLineNumber(),ecc.getMessage(),ecc.getStackTraceString(),ecc.getTypeName(),'INPUT -> jsonTrasporto: '+jsonTrasporto,'','');
	            return false;
	        }
        }
        
        
        /*RESTITUITAMANUTENZIONE*************************************************************************
        	Metodo che passa una manutenzione da In Manutenzione a Rientrata
        	OK:se chiusura andata a buon fine;
			Messaggio: se chiusura non può essere effettuata;
			KO: se c'è stato qualche errore;
    	***********************************************************************************************/
        @RemoteAction
        global static String restituitaManutenzione(String idManutenzione){
	        Savepoint sp;
	        try{
	        	sp=Database.setSavepoint();
	        	NE__Order__c manutenzione=[SELECT Id,Stato__c,Fine_Assegnazione__c/*,NE__Parent_Order__c,Km_uscita__c*/ FROM NE__Order__c WHERE id=:idManutenzione];
	        	String response=Assegna.verificaFineAssegnazione(manutenzione.Id);
	        	if(response=='OK'){
	        		manutenzione.Stato__c='1060';
	        		update manutenzione;
	        		return 'OK';
	        	}else
	        		return 'La Manutenzione non può essere chiusa, chiudere in ordine le seguenti Movimentazioni/Manutenzioni:\n'+response;
	        }catch(Exception ecc){
	        	Database.rollback(sp);
	            System.debug('restituitaManutenzione: '+ecc.getMessage()+ ' at line: '+ecc.getLineNumber()+' stack trace: '+ecc.getStackTraceString());
	            GestioneLog.creaLog('Assegna','restituitaManutenzione',ecc.getLineNumber(),ecc.getMessage(),ecc.getStackTraceString(),ecc.getTypeName(),'INPUT -> idManutenzione: '+idManutenzione,'','');
	            return 'KO';
	        }
        }
    /*GETASSEGNAZIONEBYNUMORDINE*************************************************************************
        Metodo che restituisce i dati di una vettura assegnata	
    ***********************************************************************************************/
    
        @RemoteAction
        global static Wrapper.Auto getAssegnazioneByNumOrdine(String idAssegnazione){
	       NE__Order__c assegnazione;
	       Wrapper.Auto vettura;	
	        try{
	       		/*DATI ASSEGNAZIONE*/	
	        	assegnazione=[SELECT Anno_Infocar__c,Antifurto__c,Car_full_service__c,
								Causale_Annullamento__c,Cavalli_Fiscali__c,Codice_Colore_Esterno__c,
								Codice_Colore_Interno__c,Codice_Infocar__c,Codice_Marca_Casa__c,
								Codice_Marca__c,Codice_Modello_Casa__c,Codice_Modello__c,
								Codice_Versione_Casa__c,Codice_Versione_Infocar__c,Colore_Esterno__c,
								Colore_Interno__c,Data_Creazione_Contratto__c,
								Data_Creazione_Preventivo__c,Data_Immatricolazione__c,Data_Ordine__c,
								Data_Prova__c,Data_Ultima_Modifica_Contratto__c,
								Data_Ultima_modifica_Preventivo__c,Extended_Warranty__c,Finalita_uso__c,Id,Id_Antifurto__c,
								Id_salespro__c,Id_Sede__c,Id_Venditore__c,IVA__c,KW__c,Marca__c,
								Mese_Infocar__c,Modello__c,Name,Nome_Sede__c,Numero_carta_circolazione__c,
								Numero_Contratto__c,Numero_Ordine__c,Numero_Preventivo__c,
								Prezzo_altre_spese__c,Prezzo_antifurto__c,Prezzo_car_full_service__c,
								Prezzo_di_vendita__c,Prezzo_extended_warranty__c,Prezzo_IPT__c,
								Prezzo_messa_su_strada__c,Prezzo_preparazione_veicolo__c,Stringa_data_immatricolazione__c,
								Prezzo_spese_gestione_usato__c,Richiesta_Casa_Madre__c,Stato_Vista__c,String_data_assegnazione_a_reparto__c,
								Stato__c,NE__Parent_Order__r.Targa__c,NE__Parent_Order__r.Km__c,Telaio__c,Id_Vista__c,Common_status_point_desc_vista__c,Prezzo_acquisto_auto__c,
								Allegato_assegnazione_reparto_id__c,Allegato_COC_id__c,Allegato_foto_auto_id__c,Allegato_istanza_id__c,Allegato_libretto_di_circolazione_id__c,
								Numero_preventivo_pre_tagliando__c,costo_pre_tagliando__c,Descrizione_pre_tagliando__c,Stringa_data_ass_rep__c,Data_assegnazione_a_reparto__c,Approvazione_Direttore__c,
								Allegato_tagliando_assicurazione__c,Allegato_tagliando_assicurazione_id__c,NE__AccountId__r.Name,NE__AccountId__c,Targa_Auto_Sostitutiva__c,Stringa_Inizio_Assegnazione__c,
								Stringa_Fine_Assegnazione__c,Inizio_Assegnazione__c,Fine_Assegnazione__c,NE__Parent_Order__c,Allegato_comodato_id__c,
								Luogo_consegna_stato_uso__c,Km__c,Finalita_uso_assegnazione__c,Descrizione_assegnazione__c,Approvatore_assegnazione__c,Data_approvazione_assegnazine__c,
								Job_title_approvatore__c,UrlFirma_Approvatore__c,Km_Fine_Assegnazione__c,Km_Inizio_Assegnzione__c,
								Luogo_trasporto_stazionamento__c,Costo_trasporto__c,Tipo_assegnazione__c,Note_trasporto_stazionamento__c,Allegato_documentazione_trasporto__c,
								Allegato_documentazione_trasporto_id__c,Verificatore_di_turno_nome__c,Verificatore_di_turno__c,MeseAssegnazioneLeaseCar__c,RataLeaseCar__c,
								Allegato_bolla_trasporto_andata__c,	 Allegato_bolla_di_trasporto_ritorno__c,Allegato_bolla_trasporto_andata_id__c,Allegato_bolla_di_trasporto_ritorno_id__c
								 FROM NE__Order__c 
								 WHERE Id=:idAssegnazione];
				//System.debug('Numero Ordine:'+idOrdine);
				vettura=new Wrapper.Auto(assegnazione);
				vettura.accessori=[SELECT Id_accessorio__c,Codice_accessorio__c,Codice_Infocar__c,Codice_Tipo__c,
									   Descrizione__c,Id,Name,Prezzo__c,Sconto__c,Tipo__c,NE__Order_Item__c,
									   Accessorio__c,Optional__c
									FROM NE__Order_Item_Attribute__c
									WHERE NE__Order_Item__r.NE__OrderId__c=:assegnazione.Id];
			
			/*LISTA CAMBIAMENTO STATI */
			List<NE__Order__History> dataCambiamentoStato=[SELECT CreatedDate,NewValue 
														  FROM NE__Order__History
														  WHERE ParentId=:assegnazione.Id AND Field=:'Stato__c' ORDER BY CreatedDate];
			System.debug('Date modifica stato:'+dataCambiamentoStato);
			for(NE__Order__History dat:dataCambiamentoStato){
				String dataFormatoStringa=String.valueOf(dat.CreatedDate).substring(8,10)+'/'+String.valueOf(dat.CreatedDate).substring(5,7)+'/'+String.valueOf(dat.CreatedDate).substring(0,4);
				vettura.listaCambiamentoStati.add(new Wrapper.Stati(String.valueOf(dat.NewValue),dataFormatoStringa));
			}
			System.debug('Wrapper Stati:'+vettura.listaCambiamentoStati);
			
			/*ALLEGATI ASSEGNAZIONE*/
			List<Attachment> file=[SELECT Id,Name FROM Attachment WHERE ParentId=:idAssegnazione];
			List<String> idFoto=new List<String>();
			
			if(!String.isBlank(assegnazione.Allegato_foto_auto_id__c)){
				idFoto=assegnazione.Allegato_foto_auto_id__c.split('-',0);
				System.debug('Allegato foto id:'+assegnazione.Allegato_foto_auto_id__c);
			}
			for(Attachment att: file){
				Wrapper.AttachementFile singoloFile=new Wrapper.AttachementFile();
				singoloFile.Name=att.Name;
				singoloFile.Id=att.Id;
				if(att.Id==assegnazione.Allegato_comodato_id__c)
					singoloFile.tipo='comodato';
				if(att.Id==assegnazione.Allegato_documentazione_trasporto_id__c)
					singoloFile.tipo='documento trasporto';
				if(att.Id==assegnazione.Allegato_bolla_trasporto_andata_id__c)
					singoloFile.tipo='bolla trasporto andata';
				if(att.Id==assegnazione.Allegato_bolla_di_trasporto_ritorno_id__c)
					singoloFile.tipo='bolla trasporto ritorno';
				for(Integer i=0;i<idFoto.size();i++){
					System.debug('IdFoto:'+idFoto.get(i));
					if(idFoto.get(i)==att.Id)
						singoloFile.tipo='foto';
				}
				vettura.file.add(singoloFile);
			}
			System.debug('Vettura:'+vettura);
			return vettura;
	        }catch(Exception ecc){
	            System.debug('getAssegnazioneByNumOrdine: '+ecc.getMessage()+ ' at line: '+ecc.getLineNumber()+' stack trace: '+ecc.getStackTraceString());
	            GestioneLog.creaLog('Assegna','getAssegnazioneByNumOrdine',ecc.getLineNumber(),ecc.getMessage(),ecc.getStackTraceString(),ecc.getTypeName(),'INPUT -> idAccount: '+idAssegnazione,'','');
	            return null;
	        }
        }
        
      /*AGGIORNAAPPROVATORE*************************************************************************
        Metodo che aggiorna i campi dell'approvatore in pool	
      ***********************************************************************************************/
    
        @RemoteAction
        global static Boolean aggiornaApprovatore(String idAssegnazione){
        	try{
        		NE__Order__c assegnazione=[SELECT Approvatore_assegnazione__c,Data_approvazione_assegnazine__c,
        									Job_title_approvatore__c,UrlFirma_Approvatore__c
        									FROM NE__Order__c
        									WHERE Id=:idAssegnazione];
				ProcessInstance pi=[SELECT LastModifiedById,LastModifiedDate FROM ProcessInstance WHERE TargetObjectId =:idAssegnazione];
				User approvatore=[SELECT Name,Job_Title__c,UrlFirma__c FROM User WHERE Id =:pi.LastModifiedById];
				assegnazione.Approvatore_assegnazione__c=approvatore.Name;
				assegnazione.Data_approvazione_assegnazine__c=pi.LastModifiedDate.Date();
				assegnazione.Job_title_approvatore__c=approvatore.Job_Title__c;
				assegnazione.UrlFirma_Approvatore__c=approvatore.UrlFirma__c;
				update assegnazione;
				return true;
        	}catch(Exception ecc){
	            System.debug('aggiornaApprovatore: '+ecc.getMessage()+ ' at line: '+ecc.getLineNumber()+' stack trace: '+ecc.getStackTraceString());
	            GestioneLog.creaLog('Assegna','aggiornaApprovatore',ecc.getLineNumber(),ecc.getMessage(),ecc.getStackTraceString(),ecc.getTypeName(),'','','');
	            return false;
	        }
        }
        
      /*GETMANUTENZIONEBYNUMORDINE*************************************************************************
        Metodo che restituisce i dettagli della manutenzione	
      ***********************************************************************************************/
    
        @RemoteAction
        global static Wrapper.Auto getManutenzioneByNumOrdine(String idManutenzione){
        	Wrapper.Auto manutenzione;
        	try{
        		System.debug('Id Manutenzione:'+idManutenzione);
        		NE__Order__c m=[SELECT Inizio_Assegnazione__c,Fine_Assegnazione__c,NE__Parent_Order__r.Targa__c,NE__Parent_Order__r.Modello__c,
        									NE__Parent_Order__r.Marca__c,NE__AccountId__r.Name,Data_fattura__c,Numero_fattura__c,Allegato_foto_auto_id__c,Stato__c,NE__Parent_Order__r.Km__c,Km_Fine_Assegnazione__c,Km_Inizio_Assegnzione__c,Id 
        									FROM NE__Order__c WHERE id=:idManutenzione];
        		System.debug('Manutenzione:'+m);
        	manutenzione=new Wrapper.Auto(m);
        	List<Attachment> file=[SELECT Id,Name FROM Attachment WHERE ParentId=:idManutenzione];
			List<String> idFoto=new List<String>();
			if(!String.isBlank(m.Allegato_foto_auto_id__c))
				idFoto=m.Allegato_foto_auto_id__c.split('-',0);
			for(Attachment att: file){
				Wrapper.AttachementFile singoloFile=new Wrapper.AttachementFile();
				for(Integer i=0;i<idFoto.size();i++){
					System.debug('IdFoto:'+idFoto.get(i));
					if(idFoto.get(i)==att.Id){
						singoloFile.tipo='foto';
						singoloFile.Name=att.Name;
						singoloFile.Id=att.Id;
						manutenzione.file.add(singoloFile);
					}
				}
				
				
			}
			manutenzione.listaDettagliManutenzioni.add(Assegna.getDettagliManutenzione(idManutenzione));
			System.debug('Manutenzione dettaglio:'+manutenzione.listaDettagliManutenzioni);
        		return manutenzione;
        	}catch(Exception ecc){
	            System.debug('getManutenzioneByNumOrdine: '+ecc.getMessage()+ ' at line: '+ecc.getLineNumber()+' stack trace: '+ecc.getStackTraceString());
	            GestioneLog.creaLog('Assegna','getManutenzioneByNumOrdine',ecc.getLineNumber(),ecc.getMessage(),ecc.getStackTraceString(),ecc.getTypeName(),'INPUT -> idManutenzione: '+idManutenzione,'','');
	            return null;
	        }
        }
    /*ASSEGNA*************************************************************************
        Metodo che assegna un auto a un cliente
    ***********************************************************************************************/
    
        @RemoteAction
        global static String assegna(String idAssegnazione,String idCliente,String dataConsegna,String oraConsegna){
        	try{
        		System.debug('idAssegnazione:'+idAssegnazione+' idCliente:'+idCliente+' dataConsegna:'+dataConsegna+' oraConsegna:'+oraConsegna);
        		NE__Order__c assegnazione=[SELECT NE__ServAccId__c,Luogo_consegna_stato_uso__c,NE__Parent_Order__r.NE__ServAccId__c,Allegato_comodato__c,Stato__c,Inizio_Assegnazione__c,NE__Parent_Order__r.Km__c,Km_Inizio_Assegnzione__c FROM NE__Order__c WHERE id=:idAssegnazione];
        		assegnazione.NE__Parent_Order__r.NE__ServAccId__c=idCliente;
        		assegnazione.Stato__c='1045';
        		assegnazione.Inizio_Assegnazione__c=DateTime.newInstance(Integer.valueOf(dataConsegna.substring(6,10)),Integer.valueOf(dataConsegna.substring(3,5)),Integer.valueOf(dataConsegna.substring(0,2)),Integer.valueOf(oraConsegna.substring(0,2)),Integer.valueOf(oraConsegna.substring(3,5)),Integer.valueOf(oraConsegna.substring(6,8)));
        		assegnazione.Km_Inizio_Assegnzione__c=assegnazione.NE__Parent_Order__r.Km__c;
        		update assegnazione;
        		return assegnazione.id;		
        	}catch(Exception ecc){
	            System.debug('assegna: '+ecc.getMessage()+ ' at line: '+ecc.getLineNumber()+' stack trace: '+ecc.getStackTraceString());
	            GestioneLog.creaLog('Assegna','assegna',ecc.getLineNumber(),ecc.getMessage(),ecc.getStackTraceString(),ecc.getTypeName(),'INPUT -> idCliente: '+idCliente,'INPUT -> dataConsegna'+dataConsegna,'INPUT -> oraConsegna'+oraConsegna);
	            return null;
	        }
        }
        
        /*SCEGLIVERIFICATORE*************************************************************************
        Metodo che assegna lo stato d'uso ad un utente
    	***********************************************************************************************/
    
        @RemoteAction
        global static Boolean scegliVerificatore(String idAssegnazione,String idVerificatore){
        	try{
        		NE__Order__c assegnazione=[SELECT Verificatore_di_turno__c,Stato__c,Email_Verificatore__c,Verificatore_di_turno_nome__c,Verificatore_di_turno_emali__c FROM NE__Order__c WHERE id=:idAssegnazione];
        		if(String.isBlank(idVerificatore))
        			assegnazione.Stato__c='1050';
      			else{
      				User utente=[SELECT Id,Name,Email FROM User WHERE id=:idVerificatore];
      				assegnazione.Verificatore_di_turno__c=utente.Id;
      				assegnazione.Verificatore_di_turno_nome__c=utente.Name;
      				assegnazione.Verificatore_di_turno_emali__c=utente.Email;
      				assegnazione.Email_Verificatore__c=true;
      				assegnazione.Stato__c='1055';
      			}
        		update assegnazione;
        		return true;
        			
        	}catch(Exception ecc){
	            System.debug('scegliVerificatore: '+ecc.getMessage()+ ' at line: '+ecc.getLineNumber()+' stack trace: '+ecc.getStackTraceString());
	            GestioneLog.creaLog('Assegna','scegliVerificatore',ecc.getLineNumber(),ecc.getMessage(),ecc.getStackTraceString(),ecc.getTypeName(),'INPUT -> idAssegnazione:'+idAssegnazione,'INPUT-> idVerificatore:'+idVerificatore,'');
	            return false;
	        }
        }
        
         /*GETASSEGNAZIONIDAVERIFICARE*******************************************************************
		Metodo per prendere tutte le assegnazioni che sono da verificare per un determinato utente
		***********************************************************************************************/
	@RemoteAction
	global static List<NE__Order__c> getAssegnazioniDaVerificare(){
		try{
			System.debug('Id Utente:'+UserInfo.getUserId());
			
			List<NE__Order__c> assegnazioni=[SELECT Id,Name,StringaDataCreazione__c,CreatedDate,Modello__c,Targa_Auto_Sostitutiva__c,Colore_Esterno__c,Colore_Interno__c,NE__Parent_Order__r.Targa__c,Stato__c,NE__AccountId__r.Name,NE__Parent_Order__r.NE__AccountId__r.Name,Inizio_Assegnazione__c,Fine_Assegnazione__c
											 FROM NE__Order__c
											 WHERE Flusso__c='Assegnazione'
											 AND Stato__c='1055'
											 AND Verificatore_di_turno__c=:UserInfo.getUserId()];
			return assegnazioni;
			
		}catch(Exception ecc){
	            System.debug('getAssegnazioniDaVerificare: '+ecc.getMessage()+ ' at line: '+ecc.getLineNumber()+' stack trace: '+ecc.getStackTraceString());
	            GestioneLog.creaLog('Assegna','getAssegnazioniDaVerificare',ecc.getLineNumber(),ecc.getMessage(),ecc.getStackTraceString(),ecc.getTypeName(),'','','');
	            return null;
	    }
	}
        /*GETASSEGNAZIONIBYREPARTOSTATO*******************************************************************
		Metodo per prendere tutte le assegnazioni di un reparto IN UN DETERMINATO STATO
		***********************************************************************************************/
	@RemoteAction
	global static List<NE__Order__c> getAssegnazioniByReparto (String di,String df,String sta,String mod,String id,String rep,String targa,String cliente,String tipoAssegnazione){
		String queryAssegnatoReparto;
		String queryNonAssegnatoReparto;
		List<NE__Order__c> assegnazioni;
		try{
			System.debug('DI:'+di+' DF:'+df+' Stato:'+sta+' Modello:'+mod+' Id:'+id+' Reparto:'+rep+' Targa:'+targa+' Cliente:'+cliente+' Tipo Assegnazione:'+tipoAssegnazione);
			User utente=[SELECT Id,Name,Reparto__c FROM User WHERE id=:UserInfo.getUserId()];
			String reparto=rep;
			String idRichiesta=id;
			String stato=sta;
			String modello=mod;
			queryAssegnatoReparto='SELECT Id,Name,StringaDataCreazione__c,CreatedDate,Modello__c,Targa_Auto_Sostitutiva__c,Colore_Esterno__c,Colore_Interno__c,NE__Parent_Order__r.Targa__c,Stato__c,NE__AccountId__r.Name,NE__Parent_Order__r.NE__AccountId__r.Name,Stringa_Inizio_Assegnazione__c,Stringa_Fine_Assegnazione__c,Tipo_assegnazione__c FROM NE__Order__c WHERE NE__Parent_Order__r.NE__AccountId__r.Id=\''+utente.Reparto__c+'\' AND Flusso__c=\'Assegnazione\' ';	//Stato=21-->Annullata
			queryNonAssegnatoReparto='SELECT Id,Name,StringaDataCreazione__c,CreatedDate,Modello__c,Targa_Auto_Sostitutiva__c,Colore_Esterno__c,Colore_Interno__c,NE__Parent_Order__r.Targa__c,Stato__c,NE__AccountId__r.Name,NE__Parent_Order__r.NE__AccountId__r.Name,Inizio_Assegnazione__c,Fine_Assegnazione__c,Tipo_assegnazione__c,Stringa_Inizio_Assegnazione__c,Stringa_Fine_Assegnazione__c FROM NE__Order__c WHERE Flusso__c=\'Assegnazione\' ';		
			
			DateTime dataInizio,dataFine;
			if(!String.isBlank(di) && !String.isBlank(df)){
				System.debug(di);
				dataInizio=datetime.newInstance(Integer.valueOf(di.substring(6,10)),Integer.valueOf(di.substring(3,5)),Integer.valueOf(di.substring(0,2)),02,00,00);
				dataFine=datetime.newInstance(Integer.valueOf(df.substring(6,10)),Integer.valueOf(df.substring(3,5)),Integer.valueOf(df.substring(0,2)),23,59,00);
				System.debug('Data Inizio:'+dataInizio+' Data Fine:'+dataFine);
				queryAssegnatoReparto=queryAssegnatoReparto+' AND (Inizio_Assegnazione__c>=:dataInizio AND Inizio_Assegnazione__c<=:dataFine)';
				queryNonAssegnatoReparto=queryNonAssegnatoReparto+' AND (Inizio_Assegnazione__c>=:dataInizio AND Inizio_Assegnazione__c<=:dataFine)';
			}
			if(!String.isBlank(stato)){
				queryAssegnatoReparto=queryAssegnatoReparto+' AND Stato__c=\''+stato+'\'';
				queryNonAssegnatoReparto=queryNonAssegnatoReparto+' AND Stato__c=\''+stato+'\'';
			}
			if(!String.isBlank(tipoAssegnazione)){
				queryAssegnatoReparto=queryAssegnatoReparto+' AND Tipo_assegnazione__c=\''+tipoAssegnazione+'\'';
				queryNonAssegnatoReparto=queryNonAssegnatoReparto+' AND Tipo_assegnazione__c=\''+tipoAssegnazione+'\'';
			}
			if(!String.isBlank(modello)){
				queryAssegnatoReparto=queryAssegnatoReparto+' AND Modello__c=\''+String.escapeSingleQuotes(modello)+'\'';
				queryNonAssegnatoReparto=queryNonAssegnatoReparto+' AND Modello__c=\''+String.escapeSingleQuotes(modello)+'\'';
			}
			if(!String.isBlank(idRichiesta)){
				queryAssegnatoReparto=queryAssegnatoReparto+' AND Name LIKE \'%'+idRichiesta+'%\'';
				queryNonAssegnatoReparto=queryNonAssegnatoReparto+' AND Name LIKE \'%'+idRichiesta+'%\'';
			}
			if(!String.isBlank(reparto)){
				queryAssegnatoReparto=queryAssegnatoReparto+' AND NE__Parent_Order__r.NE__AccountId__c=\''+reparto+'\'';
				queryNonAssegnatoReparto=queryNonAssegnatoReparto+' AND NE__Parent_Order__r.NE__AccountId__c=\''+reparto+'\'';
			}
			if(!String.isBlank(targa)){
				queryAssegnatoReparto=queryAssegnatoReparto+' AND NE__Parent_Order__r.Targa__c LIKE\'%'+targa+'%\'';
				queryNonAssegnatoReparto=queryNonAssegnatoReparto+' AND NE__Parent_Order__r.Targa__c LIKE\'%'+targa+'%\'';
			}
			if(!String.isBlank(cliente)){
				queryAssegnatoReparto=queryAssegnatoReparto+' AND NE__AccountId__r.Name LIKE \'%'+cliente+'%\'';
				queryNonAssegnatoReparto=queryNonAssegnatoReparto+' AND NE__AccountId__r.Name LIKE \'%'+cliente+'%\'';
			}
			System.debug('Data Inizio Richiesta:'+dataInizio+' Data Fine Richiesta:'+dataFine+' Stato:'+stato);
			System.debug('Query Utente assegnato a reparto:'+queryAssegnatoReparto);
			System.debug('Query Utente non assegnato a reparto:'+queryNonAssegnatoReparto);
			System.debug('Reparto: '+utente.Reparto__c);
			
			if(!String.isBlank(utente.Reparto__c))
				assegnazioni=Database.query(queryAssegnatoReparto);
			else
				assegnazioni=Database.query(queryNonAssegnatoReparto);

			return assegnazioni;
		}catch(Exception ecc){
	            System.debug('getRichiesteByReparto: '+ecc.getMessage()+ ' at line: '+ecc.getLineNumber()+' stack trace: '+ecc.getStackTraceString());
	            GestioneLog.creaLog('Assegna','getRichiesteByReparto',ecc.getLineNumber(),ecc.getMessage(),ecc.getStackTraceString(),ecc.getTypeName(),'INPUT -> dataI: '+di+' dataF:'+df,'INPUT -> stato'+sta+' modello:'+mod+' reparto:'+rep+' id:'+id,'');
	            return null;
	    }
	}
	
	/*ANNULLAASSEGNAZIONE*************************************************************************
        Metodo che annulla un assegnazione/manutenzione
    ***********************************************************************************************/
    
        @RemoteAction
        global static boolean annullaAssegnazione(String idAssegnazione){
        	try{
        		System.debug('Id Assegnazione:'+idAssegnazione);
        		NE__Order__c assegnazione=[SELECT Stato__c,Inizio_Assegnazione__c,Fine_Assegnazione__c FROM  NE__Order__c WHERE Id=:idAssegnazione];
        		assegnazione.Stato__c='1080';
        		//assegnazione.Inizio_Assegnazione__c=null;
        		//assegnazione.Fine_Assegnazione__c=null;
        		update assegnazione;
        		return true;
        	}catch(Exception ecc){
	            System.debug('annullaAssegnaizone: '+ecc.getMessage()+ ' at line: '+ecc.getLineNumber()+' stack trace: '+ecc.getStackTraceString());
	            GestioneLog.creaLog('Assegna','annullaAssegnaizone',ecc.getLineNumber(),ecc.getMessage(),ecc.getStackTraceString(),ecc.getTypeName(),'','','');
	            return false;
	    	}
        }
        
  	
   
      /*INFOFATTURAZIONE*************************************************************************
       
    ***********************************************************************************************/
    
        @RemoteAction
        global static boolean infoFatturazione(String idManutenzione,String idFattura,String dataFattura,String JsonManutenzione){
        	Savepoint sp;
        	try{
        		sp=Database.setSavepoint();
        		System.debug('Id Manutenzione:'+idManutenzione+' Id Fattura:'+idFattura+' Data FAttura:'+dataFattura+' Json Manutenzione:'+JsonManutenzione);
        		NE__Order__c manutenzione=[SELECT Data_fattura__c,Numero_fattura__c,Flusso__c,NE__Parent_Order__r.Targa__c,NE__Parent_Order__c,Km__c,Km_Inizio_Assegnzione__c,Km_Fine_Assegnazione__c FROM NE__Order__c WHERE id=:idManutenzione];
        		NE__Order__c vettura=[SELECT Km__c FROM NE__Order__c WHERE id=:manutenzione.NE__Parent_Order__c];
        		System.debug('ID VETTURA:'+vettura.Id);
        		Manutenzione__c man=new Manutenzione__c();
        		if(!String.isBlank(JsonManutenzione)){
        			man=(Manutenzione__c)JSON.deserialize(JsonManutenzione,Manutenzione__c.class);
        			System.debug('Json Manutenzione'+man);
        			if(!man.Stringa_data_uscita_officina__c.contains('undefined'))
        				man.Data_uscita_officina__c=DateTime.newInstance(Integer.valueOf(man.Stringa_data_uscita_officina__c.substring(6,10)),Integer.valueOf(man.Stringa_data_uscita_officina__c.substring(3,5)),Integer.valueOf(man.Stringa_data_uscita_officina__c.substring(0,2)),Integer.valueOf(man.Stringa_data_uscita_officina__c.substring(11,13)),Integer.valueOf(man.Stringa_data_uscita_officina__c.substring(14,16)),Integer.valueOf(man.Stringa_data_uscita_officina__c.substring(17,19)));
        			if(!man.Stringa_data_entrata_in_officina__c.contains('undefined'))
        				man.Data_entrata_in_officina__c=DateTime.newInstance(Integer.valueOf(man.Stringa_data_entrata_in_officina__c.substring(6,10)),Integer.valueOf(man.Stringa_data_entrata_in_officina__c.substring(3,5)),Integer.valueOf(man.Stringa_data_entrata_in_officina__c.substring(0,2)),Integer.valueOf(man.Stringa_data_entrata_in_officina__c.substring(11,13)),Integer.valueOf(man.Stringa_data_entrata_in_officina__c.substring(14,16)),Integer.valueOf(man.Stringa_data_entrata_in_officina__c.substring(17,19)));
        			if(!man.Stringa_data_preventivo__c.contains('undefined'))
        				man.Data_preventivo__c=DateTime.newInstance(Integer.valueOf(man.Stringa_data_preventivo__c.substring(6,10)),Integer.valueOf(man.Stringa_data_preventivo__c.substring(3,5)),Integer.valueOf(man.Stringa_data_preventivo__c.substring(0,2)),Integer.valueOf(man.Stringa_data_preventivo__c.substring(11,13)),Integer.valueOf(man.Stringa_data_preventivo__c.substring(14,16)),Integer.valueOf(man.Stringa_data_preventivo__c.substring(17,19)));
        			if(String.isBlank(man.Id_manutenzione__c))
        				man.Id_manutenzione__c=idManutenzione;
        			/*if(String.isBlank(man.Vettura__c))
        				man.Vettura__c=manutenzione.NE__Parent_Order__c;*/
        			if(String.isBlank(man.Targa__c))
        				man.Targa__c=manutenzione.NE__Parent_Order__r.Targa__c;
        			
        		}
        		System.debug('debug vettura:'+man.Vettura__c);
        		if(!String.isBlank(idFattura))
        			manutenzione.Numero_fattura__c=idFattura;
        		if(!String.isBlank(dataFattura))
        			manutenzione.Data_fattura__c=date.newInstance(Integer.valueOf(dataFattura.substring(6,10)),Integer.valueOf(dataFattura.substring(3,5)),Integer.valueOf(dataFattura.substring(0,2)));
        		if(!String.isBlank(man.Km_uscita__c)){
        			if(!String.isBlank(vettura.Km__c))
        				manutenzione.Km__c=''+(Integer.valueOf(man.Km_uscita__c)-Integer.valueOf(vettura.Km__c));
        			else
        				manutenzione.Km__c=''+(Integer.valueOf(man.Km_uscita__c)-0);
        			manutenzione.Km_Inizio_Assegnzione__c=vettura.Km__c;
        			vettura.Km__c=man.Km_uscita__c; //Questo passaggio deve essere spostato in restituitaManutenzione
        			manutenzione.Km_Fine_Assegnazione__c=man.Km_uscita__c;
        		}  
        		man.Flusso__c=manutenzione.Flusso__c;     		
        		update manutenzione;
        		update vettura;
        		System.debug('debug vettura2ID:'+man.Id+'debug vettura2:'+man.Vettura__c);
        		upsert man;
        		return true;
        	}catch(Exception ecc){
	            Database.rollback(sp);
	            System.debug('infoAggiuntive: '+ecc.getMessage()+ ' at line: '+ecc.getLineNumber()+' stack trace: '+ecc.getStackTraceString());
	            GestioneLog.creaLog('Assegna','infoAggiuntive',ecc.getLineNumber(),ecc.getMessage(),ecc.getStackTraceString(),ecc.getTypeName(),'INPUT->idManutenzione'+idManutenzione,'INPUT->idFattura'+idFattura+'INPUT->dataFattura'+dataFattura,'INPUT->JsonManutenzione'+JsonManutenzione);
	            return false;
	    	}
        }
        
    /*GETDETTAGLIMANUTENZIONE*************************************************************************
        Metodo che recupera i dettagli di una manutenzione
    ***********************************************************************************************/
    
        @RemoteAction
        global static Manutenzione__c getDettagliManutenzione(String idManutenzione){
        	try{
        		NE__Order__c assegnazione=[SELECT Inizio_Assegnazione__c,Fine_Assegnazione__c,NE__Parent_Order__c FROM NE__Order__c WHERE id=:idManutenzione];
        		System.debug('Assegnazione manutenzione:'+assegnazione);
        		List<Manutenzione__c> manutenzioni=[SELECT Data_entrata_in_officina__c,Data_uscita_officina__c,Km_uscita__c,Id_preventivo__c,Data_preventivo__c,Importo_preventivo__c,Tipologia_intervento__c,Descrizione_intervento__c,Id_manutenzione__c,Vettura__c,Id 
        											FROM Manutenzione__c 
        											WHERE Vettura__c=:assegnazione.NE__Parent_Order__c];
        		System.debug('Manutenzioni:'+manutenzioni.size());
        		for(Manutenzione__c m:manutenzioni){
        			System.debug('Data Assegnazione:'+assegnazione.Inizio_Assegnazione__c.date()+' Data entrata in officina:'+m.Data_entrata_in_officina__c.date());
        			if(m.Data_entrata_in_officina__c.date()==assegnazione.Inizio_Assegnazione__c.date()){
        				//C.I. ulteriore controllo per ottenere il corretto dettaglio della manutenzione. Perchè non è stato usata sempre questa chiave?
        				if(!String.isBlank(m.Id_manutenzione__c)){
        					if(m.Id_manutenzione__c==assegnazione.Id){
        						System.debug('Dettaglio trovato');  
        						return m;	
        					}
        				}else{
        					System.debug('Dettaglio trovato');
        					return m;	
        				}
        				
        			}
        		}
        		return null;
        	}catch(Exception ecc){
	            System.debug('getDettagliManutenzione: '+ecc.getMessage()+ ' at line: '+ecc.getLineNumber()+' stack trace: '+ecc.getStackTraceString());
	            GestioneLog.creaLog('Assegna','getDettagliManutenzione',ecc.getLineNumber(),ecc.getMessage(),ecc.getStackTraceString(),ecc.getTypeName(),'INPUT-> idManutenzione'+idManutenzione,'','');
	            return null;
	    	}
        }
        
  	@RemoteAction   
	global static List<String> getPicklistValues(String ObjectApi_name,String Field_name){ 
	try{
	  List<String> lstPickvals=new List<String>();
	  Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectApi_name);//From the Object Api name retrieving the SObject
	  Sobject Object_name = targetType.newSObject();
	  Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
	  Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
	  Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
	  List<Schema.PicklistEntry> pick_list_values = field_map.get(Field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
	  for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
	  	lstPickvals.add(a.getLabel());//add the value  to our final list
	  }
	  return lstPickvals;
	}catch(Exception ecc){
	 	System.debug('getPicklistValues: '+ecc.getMessage()+ ' at line: '+ecc.getLineNumber()+' stack trace: '+ecc.getStackTraceString());
	    GestioneLog.creaLog('Assegna','getPicklistValues',ecc.getLineNumber(),ecc.getMessage(),ecc.getStackTraceString(),ecc.getTypeName(),'INPUT-> Nome Api Oggetto:'+ObjectApi_name,'INPUT-> Nome Api Campo:'+Field_name,'');
	    return null;
	}
    }
    
    /*VERIFICAFINEASSEGNAZIONE********************************************************************
		METODO CHE VERIFICA SE UN ASSEGNAZIONE PUò ESSERE CHIUSA O CE NE SONO ALTRE APERTE PRIMA DI QUESTA.
	************************************************************************************/
	@RemoteAction
    public static String verificaFineAssegnazione(String idAssegnazione){
    	String response='';
    	try{
    		System.debug('Id Assegnazione:'+idAssegnazione);
    		NE__Order__c assegnazione=[SELECT Id,Name,Inizio_Assegnazione__c,Fine_assegnazione__c,NE__Parent_Order__c FROM NE__Order__c WHERE id=:idAssegnazione];
    		List<NE__Order__c> assegnazioniAperte=[SELECT Id,Name,Inizio_Assegnazione__c,Fine_assegnazione__c,Tipo_Assegnazione__c FROM NE__Order__c WHERE Flusso__c='Assegnazione' AND Stato__c!='1080' AND Stato__c!='1060' AND Inizio_Assegnazione__c<=:assegnazione.Inizio_Assegnazione__c AND id!=:assegnazione.Id AND NE__Parent_Order__c=:assegnazione.NE__Parent_Order__c AND Tipo_assegnazione__c!=:Label.CCP_transfer_assignment ORDER BY Inizio_Assegnazione__c];
    		System.debug('Numero Assegnazioni aperte:'+assegnazioniAperte.size()+' lista assegnazioni aperte:'+assegnazioniAperte);
    		if(assegnazioniAperte.size()>0)
    			for(NE__Order__c ass:assegnazioniAperte){
    				response=response+ass.Inizio_Assegnazione__c.dateGMT().format()+'-'+ass.Fine_assegnazione__c.dateGMT().format()+'\n';
    				System.debug('#Response# : ');	
    			}
    		else
    			response='OK';
    				
    		return response;
    	}catch(Exception ecc){
    		System.debug('Errore verificaFineAssegnazione: '+ecc.getMessage()+ ' at line: '+ecc.getLineNumber()+' stack trace: '+ecc.getStackTraceString());
			GestioneLog.creaLog('Assegna','sendverificaFineAssegnazioneAttach',ecc.getLineNumber(),ecc.getMessage(),ecc.getStackTraceString(),ecc.getTypeName(),'','','');
    		return response='ERRORE';
    	}
    }
    /*SENDATTACH********************************************************************
		METODO @FUTURE CHE FA RICHIESTA HTTP ALLA RISORSA REST INVIANDO URL DEL FILE DA INVIARE COME ATTACHMENT
	************************************************************************************/
	@future(callout=true)
    public static void sendAttach(String link,String userSessionId){
    	try{
	    	String addr = URL.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/sendPDFEmail';
	    	System.debug('DEBUG url sendPDFEmail'+' '+addr);
	    	Map<String,String> postBody = new Map<String,String>();
	
	        HttpRequest req = new HttpRequest();
	        req.setEndpoint( addr );
	        req.setMethod('POST');
	        req.setHeader('Authorization', 'OAuth ' + userSessionId);
	        req.setHeader('Content-Type','application/json');
	        
	        postBody.put('URL',link);
	
	        String reqBody = JSON.serialize(postBody);
	        req.setBody(reqBody);
	        Http http = new Http();
	        HttpResponse response = http.send(req);
	        System.debug('DEBUG RESPONSE HTTP'+' '+response);
    	}catch(Exception ecc){
    		System.debug('Errore sendAttach: '+ecc.getMessage()+ ' at line: '+ecc.getLineNumber()+' stack trace: '+ecc.getStackTraceString());
			GestioneLog.creaLog('Assegna','sendAttach',ecc.getLineNumber(),ecc.getMessage(),ecc.getStackTraceString(),ecc.getTypeName(),'','','');
    	}
    }  	
    
    /*################################################################################################################################
    
    Metodo utilizzato per le vetture disponibili, per trovare l'ultimo luogo di consegna della vettura
    
    #################################################################################################################################*/
    
    public static String verificaStatoPrecedente (Id ordine, Datetime dataCheck, List<NE__Order__c> ass) {
    	 
    	String ritorno ='';
    	String cliente ='La vettura è stata consegnata dal cliente presso: ';
    	String manutentore = 'Vettura rientrata dopo manutenzione effettuata presso: ';
    	String trasportatore = 'La vettura è stata trasportata e consegnata presso: ';
    	Boolean trovato = true;
    	Date d = Date.newInstance(dataCheck.year(),dataCheck.month(),dataCheck.day())-1;
    	Date dataDaVerificare = d-30; //estendo il controllo della data per un mese
    	Date consegna;
    	Integer numGiorniVerifica = 0;
    	
    	if (ass!=null && ass.size() > 0 ) {
    	
    	while(trovato) {
    			
         		for (NE__Order__c o : ass) {
	    			if (o.Fine_Assegnazione__c !=null) {
	    				consegna = Date.newInstance(o.Fine_Assegnazione__c.year(),o.Fine_Assegnazione__c.month(),o.Fine_Assegnazione__c.day());
	    						
	    			if (d==consegna) {
	    				System.debug('CONSEGNA: '+consegna);
	    				trovato = false;
	    				
	    				if (o.Tipo_Assegnatario__c =='Cliente') {
	    					if (o.Luogo_consegna_stato_uso__c !=null) {
	    						ritorno+=cliente+o.Luogo_consegna_stato_uso__c;
	    						System.debug('OGGETTO O: '+o.Id);
	    					} else {
	    						ritorno+=cliente+'<non specificato>';
	    					}
	    				} else if (o.Tipo_Assegnatario__c =='Manutentore') {
	    					if (o.Luogo_consegna_stato_uso__c !=null) {
	    						ritorno+=manutentore+o.Luogo_consegna_stato_uso__c;
	    					} else {
	    						ritorno+=manutentore+'<non specificato>';
	    					}
	    				} else if (o.Tipo_Assegnatario__c =='Trasportatore') {
	    					if (o.Luogo_consegna_stato_uso__c !=null) {
	    						ritorno+=trasportatore+o.Luogo_consegna_stato_uso__c;
	    					} else {
	    						ritorno+=trasportatore+'<non specificato>';
	    					}
	    				} else {
	    					if (o.Luogo_consegna_stato_uso__c !=null) {
	    						ritorno+=o.Luogo_consegna_stato_uso__c;
	    					} else {
	    						ritorno+='<non specificato>';
	    						}	  
	    				}	  				
	    				break;
	    			} 
    			} else {
	    				continue;	 
	    			}   		
	  			}
	  			
	    		d-=1;
	    		// faccio il controllo per un anno altrimenti va sempre in loop
	    		if (d == dataDaVerificare ) {
	    			trovato = false;		    			
		    	}    		
    		}
    	}
    	return ritorno;
    }
    
     /*######################################################################################
     
		METODO CHE VERIFICA SE SONO PRESENTI ASSEGNAZIONI CON DATA D'INIZIO UGUALE ALLA DATA 
		DI CONSEGNA IN RITARDO
		
	########################################################################################*/
	
	
	@RemoteAction
    public static String verificaInizioAssegnazioneConRitardo(String idAssegnazione, String dataOraConsegna){
    	System.debug('PARAMETRI INGRESSO: '+idAssegnazione+', '+dataOraConsegna);
    	String response='';
    	try{
    		NE__Order__c assegnazione=[SELECT Id,Name,Inizio_Assegnazione__c,Fine_assegnazione__c, NE__Parent_Order__c FROM NE__Order__c WHERE Id=:idAssegnazione];
    		//Date d = date.newInstance(Integer.valueOf(dataOraConsegna.substring(6,10)),Integer.valueOf(dataOraConsegna.substring(3,5)),Integer.valueOf(dataOraConsegna.substring(0,2)));
    		Datetime d = datetime.newInstance(Integer.valueOf(dataOraConsegna.substring(6,10)),Integer.valueOf(dataOraConsegna.substring(3,5)),Integer.valueOf(dataOraConsegna.substring(0,2)),Integer.valueOf(dataOraConsegna.substring(11,13)),Integer.valueOf(dataOraConsegna.substring(14,16)),Integer.valueOf(dataOraConsegna.substring(17,19))); 
    		List<NE__Order__c> assegnazioniAperte=[SELECT Id,Name,Inizio_Assegnazione__c,Fine_assegnazione__c,Tipo_Assegnazione__c FROM NE__Order__c WHERE Flusso__c='Assegnazione' AND Stato__c!='1080' AND Stato__c!='1060' AND id!=:assegnazione.Id AND NE__Parent_Order__c=:assegnazione.NE__Parent_Order__c AND Tipo_assegnazione__c!=:Label.CCP_transfer_assignment ORDER BY Inizio_Assegnazione__c];
    		if(assegnazioniAperte.size()>0) {
    			System.debug('assegnazioni aperte: '+assegnazioniAperte);
    			for(NE__Order__c ass:assegnazioniAperte) {
    				Datetime d2 = ass.Inizio_Assegnazione__c;
    				Datetime d3 = ass.Fine_Assegnazione__c;
    				if (d >= d2 && d <= d3) {
    					System.debug('d '+d);
    					System.debug('d2 '+d2);
    					response=response+'[Nome: '+ass.Name+' - '+'Inizio: '+ass.Inizio_Assegnazione__c.dateGMT().format()+' - '+'Fine: '+ ass.Fine_assegnazione__c.dateGMT().format()+']'+'\n';
    				}
    			}
    			/*Modifica A.B. 07/04/2016*/
    			if(response=='')
    				response='OK';
    			
    		}
    		else
    			response='OK';
    				
    		return response;
    	}catch(Exception ecc){
    		System.debug('Errore verificaInizioAssegnazioneConRitardo: '+ecc.getMessage()+ ' at line: '+ecc.getLineNumber()+' stack trace: '+ecc.getStackTraceString());
			return response='ERRORE';
    	}
    }
    
     /*######################################################################################
     
		METODO CHE PERMETTE DI MODIFICARE UN'ASSEGNAZIONE PRESENTE. DA USARE QUANDO BISOGNA
		MODIFICARE LA DATA DI ASSEGNAZIONE IN SEGUITO AD UNA CONSEGNA IN RITARDO.
		
	########################################################################################*/
       
    
    @RemoteAction
        global static boolean modificaAssegnazione(String idAssegnazione, String datain, String dataf, String orain, String oraf){
        	try{
        		System.debug('Id Assegnazione:'+idAssegnazione +'Data inizio '+datain+'Data fine '+dataf);
        		NE__Order__c assegnazione=[SELECT Inizio_Assegnazione__c,Fine_Assegnazione__c FROM  NE__Order__c WHERE Id=:idAssegnazione];
        		assegnazione.Inizio_Assegnazione__c=DateTime.newInstance(Integer.valueOf(datain.substring(6,10)),Integer.valueOf(datain.substring(3,5)),Integer.valueOf(datain.substring(0,2)),Integer.valueOf(orain.substring(0,2)),Integer.valueOf(orain.substring(3,5)),Integer.valueOf(orain.substring(6,8)));
	        	assegnazione.Fine_Assegnazione__c=DateTime.newInstance(Integer.valueOf(dataf.substring(6,10)),Integer.valueOf(dataf.substring(3,5)),Integer.valueOf(dataf.substring(0,2)),Integer.valueOf(oraf.substring(0,2)),Integer.valueOf(oraf.substring(3,5)),Integer.valueOf(oraf.substring(6,8)));
        		update assegnazione;
        		return true;
        	}catch(Exception ecc){
	            System.debug('modificaAssegnaizone: '+ecc.getMessage()+ ' at line: '+ecc.getLineNumber()+' stack trace: '+ecc.getStackTraceString());
	            return false;
	    	}
        }
     
    /*######################################################################################
     
		METODO CHE VERIFICA SE SONO PRESENTI ASSEGNAZIONI CON DATA D'INIZIO UGUALE ALLA DATA 
		DI CHISURA MANUTENZIONE. METODO USATO QUANDO SI MODIFICA LA DATA DI RICHIESTA 
		MANUTENZIONE.
		
	########################################################################################*/
	
	
	@RemoteAction
    public static String verificaManutenzione(String idManutenzione, String dataFineMan){
    	System.debug('PARAMETRI INGRESSO: '+idManutenzione+', '+dataFineMan);
    	String response='';
    	try{
    		NE__Order__c assegnazione=[SELECT Id,Name,Inizio_Assegnazione__c,Fine_assegnazione__c, NE__Parent_Order__c FROM NE__Order__c WHERE Id=:idManutenzione];
    		Date d = date.newInstance(Integer.valueOf(dataFineMan.substring(6,10)),Integer.valueOf(dataFineMan.substring(3,5)),Integer.valueOf(dataFineMan.substring(0,2)));	   		
    		List<NE__Order__c> assegnazioniAperte=[SELECT Id,Name,Inizio_Assegnazione__c,Fine_assegnazione__c,Tipo_Assegnazione__c FROM NE__Order__c WHERE (Flusso__c='Assegnazione' OR Flusso__c='Manutenzione')  AND Stato__c!='1080' AND Stato__c!='1060' AND id!=:assegnazione.Id AND NE__Parent_Order__c=:assegnazione.NE__Parent_Order__c AND Tipo_assegnazione__c!=:Label.CCP_transfer_assignment ORDER BY Inizio_Assegnazione__c];
    		if(assegnazioniAperte.size()>0) {
    			System.debug('assegnazioni aperte: '+assegnazioniAperte);
    			for(NE__Order__c ass:assegnazioniAperte) {
    				Date d2 = date.newinstance(ass.Inizio_Assegnazione__c.year(), ass.Inizio_Assegnazione__c.month(), ass.Inizio_Assegnazione__c.day());
    				Date d3 = date.newinstance(ass.Fine_Assegnazione__c.year(), ass.Fine_Assegnazione__c.month(), ass.Fine_Assegnazione__c.day());    				
    				System.debug('DATA INIZIO ASSEGNAZIONE: '+d2);
    				System.debug('DATA FINE ASSEGNAZIONE: '+d3);
    				System.debug('DATA DA CONFRONTARE: '+d);
    				if ((d >= d2 && d <= d3) || d2>=assegnazione.Inizio_Assegnazione__c && d3<=d) {
    					System.debug('d '+d);
    					System.debug('d2 '+d2);
    					//reponse=response+'[Nome: '+ass.Name+' - '+'Inizio: '+ass.Inizio_Assegnazione__c.dateGMT().format()+' - '+'Fine: '+ ass.Fine_assegnazione__c.dateGMT().format()+']'+'\n';    					
    					response = 'KO';
    				}
    			}
    			
    			if(response==''){    				
    				response='OK';
    			}    			
    		}
    		else
    			response='OK';
    		System.debug('RESPONSE: '+response);		
    		return response;
    	}catch(Exception ecc){
    		System.debug('Errore verificaManutenzione: '+ecc.getMessage()+ ' at line: '+ecc.getLineNumber()+' stack trace: '+ecc.getStackTraceString());
			return response='ERRORE';
    	}
    }
    
     /*#########################################################################################################
     
		METODO CHE SBOCCA UN UTENTE DALLA BLACK LIST (a seguito di 3 restituzioni auto con flag 'danneggiato').
		Se "FLAG" è TRUE, il cliente identificato attraverso "CF" viene dismesso dalla lista nera. 
		La dismissione avviene azzerando il campo cliente "ContatoreAutoDanneggiata__c". 
		Il metodo ritorna:
		true: il cliente è stato dismesso dalla blacklist o non lo è mai stato
		false: FLAG è false e quindi non permette la dismissione
		
	###########################################################################################################*/
    
    
    @RemoteAction
    global static boolean sbloccaCliente(boolean FLAG, String id){
    
    Account cliente;
    boolean status;
    
    status=true;
    cliente=[SELECT ContatoreAutoDanneggiata__c FROM Account WHERE Account.Id=:id];
    
    if(cliente==null){
    	status=false;
    	return status;
    }
    	
    if(FLAG==true){
    cliente.ContatoreAutoDanneggiata__c=4;
    update cliente;
   		return status;
    }else{
   		cliente.ContatoreAutoDanneggiata__c=0;
   		update cliente;   		
   	}
   	
    return status;
    }
    
    @RemoteAction
	global static List<AssegnazioniCheckbox> getAssegnazioniParcoAuto (String sta,String mod,String id,String rep, String ta, String te, String idV, String marca){
		String queryNonAssegnatoReparto;
		List<NE__Order__c> assegnazioni;
        List<AssegnazioniCheckbox> assegnazioniCheckbox = new List<AssegnazioniCheckbox>();
		try{		
			
			String reparto=rep;
			String idRichiesta=id;
			String stato=sta;
			String modello=mod;			
			String targa = ta;
			String telaio = te;
			String idVista = idV;
			queryNonAssegnatoReparto='SELECT Id,NE__Parent_Order__r.Venduta__c,NE__Parent_Order__r.Derivative_description_Vista__c,NE__Parent_Order__r.Model_description_Vista__c,NE__Parent_Order__r.Model_code_Vista__c,Telaio__c,Id_Vista__c,Name,StringaDataCreazione__c,CreatedDate,Modello__c,Targa_Auto_Sostitutiva__c,Colore_Esterno__c,Colore_Interno__c,Targa__c,Stato__c,NE__Parent_Order__r.NE__AccountId__r.Name, NE__Parent_Order__r.Targa__c,NE__AccountId__r.Name FROM NE__Order__c WHERE Flusso__c=\'Assegnazione\' AND NE__Parent_Order__r.Venduta__c=false';			
			
			if(!String.isBlank(stato)){				
				queryNonAssegnatoReparto=queryNonAssegnatoReparto+' AND Stato__c=\''+stato+'\'';
			}
			if(!String.isBlank(modello)){				
				queryNonAssegnatoReparto=queryNonAssegnatoReparto+' AND Modello__c LIKE \'%'+String.escapeSingleQuotes(modello)+'%\'';
			}
			if(!String.isBlank(idRichiesta)){				
				queryNonAssegnatoReparto=queryNonAssegnatoReparto+' AND Name LIKE \'%'+idRichiesta+'%\'';
			}
			if(!String.isBlank(reparto)){				
				queryNonAssegnatoReparto=queryNonAssegnatoReparto+' AND NE__Parent_Order__r.NE__AccountId__c=\''+reparto.substring(0,15)+'\'';
			}
			//modifiche del 19/04/2016 F.P.
			if(!String.isBlank(targa)){				
				queryNonAssegnatoReparto+=' AND NE__Parent_Order__r.Targa__c=\''+targa+'\'';
			}
			if(!String.isBlank(telaio)){				
				queryNonAssegnatoReparto+=' AND NE__Parent_Order__r.Telaio__c=\''+telaio+'\'';
			}
			if(!String.isBlank(idVista)){				
				queryNonAssegnatoReparto+=' AND NE__Parent_Order__r.Id_Vista__c=\''+idVista+'\'';
			}
			
			if(!String.isBlank(marca) && !marca.equals('Tutti')){				
				queryNonAssegnatoReparto+=' AND NE__Parent_Order__r.Marca__c=\''+marca+'\'';
			}			
			
			System.debug('QUERY: '+queryNonAssegnatoReparto);
			assegnazioni=Database.query(queryNonAssegnatoReparto);
            for (NE__Order__c a : assegnazioni){
                AssegnazioniCheckbox ac = new AssegnazioniCheckbox(a);
                assegnazioniCheckbox.add(ac);
            }
			return assegnazioniCheckbox;
		}
		catch(Exception ecc){
			System.debug('Errore getRichieste: '+ecc.getMessage()+ ' at line: '+ecc.getLineNumber()+' stack trace: '+ecc.getStackTraceString());
			return  null;
		}
	}
	
	@RemoteAction
	global static List<Wrapper.Auto> dettagliAssegnazioniParcoAuto (String di, String df, List<String> listaId){
		
		List<Wrapper.Auto> assegnazioni;
        List<NE__Order__c> vetture;
        List<NE__Order__c> avs;      
        
        try{
            assegnazioni=new List<Wrapper.Auto>();
            System.debug('di: '+di+' df: '+df);
            DateTime dataInizio=datetime.newInstance(Integer.valueOf(di.substring(6,10)),Integer.valueOf(di.substring(3,5)),Integer.valueOf(di.substring(0,2)),02,00,00);
            DateTime dataFine=datetime.newInstance(Integer.valueOf(df.substring(6,10)),Integer.valueOf(df.substring(3,5)),Integer.valueOf(df.substring(0,2)),23,59,00);
            System.debug('di:'+dataInizio+' df:'+dataFine);            
            vetture=new List<NE__Order__c>();              	            	
			vetture = [SELECT Id,Name,Data_Richiesta__c,Codice_Modello__c,Colore_Esterno__c,Colore_Interno__c,Targa__c,Modello__c,Km__c,Data_assegnazione_a_reparto__c FROM NE__Order__c WHERE Stato__c=:'170' AND Flusso__c=:'Approvvigionamento' AND Data_assegnazione_a_reparto__c<=:dataFine AND Targa__c IN: listaId ];
            System.debug('assegnazioni: '+vetture);
            List<String> idVetture=new List<String>();
            for(NE__Order__c vettura:vetture)
                idVetture.add(vettura.Id);
            System.debug('Lista id Vetture: '+idVetture);
            //Map<Id,Vettura__c> cars=new Map<Id,Vettura__c>([SELECT Id,Name,Data_Richiesta__c,Codice_Modello__c,Colore_Esterno__c,Colore_Interno__c,Targa__c,Modello__c FROM Vettura__c WHERE Id in:idVetture]);
            avs=[SELECT NE__AccountId__c,NE__Parent_Order__c,AssegnazioneId__c, Luogo_consegna_stato_uso__c, AssegnazioneId__r.Fine_Assegnazione__c,AssegnazioneId__r.Inizio_Assegnazione__c,NE__AccountId__r.Name,Id,Name,Inizio_Assegnazione__c,Fine_Assegnazione__c,Tipo_Assegnatario__c,NE__Asset_Configuration__c,Targa__c,Modello__c,Manutenzione_straordinaria__c
                                                FROM NE__Order__c 
                                                WHERE NE__Parent_Order__c in:idVetture 
                                                AND Tipo_Assegnatario__c!='Reparto' 
                                                AND ((Inizio_Assegnazione__c>=:dataInizio AND Fine_Assegnazione__c<=:dataFine) OR (Inizio_Assegnazione__c<=:dataInizio AND Fine_Assegnazione__c>=:dataInizio) OR (Inizio_Assegnazione__c<=:dataFine AND Fine_Assegnazione__c>=:dataFine) OR (Inizio_Assegnazione__c<=:dataInizio AND Fine_Assegnazione__c>=:dataFine))
                                                AND Prenotata__c=false
                                                AND Stato__c!='1080'
                                                ORDER BY Modello__c];
                                                
            List<NE__Order__c> tutteAssegnazioni = [SELECT Fine_Assegnazione__c, Luogo_consegna_stato_uso__c, Tipo_Assegnatario__c,Stato__c,NE__Parent_Order__c FROM NE__Order__c WHERE (Stato__c =:'1050' OR Stato__c =:'1060' OR Stato__c =:'1055' OR Stato__c =:'1045' OR Stato__c =:'1030' OR Stato__c =:'1020' OR Stato__c =:'1070')  ORDER BY Fine_Assegnazione__c ASC];           
            Map<String,List<NE__Order__c>> mappa = new  Map<String,List<NE__Order__c>>();
            List<NE__Order__c> assegnazioniPerID = new List<NE__Order__c>();
            
            for (NE__Order__c o : tutteAssegnazioni) {
            	if (mappa.containsKey(o.NE__Parent_Order__c)) {
            		List<NE__Order__c> presenti = mappa.get(o.NE__Parent_Order__c);
            		presenti.add(o);
            		mappa.put(o.NE__Parent_Order__c,presenti);
            	} else {
            		List<NE__Order__c> daAggiungere = new List<NE__Order__c>();
            		daAggiungere.add(o);
            		mappa.put(o.NE__Parent_Order__c,daAggiungere);
            	}            	
            }
              
            			
            System.debug('Assegnazioni: '+avs);
            //for sulle auto assegnate a Account diversi da Reparto (avs)
            for(NE__Order__c car:vetture){
                Wrapper.Auto vettura=new Wrapper.Auto(car);
                DateTime giornataIn=dataInizio;
                DateTime giornataFi=dataInizio; 
                System.debug('Giornata corrente:'+giornataIn);
                //scorro tutti i giorni da data inizio a data fine
                List<Wrapper.Assegnazione> manutenzioneInAssegnazione=new List<Wrapper.Assegnazione>();
                List<NE__Order__c> assegn = mappa.get(car.Id);           
                while(giornataIn.date()<=dataFine.date()){
                    Wrapper.Assegnazione ass=new Wrapper.Assegnazione(giornataIn.date().format(),'Disponibile',null);
                    ass.statoColor='color-swatch-disp';
                    System.debug('GIORNATA IN: '+giornataIn);
                    ass.luogoConsegna = verificaStatoPrecedente(car.Id,giornataIn,assegn); 
                    System.debug('LUOGO CONSEGNA: '+ass.luogoConsegna);
                        //se è l'ultimo giorno aggiorno l'ora
                    if(car.Data_assegnazione_a_reparto__c.date()<=giornataIn.date()){
	                    for(NE__Order__c av:avs){
	                        if(giornataIn.date()==av.Fine_Assegnazione__c.date()){
	                            Time t=Time.newInstance(Integer.valueOf(df.substring(10,12)),Integer.valueOf(df.substring(13,15)),Integer.valueOf(df.substring(16,18)), 0);
	                            giornataFi=datetime.newInstance(giornataIn.date(),t);
	                            giornataFi=giornataFi.addHours(1); 
	                            System.debug('Time:'+t+' Giornata Fine:'+giornataFi);
	                        }
	                        System.debug('Data Inizio:'+av.Inizio_Assegnazione__c+' Data Fine:'+av.Fine_Assegnazione__c+' GiornataIn:'+giornataIn.date()+' GiornafaFi:'+giornataFi.date());
	                        
	                        if(av.NE__Parent_Order__c==car.Id && av.Inizio_Assegnazione__c.date()<=giornataIn.date() && av.Fine_Assegnazione__c.date()>=giornataFi.date()){
	                            ass.stato=av.Tipo_Assegnatario__c;
	                            ass.assegnatario=av.NE__AccountId__r.Name;
	                            ass.luogoConsegna = av.Luogo_consegna_stato_uso__c; //assegno luogo consegna
	                            if(av.Tipo_Assegnatario__c=='Manutentore'){
	                            	if(av.Manutenzione_straordinaria__c){
	                            		/*if(av.Fine_Assegnazione__c.date()>=giornataIn.date() && av.Inizio_Assegnazione__c.date()<=giornataFi.date()){*/
	                            			Wrapper.Assegnazione temp=new Wrapper.Assegnazione();
	                            			temp.giorno=giornataIn.date().format();
	                            			temp.assegnatario=av.NE__AccountId__r.Name;
	                            			temp.stato=av.Tipo_Assegnatario__c;
	                            			temp.statoColor='color-swatch-inman';
	                            			manutenzioneInAssegnazione.add(temp);
	                            		/*}else
	                                		ass.statoColor='color-swatch-inman';*/
	                            	}else
	                            		ass.statoColor='color-swatch-inman';
	                            }else{if(av.Tipo_Assegnatario__c=='Trasportatore')
	                            			ass.statoColor='color-swatch-tras';
	                            		else
	                                		ass.statoColor='color-swatch-ass';
	                            }
	                        }  
	                    }
                    }else{
                    	ass.statoColor='color-swatch-black';
                    	ass.stato='Non Assegnata A Reparto';
                    	ass.assegnatario=null;
                    	ass.luogoConsegna = null;
                    }
                    vettura.assegnazioni.add(ass);
                    giornataIn=giornataIn.addDays(1);
                    giornataFi=giornataFi.addDays(1);
                    System.debug('Assegnazioni auto temp:'+vettura.assegnazioni);
                    
                }
                System.debug('DateDoppie:'+manutenzioneInAssegnazione);
                for(Integer i=0;i<vettura.assegnazioni.size();i++)
                	for(Integer j=0;j<manutenzioneInAssegnazione.size();j++){
                		if(vettura.assegnazioni.get(i).giorno==manutenzioneInAssegnazione.get(j).giorno && vettura.assegnazioni.get(i).statoColor=='color-swatch-ass'){
                			manutenzioneInAssegnazione.get(j).statoColor='color-swatch-inass';
                			vettura.assegnazioni.set(i,manutenzioneInAssegnazione.get(j));
                		}
						if(vettura.assegnazioni.get(i).giorno==manutenzioneInAssegnazione.get(j).giorno && vettura.assegnazioni.get(i).statoColor=='color-swatch-disp')
                			vettura.assegnazioni.set(i,manutenzioneInAssegnazione.get(j));
                		
                	}
                System.debug('Assegnazioni Auto: '+vettura.assegnazioni);
                assegnazioni.add(vettura);
            }
            System.debug('Response:'+assegnazioni);
            return assegnazioni;
        }
        catch(Exception ecc){
            System.debug('Errore getAssegnazioni: '+ecc.getMessage()+ ' at line: '+ecc.getLineNumber()+' stack trace: '+ecc.getStackTraceString());
            GestioneLog.creaLog('Assegna','getAssegnazioniReparto',ecc.getLineNumber(),ecc.getMessage(),ecc.getStackTraceString(),ecc.getTypeName(),'INPUT -> di: '+di+' df: '+df,'vetture: '+vetture+' avs: '+avs,'assegnazioni: '+assegnazioni);
            return  null;
        }
    }


    @RemoteAction
    global static List<OggettoRest> getElencoSedi(String idSede, String idAccount)
    {
        List<Sede_di_consegna__c> sedi;
        List<OggettoRest> rest = new List<OggettoRest>();
        Boolean sede= false;
        Boolean account = false;
        List<Account> acc;
        return rest;
    } 



    global class AssegnazioniCheckbox{
        private Boolean checked;
        private Boolean disable;
        private NE__Order__c assegnazione;

        public AssegnazioniCheckbox(NE__Order__c a){
            checked = false;
            disable = true;
            assegnazione = a;
        }
    }

    global class OggettoRest {
        public String NomeSede{get;set;}
        public String Indirizzo{get;set;}
        public String Cap{get;set;}
        public String Citta{get;set;}
        public String Provincia{get;set;}
        public String Riferimento{get;set;}
        public String Telefono{get;set;}
        public String Id{get;set;}
        
        public OggettoRest (Sede_di_consegna__c sc){
            NomeSede = sc.Name;
            Indirizzo = sc.Indirizzo__c;
            Cap = sc.Cap__c;
            Citta = sc.Citta__c;
            Provincia = sc.Provincia__c;
            Riferimento = sc.Riferimento__c;
            Telefono = sc.Telefono__c;
            Id = sc.Id;
        }
        /* public OggettoRest (Contratto_RAC__c c){
            NumeroContratto =c.Name;
            Intestatario =c.Intestatario__r.Name;
            DataContratto =String.valueOf(c.CreatedDate).substring(0,10);
            Stato =String.valueOf(c.Stato__c);
            NumeroAutoContratto =String.valueOf(c.numero_auto_contratto__c);
            NumeroAutoRientrate =String.valueOf(c.numero_auto_rientrate__c);
            Id = c.Id;
        } */
    }
    
}
