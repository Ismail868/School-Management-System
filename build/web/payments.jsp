<%@page import="java.sql.*, utils.DBConnection, java.text.SimpleDateFormat, java.util.Date, java.util.Calendar"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    if (session.getAttribute("username") == null) {
        response.sendRedirect("index.jsp");
        return; 
    }
    
    // NIDAAMKA IS-XIRISTA (LOCK UNTIL 28TH):
    // Haddii taariikhdu gaarto 28-ka, cycle-ka lacag bixinta wuxuu u wareegayaa bisha xigta.
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
        .rtl .header-actions { flex-direction: row-reverse; }
        .rtl .tabs { flex-direction: row-reverse; }
        .rtl .profile-card { flex-direction: row-reverse; text-align: right; }
        .rtl .finance-grid { flex-direction: row-reverse; }
        .rtl .modal-content { text-align: right; }
        
        body { background-color: var(--bg-main); color: var(--text-main); font-family: 'Segoe UI', sans-serif; margin: 0; padding: 30px 20px; transition: all 0.3s; }
        .container { max-width: 1200px; margin: auto; }

        /* Qaybta Sare & Search */
        .header-actions { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; gap: 15px; flex-wrap: wrap; }
        .search-container { flex: 1; display: flex; gap: 15px; max-width: 600px; }
        .search-box { width: 100%; padding: 12px 20px; font-size: 16px; border: 2px solid var(--border-color); border-radius: 10px; background: var(--card-bg); color: var(--text-main); outline: none; }
        .search-box:focus { border-color: var(--primary); }
        
        .tabs { display: flex; gap: 10px; margin-bottom: 20px; border-bottom: 2px solid var(--border-color); padding-bottom: 10px; }
        .tab-btn { padding: 10px 20px; font-size: 16px; font-weight: bold; background: none; border: none; color: var(--text-muted); cursor: pointer; border-radius: 8px; transition: 0.3s; }
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

    <div class="tabs">
        <button class="tab-btn active" id="btn-students" onclick="switchTab('students')" data-i18n="tab_students">Ardayda (Students)</button>
        <button class="tab-btn" id="btn-teachers" onclick="switchTab('teachers')" data-i18n="tab_teachers">Macalimiinta (Teachers)</button>
    </div>

    <%
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
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
        
        <!-- Fomka wuxuu ku xirmi doonaa Action page-ka xogta keydinaya -->
        <form action="process_payment_action.jsp" method="POST">
            <input type="hidden" name="user_type" id="modalUserType">
            <input type="hidden" name="user_id" id="modalUserId">
            <input type="hidden" name="billing_month" value="<%= currentMonth %>">

            <div class="form-group">
                <label data-i18n="lbl_modal_name">Magaca (Name):</label>
                <input type="text" id="modalUserName" class="form-control" readonly style="background: var(--bg-main); opacity: 0.8;">
            </div>
            
            <div class="form-group">
                <label data-i18n="lbl_modal_amount">Lacagta (Amount in $):</label>
                <input type="number" step="0.01" name="amount" id="modalAmount" class="form-control" required placeholder="Geli lacagta...">
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
            search_placeholder: "Search name, phone, or ID...", tab_students: "Students", tab_teachers: "Teachers",
            status_paid: "Paid", status_partial: "Partial", status_pending: "Pending", status_unpaid: "Unpaid",
            lbl_required: "Required", lbl_paid: "Paid", lbl_balance: "Balance", lbl_salary: "Net Salary", lbl_paid_out: "Paid Out",
            btn_pay: "Pay Fee", btn_locked: "Locked", btn_payout: "Pay Salary", btn_locked_payout: "Locked (Paid)",
            lbl_modal_name: "Name:", lbl_modal_amount: "Amount ($):", btn_modal_save: "Save Transaction"
        },
        so: {
            page_title: "Maamulka Lacagaha & Mushaaraadka", current_month: "Bisha Loo Xisaabinayo:", lock_notice: "(Waxay xirmaysaa 28-ka bisha)", 
            search_placeholder: "Raadi magac, nambar, ama ID...", tab_students: "Ardayda (Students)", tab_teachers: "Macalimiinta (Teachers)",
            status_paid: "Waa Bixiyay", status_partial: "Qayb ahaan", status_pending: "Ma Bixin", status_unpaid: "Lama Siin",
            lbl_required: "Laga Rabo", lbl_paid: "Bixiyay", lbl_balance: "Haraa", lbl_salary: "Mushaar", lbl_paid_out: "La Siiyay",
            btn_pay: "Bixi Lacagta", btn_locked: "Waa Xiran Yahay", btn_payout: "Sii Mushaarka", btn_locked_payout: "Waa Xiran Yahay",
            lbl_modal_name: "Magaca:", lbl_modal_amount: "Lacagta la bixinayo ($):", btn_modal_save: "Keydi Xogta"
        },
        ar: {
            page_title: "إدارة المدفوعات والرواتب", current_month: "شهر الفوترة:", lock_notice: "(ينتقل للشهر التالي يوم 28)", 
            search_placeholder: "ابحث عن اسم، رقم، أو هوية...", tab_students: "الطلاب", tab_teachers: "المعلمون",
            status_paid: "مدفوع", status_partial: "جزئي", status_pending: "قيد الانتظار", status_unpaid: "غير مدفوع",
            lbl_required: "المطلوب", lbl_paid: "المدفوع", lbl_balance: "المتبقي", lbl_salary: "الراتب", lbl_paid_out: "تم الدفع",
            btn_pay: "دفع الرسوم", btn_locked: "مغلق", btn_payout: "دفع الراتب", btn_locked_payout: "مغلق (مدفوع)",
            lbl_modal_name: "الاسم:", lbl_modal_amount: "المبلغ ($):", btn_modal_save: "حفظ البيانات"
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
        filterProfiles();
    }

    function filterProfiles() {
        let input = document.getElementById('searchInput').value.toLowerCase();
        let activeTab = document.querySelector('.tab-content.active');
        let cards = activeTab.getElementsByClassName('searchable');
        
        for (let i = 0; i < cards.length; i++) {
            let fullText = cards[i].innerText.toLowerCase(); 
            cards[i].style.display = fullText.includes(input) ? "flex" : "none";
        }
    }

    // Furida Modal-ka Fomka
    function openPaymentModal(type, id, name, balance) {
        document.getElementById('paymentModal').style.display = "flex";
        
        // Buuxi xogta Fomka
        document.getElementById('modalUserType').value = type;
        document.getElementById('modalUserId').value = id;
        document.getElementById('modalUserName').value = name;
        document.getElementById('modalAmount').value = balance > 0 ? balance : "";
        
        // Bedel cinwaanka Modal-ka
        let title = document.getElementById('modalTitle');
        if(currentLang === 'so') {
            title.innerHTML = type === 'student' ? '<i class="fas fa-cash-register"></i> Bixinta Lacagta Ardayga' : '<i class="fas fa-hand-holding-usd"></i> Bixinta Mushaarka Macalinka';
        } else if (currentLang === 'ar') {
            title.innerHTML = type === 'student' ? '<i class="fas fa-cash-register"></i> دفع رسوم الطالب' : '<i class="fas fa-hand-holding-usd"></i> دفع راتب المعلم';
        } else {
            title.innerHTML = type === 'student' ? '<i class="fas fa-cash-register"></i> Process Student Fee' : '<i class="fas fa-hand-holding-usd"></i> Process Teacher Salary';
        }
    }

    // Xirida Modal-ka
    function closePaymentModal() {
        document.getElementById('paymentModal').style.display = "none";
    }

    // Haddii meel banaan la gujiyo wuu xirmayaa Modal-ka
    window.onclick = function(event) {
        let modal = document.getElementById('paymentModal');
        if (event.target == modal) {
            modal.style.display = "none";
        }
    }
</script>

</body>
</html>