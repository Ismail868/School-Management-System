<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Verify OTP</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="login.css">
    <style>
        .otp-card {
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

    <div class="otp-card">
        <div class="icon-circle">
            <i class="fa-solid fa-key"></i>
        </div>
        <h2>Enter Verification Code</h2>
        <p style="color: #6b7280; margin-bottom: 25px; font-size: 14px;">
            Waxaan 6 nambar oo OTP ah ugu dirnay email-kaaga. Fadlan ku dhex geli hoos.
        </p>

        <%
            String error = request.getParameter("error");
            if ("invalid_otp".equals(error)) {
        %>
            <div style="background-color: #ffe6e6; color: #d9534f; padding: 10px; border-radius: 5px; margin-bottom: 15px; font-size: 14px;">
                <i class="fa-solid fa-triangle-exclamation"></i> OTP-ga aad gelisay waa khaldan yahay ama wuu dhacay!
            </div>
        <% } %>

        <form action="verify_otp_process.jsp" method="POST" style="text-align: left;">
            <div class="form-group">
                <label>6-Digit OTP Code</label>
                <div class="input-wrapper">
                    <i class="fa-solid fa-lock left-icon"></i>
                    <input type="text" name="otp_code" maxlength="6" placeholder="X X X X X X" style="letter-spacing: 5px; font-weight: bold; font-size: 18px; text-align: center;" required>
                </div>
            </div>

            <button type="submit" class="btn-primary" style="margin-top: 10px;">
                Verify OTP <i class="fa-solid fa-check-circle"></i>
            </button>
        </form>
    </div>

</body>
</html>