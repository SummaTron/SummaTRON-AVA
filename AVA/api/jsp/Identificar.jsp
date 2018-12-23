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
String sCuenta= request.getParameter("Cuenta").replaceAll("'","");
String sDescripcion = request.getParameter("Descripcion").replaceAll("'","");

String sUrlTransacciones= "https://api.tronscan.org/api/transaction?sort=-timestamp&limit=3&token=IdTronix&address="+sCuenta;
//String sDate_Start = Long.toString(System.currentTimeMillis()-10000000);
//String sUrlTransacciones= "https://wlcyapi.tronscan.org/api/transfer?token=IdTronix&to="+sCuenta+"&date_start="+sDate_Start;
//String sUrlHash= "https://wlcyapi.tronscan.org/api/transaction/";
System.out.println("ENTRO EN IDENTIFICAR:"+sDescripcion);
	Integer i=0, k=0, nTope=0, nIni=0, nFin=0, nVeces=0;
	String sRespuesta="", sLista="", sTransacciones = "", sStatus="", sT="", sAccount="", sSaldo="", sName="", sTokenName="", sToken="";
	String sBalance="", sHash="", sData="", sTo="", sFrom="", sAmount="", sTimestamp;
	int intValueOfChar;
	String [] aZonas, aTransacciones;
	sLista = "{'From':'Error','Amount':'Error','Token':'Error','Data':'Error'}";
	InputStream input;
	Reader reader;
	JSONObject obj;
	JSONArray arr;
	System.out.println("Entro en Identificar:" + sCuenta + " " + sDescripcion);
	// Localiza la última transaccion
	System.out.println(sUrlTransacciones);
	// Localiza la última transaccion
	while (k<60)	
	{
		try
		{
			sTransacciones="";
			input = new URL(sUrlTransacciones).openStream();
			reader = new InputStreamReader(input, "UTF-8");
			while ((intValueOfChar = reader.read()) != -1) {
				sTransacciones += (char) intValueOfChar;
			}
			reader.close();
			obj = new JSONObject(sTransacciones);
			arr = obj.getJSONArray("data");
			i=0;
			nTope=arr.length();
			if (nTope>3){nTope=3;}
			while (i < nTope)
			{	
				try
				{
					sTo = arr.getJSONObject(i).getString("toAddress");
					sFrom = arr.getJSONObject(i).getString("ownerAddress");
					sTimestamp = arr.getJSONObject(i).getString("timestamp");
					
					sData = arr.getJSONObject(i).getString("data");	
					if (sData.indexOf("-")<0)
					{sData = hexToAscii(arr.getJSONObject(i).getString("data"));}	
					
					sData = sData.replaceAll(" Sent from TronWallet","");
					

					Long nDif=System.currentTimeMillis()-Long.valueOf(sTimestamp);
					//System.out.println("Data:" + sData + " = "+sDescripcion + " Dif:"+nDif);
					//System.out.println(sData.equals(sDescripcion));
					//System.out.print(i) ;
					//System.out.print ("  " + sData + " "+ sDescripcion + " ");
					//System.out.println (nDif);
					
					if (nDif<60000) 
					{
						if (sData.equals(sDescripcion))
						{
							sLista = "{'From':'"+sFrom + "','Amount':'1','Token':'IdTronix','Data':'"+ sData +"'}";
							k=100;
							i=100;
							break;
						}
						else
						{i++;}
					}
					else
						{i++;}
				}
				catch (Exception e) {i++;}
			}
			if (k<61)
			{Thread.sleep(2000); k++;}
			//System.out.println("Data:" + sLista);
		}
		catch (Exception e)
		{
		   // Error en algun momento.
		   System.out.println("Excepcion "+e);
		   e.printStackTrace();
		}
	}
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
