function AssegnaUtenteCtrl($scope, $route, $location, DatePickerService, SweetAlert, cliente, sedeConsegna){
	//console.log("Assegna utenti");
	$scope.$parent.initdone.then(function(){
		$scope.assegnatario = cliente;
		$scope.sedeConsegna = sedeConsegna;
		$scope.edit = true;
		$scope.error = false;
		$scope.incomplete = false; 
		$scope.hideform = true; 
		$scope.data = {};
		$scope.opzioni = {};
		$scope.data.loadPatente = true;
		if($scope.assegnatario.Tipologia_Cliente__c == undefined)
			$scope.assegnatario.Tipologia_Cliente__c="azienda";
		else{
			$scope.data.disabledCombo = true;
			$scope.data.loadPatente = false;
		}
		$scope.opzioni.tipo_cliente = [{id:"Dipendente",name:"Dipendente"},{id:"Esterno",name:"Esterno"}];
		$scope.opzioni.categoria_cliente = [{id:$Label.CCP_CustomerCategory,name:$Label.CCP_CustomerCategory}];
		if($scope.assegnatario.Tipo_Cliente_I_livello__c == undefined)
			$scope.assegnatario.Tipo_Cliente_I_livello__c = $scope.opzioni.categoria_cliente[0].id;
		$scope.opzioni.categoria_cliente_lv2 = [{id:"TBD",name:"TBD"}];
		if($scope.assegnatario.Tipo_Cliente_II_livello__c == undefined)
			$scope.assegnatario.Tipo_Cliente_II_livello__c = $scope.opzioni.categoria_cliente_lv2[0].id;
		
		$scope.open = function ($event, field){
				DatePickerService.open($event, $scope.data, field);
		}
		
		
		$scope.data.urlBack="#/"
		if($location.search().fromAss!=undefined){
			$scope.data.urlBack="#/createReq?fromAss=true";
		}else if($location.search().fromMassgn!=undefined)
			$scope.data.urlBack="#/monitorassegnatari?fromMassgn=true";
		
		$scope.deletePatente = function(){
			SweetAlert.swal({
				   title: $Label.CCP_RemoveDivingLicense,
				   text: "",
				   type: "warning",
				   showCancelButton: true,
				   confirmButtonColor: "#DD6B55",confirmButtonText: $Label.CCP_Remove,
				   cancelButtonText: $Label.CCP_Cancels,
				   closeOnConfirm: false,
				   closeOnCancel: false }, 
				function(isConfirm){ 
				   if (isConfirm) {
					   $scope.data.loadPatente = true;
					   SweetAlert.swal($Label.CCP_Deleted, $Label.CCP_DivingLicenseRemoved, "success");
	//				   var sez = $scope.sezione;
	//				   if(sez == undefined) sez = "assegnatario";
	//				   HomeController.cancellaFile($scope.assegnatario.idFilePatente, sez, function(result, event){
	//						if(event.status && result){
	//							$scope.assegnatario.idFilePatente = "";
	//							$scope.data.loadPatente = true;
	//						    SweetAlert.swal($Label.CCP_Deleted, $Label.CCP_DivingLicenseRemoved, "success");
	//						}else{
	//							SweetAlert.swal($Label.CCP_Error, $Label.CCP_GenericError, "error");
	//						}
	//				   });
				   } else {
				      SweetAlert.swal($Label.CCP_Canceled, $Label.CCP_OperationCanceled, "error");
				   }
				});
		}
		

		

		$scope.save = function(){
				var isnum = /^\d+$/.test($scope.assegnatario.BillingPostalCode);
				if(($scope.assegnatario.Nome__c == "" || $scope.assegnatario.Nome__c == undefined) && $scope.assegnatario.Tipologia_Cliente__c != "rac"){
					SweetAlert.swal($Label.CCP_InsertName);
					return false;
				}
				if(($scope.assegnatario.Cognome__c == "" || $scope.assegnatario.Cognome__c == undefined) && $scope.assegnatario.Tipologia_Cliente__c != "rac"){
					SweetAlert.swal($Label.CCP_InsertLastName);
					return false;
				}
				if(($scope.assegnatario.Data_di_Nascita_text__c == "" || $scope.assegnatario.Data_di_Nascita_text__c == undefined) && $scope.assegnatario.Tipologia_Cliente__c != "rac"){
					SweetAlert.swal($Label.CCP_InsertBirthsDate);
					return false;
				}
				if(($scope.assegnatario.Comune_di_Nascita__c == "" || $scope.assegnatario.Comune_di_Nascita__c == undefined) && $scope.assegnatario.Tipologia_Cliente__c != "rac"){
					SweetAlert.swal($Label.CCP_CityBirth);
					return false;
				}
				
				if(($scope.assegnatario.Provincia_di_Nascita__c == "" || $scope.assegnatario.Provincia_di_Nascita__c == undefined) && $scope.assegnatario.Tipologia_Cliente__c != "rac"){
					SweetAlert.swal($Label.CCP_BirthsCounty);
					return false;
				}
				if(($scope.assegnatario.Nome_Azienda__c == "" || $scope.assegnatario.Nome_Azienda__c == undefined) && $scope.assegnatario.Tipologia_Cliente__c == "azienda"){
					SweetAlert.swal($Label.CCP_InsertCompanyName);
					return false;
				}
				if(($scope.assegnatario.Codice_Fiscale__c == "" || $scope.assegnatario.Codice_Fiscale__c == undefined) && $scope.assegnatario.Tipologia_Cliente__c != "rac"){
					SweetAlert.swal($Label.CCP_InsertTaxCod);
					return false;
				}
				var isCF = /^[A-Za-z]{6}[0-9]{2}[A-Za-z]{1}[0-9]{2}[A-Za-z]{1}[0-9]{3}[A-Za-z]{1}$/.test($scope.assegnatario.Codice_Fiscale__c);
				if(!isCF && $scope.assegnatario.Tipologia_Cliente__c != "rac"){
					SweetAlert.swal($Label.CCP_InvalidTaxCode);
					return false;
				}
				if(($scope.assegnatario.Partita_IVA__c == "" || $scope.assegnatario.Partita_IVA__c == undefined) && ($scope.assegnatario.Tipologia_Cliente__c == "azienda" || $scope.assegnatario.Tipologia_Cliente__c == "rac")){
					SweetAlert.swal($Label.CCP_InsertVAT);
					return false;
				}
				var isIVA = /^[0-9]{11}$/.test($scope.assegnatario.Partita_IVA__c);
				if(!isIVA && ($scope.assegnatario.Tipologia_Cliente__c == "azienda" || $scope.assegnatario.Tipologia_Cliente__c == "rac")){
					SweetAlert.swal($Label.CCP_InvalidVAT);
					return false;
				}
				if($scope.assegnatario.BillingStreet == "" || $scope.assegnatario.BillingStreet == undefined){
					SweetAlert.swal($Label.CCP_InsertAddress);
					return false;
				}
				if($scope.assegnatario.BillingPostalCode == "" || $scope.assegnatario.BillingPostalCode == undefined){
					SweetAlert.swal($Label.CCP_InsertZipCode);  
					return false;
				}
				if($scope.assegnatario.BillingState == "" || $scope.assegnatario.BillingState == undefined){
					SweetAlert.swal($Label.CCP_InsertCity);
					return false;
				}
				if($scope.assegnatario.BillingCity == "" || $scope.assegnatario.BillingCity == undefined){
					SweetAlert.swal($Label.CCP_InsertCounty);
					return false;
				}
				if(!isnum){
					SweetAlert.swal($Label.CCP_InvalidPostalCode);
					return false;
				}
				if(($scope.assegnatario.Numero_Patente__c == "" || $scope.assegnatario.Numero_Patente__c == undefined) && $scope.assegnatario.Tipologia_Cliente__c != "rac"){
					SweetAlert.swal($Label.CCP_InsertDriversLicenseNumber);
					return false;
				}
				if(($scope.assegnatario.Data_scadenza_patente_text__c == "" || $scope.assegnatario.Data_scadenza_patente_text__c == undefined) && $scope.assegnatario.Tipologia_Cliente__c != "rac"){
					SweetAlert.swal($Label.CCP_InsertDriversLicenseEndDate);
					return false;
				}
				if($scope.data.isuploadedpatente == undefined)
					$scope.data.isuploadedpatente = true;
				if(!$scope.data.isuploadedpatente){
					SweetAlert.swal($Label.CCP_UploadDriversLicense);
					return false;
				}
				if(($scope.assegnatario.Email__c == "" || $scope.assegnatario.Email__c == undefined) && $scope.assegnatario.Tipologia_Cliente__c != "rac"){
					SweetAlert.swal($Label.CCP_InsertEmail);
					return false;
				}
				if(($scope.assegnatario.Telefono__c == "" || $scope.assegnatario.Telefono__c == undefined) && $scope.assegnatario.Tipologia_Cliente__c != "rac"){
					SweetAlert.swal($Label.CCP_InsertPhoneNumber);
					return false;
				}

				if(($scope.sedeConsegna.name == "" || $scope.sedeConsegna.name == undefined) && $scope.assegnatario.Tipologia_Cliente__c == "rac"){
					SweetAlert.swal($Label.CCP_InsertLocation);
					return false;
				} 

				$scope.$parent.showLoading(true);
				$scope.assegnatario.Data_di_Nascita_text__c = angular.isDate($scope.assegnatario.Data_di_Nascita_text__c) ? formatDate($scope.assegnatario.Data_di_Nascita_text__c) : $scope.assegnatario.Data_di_Nascita_text__c;
				$scope.assegnatario.Data_scadenza_patente_text__c = angular.isDate($scope.assegnatario.Data_scadenza_patente_text__c) ? formatDate($scope.assegnatario.Data_scadenza_patente_text__c) : $scope.assegnatario.Data_scadenza_patente_text__c;
				$scope.assegnatario.NE__Type__c = $scope.assegnatario.Tipologia_Cliente__c;
				var ass = JSON.stringify($scope.assegnatario);
				var sedeCons = JSON.stringify($scope.sedeConsegna);
				//console.log(ass);
				Assegna.insertAccount(ass, function(result, event){
					if(event.status && result){
						//$scope.$parent.showLoading(false);
						$scope.$apply(function(){
							$scope.$parent.cacheApprovSearch.removeAll();
							if($location.search().fromAss!=undefined){
								$location.path('/createReq').search('fromAss',true);
							}else if($location.search().fromMassgn!=undefined){
								$route.reload();
								//$location.path('/assegnautente/'+result).search('fromMassgn',true);
							}else
								$location.path('/assegnautente/'+result+'?');
						});
						
						//$scope.$parent.forceReloadData = true;
						//$route.reload();
					}else{	
						$scope.$parent.showLoading(false);
						SweetAlert.swal($Label.CCP_GenericError);	
							
					}
				});	

				Assegna.insertSedeConsegna(sedeCons, function(result, event){
					if(event.status && result){
						//$scope.$parent.showLoading(false);
						$scope.$apply(function(){
							$scope.$parent.cacheApprovSearch.removeAll();
							if($location.search().fromAss!=undefined){
								$location.path('/createReq').search('fromAss',true);
							}else if($location.search().fromMassgn!=undefined){
								$route.reload();
								//$location.path('/assegnautente/'+result).search('fromMassgn',true);
							}else
								$location.path('/assegnautente/'+result+'?');
						});
						
						//$scope.$parent.forceReloadData = true;
						//$route.reload();
					}else{	
						$scope.$parent.showLoading(false);
						SweetAlert.swal($Label.CCP_GenericError);	
							
					}
				});
		}

		/* $scope.executeSearch = function(){
			$scope.showLoading(true);
			
			Assegna.getElencoContratti(dataI, dataF, intest, stato, numeroContr, targa, telaio, function(result, event){ //telaio,targa
				originalsearch = angular.copy(result);
				if(event.status && result){
					$scope.search.result=result;
					$scope.$parent.showLoading(false);
				
				}else{ 
					$scope.$parent.showLoading(false);
					SweetAlert.swal($Label.CCP_GenericError);
				}
				$scope.showLoading(false);	
				$scope.$apply();
			});  
		};
		
		if($location.search().fromMassgn!=undefined && $scope.$parent.cacheMonAssgn.info()["size"]>0){
			$scope.search.filter.initdate = $scope.$parent.cacheMonAssgn.get("dataI");
			$scope.search.filter.enddate = $scope.$parent.cacheMonAssgn.get("dataF");
			$scope.search.Intestatario__c = $scope.$parent.cacheMonAssgn.get("intest");
			$scope.search.Stato__c = $scope.$parent.cacheMonAssgn.get("stato");
			$scope.search.Name = $scope.$parent.cacheMonAssgn.get("numeroContr");
			$scope.search.Targa = $scope.$parent.cacheMonAssgn.get("targa");
			$scope.search.Telaio = $scope.$parent.cacheMonAssgn.get("telaio");
			
			$scope.executeSearch();
		}else $scope.$parent.cacheMonAssgn.removeAll();
	}); */



		$scope.saveSede = function()
		{
			if(($scope.sedeConsegna.name == "" || $scope.sedeConsegna.name == undefined) && $scope.assegnatario.Tipologia_Cliente__c == "rac")
			{
				SweetAlert.swal($Label.CCP_InsertLocation);
				return false;
			}

			var sedeCons = JSON.stringify($scope.sedeConsegna);

			$scope.$parent.showLoading(true);
			Assegna.insertSedeConsegna(sedeCons, function(result, event){
				if(event.status && result){
					
						$scope.$parent.showLoading(false);
						SweetAlert.swal($Label.CCP_sedeInserita);
						$scope.sedeConsegna.name = '';
						$scope.sedeConsegna.Indirizzo__c = '';
						$scope.sedeConsegna.Cap__c = '';
						$scope.sedeConsegna.Citta__c = '';
						$scope.sedeConsegna.Provincia__c = '';
						$scope.sedeConsegna.Telefono__c = '';
						$scope.sedeConsegna.Riferimento__c = '';
						$scope.hideform = true;
						return false;										
				}
			});

		}
		
		$scope.bloccaSblocca = function(){
			 
			$scope.$parent.showLoading(true);
			Assegna.sbloccaCliente($scope.assegnatario.Black_List__c,$scope.assegnatario.Id, function(result, event){
					if(event.status && result){
							$route.reload();
						}else{
							$scope.$parent.showLoading(false);
							SweetAlert.swal($Label.CCP_GenericError);
					}
				});		
		}
		
		$scope.changeTipologia = function(){
			var value = $scope.assegnatario.Tipologia_Cliente__c; 
			$scope.assegnatario = {};
			var temp = $scope.data.urlBack;
			$scope.data = {};
			$scope.data.urlBack = temp; // :)
			$scope.data.loadPatente = true;
			$scope.assegnatario.Tipologia_Cliente__c = value;
		}
	});

		$scope.creaSede = function(id) 
		{
			 //$scope.hideform = false;
			 if($scope.hideform == true)
			 {
			 	$scope.hideform = false;	
			 }

			 else
			 {
			 	$scope.hideform = true;	
			 }	


			 if (id == 'new') 
			 {
			   $scope.edit = true;
			   $scope.incomplete = true;			   
			   $scope.name = '';
			 } 
			 else 
			 {
			   $scope.edit = false;
			   //$scope.fName = $scope.users[id-1].fName;
			   //$scope.lName = $scope.users[id-1].lName; 
			  }
		};	
} 
