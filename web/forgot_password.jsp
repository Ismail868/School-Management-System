<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Forgot Password</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="login.css">
    <style>
        .forgot-card {
            background: #fff;
            padding: 40px;
            border-radius: 12px;
            box-shadow: 0 10px 25px rgba(0,0,0,0.05);
            width: 100%;
            max-width: 400px;
            margin: 50px auto;
            text-align: center;
        }
        .icon-circle {
            width: 60px;
            height: 60px;
            background: #eef2ff;
            color: #4f46e5;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
            margin: 0 auto 20px;
        }
    </style>
</head>
<body style="background-color: #f3f4f6;">

    <div class="forgot-card">
        <div class="icon-circle">
            <i class="fa-solid fa-shield-halved"></i>
        </div>
        <h2>Reset Password</h2>
        <p style="color: #6b7280; margin-bottom: 25px; font-size: 14px;">Fadlan geli email-kaaga iyo nambarkaaga tixraaca (Recovery PIN) si aad u xaqiijiso aqoonsigaaga.</p>

        <!-- Halkan waxaa kasoo muuqan doona fariimaha Error-ka -->
        <%
            String error = request.getParameter("error");
            if ("notfound".equals(error)) {
        %>
            <div style="background-color: #ffe6e6; color: #d9534f; padding: 10px; border-radius: 5px; margin-bottom: 15px; font-size: 14px;">
                <i class="fa-solid fa-triangle-exclamation"></i> Xogta aad gelisay waa khalad!
            </div>
        <% } else if ("server".equals(error)) { %>
            <div style="background-color: #fff3cd; color: #856404; padding: 10px; border-radius: 5px; margin-bottom: 15px; font-size: 14px;">
                <i class="fa-solid fa-server"></i> Qalad ayaa ka dhacay Server-ka.
            </div>
        <% } %>

        <form action="send_otp_process.jsp" method="POST" style="text-align: left;">
            <div class="form-group">
                <label>Email Address</label>
                <div class="input-wrapper">
                    <i class="fa-regular fa-envelope left-icon"></i>
                    <input type="email" name="email" placeholder="Geli email-kaaga" required>
                </div>
            </div>

            <div class="form-group">
                <label>Recovery PIN</label>
                <div class="input-wrapper">
                    <i class="fa-solid fa-hashtag left-icon"></i>
                    <input type="text" name="recovery_pin" placeholder="Geli nambarkaaga tixraaca" required>
                </div>
            </div>

            <button type="submit" class="btn-primary" style="margin-top: 10px;">
                Send OTP <i class="fa-solid fa-paper-plane"></i>
            </button>
        </form>

        <div style="margin-top: 20px;">
            <a href="index.jsp" style="color: #4f46e5; text-decoration: none; font-weight: 500; font-size: 14px;">
                <i class="fa-solid fa-arrow-left"></i> Dib ugu noqo Login
            </a>
        </div>
    </div>

</body>
</html>