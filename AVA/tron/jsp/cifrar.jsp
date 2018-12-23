<%@page pageEncoding="UTF-8"%>
<%@ page import="java.io.IOException"%>
<%@ page import="java.util.Map"%>
<%@ page import= "java.net.*" %>
<%@ page import="org.jsoup.Connection.Method"%>
<%@ page import="org.jsoup.Connection.Response"%>
<%@ page import="org.jsoup.Jsoup"%>
<%@ page import="org.jsoup.nodes.Document"%>
<%@ page import="org.json.*"%>
<%@ page import="java.io.*,java.util.*, javax.servlet.*, java.util.regex.*" %>
<%@ page import="java.io.IOException" %>

<%
String sObjeto = request.getParameter("Objeto").replaceAll("'","");
String sClave = request.getParameter("Clave").replaceAll("'","");
int intValueOfChar;

InputStream input;
Reader reader;
JSONObject obj;

String sUrl="",sRespuesta="";

		System.out.println(sObjeto);
		sUrl = "http://localhost:7000?Tipo=C&Objeto="+sObjeto +"&Clave="+sClave;
		try
		{
			input = new URL(sUrl).openStream();
			reader = new InputStreamReader(input, "UTF-8");
			while ((intValueOfChar = reader.read()) != -1) {
				sRespuesta += (char) intValueOfChar;
			}
			reader.close();
		}
		catch (Exception e) {System.out.println("Error en la llamada a nodejs"+e);}
		out.println(sRespuesta);
		
%>
