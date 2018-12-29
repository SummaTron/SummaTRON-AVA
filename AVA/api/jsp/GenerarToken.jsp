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

String sCuentaTRON = "TFQwLDzUvEc99ktd3TvUc9g3uATGmX2fS7"; // Esta la cuenta de SummaTRON donde se deben registrar las cuentas clientes
String sUrlHash= "https://wlcyapi.tronscan.org/api/transaction/";

	Integer i=0, k=0;
	String sLista="{'Descripcion':'Cuenta no Registrada'}", sTransacciones = "";
	String sHash="", sData="", sAmount="";
	int intValueOfChar;
	String [] aZonas, aTransacciones;
	
	String sUrlTransacciones= "https://wlcyapi.tronscan.org/api/transfer?from="+sCuenta+"&to="+sCuentaTRON+"&token=SummaTRON";
	sTransacciones="";
	InputStream input = new URL(sUrlTransacciones).openStream();
	Reader reader = new InputStreamReader(input, "UTF-8");
	while ((intValueOfChar = reader.read()) != -1) {
		sTransacciones += (char) intValueOfChar;
	}
	reader.close();
	
	JSONObject obj = new JSONObject(sTransacciones);
	JSONArray arr = obj.getJSONArray("data");
	for (i = 0; i < arr.length(); i++)
	{
		sHash = arr.getJSONObject(i).getString("transactionHash");
		sAmount = arr.getJSONObject(i).getString("amount");
		if (sAmount.equals("1")) // Tiene que ser>=1
		{		
			sHash = sUrlHash+sHash;

			sTransacciones="";
			input = new URL(sHash).openStream();
			reader = new InputStreamReader(input, "UTF-8");
			while ((intValueOfChar = reader.read()) != -1) {
				sTransacciones += (char) intValueOfChar;
			}
			reader.close();
				
			obj = new JSONObject(sTransacciones);
			JSONObject obj1 = obj.getJSONObject("contractData");			
			sData = hexToAscii(obj.getString("data")).replaceAll("%2F","-");
			sLista = "{'Descripcion':'"+sData.replaceAll(" Sent from TronWallet","")+"-"+ (int) (Math.random() * 100000)+"'}";
		}
	}
	
System.out.println("Retorno:"+sLista);
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
