<%@page import="java.sql.*, utils.DBConnection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // Hubi in user-ku soo galay (Logged in)
    if (session.getAttribute("username") == null) {
        response.sendRedirect("index.jsp");
        return; 
    }

    String classIdStr = request.getParameter("id");
    if (classIdStr == null || classIdStr.isEmpty()) {
        response.sendRedirect("classes_subjects.jsp");
        return;
    }

    int classId = Integer.parseInt(classIdStr);
    String className = "";
    String message = "";
    String msgType = "";

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        conn = DBConnection.getConnection();

        // Hel magaca fasalka (Fetch Class Name from table 'class')
        pstmt = conn.prepareStatement("SELECT class_name FROM class WHERE id = ?");
        pstmt.setInt(1, classId);
        rs = pstmt.executeQuery();
        
        if (rs.next()) {
            className = rs.getString("class_name");
        } else {
            response.sendRedirect("classes_subjects.jsp"); // Haddii fasalka la waayo
            return;
        }
        rs.close();
        pstmt.close();

        // Marka la taabto "Haa, Tirtir" (POST request)
        if ("POST".equalsIgnoreCase(request.getMethod())) {
            
            // CODE-KAN WUXUU TIRTIRAYAA FASALKA OO KALIYA. Ardayda shaqo kuma laha.
            pstmt = conn.prepareStatement("DELETE FROM class WHERE id = ?");
            pstmt.setInt(1, classId);
            int deleted = pstmt.executeUpdate();
            
            if (deleted > 0) {
                response.sendRedirect("classes_subjects.jsp");
                return;
            }
        }
    } catch (Exception e) {
        message = "Cilad ayaa dhacday (Hubi in uusan jirin Foreign Key xannibaya): " + e.getMessage();
        msgType = "error";
    } finally {
        if (pstmt != null) { try { pstmt.close(); } catch (Exception e) {} }
        if (conn != null) { try { conn.close(); } catch (Exception e) {} }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Delete Class</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root {
            --bg-main: #f0f4f8; --card-bg: #ffffff; --text-main: #2d3748;
            --text-muted: #718096; --border-color: #e2e8f0; 
            --danger: #ef4444; --danger-hover: #dc2626;
            --warning: #f59e0b; --warning-bg: #fef3c7;
        }
        .dark-mode {
            --bg-main: #0f172a; --card-bg: #1e293b; --text-main: #f1f5f9;
            --text-muted: #94a3b8; --border-color: #334155;
            --warning-bg: rgba(245, 158, 11, 0.1);
        }

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
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
            width: 100%; max-width: 450px; border: 1px solid var(--border-color);
            text-align: center;
        }

        .icon-circle {
            width: 80px; height: 80px; border-radius: 50%; display: flex;
            align-items: center; justify-content: center; margin: 0 auto 20px;
            font-size: 35px;
            background-color: var(--warning-bg); color: var(--warning);
        }

        h2 { margin: 0 0 10px; font-size: 24px; }
        .class-name-highlight { font-size: 20px; color: var(--danger); background: rgba(239, 68, 68, 0.1); padding: 5px 15px; border-radius: 8px; display: inline-block; margin: 15px 0;}

        .alert { padding: 15px; border-radius: 8px; margin-bottom: 20px; font-size: 14px; text-align: left; line-height: 1.5;}
        .alert-error { background-color: rgba(239, 68, 68, 0.1); color: var(--danger); border: 1px solid var(--danger); }
        .alert-warning { background-color: var(--warning-bg); color: var(--warning); border: 1px solid var(--warning); }
        .rtl .alert { text-align: right; }

        .form-actions { display: flex; gap: 15px; margin-top: 30px; }
        .btn { flex: 1; padding: 12px; font-size: 16px; font-weight: bold; border: none; border-radius: 10px; cursor: pointer; display: flex; justify-content: center; align-items: center; gap: 8px; transition: 0.2s; text-decoration: none; }
        
        .btn-danger { background-color: var(--danger); color: white; }
        .btn-danger:hover { background-color: var(--danger-hover); }
        
        .btn-cancel { background-color: var(--bg-main); color: var(--text-main); border: 2px solid var(--border-color); }
        .btn-cancel:hover { background-color: var(--border-color); }

    </style>
</head>
<body>

<div class="form-card">
    
    <!-- MUUQAALKA OGOLAANSHAHA -->
    <div class="icon-circle"><i class="fas fa-exclamation-triangle"></i></div>
    <h2 data-i18n="confirm_title">Ma hubtaa?</h2>
    <p data-i18n="confirm_desc">Ma hubtaa inaad rabto inaad tirtirto fasalkan?</p>
    <div class="class-name-highlight"><%= className %></div>
    
    <% if (!message.isEmpty()) { %>
        <div class="alert alert-error">
            <%= message %>
        </div>
    <% } %>

    <div class="alert alert-warning">
        <i class="fas fa-info-circle"></i> <span data-i18n="warning_msg">Tallaabadan lama soo celin karo. Kaliya fasalka ayaa la tirtirayaa.</span>
    </div>

    <form method="POST">
        <div class="form-actions">
            <button type="submit" class="btn btn-danger">
                <i class="fas fa-trash-alt"></i> <span data-i18n="btn_delete">Haa, Tirtir</span>
            </button>
            <a href="classes_subjects.jsp" class="btn btn-cancel">
                <i class="fas fa-times"></i> <span data-i18n="btn_cancel">Ka Noqo</span>
            </a>
        </div>
    </form>
</div>

<script>
    // NIDAAMKA LUUQADAHA
    const pageTranslations = {
        en: {
            confirm_title: "Are you sure?",
            confirm_desc: "Are you sure you want to delete this class?",
            warning_msg: "This action cannot be undone. Only the class will be deleted.",
            btn_delete: "Yes, Delete",
            btn_cancel: "Cancel"
        },
        so: {
            confirm_title: "Ma hubtaa?",
            confirm_desc: "Ma hubtaa inaad rabto inaad tirtirto fasalkan?",
            warning_msg: "Tallaabadan lama soo celin karo. Kaliya fasalka ayaa la tirtirayaa.",
            btn_delete: "Haa, Tirtir",
            btn_cancel: "Ka Noqo"
        },
        ar: {
            confirm_title: "هل أنت متأكد؟",
            confirm_desc: "هل أنت متأكد أنك تريد حذف هذا الفصل؟",
            warning_msg: "لا يمكن التراجع عن هذا الإجراء. سيتم حذف الفصل فقط.",
            btn_delete: "نعم، احذف",
            btn_cancel: "إلغاء"
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
            if (pageTranslations[lang] && pageTranslations[lang][key]) {
                el.innerHTML = pageTranslations[lang][key];
            }
        });
    }
</script>

</body>
</html>