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
"Id":"Identify",
"Enviar":"SEND with any Wallet",
"Importe":"Import",
"Descripcion":"Description",
"Resultado":"Verifying the sending of data",
"Tiempo":"Time exceeded",
"Registrar":"Sign up",
"Firmar":"Sign Document"
}

function Copy(sCampo)
{
  const el = document.createElement('textarea');
  el.value = $("#"+sCampo).val();
  alert("Datos copiados, pulse en icono de IdTron");
  document.body.appendChild(el);
  el.setAttribute('readonly', '');
  el.style = {position: 'absolute', left: '-9999px'};
  el.select();
  document.execCommand('copy');
  document.body.removeChild(el);
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
		var obj = JSON.parse(resp);
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
			var qrcodeId = new QRCode(document.getElementById("qrcodeId"), {
				width : 180,
				height : 180
			});
			sText = '{"amount":"'+sImporte+'","data":"'+sDescripcion+'","token":"IdTronix","address":"'+sCuenta+'"}';
			$("#Context").val(sText);
			qrcodeId.makeCode(sText);
		}


		sDescripcion=$("#Descripcion").val();
		sImporte = $("#Importe").val();
		$("#resultado").html("<h3>"+oLiterales.Resultado+"</h3>");
		$.get( "/api/jsp/Identificar.jsp?Cuenta='"+sCuenta+"'&Descripcion='"+sDescripcion+"'", function(resp) {
			obj = JSON.parse(resp);
			
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
		obj = JSON.parse(resp);
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
			var qrcodeId = new QRCode(document.getElementById("qrcodeId"), {
				width : 180,
				height : 180
			});
			sText = '{"data":"'+sDescripcion+'","token":"SummaTRON-R","pubkey":"04F88ED5928B9A5C4CE1901E1C0F580E20F43BF89B9C940F7E69FD89DA47E75AE310175096296970A60171B381FC6FB9AAE3D8BE1CD515AF622808999CA278067F"}';
			$("#Context").val(sText);
			qrcodeId.makeCode(sText);
		}

		sDescripcion=$("#Descripcion").val();
		sImporte = $("#Importe").val();
		$("#resultado").html("<h3>"+oLiterales.Resultado+"</h3>");
		$.get( "/api/jsp/registrar.jsp?Cuenta='"+sCuenta+"'&Descripcion='"+sDescripcion+"'", function(resp) {
			console.log("Registro: "+ resp);
			obj = JSON.parse(resp);
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
		obj = JSON.parse(resp);
		var sMD5="";
		$.get( "/api/jsp/md5.jsp?Fichero='"+sFichero+"'", function(resp) {
			var obj1 = JSON.parse(resp);
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
				var qrcodeId = new QRCode(document.getElementById("qrcodeId"), {
					width : 180,
					height : 180
				});
				sText = '{"data":"'+sDescripcion+'","token":"SummaTRON-S","address":"'+sCuenta+'","md5":"'+sMD5+'"}';
				$("#Context").val(sText);
				qrcodeId.makeCode(sText);
			}
			sDescripcion=$("#Descripcion").val();
			sImporte = $("#Importe").val();
			$("#resultado").html("<h3>"+oLiterales.Resultado+"</h3>");
			$.get( "/api/jsp/signer.jsp?Cuenta='"+sCuenta+"'&Descripcion='"+sDescripcion+"'", function(resp) {
				console.log("Firma: "+ resp);
				obj=JSON.parse(resp);
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