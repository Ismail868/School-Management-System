<%@page import="java.sql.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // Hubi in session-ka "username" uu furan yahay
    if (session.getAttribute("username") == null) {
        // Haddii uusan furaneyn (qofka uusan login sameyn), ku celi index.jsp
        response.sendRedirect("index.jsp");
        return; 
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>School Management System - Dashboard</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="admincss.css">
</head>
<body>

    <!-- Sidebar -->
    <jsp:include page="adminside.jsp" />

    <!-- Main Content -->
    <div class="main-content">
   <!-- Header -->
   <jsp:include page="adminnav.jsp" />
    <jsp:include page="adminbody.jsp" />
    </div>
    <!-- Multi-Language Dictionary & Logic -->
   
      <jsp:include page="admin_language.jsp" />
    <!-- Chart Configurations -->
    <jsp:include page="admin_charts.jsp" />
</body>
</html>