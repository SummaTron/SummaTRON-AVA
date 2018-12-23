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
String sUrlTransacciones= "https://api.tronscan.org/api/transfer?sort=-timestamp&count=true&limit=1&start=0&address="+sCuenta;
String sUrlHash= "https://api.tronscan.org/api/transaction/";

	Integer i=0, k=0, nIni=0, nFin=0, nVeces=0;
	String sRespuesta="", sLista="", sTransacciones = "", sStatus="", sT="", sAccount="", sSaldo="", sName="", sTokenName="", sToken="";
	String sBalance="", sHash="", sData="", sTo="", sFrom="", sAmount="", sTimestamp;
	int intValueOfChar;
	String [] aZonas, aTransacciones;
	sLista = "{'From':'','Amount':'','Token':'','Data':'Diferente'}";
	InputStream input;
	Reader reader;
	JSONObject obj;
	JSONArray arr;

	// Localiza la última transaccion
	while (k<30)	
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
			for (i = 0; i < arr.length(); i++)
			{
				sToken = arr.getJSONObject(i).getString("tokenName");		
				sHash = arr.getJSONObject(i).getString("transactionHash");
				sHash = sUrlHash+sHash;
				System.out.println("Hash:" + sHash);
				break;
			}
			//System.out.println("Hash:" + sHash);
				
			// Localiza el detalle de la ultima transaccion
			
			sTransacciones="";
			input = new URL(sHash).openStream();
			reader = new InputStreamReader(input, "UTF-8");
			while ((intValueOfChar = reader.read()) != -1) {
				sTransacciones += (char) intValueOfChar;
			}
			reader.close();
			System.out.println(sTransacciones);	
			obj = new JSONObject(sTransacciones);
			JSONObject obj1 = obj.getJSONObject("contractData");
			sTo = obj.getString("toAddress");
			sFrom = obj.getString("ownerAddress");
			sTimestamp = obj.getString("timestamp");
			sAmount = obj1.getString("amount");
			
			sData = hexToAscii(obj.getString("data"));
			sData = sData.replaceAll(" Sent with @TronWalletMe","");
			if (sToken.equals("TRX"))
			{
				Double dAmount = Double.valueOf(sAmount)/1000000;
				sAmount = Double.toString(dAmount);
				sAmount+= "000000";
				sAmount = sAmount.substring (0,8);
			}
			//System.out.println("sAmount:" + sAmount) ;
			
			Long nDif=System.currentTimeMillis()-Long.valueOf(sTimestamp);
			System.out.println("Data:" + sData + " = "+sDescripcion + " Dif:"+nDif);
			System.out.println(sData.equals(sDescripcion));
			sLista = "{'From':'Error','Amount':'Error','Token':'Error','Data':'Error'}";
			if (nDif<10000) 
			{
				//if (sImporte.indexOf(sAmount)>-1 || (sData.indexOf(sDescripcion) > -1 ) )
				if (sData.equals(sDescripcion))
				{
					sLista = "{'From':'"+sFrom + "','Amount':'"+ sAmount + "','Token':'" + sToken + "','Data':'"+ sData +"'}";
				}
				else
				{
					sLista = "{'From':'"+sFrom + "','Amount':'"+ sAmount + "','Token':'" + sToken + "','Data':'Diferente'}";
				}
				k=31;
			}
			else
			{	Thread.sleep(2000); k++;}
			
			System.out.println("Data:" + sLista);
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
