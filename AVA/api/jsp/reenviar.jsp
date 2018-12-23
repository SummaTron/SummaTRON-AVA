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