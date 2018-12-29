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
<%@ page import="com.itextpdf.text.*, com.itextpdf.text.pdf.*"%>
<%@include file="reenviar.jsp" %>  

<%
String sCuenta= request.getParameter("Cuenta").replaceAll("'","");
String sDescripcion = request.getParameter("Descripcion").replaceAll("'","");
String sUrlTransacciones= "https://api.tronscan.org/api/transaction?sort=-timestamp&count=true&limit=3&start=0&tokenName=SummaTRON&address="+sCuenta;
String sUrlHash= "https://wlcyapi.tronscan.org/api/transaction/";
String sId="", sName="", sSurname="", sEmail="", sFecha="";
String sPath ="C:\\Program Files (x86)\\Apache Software Foundation\\Tomcat 9.0\\webapps\\root\\pdfs\\";
String sFichero = "";
String sFicheroJSON = "{'Fichero':'Error'}";
Integer year=0, month=0, day=0, hour=0, min=0, sec=0;

	Integer i=0, j=0, k=0, nTope=0, nIni=0, nFin=0, nVeces=0;
	String sRespuesta="", sTransacciones = "", sStatus="", sTokenName="", sToken="";
	String sHash="", sData="", sTo="", sFrom="", sAmount="", sTimestamp="", sMD5="", sFicheroSigned="";
	String sDataCifrado="", sCipher="", sUrl="", sObjDescifrado="", sReenvio="";
	int intValueOfChar;
	String [] aZonas, aTransacciones;
	InputStream input;
	Reader reader;
	JSONObject obj, obj1, oCifrado;
	JSONArray arr;
	System.out.println("Entro en Signer:" + sCuenta+ " " + sDescripcion);
	// Localiza la última transaccion
	System.out.println(sUrlTransacciones);
	while (k<60)	
	{
		try
		{
			//System.out.println(sUrlTransacciones);
			sTransacciones="";
			input = new URL(sUrlTransacciones).openStream();
			reader = new InputStreamReader(input, "UTF-8");
			while ((intValueOfChar = reader.read()) != -1) {
				sTransacciones += (char) intValueOfChar;
			}
			reader.close();
			//System.out.println(sTransacciones);
			obj = new JSONObject(sTransacciones);
			arr = obj.getJSONArray("data");
			i=0;
			nTope=arr.length();
			if (nTope>3){nTope=3;}
			while (i < nTope)
			{
				try
				{
					sHash = sFrom = arr.getJSONObject(i).getString("hash");	
					sFrom = arr.getJSONObject(i).getString("ownerAddress");	
					//sToken = arr.getJSONObject(i).getString("tokenName");					
					//sAmount = arr.getJSONObject(i).getString("amount");
					sDataCifrado = arr.getJSONObject(i).getString("data");
					sDataCifrado = java.net.URLDecoder.decode(sDataCifrado, "UTF-8");
					sTimestamp = arr.getJSONObject(i).getString("timestamp");	
					oCifrado = new JSONObject(sDataCifrado);
					sData = oCifrado.getString("data");
					sData = sData.replaceAll(" Sent from TronWallet","");
					sCipher = oCifrado.getString("cipher");
					//System.out.println("Data="+sData);
					//System.out.println("Cipher="+sCipher);
					sTimestamp = arr.getJSONObject(i).getString("timestamp");
					
					long timestampLong = Long.parseLong(sTimestamp);
					Date d = new Date(timestampLong);
					Calendar c = Calendar.getInstance();
					c.setTime(d);
					year = c.get(Calendar.YEAR);
					month = c.get(Calendar.MONTH)+1;
					day = c.get(Calendar.DATE);
					hour = c.get(Calendar.HOUR_OF_DAY);
					min = c.get(Calendar.MINUTE);
					sec = c.get(Calendar.SECOND);
					sFecha = Integer.toString(year)+"-"+Integer.toString(month)+"-"+Integer.toString(day) + " " + Integer.toString(hour) +":"+ Integer.toString(min)+":"+Integer.toString(sec);
				
					Long nDif=System.currentTimeMillis()-Long.valueOf(sTimestamp);
					//System.out.println("Data:" + sData + " = "+sDescripcion + " Dif:"+nDif);
					//System.out.println(sData.equals(sDescripcion));
										
					if (nDif<60000) 
					{				
						if (sData.equals(sDescripcion))
						{	
							k=100;
							i=100;
							obj1 = new JSONObject(sCipher);

							try {sId = obj1.getString("id");}
							catch (Exception e){sId="";}
							try {sName = obj1.getString("name");}
							catch (Exception e){sName="";}
							try {sSurname = obj1.getString("surname");}
							catch (Exception e) {sSurname="";}
							try {sMD5 = obj1.getString("md5");}
							catch (Exception e) {sMD5="";}
							sName = sName+ " " + sSurname;
							sFichero = "DocumentoTRON_"+sId+".pdf";
							sFicheroSigned = "DocumentoTRON_"+sId+"_signed.pdf";
							sFicheroJSON = "{'Fichero':'"+sFicheroSigned+"'}";
							//System.out.println(sPath+sFichero);
							 
							try
							  {
								//Read file using PdfReader
								PdfReader pdfReader = new PdfReader(sPath+sFichero);
							 
								//Modify file using PdfReader
								PdfStamper pdfStamper = new PdfStamper(pdfReader, new FileOutputStream(sPath+sFicheroSigned));
							 
							 
								for( j=1; j<= pdfReader.getNumberOfPages(); j++)
								{
									PdfContentByte cb = pdfStamper.getUnderContent(j);
									cb.setFontAndSize(BaseFont.createFont(BaseFont.HELVETICA, BaseFont.WINANSI, false), 8);
									cb.beginText();
									cb.showTextAligned(Element.ALIGN_LEFT, "Document with hash "+sMD5+", signed on "+sFecha+" by "+ sName +", ", 20f, 30f, 0f);
									cb.showTextAligned(Element.ALIGN_LEFT, "Can verify the authenticity at: https://tronscan.org/#/transaction/"+sHash, 20f, 20f, 0f);
								  
									cb.endText();
									cb.stroke();
							   
								}
							 
								pdfStamper.close();
								
								// Return  the SummaTRON token to the account From
								sUrl = "http://localhost:7001?address="+ sFrom ;
								try
								{
									input = new URL(sUrl).openStream();
									reader = new InputStreamReader(input, "UTF-8");
									while ((intValueOfChar = reader.read()) != -1) {
										sReenvio += (char) intValueOfChar;
									}
									reader.close();
									//System.out.println(sReenvio);
									SendSummaTRON(sReenvio,1);
								}
								catch (Exception e) {System.out.println("Error en la llamada a reenviar.html "+e);}


							  } catch (IOException e) {System.out.println(e);
								e.printStackTrace();
							}
							
							break;
						}
						else
						{i++;}
					}
					else
					{
						i++;
					}
				}
				catch (Exception e) {System.out.println("Error JSON:"+e);i++;}
			}
			if (k<61)
			{Thread.sleep(2000); k++;}
			
		}
		catch (Exception e)
		{
		   // Error en algun momento.
		   //System.out.println("Excepcion "+e);
		   e.printStackTrace();
		}
	}
System.out.println(sFicheroJSON);
out.println(sFicheroJSON.replaceAll("'","\""));
%>

