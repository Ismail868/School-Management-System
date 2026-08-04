<%@ page import="java.sql.*" %>
<%
    Connection conn = null;
    try {
        // U yeerida Driver-ka MySQL
        Class.forName("com.mysql.cj.jdbc.Driver");
        
        // Xogta Database-kaaga rasmiga ah ee ka muuqata sawirka
        String dbUrl = "jdbc:mysql://localhost:3306/schoolmanagement";
        String dbUser = "root";       // Username-ka caadiga ah ee xampp/localhost
        String dbPass = "";           // Password-ka oo banaan ah

        // Sameynta isku-xirka (Connection)
        conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);
        
    } catch (Exception e) {
        // Fariin soo baxaysa haddii database-ka cilad ku timaado
        out.println("Cillad dhanka Database-ka ah: " + e.getMessage());
    }
%>