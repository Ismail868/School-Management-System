<%@page import="java.sql.*, java.util.*, javax.mail.*, javax.mail.internet.*, java.text.SimpleDateFormat, utils.DBConnection" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String email = request.getParameter("email");
    String recoveryPin = request.getParameter("recovery_pin");

    final String senderEmail = "maxamedxusen652@gmail.com"; 
    final String senderPassword = "rgujrgbsrvyxxwwq"; 

    if (email != null && recoveryPin != null) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        PreparedStatement updateStmt = null;
        
        try {
            // Connection-ka ka soo qaado utils.DBConnection
            conn = DBConnection.getConnection();
            
            String checkSql = "SELECT id, full_name FROM users WHERE email = ? AND recovery_pin = ?";
            pstmt = conn.prepareStatement(checkSql);
            pstmt.setString(1, email.trim());
            pstmt.setString(2, recoveryPin.trim());
            rs = pstmt.executeQuery();

            if (rs.next()) {
                String fullName = rs.getString("full_name");

                Random rnd = new Random();
                int number = rnd.nextInt(999999);
                String otp = String.format("%06d", number);

                Calendar cal = Calendar.getInstance();
                cal.add(Calendar.MINUTE, 15);
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                String expiryTime = sdf.format(cal.getTime());

                String updateSql = "UPDATE users SET reset_otp = ?, otp_expiry = ? WHERE email = ?";
                updateStmt = conn.prepareStatement(updateSql);
                updateStmt.setString(1, otp);
                updateStmt.setString(2, expiryTime);
                updateStmt.setString(3, email.trim());
                updateStmt.executeUpdate();

                // Qaybta Dirista Email-ka (Oo leh hababka cusub ee TLS/SSL)
                Properties props = new Properties();
                props.put("mail.smtp.host", "smtp.gmail.com");
                props.put("mail.smtp.port", "587");
                props.put("mail.smtp.auth", "true");
                props.put("mail.smtp.starttls.enable", "true");
                props.put("mail.smtp.ssl.trust", "smtp.gmail.com");
                props.put("mail.smtp.ssl.protocols", "TLSv1.2");

                Session mailSession = Session.getInstance(props, new javax.mail.Authenticator() {
                    protected PasswordAuthentication getPasswordAuthentication() {
                        return new PasswordAuthentication(senderEmail, senderPassword);
                    }
                });

                Message message = new MimeMessage(mailSession);
                message.setFrom(new InternetAddress(senderEmail));
                message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(email.trim()));
                message.setSubject("OTP Password Reset - School Management System");

                String emailContent = "<h3>Salaamu Calaykum " + fullName + "</h3>"
                        + "<p>Waxaad codsatay inaad bedelato Password-kaaga nidaamka maamulka iskuulka.</p>"
                        + "<p>Fadlan isticmaal nambarkan sirta ah (OTP) si aad u xaqiijiso aqoonsigaaga:</p>"
                        + "<h2 style='background: #f3f4f6; padding: 10px; display: inline-block; letter-spacing: 5px; color: #4f46e5; border-radius: 5px;'>" + otp + "</h2>"
                        + "<p>Nambarkani wuxuu dhacayaa 15 daqiiqo gudahood.</p>"
                        + "<p>Haddii aadan adigu codsan isbedelkan, fadlan iska indho-tir fariintan.</p>";

                message.setContent(emailContent, "text/html; charset=utf-8");

                Transport.send(message);

                session.setAttribute("reset_email", email.trim());
                response.sendRedirect("verify_otp.jsp"); 
                return;

            } else {
                response.sendRedirect("forgot_password.jsp?error=notfound");
                return;
            }

        } catch (Exception e) {
            // Halkan waxaa lagu soo saarayaa qaladka dhabta ah si aad shaashadda uga akhriso
            out.println("<div style='color:red; background:#fee2e2; padding:20px; font-family:sans-serif; border-radius:8px; margin:20px;'>");
            out.println("<h2>Qalad ayaa ka dhacay Dirista Emailka:</h2>");
            out.println("<p><b>Faahfaahinta:</b> " + e.getMessage() + "</p>");
            out.println("<pre>");
            e.printStackTrace(new java.io.PrintWriter(out));
            out.println("</pre>");
            out.println("</div>");
        } finally {
            // Xir kheyraadka si nidaamku u ahaado mid ammaan ah oo xusuusta nadiif ka ah
            try { if (updateStmt != null) updateStmt.close(); } catch (SQLException e) { e.printStackTrace(); }
            
            // Isticmaal Class-ka cusub si loo xiro ResultSet, PreparedStatement-kii ugu horeeyay iyo Connection-ka guud
            DBConnection.close(conn, pstmt, rs);
        }
    } else {
        response.sendRedirect("forgot_password.jsp");
    }
%>