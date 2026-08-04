<%@page import="java.sql.*, utils.DBConnection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String newPass = request.getParameter("new_password");
    String confirmPass = request.getParameter("confirm_password");
    String userEmail = (String) session.getAttribute("reset_email");

    if (newPass != null && confirmPass != null && newPass.equals(confirmPass) && userEmail != null) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            // Connection-ka ka soo qaado utils.DBConnection
            conn = DBConnection.getConnection();
            
            String sql = "UPDATE users SET password = ?, reset_otp = NULL, otp_expiry = NULL WHERE email = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, newPass.trim());
            pstmt.setString(2, userEmail);

            int rowsUpdated = pstmt.executeUpdate();

            if (rowsUpdated > 0) {
                // Tirtir Session-kii dib u habaynta
                session.removeAttribute("reset_email");
                session.removeAttribute("otp_verified");

                // U dib-u-jaheeyay login-ka isagoo wata fariin guul ah
                response.sendRedirect("index.jsp?msg=reset_success");
                return;
            } else {
                response.sendRedirect("reset_password.jsp?error=failed");
                return;
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("reset_password.jsp?error=server");
        } finally {
            // Xir kheyraadka adigoo isticmaalaya Class-ka cusub si xiriirka loogu celiyo Pool-ka
            DBConnection.close(conn, pstmt, null);
        }
    } else {
        response.sendRedirect("reset_password.jsp?error=mismatch");
    }
%>