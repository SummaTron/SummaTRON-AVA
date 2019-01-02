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
String sUrlTransacciones= "https://wlcyapi.tronscan.org/api/transaction?sort=-timestamp&count=true&limit=3&start=0&tokenName=SummaTRON&address="+sCuenta;
String sUrlHash= "https://wlcyapi.tronscan.org/api/transaction/";
String sId="", sName="", sSurname="", sEmail="";
String sPath ="C:\\Program Files (x86)\\Apache Software Foundation\\Tomcat 9.0\\webapps\\root\\pdfs\\";
String sFichero = "";
String sFicheroJSON = "{'Fichero':'Error'}";;
String sClave = LeerPrivateKey();
	Integer i=0, j=0, k=0, nTope=0, nIni=0, nFin=0, nVeces=0;
	String sRespuesta="", sLista="", sTransacciones = "", sStatus="", sTokenName="", sToken="";
	String sData="", sTo="", sFrom="", sAmount="", sTimestamp="";
	String sDataCifrado="", sCipher="", sUrl="", sObjDescifrado="", sReenvio="";
	int intValueOfChar;
	String [] aZonas, aTransacciones;
	sLista = "{'From':'','Amount':'','Token':'','Data':'Diferente'}";
	
	InputStream input;
	Reader reader;
	JSONObject obj, obj1, oCifrado;
	JSONArray arr;
	System.out.println("Entro en registrar:" + sCuenta + " " + sDescripcion);
	// Localiza la última transaccion
	System.out.println(sUrlTransacciones);

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
					
					Long nDif=System.currentTimeMillis()-Long.valueOf(sTimestamp);
					//System.out.println("Data:" + sData + " = "+sDescripcion + " Dif:"+nDif);
					//System.out.println(sData.equals(sDescripcion));
					sUrl = "http://localhost:7000?Tipo=D&Objeto="+ sCipher +"&Clave="+sClave;	
					//System.out.println("Url:"+sUrl);					
					if (nDif<60000) 
					{				
						if (sData.equals(sDescripcion))
						{	
							System.out.println("Encontrado:"+ Integer.toString(k));
							k=100;
							i=100;
							//Descifra el campo Cipher
							sUrl = "http://localhost:7000?Tipo=D&Objeto="+ sCipher +"&Clave="+sClave;
							try
							{
								input = new URL(sUrl).openStream();
								reader = new InputStreamReader(input, "UTF-8");
								while ((intValueOfChar = reader.read()) != -1) {
									sObjDescifrado += (char) intValueOfChar;
								}
								reader.close();
								sObjDescifrado = sObjDescifrado.replaceAll("$"," ");
							}
							catch (Exception e) {System.out.println("Error en la llamada a nodejs"+e);}
							
							obj1 = new JSONObject(sObjDescifrado);
							try {sId = obj1.getString("id");}
							catch (Exception e){sId="";}
							try {sName = obj1.getString("name");}
							catch (Exception e){sName="";}
							try {sSurname = obj1.getString("surname");}
							catch (Exception e) {sSurname="";}
							try {sEmail = obj1.getString("email");}
							catch (Exception e) {sEmail="";}
													
							sFichero = "DocumentoTRON_"+sId+".pdf";
							sFicheroJSON = "{'Fichero':'"+sFichero+"'}";
							try
							{
								//Read file using PdfReader
								PdfReader pdfReader = new PdfReader(sPath+"DocumentoTRON.pdf");
							 
								//Modify file using PdfReader
								PdfStamper pdfStamper = new PdfStamper(pdfReader, new FileOutputStream(sPath+sFichero));
							
								for( j=1; j<= pdfReader.getNumberOfPages(); j++)
								{
									PdfContentByte cb = pdfStamper.getUnderContent(j);
									cb.setFontAndSize(BaseFont.createFont(BaseFont.HELVETICA, BaseFont.WINANSI, false), 11);

									cb.beginText();
									cb.showTextAligned(Element.ALIGN_LEFT, "Registration data", 85f, 420f, 0f);
									cb.showTextAligned(Element.ALIGN_LEFT, "Identification: "+sId, 100f, 400f, 0f);
									cb.showTextAligned(Element.ALIGN_LEFT, "Name: "+sName, 100f, 380f, 0f);
									cb.showTextAligned(Element.ALIGN_LEFT, "Surname: "+sSurname, 100f, 360f, 0f);
									cb.showTextAligned(Element.ALIGN_LEFT, "Email: "+sEmail, 100f, 340f, 0f);
									cb.showTextAligned(Element.ALIGN_LEFT, "Address: "+sFrom, 100f, 320f, 0f);
									
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
									System.out.println(sReenvio);
									SendSummaTRON(sReenvio,1);
								}
								catch (Exception e) {System.out.println("Error en la llamada a reenviar.html "+e);}
								
								break;
							  } catch (IOException e) {System.out.println(e);
								e.printStackTrace();
							}
							
						}
						else
						{i++;}
					}
					else
					{i++;}
				}
				catch (Exception e) {System.out.println("Error"+e);i++;}
			}
			if (k<61)
			{Thread.sleep(2000); k++;}
			//System.out.println("Data:" + sLista);
		}
		catch (Exception e)
		{
		   // Error en algun momento.
		   System.out.println("Excepcion "+e);
		   //e.printStackTrace();
		}
	}
System.out.println(sFicheroJSON);
out.println(sFicheroJSON.replaceAll("'","\""));
%>

