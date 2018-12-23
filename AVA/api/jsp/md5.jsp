<%@ page pageEncoding="UTF-8"%>

<%@
page import="org.apache.commons.codec.digest.DigestUtils, java.io.*, com.itextpdf.text.*, com.itextpdf.text.pdf.*"
%>
<%
String sFich= request.getParameter("Fichero").replaceAll("'","");
String sPath ="C:\\Program Files (x86)\\Apache Software Foundation\\Tomcat 9.0\\webapps\\root\\pdfs\\";
String sFichero =  sPath + sFich;
FileInputStream fin = new FileInputStream(sFichero);
String digest = DigestUtils.md5Hex(fin); //used to get MD5 
fin.close();
String sMD5 = "{'md5':'"+digest+"'}";
out.println(sMD5.replaceAll("'","\""));
%>