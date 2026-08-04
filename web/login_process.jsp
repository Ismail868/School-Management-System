<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="utils.DBConnection, java.sql.*" %>
<%
    String userInput = request.getParameter("username"); 
    String userPass = request.getParameter("password");

    // Hubi in xogtu ay soo gaartay ka hor intaanan Database-ka la furin!
    if (userInput != null && userPass != null && !userInput.trim().isEmpty() && !userPass.trim().isEmpty()) {
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            // Connection-ka halkan ayaa lagu furaa oo kaliya marka foomka la soo buuxiyo
            conn = DBConnection.getConnection(); 

            String sql = "SELECT * FROM users WHERE (username = ? OR email = ?) AND password = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, userInput.trim());
            pstmt.setString(2, userInput.trim());
            pstmt.setString(3, userPass.trim());

            rs = pstmt.executeQuery();

            if (rs.next()) {
                // Helitaanka Role-ka qofka
                String userRole = rs.getString("role");

                // Kaydinta Xogta Session-ka
                session.setAttribute("user_id", rs.getInt("id"));
                session.setAttribute("username", rs.getString("username"));
                session.setAttribute("email", rs.getString("email"));
                session.setAttribute("full_name", rs.getString("full_name"));
                session.setAttribute("role", userRole);

                // Kala hagidda (Redirect) iyadoo lagu salaynayo Role-ka
                if ("admin".equalsIgnoreCase(userRole)) {
                    response.sendRedirect("Admin_dashboard.jsp");
                } else if ("teacher".equalsIgnoreCase(userRole)) {
                    response.sendRedirect("teacher_dashboard.jsp");
                } else {
                    response.sendRedirect("index.jsp?error=invalid_role");
                }
                return;
            } else {
                response.sendRedirect("index.jsp?error=invalid");
                return;
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("index.jsp?error=server");
        } finally {
            // Sidan nadiifka ah ayay dib ugu noqonayaan Pool-ka!
            DBConnection.close(conn, pstmt, rs);
        }
    } else {
        // Haddii foomka la soo buuxin waayo, toos aya loo celinayaa iyadoo aan Database-ka la taaban
        response.sendRedirect("index.jsp");
    }
%>