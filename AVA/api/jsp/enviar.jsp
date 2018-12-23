<%@ page pageEncoding="UTF-8"%>

<%@ page import="java.io.IOException"%>
<%@ page import="java.util.Map"%>
 
<%@ page import="org.jsoup.Connection.Method"%>
<%@ page import="org.jsoup.Connection.Response"%>
<%@ page import="org.jsoup.Jsoup"%>
<%@ page import="org.jsoup.nodes.Document"%>
<%@ page import="org.json.*"%>

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
String sCuenta =  request.getParameter("Cuenta").replaceAll("'","");
String sCuenta64 =  request.getParameter("Cuenta64").replaceAll("'","");
String sResultIdTronix="";
String sResultSummaTRON ="";
String sResultado="";
//String sCuenta= "41CA7B3B7EBB7BBBE5DA0A5B63954B6A29590580DD";
//String sResultTRX= SendTRX(sCuenta);
	if ( Verificar (sCuenta) )
	{
		sResultIdTronix= SendIdTronix(sCuenta64,1000);
		sResultSummaTRON= SendSummaTRON(sCuenta64,1);
		sResultado = "{\"Resultado\":\"Envio realizado\"}";
	}
	else
	{
		sResultado = "{\"Resultado\":\"Ya se realizó un envío previo\"}";
	}
//out.println(sResultTRX+" "+sResultIdTronix);
out.println(sResultado);
%>
<%!
private static Boolean Verificar (String sCuenta)
{
String sSummaTRONID = "TCHDEWDqrSPGywDXxhMUffqwbdfpcN4rTH";
String sUrlTransacciones="",sTransacciones="", sAccount="";
int intValueOfChar;
InputStream input;
Reader reader;
JSONObject obj;

Boolean bResultado=true;
try
	{
		// Determinar Inversion
		sAccount="";
		sUrlTransacciones= "https://wlcyapi.tronscan.org/api/transfer?count=true&limit=1&from="+sSummaTRONID+"&to="+sCuenta+"&token=SummaTRON";
		sTransacciones="";
		input = new URL(sUrlTransacciones).openStream();
		reader = new InputStreamReader(input, "UTF-8");
		while ((intValueOfChar = reader.read()) != -1) {
			sTransacciones += (char) intValueOfChar;
		}
		reader.close();
		System.out.println("sUrlTransacciones en Cuentas:" + sUrlTransacciones);	
		System.out.println("Transacciones en Cuentas:" + sTransacciones);	
		obj = new JSONObject(sTransacciones);
		if (obj.getString("total").equals("0") )
		{
			bResultado = true;
		}
		else
		{
			bResultado = false;
		}			
	}
	catch (Exception e)
	{
	   // Error en algun momento.
	   System.out.println("Excepcion "+e);
	   e.printStackTrace();
	}
	return bResultado;
}
%>
<%! 
private static String  SendTRX( String sCuenta)
{
String sOwner ="411957EEB166BE99085C51406C0DD8E6B1DC41396F";
String sUrlTransaction = "https://api.trongrid.io/wallet/createtransaction";
String sUrlSing = "https://api.trongrid.io/wallet/gettransactionsign";
String sUrlSend = "https://api.trongrid.io/wallet/broadcasttransaction";
String sPrivateKey = "1300CA34BD77D6DCB61DE314F96ECE7D9AB0A65E75B4EE56A3D40B89A00F1EEA";
String result ="";
try
	{
	JSONObject objeto = new JSONObject();
        objeto.put("owner_address",sOwner);
        objeto.put("to_address",sCuenta);
		objeto.put("amount",1000000);

	System.out.println(objeto.toString());


		Response doc = 
            Jsoup.connect(sUrlTransaction)
                .userAgent("Mozilla/5.0")
                .timeout(30* 1000)
                .method(Method.POST)
				.header("Content-Type", "application/json")
                .requestBody(objeto.toString())
                .execute();

		result = doc.body();
		JSONObject oSing = new JSONObject();
        oSing.put("transaction",result);
        oSing.put("privateKey",sPrivateKey);
		Response docSing = 
            Jsoup.connect(sUrlSing)
                .userAgent("Mozilla/5.0")
                .timeout(30* 1000)
                .method(Method.POST)
				.header("Content-Type", "application/json")
                .requestBody(oSing.toString())
                .execute();
		result = docSing.body();		
		Response docSend = 
            Jsoup.connect(sUrlSend)
                .userAgent("Mozilla/5.0")
                .timeout(30* 1000)
                .method(Method.POST)
				.header("Content-Type", "application/json")
                .requestBody(result)
                .execute();
		result = docSend.body();		
		System.out.println(result);

	}
	catch (Exception e)
		{
		   // Error en algun momento.
		   System.out.println("Excepcion "+e);
		   e.printStackTrace();
		}
	return result;
}
%>
<%! 
private static String  SendSummaTRON( String sCuenta, Integer nAmount)
{
String sCuenta64 = "41CA7B3B7EBB7BBBE5DA0A5B63954B6A29590580DD";
String sOwner ="411957EEB166BE99085C51406C0DD8E6B1DC41396F";
String sToken = asciiToHex("SummaTRON");
String sUrlTransfer = "https://api.trongrid.io/wallet/transferasset";
String sUrlSing = "https://api.trongrid.io/wallet/gettransactionsign";
String sUrlSend = "https://api.trongrid.io/wallet/broadcasttransaction";
String sPrivateKey = "1300CA34BD77D6DCB61DE314F96ECE7D9AB0A65E75B4EE56A3D40B89A00F1EEA";
String result ="", sData="";
try
	{	
	JSONObject objeto = new JSONObject();
        objeto.put("owner_address",sOwner);
        objeto.put("to_address",sCuenta);
		objeto.put("asset_name",sToken);
		objeto.put("amount",nAmount);

	System.out.println(objeto.toString());

		Response doc = 
            Jsoup.connect(sUrlTransfer)
                .userAgent("Mozilla/5.0")
                .timeout(30* 1000)
                .method(Method.POST)
				.header("Content-Type", "application/json")
                .requestBody(objeto.toString())
                .execute();

		result = doc.body();
		JSONObject oSing = new JSONObject();
		//sData=",\"data\":\"5492dad6774fa446c7606e72f6107ab9\"}}";
		//result=result.replaceAll("}}",sData);
		//System.out.println(result.toString());
		
        oSing.put("transaction",result);
        oSing.put("privateKey",sPrivateKey);
		Response docSing = 
            Jsoup.connect(sUrlSing)
                .userAgent("Mozilla/5.0")
                .timeout(30* 1000)
                .method(Method.POST)
				.header("Content-Type", "application/json")
                .requestBody(oSing.toString())
                .execute();
		result = docSing.body();		
		Response docSend = 
            Jsoup.connect(sUrlSend)
                .userAgent("Mozilla/5.0")
                .timeout(30* 1000)
                .method(Method.POST)
				.header("Content-Type", "application/json")
                .requestBody(result)
                .execute();
		result = docSend.body();		
		System.out.println(result);
	}
	catch (Exception e)
		{
		   // Error en algun momento.
		   System.out.println("Excepcion "+e);
		   e.printStackTrace();
		}
	return result;
}
%>
<%! 
private static String  SendIdTronix( String sCuenta, Integer nAmount)
{
String sCuenta64 = "41CA7B3B7EBB7BBBE5DA0A5B63954B6A29590580DD";
String sOwner ="411957EEB166BE99085C51406C0DD8E6B1DC41396F";
String sToken = asciiToHex("IdTronix");
String sUrlTransfer = "https://api.trongrid.io/wallet/transferasset";
String sUrlSing = "https://api.trongrid.io/wallet/gettransactionsign";
String sUrlSend = "https://api.trongrid.io/wallet/broadcasttransaction";
String sPrivateKey = "1300CA34BD77D6DCB61DE314F96ECE7D9AB0A65E75B4EE56A3D40B89A00F1EEA";
String result ="";
try
	{
	JSONObject objeto = new JSONObject();
        objeto.put("owner_address",sOwner);
        objeto.put("to_address",sCuenta);
		objeto.put("asset_name",sToken);
		objeto.put("amount",nAmount);

	System.out.println(objeto.toString());

		Response doc = 
            Jsoup.connect(sUrlTransfer)
                .userAgent("Mozilla/5.0")
                .timeout(30* 1000)
                .method(Method.POST)
				.header("Content-Type", "application/json")
                .requestBody(objeto.toString())
                .execute();

		result = doc.body();
		JSONObject oSing = new JSONObject();
        oSing.put("transaction",result);
        oSing.put("privateKey",sPrivateKey);
		Response docSing = 
            Jsoup.connect(sUrlSing)
                .userAgent("Mozilla/5.0")
                .timeout(30* 1000)
                .method(Method.POST)
				.header("Content-Type", "application/json")
                .requestBody(oSing.toString())
                .execute();
		result = docSing.body();		
		Response docSend = 
            Jsoup.connect(sUrlSend)
                .userAgent("Mozilla/5.0")
                .timeout(30* 1000)
                .method(Method.POST)
				.header("Content-Type", "application/json")
                .requestBody(result)
                .execute();
		result = docSend.body();		
		System.out.println(result);
	}
	catch (Exception e)
		{
		   // Error en algun momento.
		   System.out.println("Excepcion "+e);
		   e.printStackTrace();
		}
	return result;
}
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

<%! 
private static String asciiToHex(String asciiValue)
{
	char[] chars = asciiValue.toCharArray();
	StringBuffer hex = new StringBuffer();
	for (int i = 0; i < chars.length; i++)
	{
		hex.append(Integer.toHexString((int) chars[i]));
	}
	return hex.toString();
}
%>