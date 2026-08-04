<%@page import="java.sql.*, utils.DBConnection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // Hubinta in user-ka uu soo galay (Logged In)
    if (session.getAttribute("username") == null) {
        response.sendRedirect("index.jsp");
        return; 
    }

    String message = "";
    
    // Maareynta Form Submit (POST Request)
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String subjectName = request.getParameter("subject_name");
        String subjectCode = request.getParameter("subject_code");

        if (subjectName != null && !subjectName.trim().isEmpty() && subjectCode != null && !subjectCode.trim().isEmpty()) {
            Connection conn = null;
            PreparedStatement pstmtCheck = null;
            PreparedStatement pstmtInsert = null;
            ResultSet rs = null;
            
            try {
                conn = DBConnection.getConnection();
                
                // 1. Ugu horreyn, Hubi in Maadada ama Code-ka ay horey u jireen
                String checkSql = "SELECT * FROM subjects WHERE subject_name = ? OR subject_code = ?";
                pstmtCheck = conn.prepareStatement(checkSql);
                pstmtCheck.setString(1, subjectName.trim());
                pstmtCheck.setString(2, subjectCode.trim().toUpperCase());
                rs = pstmtCheck.executeQuery();
                
                if (rs.next()) {
                    // Haddii xogta la helo, macnaheedu waa horey ayey ugu jirtay
                    message = "exists";
                } else {
                    // 2. Haddii aysan ku jirin, Database-ka geli xogta cusub
                    String insertSql = "INSERT INTO subjects (subject_name, subject_code) VALUES (?, ?)";
                    pstmtInsert = conn.prepareStatement(insertSql);
                    pstmtInsert.setString(1, subjectName.trim());
                    pstmtInsert.setString(2, subjectCode.trim().toUpperCase());
                    
                    int rows = pstmtInsert.executeUpdate();
                    if (rows > 0) {
                        message = "success";
                    }
                }
            } catch (Exception e) {
                message = "error";
                System.out.println("Error Add Subject: " + e.getMessage());
            } finally {
                // Xiritaanka Connections-ka si loo ilaaliyo memory-ga
                if (rs != null) try { rs.close(); } catch(Exception e) {}
                if (pstmtCheck != null) try { pstmtCheck.close(); } catch(Exception e) {}
                if (pstmtInsert != null) try { pstmtInsert.close(); } catch(Exception e) {}
                if (conn != null) try { conn.close(); } catch(Exception e) {}
            }
        } else {
            message = "empty";
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add Subject - School Management</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root {
            --bg-main: #f0f4f8; --card-bg: #ffffff; --text-main: #2d3748;
            --text-muted: #718096; --border-color: #e2e8f0; --primary: #4f46e5;
            --primary-hover: #4338ca; --input-bg: #ffffff;
        }
        .dark-mode {
            --bg-main: #0f172a; --card-bg: #1e293b; --text-main: #f1f5f9;
            --text-muted: #94a3b8; --border-color: #334155; --input-bg: #0f172a;
        }

        .rtl { direction: rtl; text-align: right; }
        .rtl .form-group label { text-align: right; }
        .rtl .btn-back i { transform: rotate(180deg); }

        body { 
            background-color: var(--bg-main); 
            color: var(--text-main); 
            font-family: 'Segoe UI', sans-serif; 
            margin: 0; 
            padding: 40px 20px; 
            transition: all 0.3s; 
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 80vh;
        }

        .form-container {
            background: var(--card-bg);
            padding: 30px;
            border-radius: 12px;
            border: 1px solid var(--border-color);
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
            width: 100%;
            max-width: 500px;
        }

        .form-header {
            display: flex;
            align-items: center;
            gap: 15px;
            margin-bottom: 25px;
            border-bottom: 2px solid var(--border-color);
            padding-bottom: 15px;
        }

        .header-icon {
            font-size: 28px;
            color: var(--primary);
        }

        .form-header h2 {
            margin: 0;
            font-size: 22px;
        }

        .form-group {
            margin-bottom: 20px;
            display: flex;
            flex-direction: column;
            gap: 8px;
        }

        .form-group label {
            font-weight: 600;
            font-size: 15px;
            color: var(--text-main);
        }

        .form-group input {
            padding: 12px 15px;
            border: 2px solid var(--border-color);
            border-radius: 8px;
            background: var(--input-bg);
            color: var(--text-main);
            font-size: 15px;
            outline: none;
            transition: 0.3s;
        }

        .form-group input:focus {
            border-color: var(--primary);
        }

        .btn-group {
            display: flex;
            gap: 15px;
            margin-top: 30px;
        }

        .btn {
            flex: 1;
            padding: 12px;
            font-size: 16px;
            font-weight: bold;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            transition: 0.2s;
            text-decoration: none;
        }

        .btn-save { background-color: var(--primary); color: white; }
        .btn-save:hover { background-color: var(--primary-hover); }
        
        .btn-back { background-color: var(--text-muted); color: white; }
        .btn-back:hover { opacity: 0.9; }

        /* Fariimaha Alerts-ka */
        .alert {
            padding: 12px 15px;
            border-radius: 8px;
            margin-bottom: 20px;
            font-weight: bold;
            display: none;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .alert-success { background-color: #d1fae5; color: #065f46; border: 1px solid #34d399; }
        .alert-error { background-color: #fee2e2; color: #991b1b; border: 1px solid #f87171; }
        .alert-warning { background-color: #fef3c7; color: #b45309; border: 1px solid #fbbf24; }
        
        .dark-mode .alert-success { background-color: #064e3b; color: #34d399; border: 1px solid #059669; }
        .dark-mode .alert-error { background-color: #7f1d1d; color: #f87171; border: 1px solid #dc2626; }
        .dark-mode .alert-warning { background-color: #78350f; color: #fbbf24; border: 1px solid #b45309; }
    </style>
</head>
<body>

<div class="form-container">
    <div class="form-header">
        <i class="fas fa-book-medical header-icon"></i>
        <h2 data-i18n="page_title">Ku Dar Maado Cusub</h2>
    </div>

    <!-- Fariimaha Natiijada -->
    <% if ("success".equals(message)) { %>
        <div class="alert alert-success"><i class="fas fa-check-circle"></i> <span data-i18n="msg_success">Maadada si guul ah ayaa lagu daray!</span></div>
    <% } else if ("error".equals(message)) { %>
        <div class="alert alert-error"><i class="fas fa-times-circle"></i> <span data-i18n="msg_error">Cilad ayaa dhacday! Fadlan hubi xogta.</span></div>
    <% } else if ("empty".equals(message)) { %>
        <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> <span data-i18n="msg_empty">Fadlan buuxi dhammaan meelaha banaan!</span></div>
    <% } else if ("exists".equals(message)) { %>
        <div class="alert alert-warning"><i class="fas fa-exclamation-triangle"></i> <span data-i18n="msg_exists">Maadadan ama Koodhkeeda horey ayey nidaamka ugu jirtay!</span></div>
    <% } %>

    <form action="add_subject.jsp" method="POST">
        <div class="form-group">
            <label data-i18n="lbl_name">Magaca Maadada:</label>
            <input type="text" name="subject_name" required data-i18n-placeholder="ph_name" placeholder="Tusaale: Xisaab">
        </div>

        <div class="form-group">
            <label data-i18n="lbl_code">Koodhka Maadada (Subject Code):</label>
            <input type="text" name="subject_code" required data-i18n-placeholder="ph_code" placeholder="Tusaale: MTH">
        </div>

        <div class="btn-group">
            <a href="classes_subjects.jsp" class="btn btn-back">
                <i class="fas fa-arrow-left"></i> <span data-i18n="btn_back">Kunoqo</span>
            </a>
            <button type="submit" class="btn btn-save">
                <i class="fas fa-save"></i> <span data-i18n="btn_save">Keydi Maadada</span>
            </button>
        </div>
    </form>
</div>

<script>
    // NIDAAMKA LUUQADAHA
    const pageTranslations = {
        en: {
            page_title: "Add New Subject",
            lbl_name: "Subject Name:",
            ph_name: "e.g. Mathematics",
            lbl_code: "Subject Code:",
            ph_code: "e.g. MTH",
            btn_save: "Save Subject",
            btn_back: "Back to List",
            msg_success: "Subject added successfully!",
            msg_error: "Database error occurred!",
            msg_empty: "Please fill in all required fields!",
            msg_exists: "Subject Name or Code already exists!"
        },
        so: {
            page_title: "Ku Dar Maado Cusub",
            lbl_name: "Magaca Maadada:",
            ph_name: "Tusaale: Xisaab",
            lbl_code: "Koodhka Maadada:",
            ph_code: "Tusaale: MTH",
            btn_save: "Keydi Maadada",
            btn_back: "Kunoqo",
            msg_success: "Maadada si guul ah ayaa lagu daray!",
            msg_error: "Cilad ayaa dhacday! Fadlan hubi xogta.",
            msg_empty: "Fadlan buuxi dhammaan meelaha banaan!",
            msg_exists: "Maadadan ama Koodhkeeda horey ayey nidaamka ugu jirtay!"
        },
        ar: {
            page_title: "إضافة مادة جديدة",
            lbl_name: "اسم المادة:",
            ph_name: "مثال: الرياضيات",
            lbl_code: "رمز المادة:",
            ph_code: "مثال: MTH",
            btn_save: "حفظ المادة",
            btn_back: "رجوع",
            msg_success: "تمت إضافة المادة بنجاح!",
            msg_error: "حدث خطأ في قاعدة البيانات!",
            msg_empty: "يرجى ملء جميع الحقول المطلوبة!",
            msg_exists: "اسم المادة أو الرمز موجود بالفعل!"
        }
    };

    const currentTheme = localStorage.getItem('app_theme') || 'light';
    const currentLang = localStorage.getItem('app_language') || 'so'; 

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
</script>

</body>
</html>