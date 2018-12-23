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
String sUrlTransacciones= "https://api.tronscan.org/api/transfer?sort=-timestamp&count=true&limit=3&start=0&address="+sCuenta;
String sUrlHash= "https://api.tronscan.org/api/transaction/";
System.out.println(sDescripcion);
	Integer i=0, k=0, nIni=0, nFin=0, nVeces=0;
	String sRespuesta="", sLista="", sTransacciones = "", sStatus="", sT="", sAccount="", sSaldo="", sName="", sTokenName="", sToken="";
	String sBalance="", sHash="", sData="", sTo="", sFrom="", sAmount="", sTimestamp;
	int intValueOfChar;
	String [] aZonas, aTransacciones;
	sLista = "{'From':'Error','Amount':'Error','Token':'Error','Data':'Error'}";
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
			System.out.println(sUrlTransacciones);	
			obj = new JSONObject(sTransacciones);
			arr = obj.getJSONArray("data");
			for (i = 0; i < arr.length(); i++)
			{
				sToken = arr.getJSONObject(i).getString("tokenName");		
				sHash = arr.getJSONObject(i).getString("transactionHash");
				sHash = sUrlHash+sHash;
				//System.out.println("Hash:" + sHash + " Token:" + sToken);
				if (sToken.equals("IdTronix"))
				{			
					//System.out.println("Hash:" + sHash);
						
					// Localiza el detalle de la ultima transaccion
					
					sTransacciones="";
					input = new URL(sHash).openStream();
					reader = new InputStreamReader(input, "UTF-8");
					while ((intValueOfChar = reader.read()) != -1) {
						sTransacciones += (char) intValueOfChar;
					}
					reader.close();
					//System.out.println(sTransacciones);	
					obj = new JSONObject(sTransacciones);
					sTo = obj.getString("toAddress");
					sFrom = obj.getString("ownerAddress");
					sTimestamp = obj.getString("timestamp");
					
					sData = hexToAscii(obj.getString("data"));
					sData = sData.replaceAll(" Sent with @TronWalletMe","");
				
					//System.out.println("sAmount:" + sAmount) ;
					System.out.println (sData + " "+ sDescripcion);
					Long nDif=System.currentTimeMillis()-Long.valueOf(sTimestamp);
					//System.out.println("Data:" + sData + " = "+sDescripcion + " Dif:"+nDif);
					//System.out.println(sData.equals(sDescripcion));
					if (nDif<10000) 
					{
						//if (sImporte.indexOf(sAmount)>-1 || (sData.indexOf(sDescripcion) > -1 ) )
						System.out.println (sData + " "+ sDescripcion);
						if (sData.equals(sDescripcion))
						{
							sLista = "{'From':'"+sFrom + "','Amount':1,'Token':'IdTronix','Data':'"+ sData +"'}";
							k=31;
							i=arr.length();
						}
					}
				}
			}
			if (k<31)
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
