<%@page import="java.sql.*, utils.DBConnection, java.text.SimpleDateFormat, java.util.Date, java.util.Calendar"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%!
    private String escapeJs(String value) {
        if (value == null) {
            return "";
        }

        return value
            .replace("\\", "\\\\")
            .replace("'", "\\'")
            .replace("\"", "\\\"")
            .replace("\r", "\\r")
            .replace("\n", "\\n")
            .replace("<", "\\u003C")
            .replace(">", "\\u003E")
            .replace("&", "\\u0026");
    }
%>
<%
    if (session.getAttribute("username") == null) {
        response.sendRedirect("index.jsp");
        return; 
    }
    
    // NIDAAMKA IS-XIRISTA (LOCK UNTIL 28TH):
    Calendar cal = Calendar.getInstance();
    if (cal.get(Calendar.DAY_OF_MONTH) >= 28) {
        cal.add(Calendar.MONTH, 1);
    }
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM");
    String currentMonth = sdf.format(cal.getTime());
    
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payments & Payroll - School Management</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- SweetAlert2 CSS -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css">
<!-- SweetAlert2 JS -->
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <style>
        :root {
            --bg-main: #f0f4f8; --card-bg: #ffffff; --text-main: #2d3748;
            --text-muted: #718096; --border-color: #e2e8f0; --primary: #4f46e5;
            --success: #10b981; --warning: #f59e0b; --danger: #ef4444;
        }
        .dark-mode {
            --bg-main: #0f172a; --card-bg: #1e293b; --text-main: #f1f5f9;
            --text-muted: #94a3b8; --border-color: #334155;
        }

       .rtl { direction: rtl; text-align: right; }
        .rtl .profile-card { text-align: right; }
        .rtl .modal-content { text-align: right; }
        
        body { background-color: var(--bg-main); color: var(--text-main); font-family: 'Segoe UI', sans-serif; margin: 0; padding: 30px 20px; transition: all 0.3s; }
        .container { max-width: 1200px; margin: auto; }

        /* Qaybta Sare & Search */
        .header-actions { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; gap: 15px; flex-wrap: wrap; }
        .search-container { flex: 1; display: flex; gap: 15px; max-width: 600px; }
        .search-box { width: 100%; padding: 12px 20px; font-size: 16px; border: 2px solid var(--border-color); border-radius: 10px; background: var(--card-bg); color: var(--text-main); outline: none; }
        .search-box:focus { border-color: var(--primary); }
        
        .tabs { display: flex; gap: 10px; margin-bottom: 20px; border-bottom: 2px solid var(--border-color); padding-bottom: 10px; overflow-x: auto;}
        .tab-btn { padding: 10px 20px; font-size: 16px; font-weight: bold; background: none; border: none; color: var(--text-muted); cursor: pointer; border-radius: 8px; transition: 0.3s; white-space: nowrap;}
        .tab-btn.active { background: var(--primary); color: white; }
        .tab-content { display: none; }
        .tab-content.active { display: block; }

        /* CARDS DESIGN */
        .grid-container { display: grid; grid-template-columns: repeat(auto-fill, minmax(340px, 1fr)); gap: 20px; }
        
        .profile-card { background: var(--card-bg); border-radius: 16px; border: 1px solid var(--border-color); padding: 20px; display: flex; flex-direction: column; gap: 15px; transition: transform 0.2s, box-shadow 0.2s; position: relative; }
        .profile-card:hover { transform: translateY(-3px); box-shadow: 0 10px 20px rgba(0,0,0,0.05); }
        
        .card-header { display: flex; align-items: flex-start; gap: 15px; }
        .profile-img { width: 65px; height: 65px; border-radius: 50%; object-fit: cover; border: 3px solid var(--border-color); flex-shrink: 0; }
        .profile-info { flex: 1; }
        .profile-info h3 { margin: 0 0 5px 0; font-size: 17px; color: var(--text-main); display: flex; justify-content: space-between; align-items: center;}
        .profile-info p { margin: 3px 0; font-size: 13px; color: var(--text-muted); }
        
        /* Badges */
        .status-badge { padding: 4px 10px; border-radius: 20px; font-size: 11px; font-weight: bold; text-transform: uppercase; letter-spacing: 0.5px;}
        .status-Paid { background: #d1fae5; color: #065f46; }
        .status-Partial { background: #fef3c7; color: #92400e; }
        .status-Pending, .status-Unpaid { background: #fee2e2; color: #991b1b; }

        .dark-mode .status-Paid { background: rgba(16, 185, 129, 0.2); color: #34d399; }
        .dark-mode .status-Partial { background: rgba(245, 158, 11, 0.2); color: #fbbf24; }
        .dark-mode .status-Pending, .dark-mode .status-Unpaid { background: rgba(239, 68, 68, 0.2); color: #f87171; }

        /* Qaybta Xisaabta (Finance Grid) */
        .finance-grid { display: flex; justify-content: space-between; background: var(--bg-main); padding: 12px; border-radius: 10px; border: 1px solid var(--border-color); margin-top: 5px; }
        .finance-item { text-align: center; flex: 1; border-right: 1px solid var(--border-color); }
        .finance-item:last-child { border-right: none; }
        .finance-item small { font-size: 11px; color: var(--text-muted); text-transform: uppercase; font-weight: 600; display: block; margin-bottom: 4px; }
        .finance-item b { font-size: 15px; }
        .text-success { color: var(--success) !important; }
        .text-danger { color: var(--danger) !important; }
        .text-warning { color: var(--warning) !important; }

        /* Badhanka Kaarka Dhexdiisa (Card Action Button) */
        .btn-card-action { width: 100%; padding: 10px; border: none; border-radius: 8px; font-weight: bold; font-size: 14px; cursor: pointer; transition: 0.3s; display: flex; justify-content: center; align-items: center; gap: 8px; margin-top: 10px; }
        .btn-pay-now { background: var(--primary); color: white; }
        .btn-pay-now:hover { background: #4338ca; }
        .btn-locked { background: var(--border-color); color: var(--text-muted); cursor: not-allowed; }
        .dark-mode .btn-locked { background: #1e293b; color: #475569; }

        /* Modal Styling (Form-ka Lacagta) */
        .modal { display: none; position: fixed; z-index: 1000; left: 0; top: 0; width: 100%; height: 100%; background-color: rgba(0, 0, 0, 0.5); backdrop-filter: blur(4px); align-items: center; justify-content: center; }
        .modal-content { background-color: var(--card-bg); margin: auto; padding: 30px; border-radius: 16px; width: 90%; max-width: 400px; box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1); border: 1px solid var(--border-color); position: relative; animation: slideDown 0.3s ease-out; }
        @keyframes slideDown { from { transform: translateY(-20px); opacity: 0; } to { transform: translateY(0); opacity: 1; } }
        
        .close-modal { position: absolute; top: 15px; right: 20px; color: var(--text-muted); font-size: 24px; font-weight: bold; cursor: pointer; }
        .close-modal:hover { color: var(--danger); }
        .rtl .close-modal { right: auto; left: 20px; }
        
        .form-group { margin-bottom: 15px; }
        .form-group label { display: block; margin-bottom: 5px; font-weight: bold; color: var(--text-main); font-size: 14px; }
        .form-control { width: 100%; padding: 10px; border: 1px solid var(--border-color); border-radius: 8px; background: var(--bg-main); color: var(--text-main); font-size: 15px; box-sizing: border-box; }
        .form-control:focus { outline: none; border-color: var(--primary); }
        .btn-submit { width: 100%; padding: 12px; background: var(--success); color: white; border: none; border-radius: 8px; font-size: 16px; font-weight: bold; cursor: pointer; margin-top: 10px; transition: 0.3s; }
        .btn-submit:hover { background: #059669; }

        /* CSS CUSUB: Styling-ka Miiska Taariikhda (History Table) */
        .history-card { background: var(--card-bg); border-radius: 16px; border: 1px solid var(--border-color); padding: 20px; overflow-x: auto; }
        .history-table { width: 100%; border-collapse: collapse; text-align: left; }
        .rtl .history-table { text-align: right; }
        .history-table th { padding: 12px 15px; border-bottom: 2px solid var(--border-color); color: var(--text-muted); font-weight: 600; font-size: 14px; background: var(--bg-main); }
        .history-table td { padding: 12px 15px; border-bottom: 1px solid var(--border-color); color: var(--text-main); font-size: 14px; }
        .history-table tbody tr:hover { background-color: var(--bg-main); }
        .badge-student { background: #d1fae5; color: #065f46; padding: 4px 10px; border-radius: 20px; font-size: 11px; font-weight: bold; }
        .badge-teacher { background: #e0e7ff; color: #3730a3; padding: 4px 10px; border-radius: 20px; font-size: 11px; font-weight: bold; }
        .dark-mode .badge-student { background: rgba(16, 185, 129, 0.2); color: #34d399; }
        .dark-mode .badge-teacher { background: rgba(99, 102, 241, 0.2); color: #818cf8; }
        
        /* CSS-KII PRINT KA OO LA SAXAY SOONA NOQDAY MID LA GUJIN KARO */
        .btn-print { background: transparent; border: 1px solid var(--primary); color: var(--primary); padding: 6px 12px; border-radius: 6px; cursor: pointer; font-size: 13px; font-weight: 600; transition: 0.3s; }
        .btn-print:hover { background: var(--primary); color: white; }
    </style>
</head>
<body>

<div class="container">
    
    <div style="margin-bottom: 20px;">
        <h2 style="margin: 0;"><i class="fas fa-wallet"></i> <span data-i18n="page_title">Maamulka Lacagaha & Mushaaraadka</span></h2>
        <p style="margin: 5px 0 0 0; color: var(--text-muted);">
            <span data-i18n="current_month">Bisha Loo Xisaabinayo:</span> <b><%= currentMonth %></b> 
            <small style="color: var(--warning); margin-left: 10px;" data-i18n="lock_notice">(Waxay xirmaysaa 28-ka bisha)</small>
        </p>
    </div>

    <div class="header-actions">
        <div class="search-container">
            <input type="text" id="searchInput" class="search-box" data-i18n-placeholder="search_placeholder" placeholder="Raadi magac, nambar, ama ID..." onkeyup="filterProfiles()">
        </div>
    </div>

    <!-- TABS: Waxaa lagu daray Tab 3-aad ee Taariikhda -->
    <div class="tabs">
        <button class="tab-btn active" id="btn-students" onclick="switchTab('students')" data-i18n="tab_students">Ardayda (Students)</button>
        <button class="tab-btn" id="btn-teachers" onclick="switchTab('teachers')" data-i18n="tab_teachers">Macalimiinta (Teachers)</button>
        <button class="tab-btn" id="btn-history" onclick="switchTab('history')" data-i18n="tab_history">Taariikhda (History)</button>
    </div>

    <%
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            String schoolName = "SCHOOL";
String schoolLogo = "uploads/logos/default-logo.png";

PreparedStatement psConfig = null;
ResultSet rsConfig = null;

try {
    String configSql = "SELECT school_name, logo_path FROM system_config WHERE id = 1 LIMIT 1";
    psConfig = conn.prepareStatement(configSql);
    rsConfig = psConfig.executeQuery();

    if (rsConfig.next()) {
        if (rsConfig.getString("school_name") != null) {
            schoolName = rsConfig.getString("school_name");
        }

        if (rsConfig.getString("logo_path") != null &&
            !rsConfig.getString("logo_path").trim().isEmpty()) {
            schoolLogo = rsConfig.getString("logo_path");
        }
    }
} finally {
    if (rsConfig != null) try { rsConfig.close(); } catch (SQLException ignored) {}
    if (psConfig != null) try { psConfig.close(); } catch (SQLException ignored) {}
}
    %>

    <!-- TAB 1: ARDAYDA -->
    <div id="tab-students" class="tab-content active">
        <div class="grid-container">
            <%
                String stuSql = "SELECT s.id, s.student_id, s.full_name, s.class, s.photo, s.student_phone, " +
                                "COALESCE(c.monthly_fee, 0.00) as required_fee, " +
                                "COALESCE(sp.paid_amount, 0.00) as paid_amount, " +
                                "(COALESCE(c.monthly_fee, 0.00) - COALESCE(sp.paid_amount, 0.00)) as balance, " +
                                "CASE " +
                                "  WHEN COALESCE(sp.paid_amount, 0.00) >= COALESCE(c.monthly_fee, 0.00) AND COALESCE(c.monthly_fee, 0.00) > 0 THEN 'Paid' " +
                                "  WHEN COALESCE(sp.paid_amount, 0.00) > 0 THEN 'Partial' " +
                                "  ELSE 'Pending' " +
                                "END as pay_status " +
                                "FROM students s " +
                                "LEFT JOIN class c ON s.class = c.class_name " +
                                "LEFT JOIN student_payments sp ON s.id = sp.student_id AND sp.month_year = ?";
                
                PreparedStatement psStu = conn.prepareStatement(stuSql);
                psStu.setString(1, currentMonth);
                ResultSet rsStu = psStu.executeQuery();
                
                while(rsStu.next()) {
                    String photo = rsStu.getString("photo");
                    if(photo == null || photo.isEmpty()) photo = "uploads/students/default-avatar.png";
                    
                    String status = rsStu.getString("pay_status");
                    double reqFee = rsStu.getDouble("required_fee");
                    double paidAmt = rsStu.getDouble("paid_amount");
                    double balance = rsStu.getDouble("balance");
            %>
            <div class="profile-card searchable">
                <div class="card-header">
                    <img src="<%= photo %>" class="profile-img" onerror="this.src='uploads/students/default-avatar.png'">
                    <div class="profile-info">
                        <h3>
                            <span class="search-name"><%= rsStu.getString("full_name") %></span>
                            <span class="status-badge status-<%= status %>" data-i18n="status_<%= status.toLowerCase() %>"><%= status %></span>
                        </h3>
                        <p><i class="fas fa-id-badge text-muted"></i> ID: <%= rsStu.getString("student_id") %> | <i class="fas fa-chalkboard text-muted"></i> <%= rsStu.getString("class") %></p>
                        <p class="search-phone"><i class="fas fa-phone text-muted"></i> <%= rsStu.getString("student_phone") != null ? rsStu.getString("student_phone") : "Lama diiwaangelin" %></p>
                    </div>
                </div>
                
                <div class="finance-grid">
                    <div class="finance-item">
                        <small data-i18n="lbl_required">Laga Rabo</small>
                        <b>$<%= String.format("%.2f", reqFee) %></b>
                    </div>
                    <div class="finance-item">
                        <small data-i18n="lbl_paid">Bixiyay</small>
                        <b class="<%= paidAmt > 0 ? "text-success" : "" %>">$<%= String.format("%.2f", paidAmt) %></b>
                    </div>
                    <div class="finance-item">
                        <small data-i18n="lbl_balance">Haraa</small>
                        <b class="<%= balance > 0 ? "text-danger" : (balance < 0 ? "text-warning" : "text-success") %>">$<%= String.format("%.2f", balance) %></b>
                    </div>
                </div>
                
                <!-- BADHANKA LACAG BIXINTA -->
                <% if(status.equals("Paid") || reqFee <= 0) { %>
                    <button class="btn-card-action btn-locked" disabled>
                        <i class="fas fa-lock"></i> <span data-i18n="btn_locked">Waa Xiran Yahay</span>
                    </button>
                <% } else { %>
                    <button class="btn-card-action btn-pay-now" onclick="openPaymentModal('student', '<%= rsStu.getString("id") %>', '<%= rsStu.getString("full_name") %>', <%= balance %>)">
                        <i class="fas fa-cash-register"></i> <span data-i18n="btn_pay">Bixi Lacagta</span>
                    </button>
                <% } %>
            </div>
            <%  } rsStu.close(); psStu.close(); %>
        </div>
    </div>

    <!-- TAB 2: MACALIMIINTA -->
    <div id="tab-teachers" class="tab-content">
        <div class="grid-container">
            <%
                String teachSql = "SELECT t.id, u.full_name, t.photo, t.phone, t.base_salary, " +
                                  "COALESCE(tp.net_salary, t.base_salary) as net_salary, " +
                                  "COALESCE(tp.paid_amount, 0.00) as paid_amount, " +
                                  "(COALESCE(tp.net_salary, t.base_salary) - COALESCE(tp.paid_amount, 0.00)) as balance, " +
                                  "CASE " +
                                  "  WHEN COALESCE(tp.paid_amount, 0.00) >= COALESCE(tp.net_salary, t.base_salary) AND COALESCE(tp.net_salary, t.base_salary) > 0 THEN 'Paid' " +
                                  "  WHEN COALESCE(tp.paid_amount, 0.00) > 0 THEN 'Partial' " +
                                  "  ELSE 'Unpaid' " +
                                  "END as pay_status " +
                                  "FROM teachers t " +
                                  "JOIN users u ON t.user_id = u.id " +
                                  "LEFT JOIN teacher_payments tp ON t.id = tp.teacher_id AND tp.month_year = ?";
                                  
                PreparedStatement psTeach = conn.prepareStatement(teachSql);
                psTeach.setString(1, currentMonth);
                ResultSet rsTeach = psTeach.executeQuery();
                
                while(rsTeach.next()) {
                    String tPhoto = rsTeach.getString("photo");
                    if (tPhoto == null || tPhoto.trim().isEmpty()) { tPhoto = "uploads/teacher/default-avatar.png"; } 
                    else {
                        tPhoto = tPhoto.trim();
                        if (tPhoto.startsWith("uploads/teachers/")) tPhoto = tPhoto.replace("uploads/teachers/", "uploads/teacher/");
                        if (!tPhoto.contains("/")) tPhoto = "uploads/teacher/" + tPhoto;
                    }
                    
                    String tStatus = rsTeach.getString("pay_status");
                    double netSal = rsTeach.getDouble("net_salary");
                    double tPaid = rsTeach.getDouble("paid_amount");
                    double tBal = rsTeach.getDouble("balance");
            %>
            <div class="profile-card searchable">
                <div class="card-header">
                    <img src="<%= tPhoto %>" class="profile-img" onerror="this.onerror=null; this.src='uploads/teacher/default-avatar.png';">
                    
                    <div class="profile-info">
                        <h3>
                            <span class="search-name"><%= rsTeach.getString("full_name") %></span>
                            <span class="status-badge status-<%= tStatus %>" data-i18n="status_<%= tStatus.toLowerCase() %>"><%= tStatus %></span>
                        </h3>
                        <p class="search-phone"><i class="fas fa-phone text-muted"></i> <%= (rsTeach.getString("phone") != null && !rsTeach.getString("phone").isEmpty()) ? rsTeach.getString("phone") : "N/A" %></p>
                        <p><i class="fas fa-briefcase text-muted"></i> Macalin</p>
                    </div>
                </div>

                <div class="finance-grid">
                    <div class="finance-item">
                        <small data-i18n="lbl_salary">Net Salary</small>
                        <b>$<%= String.format("%.2f", netSal) %></b>
                    </div>
                    <div class="finance-item">
                        <small data-i18n="lbl_paid_out">La Siiyay</small>
                        <b class="<%= tPaid > 0 ? "text-success" : "" %>">$<%= String.format("%.2f", tPaid) %></b>
                    </div>
                    <div class="finance-item">
                        <small data-i18n="lbl_balance">Haraa</small>
                        <b class="<%= tBal > 0 ? "text-danger" : "text-success" %>">$<%= String.format("%.2f", tBal) %></b>
                    </div>
                </div>
                
                <!-- BADHANKA MUSHAAAR BIXINTA -->
                <% if(tStatus.equals("Paid") || netSal <= 0) { %>
                    <button class="btn-card-action btn-locked" disabled>
                        <i class="fas fa-lock"></i> <span data-i18n="btn_locked_payout">Waa Xiran Yahay</span>
                    </button>
                <% } else { %>
                    <button class="btn-card-action btn-pay-now" onclick="openPaymentModal('teacher', '<%= rsTeach.getString("id") %>', '<%= rsTeach.getString("full_name") %>', <%= tBal %>)" style="background: var(--success);">
                        <i class="fas fa-hand-holding-usd"></i> <span data-i18n="btn_payout">Sii Mushaarka</span>
                    </button>
                <% } %>
            </div>
            <%  } rsTeach.close(); psTeach.close(); %>
        </div>
    </div>

    <!-- TAB 3: TAARIIKHDA (HISTORY) - LA HORUMARIYAY -->
    <div id="tab-history" class="tab-content">
        <div class="history-card">
            <h3 style="margin-top:0; margin-bottom: 20px;"><i class="fas fa-history text-muted"></i> <span data-i18n="tab_history">Taariikhda Lacag Bixinta (Recent Transactions)</span></h3>
            <table class="history-table">
                <thead>
                    <tr>
                        <th data-i18n="col_receipt">Rasiidka #</th>
                        <th data-i18n="col_type">Nooca</th>
                        <th>Qofka (Sawir, Magac & ID)</th>
                        <th data-i18n="col_amount">Lacagta</th>
                        <th data-i18n="col_date">Taariikhda</th>
                        <th data-i18n="col_action">Action</th>
                    </tr>
                </thead>
               <tbody>
                    <%
                        PreparedStatement psHist = null;
                        ResultSet rsHist = null;
                        try {
                          String histSql =
                          "SELECT ph.receipt_no, ph.user_type, ph.user_id, ph.amount, " +
                          "ph.billing_month, ph.payment_date, " +
                          "CASE WHEN ph.user_type = 'student' THEN s.full_name ELSE u.full_name END AS person_name, " +
                          "CASE WHEN ph.user_type = 'student' THEN s.student_id ELSE CAST(t.id AS CHAR) END AS display_id, " +
                          "CASE WHEN ph.user_type = 'student' THEN s.photo ELSE t.photo END AS person_photo, " +
                          "s.class AS student_class " +
                          "FROM payment_history ph " +
                          "LEFT JOIN students s ON ph.user_type = 'student' AND ph.user_id = s.id " +
                          "LEFT JOIN teachers t ON ph.user_type = 'teacher' AND ph.user_id = t.id " +
                          "LEFT JOIN users u ON t.user_id = u.id " +
                          "ORDER BY ph.id DESC LIMIT 15";
                                             
                            psHist = conn.prepareStatement(histSql);
                            rsHist = psHist.executeQuery();
                            
                            while(rsHist.next()) {
                                String rNo = rsHist.getString("receipt_no");
                                String pType = rsHist.getString("user_type");
                                double amt = rsHist.getDouble("amount");
                                Timestamp pDate = rsHist.getTimestamp("payment_date");
                                
                                String personName = rsHist.getString("person_name");
String displayId = rsHist.getString("display_id");
String personPhoto = rsHist.getString("person_photo");
String billingMonth = rsHist.getString("billing_month");
String studentClass = rsHist.getString("student_class");

                                if(personName == null) personName = "Lama helin";
                                if(displayId == null) displayId = "N/A";
                                
                                if (personPhoto == null || personPhoto.trim().isEmpty()) { 
                                    personPhoto = pType.equals("student") ? "uploads/students/default-avatar.png" : "uploads/teacher/default-avatar.png";
                                } else {
                                    if (personPhoto.startsWith("uploads/teachers/")) personPhoto = personPhoto.replace("uploads/teachers/", "uploads/teacher/");
                                    if (!personPhoto.contains("/")) personPhoto = (pType.equals("student") ? "uploads/students/" : "uploads/teacher/") + personPhoto;
                                }
                               


if (personName == null) personName = "Lama helin";
if (displayId == null) displayId = "N/A";
if (billingMonth == null) billingMonth = "N/A";
if (studentClass == null) studentClass = "N/A";

if (personPhoto == null || personPhoto.trim().isEmpty()) {

    if ("student".equalsIgnoreCase(pType)) {
        personPhoto = "uploads/students/default-avatar.png";
    } else {
        personPhoto = "uploads/teacher/default-avatar.png";
    }

} else {

    personPhoto = personPhoto.trim();

    if ("teacher".equalsIgnoreCase(pType)) {

        if (personPhoto.startsWith("uploads/teachers/")) {
            personPhoto = personPhoto.replace(
                "uploads/teachers/",
                "uploads/teacher/"
            );
        }

        if (!personPhoto.contains("/")) {
            personPhoto = "uploads/teacher/" + personPhoto;
        }
    }
}
                    %>
                    <tr>
                        <td><strong><%= rNo != null ? rNo : "N/A" %></strong></td>
                        <td>
                            <% if("student".equalsIgnoreCase(pType)) { %>
                                <span class="badge-student"><i class="fas fa-user-graduate"></i> Arday</span>
                            <% } else { %>
                                <span class="badge-teacher"><i class="fas fa-chalkboard-teacher"></i> Macalin</span>
                            <% } %>
                        </td>
                        <td>
                            <div style="display: flex; align-items: center; gap: 12px;">
                                <img src="<%= personPhoto %>" style="width: 35px; height: 35px; border-radius: 50%; object-fit: cover; border: 1px solid var(--border-color);" onerror="this.src='uploads/students/default-avatar.png'">
                                <div>
                                    <div style="font-weight: 600; font-size: 14px; color: var(--text-main);"><%= personName %></div>
                                    <div style="font-size: 12px; color: var(--text-muted);">ID: <%= displayId %></div>
                                </div>
                            </div>
                        </td>
                        <td><strong>$<%= String.format("%.2f", amt) %></strong></td>
                        <td><span style="color: var(--text-muted); font-size: 13px;"><%= pDate != null ? pDate.toString().substring(0, 16) : "" %></span></td>
                        <td>
                           <button
  
    type="button"
    class="btn-print"
    onclick="printReceipt(
        '<%= escapeJs(rNo) %>',
        '<%= escapeJs(pType) %>',
        '<%= escapeJs(personName) %>',
        '<%= escapeJs(displayId) %>',
        '<%= String.format("%.2f", amt) %>',
        '<%= escapeJs(String.valueOf(pDate)) %>',
        '<%= escapeJs(schoolName) %>',
        '<%= escapeJs(schoolLogo) %>',
        '<%= escapeJs(personPhoto) %>',
        '<%= escapeJs(billingMonth) %>',
        '<%= escapeJs(studentClass) %>'
    )">
    <i class="fas fa-print"></i> Print

</button>
                        </td>
                    </tr>
                    <%
                            }
                        } catch (Exception ex) {
                            out.print("<tr><td colspan='6' class='text-danger'>Waxaa cillad ka dhacday taariikhda: " + ex.getMessage() + "</td></tr>");
                        } finally {
                            if(rsHist != null) rsHist.close();
                            if(psHist != null) psHist.close();
                        }
                    %>
                </tbody>
            </table>
        </div>
    </div>

    <%
        } catch(Exception e) {
            out.println("<div style='background:#fee2e2; color:#991b1b; padding:15px; border-radius:8px;'>Cilad Database: " + e.getMessage() + "</div>");
        } finally {
            if(conn != null) conn.close();
        }
    %>

</div>

<!-- MODAL-KA LACAGTA / MUSHAARKA LAGU QABANAYO -->
<div id="paymentModal" class="modal">
    <div class="modal-content">
        <span class="close-modal" onclick="closePaymentModal()">&times;</span>
        <h2 id="modalTitle" style="margin-top: 0; color: var(--text-main); font-size: 20px; border-bottom: 2px solid var(--border-color); padding-bottom: 10px;">Process Transaction</h2>
        
<form action="process_payment_action.jsp" method="POST">
    <input type="hidden" name="user_type" id="modalUserType">
    <input type="hidden" name="user_id" id="modalUserId">
    
    <div class="form-group">
        <label data-i18n="lbl_modal_month">Bisha (Month):</label>
        <input type="month" name="billing_month" id="modalMonth" class="form-control" required>
    </div>

    <div class="form-group">
        <label data-i18n="lbl_modal_name">Magaca (Name):</label>
        <input type="text" id="modalUserName" class="form-control" readonly style="background: var(--bg-main); opacity: 0.8;">
    </div>
    
    <div class="form-group">
        <label data-i18n="lbl_modal_amount">Lacagta (Amount in $):</label>
        <input type="number" step="0.01" name="amount" id="modalAmount" class="form-control" required placeholder="Geli lacagta..." oninput="preventOverpayment(this)">
        <small id="overpayWarning" style="color: var(--danger); display: none; font-size: 12px; margin-top: 5px;"></small>
    </div>

    <div id="teacherExtras" style="display: none; border-top: 1px dashed var(--border-color); padding-top: 15px; margin-top: 10px;">
        <div class="form-group">
            <label style="color: var(--success);">Bonus (Guno $):</label>
            <input type="number" step="0.01" name="bonus" id="modalBonus" class="form-control" value="0.00" placeholder="0.00" oninput="updatePaymentAmount()">
        </div>
        <div class="form-group">
            <label style="color: var(--danger);">Deduction (Ganaax/Goyn $):</label>
            <input type="number" step="0.01" name="deductions" id="modalDeductions" class="form-control" value="0.00" placeholder="0.00" oninput="updatePaymentAmount()">
        </div>
    </div>
    
    <button type="submit" class="btn-submit">
        <i class="fas fa-check-circle"></i> <span data-i18n="btn_modal_save">Keydi (Save)</span>
    </button>
</form>
    </div>
</div>

<script>
    const pageTranslations = {
        en: {
            page_title: "Payments & Payroll", current_month: "Billing Month:", lock_notice: "(Cycles to next month on the 28th)", 
            search_placeholder: "Search name, phone, or ID...", tab_students: "Students", tab_teachers: "Teachers", tab_history: "History",
            status_paid: "Paid", status_partial: "Partial", status_pending: "Pending", status_unpaid: "Unpaid",
            lbl_required: "Required", lbl_paid: "Paid", lbl_balance: "Balance", lbl_salary: "Net Salary", lbl_paid_out: "Paid Out",
            btn_pay: "Pay Fee", btn_locked: "Locked", btn_payout: "Pay Salary", btn_locked_payout: "Locked (Paid)",
            lbl_modal_month: "Billing Month:", lbl_modal_name: "Name:", lbl_modal_amount: "Amount ($):", btn_modal_save: "Save Transaction",
            col_receipt: "Receipt #", col_type: "Type", col_person: "Person ID", col_amount: "Amount", col_date: "Date", col_action: "Action"
        },
        so: {
            page_title: "Maamulka Lacagaha & Mushaaraadka", current_month: "Bisha Loo Xisaabinayo:", lock_notice: "(Waxay xirmaysaa 28-ka bisha)", 
            search_placeholder: "Raadi magac, nambar, ama ID...", tab_students: "Ardayda (Students)", tab_teachers: "Macalimiinta (Teachers)", tab_history: "Taariikhda (History)",
            status_paid: "Waa Bixiyay", status_partial: "Qayb ahaan", status_pending: "Ma Bixin", status_unpaid: "Lama Siin",
            lbl_required: "Laga Rabo", lbl_paid: "Bixiyay", lbl_balance: "Haraa", lbl_salary: "Mushaar", lbl_paid_out: "La Siiyay",
            btn_pay: "Bixi Lacagta", btn_locked: "Waa Xiran Yahay", btn_payout: "Sii Mushaarka", btn_locked_payout: "Waa Xiran Yahay",
            lbl_modal_month: "Bisha (Month):", lbl_modal_name: "Magaca:", lbl_modal_amount: "Lacagta la bixinayo ($):", btn_modal_save: "Keydi Xogta",
            col_receipt: "Rasiidka #", col_type: "Nooca", col_person: "Aqoonsiga", col_amount: "Lacagta", col_date: "Taariikhda", col_action: "Falka"
        },
        ar: {
            page_title: "إدارة المدفوعات والرواتب", current_month: "شهر الفوترة:", lock_notice: "(ينتقل للشهر التالي يوم 28)", 
            search_placeholder: "ابحث عن اسم، رقم، أو هوية...", tab_students: "الطلاب", tab_teachers: "المعلمون", tab_history: "السجل (History)",
            status_paid: "مدفوع", status_partial: "جزئي", status_pending: "قيد الانتظار", status_unpaid: "غير مدفوع",
            lbl_required: "المطلوب", lbl_paid: "المدفوع", lbl_balance: "المتبقي", lbl_salary: "الراتب", lbl_paid_out: "تم الدفع",
            btn_pay: "دفع الرسوم", btn_locked: "مغلق", btn_payout: "دفع الراتب", btn_locked_payout: "مغلق (مدفوع)",
            lbl_modal_month: "شهر الفوترة:", lbl_modal_name: "الاسم:", lbl_modal_amount: "المبلغ ($):", btn_modal_save: "حفظ البيانات",
            col_receipt: "رقم الإيصال", col_type: "النوع", col_person: "رقم الهوية", col_amount: "المبلغ", col_date: "التاريخ", col_action: "الإجراء"
        }
    };

    const currentTheme = localStorage.getItem('app_theme') || 'light';
    const currentLang = localStorage.getItem('app_language') || 'en';

    document.addEventListener("DOMContentLoaded", () => {
        if (currentTheme === 'dark') document.body.classList.add("dark-mode");
        applyPageLanguage(currentLang);
    });

    function applyPageLanguage(lang) {
        if (lang === 'ar') document.body.classList.add('rtl');
        else document.body.classList.remove('rtl');

        document.querySelectorAll('[data-i18n]').forEach(el => {
            const key = el.getAttribute('data-i18n');
            if (pageTranslations[lang] && pageTranslations[lang][key]) el.innerHTML = pageTranslations[lang][key];
        });
        document.querySelectorAll('[data-i18n-placeholder]').forEach(el => {
            const key = el.getAttribute('data-i18n-placeholder');
            if (pageTranslations[lang] && pageTranslations[lang][key]) el.placeholder = pageTranslations[lang][key];
        });
    }

    function switchTab(tabName) {
        document.querySelectorAll('.tab-btn').forEach(btn => btn.classList.remove('active'));
        document.querySelectorAll('.tab-content').forEach(content => content.classList.remove('active'));
        document.getElementById('btn-' + tabName).classList.add('active');
        document.getElementById('tab-' + tabName).classList.add('active');
        document.getElementById('searchInput').value = '';
        if(tabName !== 'history') filterProfiles(); // Search-ga yaanu table-ka history-ga khalkhal gelinin
    }

    function filterProfiles() {
        let input = document.getElementById('searchInput').value.toLowerCase();
        let activeTab = document.querySelector('.tab-content.active');
        if(!activeTab) return;
        
        let cards = activeTab.getElementsByClassName('searchable');
        
        for (let i = 0; i < cards.length; i++) {
            let fullText = cards[i].innerText.toLowerCase(); 
            cards[i].style.display = fullText.includes(input) ? "flex" : "none";
        }
    }

    function preventOverpayment(inputElement) {
        let maxAllowed = parseFloat(inputElement.getAttribute("max"));
        let enteredValue = parseFloat(inputElement.value);
        let warningMsg = document.getElementById("overpayWarning");

        if (enteredValue > maxAllowed) {
            inputElement.value = maxAllowed; 
            warningMsg.innerText = "Error: You Cannot Exceed the Remaining Balance. ($" + maxAllowed + ")!";
            warningMsg.style.display = "block";
        } else {
            warningMsg.style.display = "none";
        }
    }

    let globalOriginalBalance = 0; 

    function openPaymentModal(type, id, name, balance) {
        document.getElementById('paymentModal').style.display = "flex";
        
        document.getElementById('modalUserType').value = type;
        document.getElementById('modalUserId').value = id;
        document.getElementById('modalUserName').value = name;
        
        document.getElementById('modalMonth').value = "<%= currentMonth %>";

        globalOriginalBalance = balance > 0 ? balance : 0; 

        let amountInput = document.getElementById('modalAmount');
        amountInput.value = globalOriginalBalance > 0 ? globalOriginalBalance : "";
        amountInput.setAttribute("max", globalOriginalBalance); 
        document.getElementById("overpayWarning").style.display = "none";
        
        let teacherExtras = document.getElementById('teacherExtras');
        if (type === 'teacher') {
            teacherExtras.style.display = "block"; 
            document.getElementById('modalBonus').value = "0.00"; 
            document.getElementById('modalDeductions').value = "0.00"; 
        } else {
            teacherExtras.style.display = "none"; 
        }
        
        let title = document.getElementById('modalTitle');
        if(currentLang === 'so') {
            title.innerHTML = type === 'student' ? '<i class="fas fa-cash-register"></i> Bixinta Lacagta Ardayga' : '<i class="fas fa-hand-holding-usd"></i> Bixinta Mushaarka Macalinka';
        } else if (currentLang === 'ar') {
            title.innerHTML = type === 'student' ? '<i class="fas fa-cash-register"></i> دفع رسوم الطالب' : '<i class="fas fa-hand-holding-usd"></i> دفع راتب المعلم';
        } else {
            title.innerHTML = type === 'student' ? '<i class="fas fa-cash-register"></i> Process Student Fee' : '<i class="fas fa-hand-holding-usd"></i> Process Teacher Salary';
        }
    }

    function updatePaymentAmount() {
        let userType = document.getElementById('modalUserType').value;
        if (userType !== 'teacher') return; 

        let bonus = parseFloat(document.getElementById('modalBonus').value) || 0;
        let deduction = parseFloat(document.getElementById('modalDeductions').value) || 0;
        
        let newMax = globalOriginalBalance + bonus - deduction;
        if (newMax < 0) newMax = 0; 

        let amountInput = document.getElementById('modalAmount');
        amountInput.setAttribute("max", newMax);
        
        amountInput.value = newMax.toFixed(2); 
        
        preventOverpayment(amountInput); 
    }

    function closePaymentModal() {
        document.getElementById('paymentModal').style.display = "none";
    }

    window.onclick = function(event) {
        let modal = document.getElementById('paymentModal');
        if (event.target == modal) {
            modal.style.display = "none";
        }
    };
    
    document.addEventListener("DOMContentLoaded", function() {
        const urlParams = new URLSearchParams(window.location.search);
        const status = urlParams.get('status');
        const msg = urlParams.get('msg');

        if (status) {
            if (status === 'error') {
                Swal.fire({
                    icon: 'error',
                    title: 'An error occurred!',
                    text: msg ? msg : 'Fadlan hubi xogta aad gelisay.',
                    confirmButtonColor: '#d33',
                    confirmButtonText: 'Xir'
                });
            } else if (status === 'success') {
                Swal.fire({
                    icon: 'success',
                    title: 'Waa Hagaag!',
                    text: 'Lacag-bixinta si guul ah ayay u diiwaangashay.',
                    confirmButtonColor: '#28a745',
                    confirmButtonText: 'Waayahay'
                });
            }
            window.history.replaceState(null, null, window.location.pathname);
        }
    });

    // FUNCTION-KA RASIIDKA
 // FUNCTION-KA RASIIDKA
  function printReceipt(
    receiptNo,
    type,
    name,
    personId,
    amount,
    date,
    schoolName,
    schoolLogo,
    personPhoto,
    billingMonth,
    studentClass
) {

    // 1. HUBI LACAGTA
    var numericAmount = parseFloat(amount);
    if (isNaN(numericAmount)) {
        alert("Lacagta rasiidka lama aqrin karin.");
        return;
    }

    // 2. NOOCA QOFKA
    var isStudent = type === "student";
    var typeName = isStudent ? "Arday (Student)" : "Macalin (Teacher)";

    // 3. FUR PRINT WINDOW
    var printWindow = window.open("", "_blank", "width=550,height=750");
    if (!printWindow) {
        alert("Print window-ka waa la xannibay.\n\nFadlan browser-ka u oggolow pop-ups-ka website-kan.");
        return;
    }

    // 4. HTML IYO CSS (LA ISKU CADAADIYAY SI UU HAL BOG U NOQDO)
    var html = "";
    html += "<!DOCTYPE html>";
    html += "<html lang='so'>";
    html += "<head>";
    html += "<meta charset='UTF-8'>";
    html += "<meta name='viewport' content='width=device-width, initial-scale=1.0'>";
    html += "<title>Receipt - " + escapeHtml(receiptNo) + "</title>";

    html += "<style>";
    html += "* { box-sizing: border-box; }";
    html += "html, body { margin:0; padding:0; }";
    html += "body { font-family: 'Segoe UI', Arial, sans-serif; background:#f1f5f9; color:#111827; padding:25px; }";

    html += ".receipt { width:100%; max-width:390px; margin:0 auto; background:#ffffff; border-radius:14px; overflow:hidden; box-shadow:0 8px 30px rgba(0,0,0,.10); border:1px solid #e5e7eb; }";
    html += ".top { padding:20px 22px 15px; text-align:center; background:#ffffff; border-bottom:2px dashed #d1d5db; }";
    html += ".school-logo { width:65px; height:65px; object-fit:contain; border-radius:50%; border:2px solid #e5e7eb; padding:5px; background:#fff; }";
    html += ".school-name { margin:10px 0 4px; font-size:18px; font-weight:800; color:#111827; text-transform:uppercase; }";
    html += ".receipt-title { font-size:11px; font-weight:600; color:#6b7280; text-transform:uppercase; letter-spacing:1.5px; }";
    
    html += ".meta { padding:12px 20px; background:#f8fafc; }";
    html += ".row { display:flex; justify-content:space-between; gap:15px; margin-bottom:6px; font-size:12px; }";
    html += ".row:last-child { margin-bottom:0; }";
    html += ".label { color:#64748b; }";
    html += ".value { font-weight:700; text-align:right; word-break:break-word; }";

    html += ".person { padding:15px; text-align:center; }";
    html += ".person-photo { width:75px; height:75px; border-radius:50%; object-fit:cover; border:3px solid #f1f5f9; box-shadow:0 3px 10px rgba(0,0,0,.10); }";
    html += ".person-name { margin:8px 0 2px; font-size:16px; font-weight:800; color:#111827; }";
    html += ".person-type { font-size:11px; color:#64748b; }";

    html += ".details { margin:0 20px; padding:12px; border:1px solid #e5e7eb; border-radius:10px; }";

    html += ".amount-box { margin:15px 20px; padding:15px; text-align:center; border-radius:12px; background:#f8fafc; border:1px solid #e2e8f0; }";
    html += ".amount-label { font-size:10px; font-weight:700; color:#64748b; text-transform:uppercase; letter-spacing:1.2px; }";
    html += ".amount { margin-top:3px; font-size:28px; font-weight:900; color:#111827; }";
    html += ".status { display:inline-block; margin-top:4px; padding:4px 12px; border-radius:30px; font-size:10px; font-weight:800; background:#dcfce7; color:#166534; text-transform:uppercase; }";

    html += ".footer { margin-top:5px; padding:15px 20px 20px; text-align:center; border-top:2px dashed #d1d5db; font-size:11px; color:#64748b; }";
    html += ".signature { display:block; width:65%; margin:20px auto 0; padding-top:5px; border-top:1px solid #9ca3af; color:#374151; font-weight: 600; }";


    // =========================================================
    // CSS-KA WAKHTIGA PRINT-GA EE LA SAXAY (HAL BOG)
    // =========================================================
    html += "@media print {";
    
    html += "@page {";
    html += "size: A5 portrait;";
    html += "margin: 0;"; /* Wuxuu meesha ka saarayaa Headers-ka/Footers-ka default ee browser-ka */
    html += "}";

    html += "body {";
    html += "background: #fff;";
    html += "padding: 8mm;"; /* Banan yar oo dhan walba ah */
    html += "margin: 0;";
    html += "-webkit-print-color-adjust: exact;"; 
    html += "}";

    html += ".receipt {";
    html += "box-shadow: none;";
    html += "border: 0;";
    html += "max-width: 100%;";
    html += "page-break-inside: avoid;"; /* Rasiidka inaan labo loo kala jarin */
    html += "}";

    /* Spacing-ka oo yara la dhimaayo si uusan u dhaafin dhererka warqadda */
    html += ".top { padding: 10px; }";
    html += ".meta { padding: 10px 15px; }";
    html += ".person { padding: 10px; }";
    html += ".details { padding: 8px 12px; margin: 0 10px; }";
    html += ".amount-box { margin: 10px; padding: 10px; }";
    html += ".footer { padding: 10px 15px; margin-top: 5px; }";
    html += ".signature { margin: 15px auto 0; }";

    html += "}";
    html += "</style>";
    html += "</head>";

    // HTML BODY
    html += "<body>";
    html += "<div class='receipt'>";

    html += "<div class='top'>";
    html += "<img class='school-logo' src='" + escapeHtml(schoolLogo) + "' onerror=\"this.style.display='none'\">";
    html += "<div class='school-name'>" + escapeHtml(schoolName) + "</div>";
    html += "<div class='receipt-title'>Official Payment Receipt</div>";
    html += "</div>";

    html += "<div class='meta'>";
    html += "<div class='row'><span class='label'>Receipt No.</span><span class='value'>" + escapeHtml(receiptNo) + "</span></div>";
    html += "<div class='row'><span class='label'>Date</span><span class='value'>" + escapeHtml(date) + "</span></div>";
    html += "<div class='row'><span class='label'>Payment Type</span><span class='value'>" + escapeHtml(typeName) + "</span></div>";
    html += "<div class='row'><span class='label'>Billing Month</span><span class='value'>" + escapeHtml(billingMonth) + "</span></div>";
    html += "</div>";

    html += "<div class='person'>";
    html += "<img class='person-photo' src='" + escapeHtml(personPhoto) + "' onerror=\"this.src='" + (isStudent ? "uploads/students/default-avatar.png" : "uploads/teacher/default-avatar.png") + "'\">";
    html += "<div class='person-name'>" + escapeHtml(name) + "</div>";
    html += "<div class='person-type'>" + escapeHtml(typeName) + "</div>";
    html += "</div>";

    html += "<div class='details'>";
    html += "<div class='row'><span class='label'>" + (isStudent ? "Student ID" : "Teacher ID") + "</span><span class='value'>" + escapeHtml(personId) + "</span></div>";
    if (isStudent) {
        html += "<div class='row'><span class='label'>Class</span><span class='value'>" + escapeHtml(studentClass) + "</span></div>";
    }
    html += "</div>";

    html += "<div class='amount-box'>";
    html += "<div class='amount-label'>Amount Paid</div>";
    html += "<div class='amount'>$" + numericAmount.toFixed(2) + "</div>";
    html += "<span class='status'>PAID</span>";
    html += "</div>";

    html += "<div class='footer'>";
    html += "Mahadsanid! Lacag-bixintaada si rasmi ah ayaa loo diiwaangeliyay.";
    html += "<span class='signature'>Saxiixa Maamulaha</span>";
    html += "</div>";

    html += "</div>";

    // PRINT SCRIPT
    html += "<script>";
    html += "window.onload = function() {";
    html += "setTimeout(function() {";
    html += "window.print();";
    html += "setTimeout(function() { window.close(); }, 800);";
    html += "}, 300);";
    html += "};";
    html += "<\/script>";

    html += "</body></html>";

    try {
        printWindow.document.open();
        printWindow.document.write(html);
        printWindow.document.close();
        printWindow.focus();
    } catch (error) {
        console.error("Print Error:", error);
        try { printWindow.close(); } catch (e) {}
        alert("Rasiidka lama daabici karin. Fadlan isku day mar kale.");
    }
}


function escapeHtml(value) {
    return String(value == null ? "" : value)
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#39;");
}
</script>

</body>
</html>