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

	Integer i=0, j=0, k=0, x=0, nFrom=0, nIni=0, nFin=0, nVeces=0;
	String sRespuesta="", sLista="", sTransacciones = "", sStatus="", sT="", sAccount="", sSaldo="", sName="", sTokenName="", sToken="";
	String sBalance="", sHash="", sData="", sTo="", sFrom="", sAmount="", sTimestamp="", sFrozen="", sNombre="", sInversion="";
	int intValueOfChar, Existe;
	
	System.out.println("Entro en Cuentas:" + sCuenta);	
	// Determinar Inversion
	sAccount="";
	String sUrlTransacciones= "https://wlcyapi.tronscan.org/api/transfer?sort=-timestamp&count=true&limit=10&start=0&address="+sCuenta;
	sTransacciones="";
	InputStream input = new URL(sUrlTransacciones).openStream();
	Reader reader = new InputStreamReader(input, "UTF-8");
	while ((intValueOfChar = reader.read()) != -1) {
		sTransacciones += (char) intValueOfChar;
	}
	reader.close();
	System.out.println("sUrlTransacciones en Cuenta:" + sUrlTransacciones);	
	JSONObject obj = new JSONObject(sTransacciones);
	JSONArray arr = obj.getJSONArray("data");
	sLista = "{'data':[";
	for (i = 0; i < arr.length(); i++)
	{
		sToken = arr.getJSONObject(i).getString("tokenName");	
		sTo =  arr.getJSONObject(i).getString("transferToAddress");
		sFrom =  arr.getJSONObject(i).getString("transferFromAddress");
		sTimestamp =  arr.getJSONObject(i).getString("timestamp");
		sAmount =  arr.getJSONObject(i).getString("amount");
		if (sToken.equals("TRX"))
		{
			Double dAmount = Double.valueOf(sAmount)/1000000;
			sAmount = Double.toString(dAmount);
			sAmount+= "000000";
			sAmount = sAmount.substring (0,8);
		}
		sLista = sLista + "{'From':'"+sFrom+"','To':'"+ sTo +"','Token':'" + sToken +"','Timestamp':"+sTimestamp+",'Amount':'"+sAmount+"'},";
	}
	sLista = sLista.substring(0,sLista.length()-1) + "]}";
	// Localiza el detalle de la ultima transaccion
	
	System.out.println("Data:" + sLista);

out.println(sLista.replaceAll("'","\""));

%>
