const Espanol =
{
"Id":"Identificar",
"Enviar":"ENVIAR con cualquier Wallet",
"Importe":"Importe",
"Descripcion":"Descripción",
"Resultado":"Estamos verificando el envío",
"Tiempo":"Tiempo de espera superado",
"Registrar":"Registrar",
"Firmar":"Firmar Documento"
}
const Ingles =
{
"Id":"Sign in",
"Enviar":"SEND with any Wallet",
"Importe":"Import",
"Descripcion":"Description",
"Resultado":"Verifying the sending of data",
"Tiempo":"Time exceeded",
"Registrar":"Sign up",
"Firmar":"Sign Document"
}
function iOS() {
 if (/iPad|iPhone|iPod/.test(navigator.userAgent) && !window.MSStream) {
    return true;
  }
  return false;
}
function Copy(sCampo)
{
	    if (iOS())
		{
            textArea = document.createElement('textArea');
			textArea.value =  $("#"+sCampo).val();
			document.body.appendChild(textArea);
			textArea.style = {position: 'absolute', left: '-999px'};
			var range,
				selection;
            range = document.createRange();
            range.selectNodeContents(textArea);
            selection = window.getSelection();
            selection.removeAllRanges();
            selection.addRange(range);
            textArea.setSelectionRange(0, 999);
			document.execCommand('copy');
			document.body.removeChild(textArea);
			window.scrollBy(0, -1000);
			alert("Copied, paste on IdTron icon")
        }
		else
		{
			const el = document.createElement('textarea');
			el.value = $("#"+sCampo).val();  
			document.body.appendChild(el);
			el.setAttribute('readonly', '');
			el.style = {position: 'absolute', left: '-999px'};
			el.select();
			document.execCommand('copy');
			document.body.removeChild(el);
			alert("Copied, paste on IdTron icon");	
		}
		
}

function Verificar (sCuenta, sIdioma,sFuncion) 
{
	$("#PanelIRS").css("display","block");
	switch (sIdioma)
	{
	case "ES":
		{oLiterales=Espanol;break}	
	case "EN":
		{oLiterales=Ingles;break}
	}
	$("#lId").text(oLiterales.Id);
	$("#lEnviar").text(oLiterales.Enviar);
	$.get( "/api/jsp/GenerarToken.jsp?Cuenta='"+sCuenta+"'", function(resp) {
		try {obj = JSON.parse(resp.trim());}
		catch {obj=resp.trim();}
		sDescripcion = obj.Descripcion;
		if (sDescripcion=="Cuenta no Registrada")
		{
			alert("Cuenta no Registrada");
		}
		else
		{
			sImporte = "1";
			$("#Importe").val(sImporte);
			$("#Descripcion").val(sDescripcion);
			$("#DatosEnviar").html("("+oLiterales.Importe+": <b>1 IdTronix</b>. "+oLiterales.Descripcion+": <b>"+sDescripcion+"</b>)");
			sText = '{"amount":"'+sImporte+'","data":"'+sDescripcion+'","token":"IdTronix","address":"'+sCuenta+'"}';
			$("#Context").val(sText);
			$("#qrcodeId").qrcode({
				render:'canvas',
				size:180,
				color:'#000',
				text:sText
			});
		}

		sDescripcion=$("#Descripcion").val();
		sImporte = $("#Importe").val();
		$("#resultado").html("<h3>"+oLiterales.Resultado+"</h3>");
		$.get( "/api/jsp/Identificar.jsp?Cuenta='"+sCuenta+"'&Descripcion='"+sDescripcion+"'", function(resp) {
			try {obj = JSON.parse(resp.trim());}
			catch {obj=resp.trim();}
			
			if (obj.From=="Error")
			{
				$("#resultado").html("<h3>"+oLiterales.Tiempo+"</h3>");
				$("#ID").css("display","none");
				$("#resultado").css("display","block");
			}
			else
			{
				if ((obj.Amount==sImporte) || (obj.Data==sDescripcion))
				{	
					$("#PanelIRS").css("display","none");
					$("#Cuenta").val(obj.From);
					eval( sFuncion + '("'+obj.From+'")' ); 
				}
			}
		});
	});
}

function Registrar (sCuenta, sIdioma, sFuncion) 
{
	$("#PanelIRS").css("display","block");
	switch (sIdioma)
	{
	case "ES":
		{oLiterales=Espanol;break}	
	case "EN":
		{oLiterales=Ingles;break}
	}
	$("#lId").text(oLiterales.Registrar);
	$.get( "/api/jsp/GenerarToken.jsp?Cuenta='"+sCuenta+"'", function(resp) {
		try {obj = JSON.parse(resp.trim());}
		catch {obj=resp.trim();}
		sDescripcion = obj.Descripcion;
		if (sDescripcion=="Cuenta no Registrada")
		{
			alert("Cuenta no Registrada");
		}
		else
		{
			sImporte = "1";
			$("#Importe").val(sImporte);
			$("#Descripcion").val(sDescripcion);
			sText = '{"data":"'+sDescripcion+'","token":"SummaTRON-R","pubkey":"04F7B6442F5CCB364A181D5EEC66A3C26281F96E7B9BA4EEDA8BFC018174B5BABBF9FBB88B236F0FB42EA6F630B0013DB5EB82A1E94146D8A223C0374B4F26AABD"}';
			$("#Context").val(sText);
			$("#qrcodeId").qrcode({
				render:'canvas',
				size:180,
				color:'#000',
				text:sText
			});
		}

		sDescripcion=$("#Descripcion").val();
		sImporte = $("#Importe").val();
		$("#resultado").html("<h3>"+oLiterales.Resultado+"</h3>");
		$.get( "/api/jsp/registrar.jsp?Cuenta='"+sCuenta+"'&Descripcion='"+sDescripcion+"'", function(resp) {
			try {obj = JSON.parse(resp.trim());}
			catch {obj=resp.trim();}
			if (obj.Fichero=="Error")
			{
				$("#resultado").html("<h3>"+oLiterales.Tiempo+"</h3>");
				$("#ID").css("display","none");
				$("#resultado").css("display","block");
			}
			else
			{	
				$("#PanelIRS").css("display","none");
				eval( sFuncion + '("'+obj.Fichero+'","'+sIdioma+'")' ); 
			}
		});
	});
}
function Firmar (sCuenta, sIdioma, sFichero, sFuncion) 
{
	$("#PanelIRS").css("display","block");
	switch (sIdioma)
	{
	case "ES":
		{oLiterales=Espanol;break}	
	case "EN":
		{oLiterales=Ingles;break}
	}
	$("#lId").text(oLiterales.Firmar);
	$.get( "/api/jsp/GenerarToken.jsp?Cuenta='"+sCuenta+"'", function(resp) {
		try {obj = JSON.parse(resp.trim());}
		catch {obj=resp.trim();}
		var sMD5="";
		$.get( "/api/jsp/md5.jsp?Fichero='"+sFichero+"'", function(resp) {
			try {obj1 = JSON.parse(resp.trim());}
			catch {obj1=resp.trim();}
			sMD5 = obj1.md5;
			sDescripcion = obj.Descripcion;
			if (sDescripcion=="Cuenta no Registrada")
			{
				alert("Cuenta no Registrada");
			}
			else
			{
				sImporte = "1";
				$("#Importe").val(sImporte);
				$("#Descripcion").val(sDescripcion);
				sText = '{"data":"'+sDescripcion+'","token":"SummaTRON-S","address":"'+sCuenta+'","md5":"'+sMD5+'"}';
				$("#Context").val(sText);
				$("#qrcodeId").qrcode({
					render:'canvas',
					size:180,
					color:'#000',
					text:sText
				});
			}
			sDescripcion=$("#Descripcion").val();
			sImporte = $("#Importe").val();
			$("#resultado").html("<h3>"+oLiterales.Resultado+"</h3>");
			$.get( "/api/jsp/signer.jsp?Cuenta='"+sCuenta+"'&Descripcion='"+sDescripcion+"'", function(resp) {
				try {obj = JSON.parse(resp.trim());}
				catch {obj=resp.trim();}
				if (obj.Fichero=="Error")
				{
					$("#resultado").html("<h3>"+oLiterales.Tiempo+"</h3>");
					$("#ID").css("display","none");
					$("#resultado").css("display","block");
				}
				else
				{	
					$("#PanelIRS").css("display","none");
					eval( sFuncion + '("'+obj.Fichero+'")' ); 
				}
			});
		});
	});
}