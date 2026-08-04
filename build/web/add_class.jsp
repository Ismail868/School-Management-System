<%@page import="java.sql.*, utils.DBConnection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // Hubi in user-ku soo galay (Logged in)
    if (session.getAttribute("username") == null) {
        response.sendRedirect("index.jsp");
        return; 
    }

    String message = "";
    String msgType = "";

    // Haddii Form-ka la soo diro (POST request)
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String className = request.getParameter("class_name");

        if (className != null && !className.trim().isEmpty()) {
            Connection conn = null;
            PreparedStatement pstmtCheck = null;
            PreparedStatement pstmtInsert = null;
            ResultSet rs = null;
            
            try {
                conn = DBConnection.getConnection();
                
                // 1. Hubi in fasalkan uu horey ugu jiray database-ka
                String checkSql = "SELECT * FROM class WHERE class_name = ?";
                pstmtCheck = conn.prepareStatement(checkSql);
                pstmtCheck.setString(1, className.trim().toUpperCase()); // Xarfaha waaweyn ka dhig si hubintu u noqoto mid sax ah
                rs = pstmtCheck.executeQuery();
                
                if (rs.next()) {
                    // Haddii uu jiro fasalkaan, digniin soo saar
                    message = "Fasalkan horey ayuu nidaamka ugu jiray! / This class already exists!";
                    msgType = "warning";
                } else {
                    // 2. Haddii uusan jirin, ku dar database-ka
                    String sql = "INSERT INTO class (class_name) VALUES (?)";
                    pstmtInsert = conn.prepareStatement(sql);
                    pstmtInsert.setString(1, className.trim().toUpperCase()); 
                    
                    int rows = pstmtInsert.executeUpdate();
                    if (rows > 0) {
                        // Markuu kaydiyo dib haugu noqdo bogga fasalada
                        response.sendRedirect("classes_subjects.jsp");
                        return;
                    }
                }
            } catch (Exception e) {
                message = "Cilad ayaa dhacday: " + e.getMessage();
                msgType = "error";
            } finally {
                // Xir connections-ka si memory-ga loo ilaaliyo
                if (rs != null) try { rs.close(); } catch(Exception e) {}
                if (pstmtCheck != null) try { pstmtCheck.close(); } catch(Exception e) {}
                if (pstmtInsert != null) try { pstmtInsert.close(); } catch(Exception e) {}
                if (conn != null) try { conn.close(); } catch(Exception e) {}
            }
        } else {
            message = "Fadlan geli magaca fasalka / Please enter class name.";
            msgType = "error";
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add New Class</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root {
            --bg-main: #f0f4f8; --card-bg: #ffffff; --text-main: #2d3748;
            --text-muted: #718096; --border-color: #e2e8f0; --primary: #4f46e5;
            --primary-hover: #4338ca; --success: #10b981; --warning: #f59e0b;
            --danger: #ef4444; 
        }
        .dark-mode {
            --bg-main: #0f172a; --card-bg: #1e293b; --text-main: #f1f5f9;
            --text-muted: #94a3b8; --border-color: #334155;
        }

        /* RTL (Arabic) Support */
        .rtl { direction: rtl; text-align: right; }
        .rtl .form-actions { flex-direction: row-reverse; }

        body { 
            background-color: var(--bg-main); color: var(--text-main); 
            font-family: 'Segoe UI', sans-serif; margin: 0; padding: 20px; 
            display: flex; justify-content: center; align-items: center; min-height: 100vh;
            transition: all 0.3s; 
        }

        .form-card {
            background: var(--card-bg); padding: 40px; border-radius: 16px; 
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
            width: 100%; max-width: 450px; border: 1px solid var(--border-color);
        }

        .form-header { text-align: center; margin-bottom: 30px; }
        .form-header i { font-size: 40px; color: var(--primary); margin-bottom: 15px; display: inline-block; }
        .form-header h2 { margin: 0; font-size: 24px; }
        .form-header p { color: var(--text-muted); font-size: 14px; margin-top: 5px; }

        .form-group { margin-bottom: 20px; }
        .form-group label { display: block; margin-bottom: 8px; font-weight: 600; font-size: 14px; }
        .form-control { 
            width: 100%; padding: 12px 15px; font-size: 16px; 
            border: 2px solid var(--border-color); border-radius: 10px; 
            background: var(--bg-main); color: var(--text-main); outline: none; transition: 0.3s;
            box-sizing: border-box;
        }
        .form-control:focus { border-color: var(--primary); background: var(--card-bg); }

        .form-actions { display: flex; gap: 15px; margin-top: 30px; }
        .btn { flex: 1; padding: 12px; font-size: 16px; font-weight: bold; border: none; border-radius: 10px; cursor: pointer; display: flex; justify-content: center; align-items: center; gap: 8px; transition: 0.2s; text-decoration: none; text-align: center;}
        .btn-save { background-color: var(--primary); color: white; }
        .btn-save:hover { background-color: var(--primary-hover); }
        .btn-cancel { background-color: var(--bg-main); color: var(--text-main); border: 2px solid var(--border-color); }
        .btn-cancel:hover { background-color: var(--border-color); }

        .alert { padding: 15px; border-radius: 8px; margin-bottom: 20px; font-size: 14px; text-align: center; font-weight: bold;}
        .alert-error { background-color: rgba(239, 68, 68, 0.1); color: var(--danger); border: 1px solid var(--danger); }
        .alert-success { background-color: rgba(16, 185, 129, 0.1); color: var(--success); border: 1px solid var(--success); }
        .alert-warning { background-color: rgba(245, 158, 11, 0.1); color: var(--warning); border: 1px solid var(--warning); } /* Midabka digniinta cusub */
    </style>
</head>
<body>

<div class="form-card">
    <div class="form-header">
        <i class="fas fa-chalkboard"></i>
        <h2 data-i18n="page_title">Ku dar Fasal Cusub</h2>
        <p data-i18n="page_desc">Geli magaca fasalka si aad ugu diiwaangeliso nidaamka.</p>
    </div>

    <% if (!message.isEmpty()) { 
        String alertClass = "alert-error";
        if (msgType.equals("success")) alertClass = "alert-success";
        else if (msgType.equals("warning")) alertClass = "alert-warning";
    %>
        <div class="alert <%= alertClass %>">
            <% if (msgType.equals("warning")) { %> <i class="fas fa-exclamation-triangle"></i> <% } %>
            <% if (msgType.equals("error")) { %> <i class="fas fa-times-circle"></i> <% } %>
            <%= message %>
        </div>
    <% } %>

    <form method="POST">
        <div class="form-group">
            <label data-i18n="class_name_label">Magaca Fasalka (Class Name):</label>
            <input type="text" name="class_name" class="form-control" data-i18n-placeholder="class_name_placeholder" placeholder="Tusaale: F4, Form 1, Grade 8..." required autofocus autocomplete="off">
        </div>

        <div class="form-actions">
            <button type="submit" class="btn btn-save">
                <i class="fas fa-save"></i> <span data-i18n="btn_save">Kaydi</span>
            </button>
            <a href="classes_subjects.jsp" class="btn btn-cancel">
                <i class="fas fa-arrow-left"></i> <span data-i18n="btn_cancel">Ka Noqo</span>
            </a>
        </div>
    </form>
</div>

<script>
    // NIDAAMKA LUUQADAHA 
    const pageTranslations = {
        en: {
            page_title: "Add New Class",
            page_desc: "Enter the class name to register it in the system.",
            class_name_label: "Class Name:",
            class_name_placeholder: "Example: F4, Form 1, Grade 8...",
            btn_save: "Save Class",
            btn_cancel: "Go Back"
        },
        so: {
            page_title: "Ku dar Fasal Cusub",
            page_desc: "Geli magaca fasalka si aad ugu diiwaangeliso nidaamka.",
            class_name_label: "Magaca Fasalka:",
            class_name_placeholder: "Tusaale: F4, Form 1, Grade 8...",
            btn_save: "Kaydi Fasalka",
            btn_cancel: "Ka Noqo"
        },
        ar: {
            page_title: "إضافة فصل جديد",
            page_desc: "أدخل اسم الفصل لتسجيله في النظام.",
            class_name_label: "اسم الفصل:",
            class_name_placeholder: "مثال: F4, Form 1, Grade 8...",
            btn_save: "حفظ الفصل",
            btn_cancel: "رجوع"
        }
    };

    // Helitaanka Theme-ka iyo Luuqada
    const currentTheme = localStorage.getItem('app_theme') || 'light';
    const currentLang = localStorage.getItem('app_language') || 'so';

    document.addEventListener("DOMContentLoaded", () => {
        if (currentTheme === 'dark') {
            document.body.classList.add("dark-mode");
        }
        applyPageLanguage(currentLang);
    });

    function applyPageLanguage(lang) {
        if (lang === 'ar') {
            document.body.classList.add('rtl');
        } else {
            document.body.classList.remove('rtl');
        }

        // Bedel qoraalada caadiga ah
        document.querySelectorAll('[data-i18n]').forEach(el => {
            const key = el.getAttribute('data-i18n');
            if (pageTranslations[lang] && pageTranslations[lang][key]) {
                el.innerHTML = pageTranslations[lang][key];
            }
        });
        
        // Bedel placeholders-ka input-yada
        document.querySelectorAll('[data-i18n-placeholder]').forEach(el => {
            const key = el.getAttribute('data-i18n-placeholder');
            if (pageTranslations[lang] && pageTranslations[lang][key]) {
                el.placeholder = pageTranslations[lang][key];
            }
        });
    }
</script>

</body>
</html>