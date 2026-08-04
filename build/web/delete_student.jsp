<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*, utils.DBConnection"%>

<%
    // Hubi in Session-ka uu jiro (Amni)
    if (session.getAttribute("username") == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    String id = request.getParameter("id");
    
    if (id != null && !id.trim().isEmpty()) {
        Connection conn = null;
        PreparedStatement pst = null;
        
        try {
            // Xiriirka waxaan ka helaynaa DBConnection class-ka cusub
            conn = DBConnection.getConnection();
            
            String sql = "DELETE FROM students WHERE id = ?";
            pst = conn.prepareStatement(sql);
            pst.setString(1, id);
            
            pst.executeUpdate();
            
        } catch (Exception e) {
            e.printStackTrace(); // Cilada log-ka ayey ku dhacaysaa
        } finally {
            // Habkan cusub ayaa aad uga nadiifsan tii hore, wuxuuna xiriirka ku celinayaa Pool-ka
            DBConnection.close(conn, pst, null);
        }
    }
    
    // Dib ugu noqo bogga ardayda marka la tirtiro kadib
    response.sendRedirect("students.jsp");
%>