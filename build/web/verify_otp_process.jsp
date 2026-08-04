<%@page import="java.sql.*, java.util.Date, java.text.SimpleDateFormat"%>
<%@page import="utils.DBConnection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String inputOtp = request.getParameter("otp_code");
    String userEmail = (String) session.getAttribute("reset_email");

    if (inputOtp != null && userEmail != null) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            // conn waxaa laga helayaa Connection Pool-ka
            conn = DBConnection.getConnection();
            
            String sql = "SELECT * FROM users WHERE email = ? AND reset_otp = ? AND otp_expiry >= NOW()";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, userEmail);
            pstmt.setString(2, inputOtp.trim());

            rs = pstmt.executeQuery();

            if (rs.next()) {
                // OTP-gu waa sax, xaqiiji session-ka
                session.setAttribute("otp_verified", true);
                response.sendRedirect("reset_password.jsp");
                return;
            } else {
                response.sendRedirect("verify_otp.jsp?error=invalid_otp");
                return;
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("verify_otp.jsp?error=server");
            return;
        } finally {
            // Xir kheyraadka si nidaamku u ahaado mid ammaan ah oo xusuusta nadiif ka ah (Dib ugu celi Pool-ka)
            try { if (rs != null) rs.close(); } catch (SQLException e) { e.printStackTrace(); }
            try { if (pstmt != null) pstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
            try { if (conn != null) conn.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
    } else {
        response.sendRedirect("forgot_password.jsp");
    }
%>