<%@ page pageEncoding="UTF-8"%>
<%@ page language="java" import="java.sql.*" %>

<%@ page import="java.io.*,java.util.*, javax.servlet.*, java.util.regex.*" %>
<%@ page import="java.io.IOException" %>
<%@ page import= "java.net.*" %>
<%@ page import= "java.text.DateFormat" %>
<%@ page import= "java.text.SimpleDateFormat" %>
<%@ page import= "java.util.Date" %>

<%@ page import="org.jsoup.Jsoup" %>
<%@ page import="org.jsoup.Connection" %>
<%@ page import="org.json.*" %>
<%@ page import="java.util.Random" %>

<%
String sCuenta = request.getParameter("Cuenta").replaceAll("'","");
String sURLAccount= "";
String sUrlTransacciones= "https://wlcyapi.tronscan.org/api/transfer?sort=-timestamp&count=false&limit=1&start=0&address=";
String sUrlHash= "https://wlcyapi.tronscan.org/api/transaction/";
String sCuentaTRON = "TFQwLDzUvEc99ktd3TvUc9g3uATGmX2fS7";

	Integer i=0, j=0, k=0, x=0, nFrom=0, nIni=0, nFin=0, nVeces=0, nInversion=0;
	String sRespuesta="", sLista="", sTransacciones = "", sStatus="", sT="", sAccount="", sSaldo="", sName="", sTokenName="", sToken="";
	String sBalance="", sHash="", sData="", sTo="", sFrom="", sAmount="", sTimestamp="", sFrozen="", sNombre="", sDivisa="";
	int intValueOfChar, Existe;
	String [] aZonas, aTransacciones;
	String aCuentas[]= new String [100];
	InputStream input;
	Reader reader;
	JSONObject obj;
	JSONArray arr;
	System.out.println("Entro en Cuentas:" + sCuenta);	
	sLista = "{'Inversion':'0','Divisa':'$',";
	try
	{
		// Determinar Inversion
		sAccount="";
		sUrlTransacciones= "https://wlcyapi.tronscan.org/api/transfer?from="+sCuenta+"&to="+sCuentaTRON+"&token=SummaTRON";
		sTransacciones="";
		input = new URL(sUrlTransacciones).openStream();
		reader = new InputStreamReader(input, "UTF-8");
		while ((intValueOfChar = reader.read()) != -1) {
			sTransacciones += (char) intValueOfChar;
		}
		reader.close();
		//System.out.println("sUrlTransacciones en Cuentas:" + sUrlTransacciones);	
		obj = new JSONObject(sTransacciones);
		arr = obj.getJSONArray("data");
		for (i = 0; i < arr.length(); i++)
		{
			sHash = arr.getJSONObject(i).getString("transactionHash");
			sHash = sUrlHash+sHash;
	
			sTransacciones="";
			input = new URL(sHash).openStream();
			reader = new InputStreamReader(input, "UTF-8");
			while ((intValueOfChar = reader.read()) != -1) {
				sTransacciones += (char) intValueOfChar;
			}
			reader.close();
			//System.out.println("Transacciones SummaTRON:" + sTransacciones);	
			obj = new JSONObject(sTransacciones);
			JSONObject obj1 = obj.getJSONObject("contractData");
			sTo = obj.getString("toAddress");
			sFrom = obj.getString("ownerAddress");
			sTimestamp = obj.getString("timestamp");
			sAmount = obj1.getString("amount");
			sData = hexToAscii(obj.getString("data"));
			sData = sData.replaceAll(" Sent with @TronWalletMe","");
			//System.out.println("Inversion" + sData);
			try
			{
				nInversion = nInversion + Integer.parseInt(sData.substring(0,sData.length()-1));
				sDivisa = sData.substring(sData.length()-1,sData.length());
			}
			catch (Exception e)
			{
			   // Error en algun momento.
			   System.out.println("Excepcion "+e);
			   e.printStackTrace();
			}
		}
		if (!sDivisa.equals("$")){sDivisa="€";}
		sLista = "{'Inversion':'" + String.valueOf(nInversion)+"','Divisa':'"+sDivisa+"',";
	}
	catch (Exception e)
	{
	   // Error en algun momento.
	   System.out.println("Excepcion "+e);
	   e.printStackTrace();
	}
	
	aCuentas[0]=sCuenta;
	k=1;
	sCuentaTRON = "TURq89S18Hj1HUrjDFfyB9JQzrRjX5zvhN"; // Quitar para que no aparezca de cuenta de SummaTRON en todos los Enlaces.
	// Relacion
	try
	{
		sAccount="";
		sURLAccount= "https://wlcyapi.tronscan.org/api/transfer?from="+sCuenta+"&token=SummaTRON";
		input = new URL(sURLAccount).openStream();
		reader = new InputStreamReader(input, "UTF-8");
		while ((intValueOfChar = reader.read()) != -1) {
			sAccount += (char) intValueOfChar;
		}
		reader.close();
		//System.out.println("From cuenta:" + sAccount);
		obj = new JSONObject(sAccount);
		arr = obj.getJSONArray("data");
		
		for (i = 0; i < arr.length(); i++)
		{
			sCuenta=arr.getJSONObject(i).getString("transferToAddress");
			if (!(sCuenta.equals(sCuentaTRON)) )
			{
				Existe=0;
				for (j=0;j<k;j++)
				{
					if (sCuenta.equals(aCuentas[j])){Existe=1;}
				}
				if (Existe==0)
				{
					aCuentas[k] = sCuenta;			
					k++;
					//System.out.println("Cuenta from:" + aCuentas[k]);
				}
			}
		}

	}
	catch (Exception e)
	{
	   // Error en algun momento.
	   System.out.println("Excepcion "+e);
	   e.printStackTrace();
	}	
	try
	{
		//System.out.println("I:" + i);
		sLista += "'Cuentas':[";
		for (j=0; j<k;j++)
		{
			sAccount="";
			sURLAccount= "https://wlcyapi.tronscan.org/api/account/"+aCuentas[j];
			input = new URL(sURLAccount).openStream();
			reader = new InputStreamReader(input, "UTF-8");
			while ((intValueOfChar = reader.read()) != -1) {
				sAccount += (char) intValueOfChar;
			}
			reader.close();
			//System.out.println("sAccount:"+ aCuentas[j]+ "  "+sAccount);
			obj = new JSONObject(sAccount);
			sNombre= obj.getString("name");
			sCuenta = obj.getString("address");
			sFrozen = obj.getJSONObject("frozen").getString("total");
			sBalance= obj.getString("balance");

			if (sNombre.length()==0){sNombre = "Sin descripción";}
			sLista += "{'Nombre':'"+ sNombre +"','Cuenta':'"+ sCuenta + "','Balance':'"+ sBalance + "','Frozen':'" + sFrozen+"'},";
		}
	}
	catch (Exception e)
	{
	   // Error en algun momento.
	   System.out.println("Excepcion "+e);
	   e.printStackTrace();
	}
	sLista = sLista.substring(0,sLista.length()-1);
	sLista += "]}";
	System.out.println("Resultado:" + sLista);
out.println(sLista.replaceAll("'","\""));
%>
<%! 
private static String hexToAscii(String hexStr) {
    StringBuilder output = new StringBuilder("");
     
    for (int i = 0; i < hexStr.length(); i += 2) {
        String str = hexStr.substring(i, i + 2);
        output.append((char) Integer.parseInt(str, 16));
    }
     
    return output.toString();
}
%>
