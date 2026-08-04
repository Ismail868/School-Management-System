<%@page import="java.sql.*, utils.DBConnection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    if (session.getAttribute("username") == null) { response.sendRedirect("index.jsp"); return; }

    String id = request.getParameter("id");
    if (id == null) { response.sendRedirect("students.jsp"); return; }

    String msg = "";
    Connection conn = null;
    PreparedStatement pst = null;
    ResultSet rs = null;

    try {
        // Connection-ka ka hel DBConnection class-ka cusub
        conn = DBConnection.getConnection();

        if (request.getMethod().equalsIgnoreCase("post")) {
            String studentId = request.getParameter("student_id");
            String fullName = request.getParameter("full_name");
            String sClass = request.getParameter("class");
            String gender = request.getParameter("gender");
            String parentPhone = request.getParameter("parent_phone");
            String motherName = request.getParameter("mother_name");
            String motherPhone = request.getParameter("mother_phone");
            String studentPhone = request.getParameter("student_phone");
            String email = request.getParameter("email");
            String address = request.getParameter("address");

            String sqlUpdate = "UPDATE students SET student_id=?, full_name=?, class=?, gender=?, parent_phone=?, mother_name=?, mother_phone=?, student_phone=?, email=?, address=? WHERE id=?";
            pst = conn.prepareStatement(sqlUpdate);
            pst.setString(1, studentId); pst.setString(2, fullName); pst.setString(3, sClass);
            pst.setString(4, gender); pst.setString(5, parentPhone); pst.setString(6, motherName);
            pst.setString(7, motherPhone); pst.setString(8, studentPhone); pst.setString(9, email);
            pst.setString(10, address); pst.setString(11, id);
            
            pst.executeUpdate();
            response.sendRedirect("students.jsp?msg=updated");
            return;
        }

        pst = conn.prepareStatement("SELECT * FROM students WHERE id=?");
        pst.setString(1, id);
        rs = pst.executeQuery();
        
        if (rs.next()) {
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title data-i18n="page_title">Edit Student</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <style>
        :root {
            /* Light Mode Variables */
            --primary-color: #f59e0b; /* Orange for Edit */
            --primary-hover: #d97706;
            --btn-back: #4f46e5;
            --bg-color: #f0f4f8;
            --card-bg: #ffffff;
            --text-main: #1f2937;
            --text-muted: #4a5568;
            --border-color: #e2e8f0;
            --input-bg: #ffffff;
        }
        
        /* Dark Mode Styles */
        body.dark-mode {
            --bg-color: #0f172a;       
            --card-bg: #1e293b;        
            --text-main: #f8fafc;      
            --text-muted: #94a3b8;     
            --border-color: #334155;   
            --input-bg: #0f172a;
            --btn-back: #818cf8;
        }
        
        /* RTL (Arabic) Styles */
        body.rtl {
            direction: rtl;
            text-align: right;
        }
        body.rtl .btn-back i {
            transform: rotate(180deg);
        }

        * { box-sizing: border-box; margin: 0; padding: 0; }

        body { 
            background-color: var(--bg-color); 
            font-family: 'Segoe UI', Tahoma, sans-serif; 
            padding: 30px 15px; 
            color: var(--text-main);
            transition: background-color 0.3s ease, color 0.3s ease;
        }
        
        .form-container { 
            width: 100%;
            max-width: 800px; 
            margin: auto; 
            background: var(--card-bg); 
            padding: 30px; 
            border-radius: 16px; 
            box-shadow: 0 10px 25px rgba(0,0,0,0.05); 
            transition: background-color 0.3s ease;
        }
        
        h2 { 
            color: var(--primary-color); 
            border-bottom: 2px solid var(--primary-color); 
            padding-bottom: 10px; 
            margin-bottom: 25px; 
            font-size: 22px;
        }
        
        .form-grid { 
            display: grid; 
            grid-template-columns: repeat(2, 1fr); 
            gap: 20px; 
        }
        
        .form-group { 
            display: flex; 
            flex-direction: column; 
        }
        
        .form-group label { 
            font-size: 14px; 
            font-weight: 600; 
            color: var(--text-muted); 
            margin-bottom: 8px; 
        }
        
        .form-group input, .form-group select { 
            width: 100%;
            padding: 12px; 
            border: 1px solid var(--border-color); 
            border-radius: 8px; 
            font-size: 15px; 
            background-color: var(--input-bg);
            color: var(--text-main);
            transition: all 0.3s ease;
        }
        
        .form-group input:focus, .form-group select:focus {
            border-color: var(--primary-color);
            outline: none;
            box-shadow: 0 0 0 3px rgba(245, 158, 11, 0.1);
        }
        
        /* Readonly Styling for ID */
        .readonly-input {
            background-color: var(--border-color) !important;
            cursor: not-allowed;
            color: var(--text-muted) !important;
            font-weight: bold;
        }

        .full-width { 
            grid-column: span 2; 
        }
        
        .btn-submit { 
            background: var(--primary-color); 
            color: white; 
            border: none; 
            padding: 14px 24px; 
            font-size: 16px; 
            font-weight: bold; 
            border-radius: 8px; 
            cursor: pointer; 
            margin-top: 25px; 
            width: 100%; 
            transition: background-color 0.3s ease, transform 0.1s ease;
            display: flex; 
            justify-content: center; 
            align-items: center; 
            gap: 10px;
        }
        .btn-submit:hover { background: var(--primary-hover); }
        .btn-submit:active { transform: scale(0.98); }
        
        .btn-back { 
            display: inline-flex; 
            align-items: center; 
            gap: 8px; 
            margin-bottom: 20px; 
            color: var(--btn-back); 
            text-decoration: none; 
            font-weight: bold; 
            transition: opacity 0.3s ease;
        }
        .btn-back:hover { opacity: 0.8; }
        
        /* RESPONSIVE MEDIA QUERIES FOR MOBILE & TABLET */
        @media(max-width: 768px) { 
            body {
                padding: 15px 10px;
            }
            .form-container { 
                padding: 20px 15px; 
                border-radius: 12px;
            }
            .form-grid { 
                grid-template-columns: 1fr; 
                gap: 15px;
            }
            .full-width { 
                grid-column: span 1; 
            }
            .form-group input, .form-group select {
                font-size: 16px; /* Prevents zoom-in on iOS Safari */
                padding: 10px 12px;
            }
            h2 {
                font-size: 18px;
            }
        }
    </style>
</head>
<body>
    <div class="form-container">
        <a href="students.jsp" class="btn-back"><i class="fas fa-arrow-left"></i> <span data-i18n="btn_back">Back</span></a>
        <h2 data-i18n="title_edit_student">Edit Student Data</h2>
        
        <form method="POST">
            <div class="form-grid">
                <div class="form-group">
                    <label data-i18n="label_student_id">Student ID</label>
                    <input type="text" name="student_id" class="readonly-input" value="<%= rs.getString("student_id") != null ? rs.getString("student_id") : "" %>" required readonly>
                </div>
                <div class="form-group">
                    <label data-i18n="label_fullname">Full Name</label>
                    <input type="text" name="full_name" value="<%= rs.getString("full_name") %>" required>
                </div>
                <div class="form-group">
                    <label data-i18n="label_class">Class</label>
                    <input type="text" name="class" value="<%= rs.getString("class") %>" required>
                </div>
                <div class="form-group">
                    <label data-i18n="label_gender">Gender</label>
                    <select name="gender" required>
                        <option value="Male" data-i18n="opt_male" <%= "Male".equals(rs.getString("gender")) ? "selected" : "" %>>Male</option>
                        <option value="Female" data-i18n="opt_female" <%= "Female".equals(rs.getString("gender")) ? "selected" : "" %>>Female</option>
                    </select>
                </div>
                <div class="form-group">
                    <label data-i18n="label_parent_phone">Parent / Guardian Phone</label>
                    <input type="text" name="parent_phone" value="<%= rs.getString("parent_phone") %>" required>
                </div>
                <div class="form-group">
                    <label data-i18n="label_student_phone">Student Phone</label>
                    <input type="text" name="student_phone" value="<%= rs.getString("student_phone") != null ? rs.getString("student_phone") : "" %>">
                </div>
                <div class="form-group">
                    <label data-i18n="label_mother_name">Mother Name</label>
                    <input type="text" name="mother_name" value="<%= rs.getString("mother_name") != null ? rs.getString("mother_name") : "" %>">
                </div>
                <div class="form-group">
                    <label data-i18n="label_mother_phone">Mother Phone</label>
                    <input type="text" name="mother_phone" value="<%= rs.getString("mother_phone") != null ? rs.getString("mother_phone") : "" %>">
                </div>
                
                <!-- QAYBTA EMAIL-KA -->
                <div class="form-group">
                    <label data-i18n="label_email">Email Address</label>
                    <input type="email" name="email" value="<%= rs.getString("email") != null ? rs.getString("email") : "" %>">
                </div>

                <div class="form-group full-width">
                    <label data-i18n="label_address">Address</label>
                    <input type="text" name="address" value="<%= rs.getString("address") %>" required>
                </div>
            </div>
            <button type="submit" class="btn-submit"><i class="fas fa-edit"></i> <span data-i18n="btn_update">Update Data</span></button>
        </form>
    </div>

    <!-- Script-ka Luqadaha iyo Syncing-ka -->
    <script>
        const translations = {
            en: {
                page_title: "Edit Student",
                title_edit_student: "Edit Student Data",
                btn_back: "Back",
                label_student_id: "Student ID",
                label_fullname: "Full Name",
                label_class: "Class",
                label_gender: "Gender",
                label_parent_phone: "Parent Phone",
                label_student_phone: "Student Phone",
                label_mother_name: "Mother's Name",
                label_mother_phone: "Mother's Phone",
                label_email: "Email Address",
                label_address: "Address",
                btn_update: "Update Data",
                opt_male: "Male",
                opt_female: "Female"
            },
            so: {
                page_title: "Wax ka beddel Ardayga",
                title_edit_student: "Wax ka beddel Xogta Ardayga",
                btn_back: "Dib u noqo",
                label_student_id: "ID-ga Ardayga",
                label_fullname: "Magaca Buuxa",
                label_class: "Fasalka",
                label_gender: "Jinsiga",
                label_parent_phone: "Tel Aabaha/Waalidka",
                label_student_phone: "Tel Ardayga",
                label_mother_name: "Magaca Hooyada",
                label_mother_phone: "Tel Hooyada",
                label_email: "Email-ka",
                label_address: "Cinwaanka",
                btn_update: "Cusbooneysii Xogta",
                opt_male: "Lab (Male)",
                opt_female: "Dhedig (Female)"
            },
            ar: {
                page_title: "تعديل بيانات الطالب",
                title_edit_student: "تعديل بيانات الطالب",
                btn_back: "رجوع",
                label_student_id: "معرف الطالب",
                label_fullname: "الاسم الكامل",
                label_class: "الفصل",
                label_gender: "الجنس",
                label_parent_phone: "هاتف ولي الأمر",
                label_student_phone: "هاتف الطالب",
                label_mother_name: "اسم الأم",
                label_mother_phone: "هاتف الأم",
                label_email: "البريد الإلكتروني",
                label_address: "العنوان",
                btn_update: "تحديث البيانات",
                opt_male: "ذكر",
                opt_female: "أنثى"
            }
        };

        function applyTheme(theme) {
            if (theme === 'dark') {
                document.body.classList.add("dark-mode");
            } else {
                document.body.classList.remove("dark-mode");
            }
        }

        function applyLanguage(lang) {
            if (lang === 'ar') {
                document.body.classList.add('rtl');
            } else {
                document.body.classList.remove('rtl');
            }

            // Baddal Dhammaan Text-ga
            document.querySelectorAll('[data-i18n]').forEach(el => {
                const key = el.getAttribute('data-i18n');
                if (translations[lang] && translations[lang][key]) {
                    el.innerText = translations[lang][key];
                }
            });
        }

        document.addEventListener("DOMContentLoaded", () => {
            const currentTheme = localStorage.getItem('app_theme') || 'light';
            const currentLang = localStorage.getItem('app_language') || 'en';
            applyTheme(currentTheme);
            applyLanguage(currentLang);
        });

        // Sync-garee Isbaddalada (Haddii luqadda ama Theme-ka laga baddalo Dashboard-ka)
        window.addEventListener('storage', (e) => {
            if (e.key === 'app_language' && e.newValue) {
                applyLanguage(e.newValue);
            }
            if (e.key === 'app_theme' && e.newValue) {
                applyTheme(e.newValue);
            }
        });
    </script>
</body>
</html>
<%
        } else { out.println("Ardaygan lama helin."); }
    } catch(Exception e) { out.println("Cilad: " + e.getMessage()); } 
    finally { DBConnection.close(conn, pst, rs); }
%>