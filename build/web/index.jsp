
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="utils.DBConnection, java.sql.*" %>
<% 
    Connection conn = DBConnection.getConnection(); 
    
%>
<%
    String contextPath = request.getContextPath(); 
    
    String schoolName = "SCHOOL MANAGEMENT SYSTEM";
    String logoPath = "uploads/logos/logo.png";
    String bgImagePath = "uploads/images/bg.jpg";
    boolean hasActiveAd = false;
    String adTitle = "";
    String adDesc = "";
    String adVideoPath = "uploads/videos/ad_video.mp4";

    Statement stmt = null;
    ResultSet rs = null;

    try {
        // conn waxaa si toos ah looga helayaa Java Class-ka utils.DBConnection
        stmt = conn.createStatement();
        rs = stmt.executeQuery("SELECT * FROM system_config ORDER BY id DESC LIMIT 1");
        
        if (rs.next()) {
            if (rs.getString("school_name") != null && !rs.getString("school_name").trim().isEmpty()) {
                schoolName = rs.getString("school_name");
            }
            if (rs.getString("logo_path") != null && !rs.getString("logo_path").trim().isEmpty()) {
                logoPath = rs.getString("logo_path");
            }
            if (rs.getString("bg_image_path") != null && !rs.getString("bg_image_path").trim().isEmpty()) {
                bgImagePath = rs.getString("bg_image_path");
            }
            hasActiveAd = rs.getBoolean("has_active_ad");
            adTitle = rs.getString("ad_title");
            adDesc = rs.getString("ad_description");
            adVideoPath = rs.getString("ad_video_path");
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        // Xir xiriirinta si nidaamku u ahaado mid dhab ah oo ammaan ah
        DBConnection.close(rs);
        DBConnection.close(stmt);
        DBConnection.close(conn);
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= schoolName %> Login</title>
    
    <link rel="icon" type="image/png" href="<%= contextPath %>/<%= logoPath %>">
    
    <!-- Font Awesome for Icons -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    
    <link rel="stylesheet" href="login.css">
</head>
<body>

    <div class="left-panel" style="background-image: url('<%= contextPath %>/<%= bgImagePath %>');">
        <div class="left-overlay"></div>
        <div class="left-content">
            <div class="logo-section">
                <% if (logoPath != null && !logoPath.trim().isEmpty()) { %>
                    <img src="<%= contextPath %>/<%= logoPath %>" alt="School Logo" class="dynamic-logo">
                <% } else { %>
                    <div class="logo-icon"></div>
                <% } %>
                <div class="logo-text">
                    <h1><%= schoolName %></h1>
                </div>
            </div>

            <% if (hasActiveAd && adVideoPath != null && !adVideoPath.trim().isEmpty()) { %>
            <div class="ad-section">
                <h3><i class="fa-solid fa-bullhorn"></i> <%= adTitle %></h3>
                <p><%= adDesc %></p>
                <div class="video-container">
                    <video autoplay loop muted playsinline controls>
                        <source src="<%= contextPath %>/<%= adVideoPath %>" type="video/mp4">
                        Your browser does not support HTML video.
                    </video>
                </div>
            </div>
            <% } %>
        </div>

        <div class="wave-bottom">
            <svg viewBox="0 0 1200 120" preserveAspectRatio="none" style="fill: #f7f9fc;">
                <path d="M0,0V46.29c47.79,22.2,103.59,32.17,158,28,70.36-5.37,136.33-33.31,206.8-37.5C438.64,32.43,512.34,53.67,583,72.05c69.27,18,138.3,24.88,209.4,13.08,36.15-6,69.85-17.84,104.45-29.34C989.49,25,1113-14.29,1200,52.47V120H0Z"></path>
            </svg>
        </div>
    </div>

    <div class="right-panel">
        <div class="login-card">
            <div class="admin-icon">
                <i class="fa-regular fa-user"></i>
            </div>
            <h2>Admin Login</h2>
            <p>Enter your credentials to login</p>

            <%-- Qaybta Muujinta Error-ka --%>
            <%
                String error = request.getParameter("error");
                if ("invalid".equals(error)) {
            %>
                <div style="background-color: #ffe6e6; color: #d9534f; padding: 10px; border-radius: 5px; margin-bottom: 15px; font-size: 14px; text-align: center;">
                    <i class="fa-solid fa-triangle-exclamation"></i> Login Failed! Invalid username or password. Please try again.!
                </div>
            <%
                } else if ("server".equals(error)) {
            %>
                <div style="background-color: #fff3cd; color: #856404; padding: 10px; border-radius: 5px; margin-bottom: 15px; font-size: 14px; text-align: center;">
                    <i class="fa-solid fa-server"></i> Qalad ayaa ka dhacay Server-ka ama Database-ka!
                </div>
            <%
                }
            %>

            <form action="login_process.jsp" method="POST">
                <div class="form-group">
                    <label>Username / Email</label>
                    <div class="input-wrapper">
                        <i class="fa-regular fa-user left-icon"></i>
                        <input type="text" name="username" placeholder="Enter your username or email" required>
                    </div>
                </div>

                <div class="form-group">
                    <label>Password</label>
                    <div class="input-wrapper">
                        <i class="fa-solid fa-lock left-icon"></i>
                        <input type="password" id="password" name="password" placeholder="Enter your password" required>
                        <i class="fa-regular fa-eye right-icon" onclick="togglePassword()"></i>
                    </div>
                </div>

                <div class="form-options">
                    <a href="forgot_password.jsp" class="forgot-link">Forgot Password?</a>
                </div>

                <button type="submit" class="btn-primary">
                    Login <i class="fa-solid fa-arrow-right-to-bracket"></i>
                </button>
            </form>
        </div>

        <p class="footer-text">© 2026 <%= schoolName %>. All rights reserved.</p>
    </div>

    <script>
        function togglePassword() {
            var pwd = document.getElementById("password");
            var icon = document.querySelector(".right-icon");
            if (pwd.type === "password") {
                pwd.type = "text";
                icon.classList.remove("fa-eye");
                icon.classList.add("fa-eye-slash");
            } else {
                pwd.type = "password";
                icon.classList.remove("fa-eye-slash");
                icon.classList.add("fa-eye");
            }
        }
    </script>
</body>
</html>