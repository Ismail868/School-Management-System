<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    Boolean isVerified = (Boolean) session.getAttribute("otp_verified");
    if (isVerified == null || !isVerified) {
        response.sendRedirect("forgot_password.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>New Password</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="login.css">
    <style>
        .reset-card {
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

    <div class="reset-card">
        <div class="icon-circle">
            <i class="fa-solid fa-lock"></i>
        </div>
        <h2>Create New Password</h2>
        <p style="color: #6b7280; margin-bottom: 25px; font-size: 14px;">Geli password cusub oo ammaan ah.</p>

        <form action="reset_password_process.jsp" method="POST" style="text-align: left;">
            <div class="form-group">
                <label>New Password</label>
                <div class="input-wrapper">
                    <i class="fa-solid fa-lock left-icon"></i>
                    <input type="password" name="new_password" required placeholder="Enter new password">
                </div>
            </div>

            <div class="form-group">
                <label>Confirm Password</label>
                <div class="input-wrapper">
                    <i class="fa-solid fa-lock left-icon"></i>
                    <input type="password" name="confirm_password" required placeholder="Confirm new password">
                </div>
            </div>

            <button type="submit" class="btn-primary" style="margin-top: 10px;">
                Save Password <i class="fa-solid fa-floppy-disk"></i>
            </button>
        </form>
    </div>

</body>
</html>