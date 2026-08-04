<%@page import="java.sql.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    if (session.getAttribute("username") == null) {
        response.sendRedirect("index.jsp");
        return; 
    }
    String teacherId = request.getParameter("id");
    if (teacherId == null || teacherId.trim().isEmpty()) {
        response.sendRedirect("teacher.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title data-i18n="page_title">Edit Teacher</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root {
            /* Light Mode Variables */
            --bg-main: #f0f4f8; 
            --card-bg: #ffffff; 
            --text-main: #2d3748;
            --text-muted: #4a5568;
            --border-color: #e2e8f0; 
            --primary: #4f46e5; 
            --primary-hover: #4338ca;
            --success: #10b981;
            --input-bg: #ffffff;
            --readonly-bg: #e9ecef;
            --readonly-color: #6c757d;
        }

        /* Dark Mode Styles */
        body.dark-mode {
            --bg-main: #0f172a;
            --card-bg: #1e293b;
            --text-main: #f8fafc;
            --text-muted: #94a3b8;
            --border-color: #334155;
            --input-bg: #0f172a;
            --primary: #818cf8;
            --primary-hover: #6366f1;
            --readonly-bg: #334155;
            --readonly-color: #94a3b8;
        }

        /* RTL (Arabic) Styles */
        body.rtl {
            direction: rtl;
            text-align: right;
        }

        body { 
            background-color: var(--bg-main); 
            color: var(--text-main); 
            font-family: 'Segoe UI', Tahoma, sans-serif; 
            padding: 30px 20px; 
            transition: background-color 0.3s ease, color 0.3s ease;
        }

        .container { 
            max-width: 900px; 
            margin: auto; 
            background: var(--card-bg); 
            padding: 30px; 
            border-radius: 16px; 
            box-shadow: 0 10px 15px -3px rgba(0,0,0,0.1); 
            transition: background-color 0.3s ease;
        }

        .form-title { 
            font-size: 24px; 
            color: var(--primary); 
            margin-bottom: 20px; 
            border-bottom: 2px solid var(--border-color); 
            padding-bottom: 10px; 
        }

        .form-grid { 
            display: grid; 
            grid-template-columns: 1fr 1fr; 
            gap: 20px; 
        }

        .form-group { 
            display: flex; 
            flex-direction: column; 
            gap: 8px; 
        }

        .form-group.full-width { 
            grid-column: 1 / -1; 
        }

        label { 
            font-weight: 600; 
            font-size: 14px; 
            color: var(--text-muted);
        }

        input, select, textarea { 
            padding: 12px; 
            border: 1px solid var(--border-color); 
            border-radius: 8px; 
            font-size: 15px; 
            width: 100%; 
            box-sizing: border-box; 
            background-color: var(--input-bg);
            color: var(--text-main);
            transition: all 0.3s ease;
        }

        input:focus, select:focus, textarea:focus { 
            border-color: var(--primary); 
            outline: none; 
            box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.1);
        }

        .readonly-field { 
            background-color: var(--readonly-bg) !important; 
            cursor: not-allowed; 
            color: var(--readonly-color) !important; 
        }

        .btn-submit { 
            background-color: var(--primary); 
            color: white; 
            padding: 14px 20px; 
            font-size: 16px; 
            border: none; 
            border-radius: 8px; 
            cursor: pointer; 
            margin-top: 20px; 
            width: 100%; 
            font-weight: bold; 
            transition: background-color 0.3s ease;
        }

        .btn-submit:hover { 
            background-color: var(--primary-hover); 
        }

        .img-preview { 
            width: 80px; 
            height: 80px; 
            border-radius: 8px; 
            object-fit: cover; 
            margin-top: 10px; 
            border: 2px solid var(--primary); 
        }

        @media(max-width: 768px) {
            .form-grid {
                grid-template-columns: 1fr;
            }
            .full-width {
                grid-column: span 1;
            }
        }
    </style>
</head>
<body>

<div class="container">
    <h2 class="form-title"><i class="fas fa-edit"></i> <span data-i18n="form_title">Wax ka beddel Xogta Macalinka</span></h2>
    
    <%@ include file="db_connection.jsp" %>
    <%
        try {
            // Soo akhrinta xogta macalinka iyo user-ka
            String sql = "SELECT t.*, u.full_name, u.username, u.email, u.status FROM teachers t JOIN users u ON t.user_id = u.id WHERE t.id = ?";
            PreparedStatement pst = conn.prepareStatement(sql);
            pst.setString(1, teacherId);
            ResultSet rs = pst.executeQuery();

            if (rs.next()) {
    %>
    <!-- Form-ka Waxa uu u socdaa UpdateTeacherServlet (Servlet) si sawirada uu u handle gareeyo -->
    <form action="UpdateTeacherServlet" method="POST" enctype="multipart/form-data">
        <input type="hidden" name="teacher_id" value="<%= rs.getString("id") %>">
        <input type="hidden" name="user_id" value="<%= rs.getString("user_id") %>">
        
        <div class="form-grid">
            <!-- Xogta Login-ka -->
            <div class="form-group">
                <label data-i18n="label_fullname">Magaca Buuxa (Full Name)</label>
                <input type="text" name="full_name" value="<%= rs.getString("full_name") %>" required>
            </div>
            <div class="form-group">
                <label data-i18n="label_username">Username</label>
                <input type="text" name="username" value="<%= rs.getString("username") %>" required>
            </div>
            <div class="form-group full-width">
                <label data-i18n="label_email">Email-ka (Lama beddeli karo)</label>
                <input type="email" name="email" value="<%= rs.getString("email") %>" class="readonly-field" readonly>
            </div>
            <!-- FIIRO GAAR AH: Password iyo Recovery PIN meesha kuma jiraan (Lama beddeli karo halkan) -->

            <div class="form-group">
                <label data-i18n="label_status">Xaaladda (Status)</label>
                <select name="status">
                    <option value="Active" <%= "Active".equalsIgnoreCase(rs.getString("status")) ? "selected" : "" %>>Active</option>
                    <option value="Inactive" <%= "Inactive".equalsIgnoreCase(rs.getString("status")) ? "selected" : "" %>>Inactive</option>
                </select>
            </div>

            <!-- Xogta Shaqsiga -->
            <div class="form-group">
                <label data-i18n="label_phone">Telefoonka (Phone)</label>
                <input type="text" name="phone" value="<%= rs.getString("phone") %>" required>
            </div>
            <div class="form-group">
                <label data-i18n="label_alt_phone">Telefoon Labaad (Alt Phone)</label>
                <input type="text" name="alt_phone" value="<%= rs.getString("alt_phone") != null ? rs.getString("alt_phone") : "" %>">
            </div>
            <div class="form-group">
                <label data-i18n="label_gender">Jinsiga (Gender)</label>
                <select name="gender">
                    <option value="Male" data-i18n="opt_male" <%= "Male".equalsIgnoreCase(rs.getString("gender")) ? "selected" : "" %>>Lab (Male)</option>
                    <option value="Female" data-i18n="opt_female" <%= "Female".equalsIgnoreCase(rs.getString("gender")) ? "selected" : "" %>>Dhedig (Female)</option>
                </select>
            </div>
            <div class="form-group">
                <label data-i18n="label_dob">Taariikhda Dhalashada (DOB)</label>
                <input type="date" name="dob" value="<%= rs.getString("dob") %>">
            </div>
            <div class="form-group full-width">
                <label data-i18n="label_address">Cinwaanka (Address)</label>
                <input type="text" name="address" value="<%= rs.getString("address") %>">
            </div>

            <!-- Khibradda iyo Aqoonta -->
            <div class="form-group">
                <label data-i18n="label_qualification">Shahaadada (Qualification)</label>
                <input type="text" name="qualification" value="<%= rs.getString("qualification") %>">
            </div>
            <div class="form-group">
                <label data-i18n="label_experience">Khibrad (Sanooyin)</label>
                <input type="number" name="experience_years" value="<%= rs.getInt("experience_years") %>">
            </div>
            <div class="form-group full-width">
                <label data-i18n="label_prev_workplaces">Meelihii hore uu uga soo shaqeeyay</label>
                <textarea name="previous_workplaces" rows="2"><%= rs.getString("previous_workplaces") != null ? rs.getString("previous_workplaces") : "" %></textarea>
            </div>

            <!-- Xogta Damiinka -->
            <div class="form-group">
                <label data-i18n="label_guarantor_name">Magaca Damiinka (Guarantor Name)</label>
                <input type="text" name="guarantor_name" value="<%= rs.getString("guarantor_name") %>">
            </div>
            <div class="form-group">
                <label data-i18n="label_guarantor_phone">Telefoonka Damiinka (Guarantor Phone)</label>
                <input type="text" name="guarantor_phone" value="<%= rs.getString("guarantor_phone") %>">
            </div>
            <div class="form-group">
                <label data-i18n="label_guarantor_relation">Xiriirka Damiinka (Relation)</label>
                <input type="text" name="guarantor_relation" value="<%= rs.getString("guarantor_relation") %>">
            </div>
            <div class="form-group">
                <label><span data-i18n="label_guarantor_id">Aqoonsiga Damiinka (Guarantor ID Image)</span> - <small data-i18n="small_change_img">Geli haddii aad beddelayso</small></label>
                <input type="file" name="guarantor_id_image" accept="image/*">
                <input type="hidden" name="old_guarantor_id" value="<%= rs.getString("guarantor_id_image") %>">
            </div>

            <!-- Maamulka iyo Sawirka Macalinka -->
            <div class="form-group">
                <label data-i18n="label_base_salary">Mushaarka Asalka ah (Base Salary)</label>
                <input type="number" step="0.01" name="base_salary" value="<%= rs.getString("base_salary") %>">
            </div>
            <div class="form-group">
                <label data-i18n="label_hire_date">Taariikhda Shaqaaleynta (Hire Date)</label>
                <input type="date" name="hire_date" value="<%= rs.getString("hire_date") %>">
            </div>
            <div class="form-group full-width">
                <label><span data-i18n="label_photo">Sawirka Macalinka (Photo)</span> - <small data-i18n="small_change_img">Geli sawir cusub haddii aad beddelayso</small></label>
                <input type="file" name="photo" accept="image/*">
                <!-- Xafidida sawirkii hore si aan loo tirtirin haddii aan la soo gelin mid cusub -->
                <input type="hidden" name="old_photo" value="<%= rs.getString("photo") %>">
                <% if(rs.getString("photo") != null && !rs.getString("photo").isEmpty()) { %>
                    <img src="uploads/teacher/<%= rs.getString("photo") %>" class="img-preview" alt="Current Photo">
                <% } %>
            </div>
        </div>

        <button type="submit" class="btn-submit"><i class="fas fa-save"></i> <span data-i18n="btn_save">Keydi Isbedelka (Save Changes)</span></button>
    </form>
    <%
            } else {
                out.println("<p style='color:red;'>Xogta macalinkan lama helin!</p>");
            }
            rs.close(); pst.close(); conn.close();
        } catch (Exception e) {
            out.println("<p style='color:red;'>Cilad Database: " + e.getMessage() + "</p>");
        }
    %>
</div>

<!-- Script-ka Luqadaha iyo Dark Mode Syncing-ka -->
<script>
    const translations = {
        en: {
            page_title: "Edit Teacher",
            form_title: "Edit Teacher Data",
            label_fullname: "Full Name",
            label_username: "Username",
            label_email: "Email (Read-only)",
            label_status: "Status",
            label_phone: "Phone",
            label_alt_phone: "Alt Phone",
            label_gender: "Gender",
            label_dob: "Date of Birth (DOB)",
            label_address: "Address",
            label_qualification: "Qualification",
            label_experience: "Experience (Years)",
            label_prev_workplaces: "Previous Workplaces",
            label_guarantor_name: "Guarantor Name",
            label_guarantor_phone: "Guarantor Phone",
            label_guarantor_relation: "Guarantor Relation",
            label_guarantor_id: "Guarantor ID Image",
            label_base_salary: "Base Salary",
            label_hire_date: "Hire Date",
            label_photo: "Teacher Photo",
            small_change_img: "Upload new if changing",
            btn_save: "Save Changes",
            opt_male: "Male",
            opt_female: "Female"
        },
        so: {
            page_title: "Wax ka beddel Macalinka",
            form_title: "Wax ka beddel Xogta Macalinka",
            label_fullname: "Magaca Buuxa (Full Name)",
            label_username: "Username",
            label_email: "Email-ka (Lama beddeli karo)",
            label_status: "Xaaladda (Status)",
            label_phone: "Telefoonka (Phone)",
            label_alt_phone: "Telefoon Labaad (Alt Phone)",
            label_gender: "Jinsiga (Gender)",
            label_dob: "Taariikhda Dhalashada (DOB)",
            label_address: "Cinwaanka (Address)",
            label_qualification: "Shahaadada (Qualification)",
            label_experience: "Khibrad (Sanooyin)",
            label_prev_workplaces: "Meelihii hore uu uga soo shaqeeyay",
            label_guarantor_name: "Magaca Damiinka (Guarantor Name)",
            label_guarantor_phone: "Telefoonka Damiinka (Guarantor Phone)",
            label_guarantor_relation: "Xiriirka Damiinka (Relation)",
            label_guarantor_id: "Aqoonsiga Damiinka (Guarantor ID Image)",
            label_base_salary: "Mushaarka Asalka ah (Base Salary)",
            label_hire_date: "Taariikhda Shaqaaleynta (Hire Date)",
            label_photo: "Sawirka Macalinka (Photo)",
            small_change_img: "Geli haddii aad beddelayso",
            btn_save: "Keydi Isbedelka (Save Changes)",
            opt_male: "Lab (Male)",
            opt_female: "Dhedig (Female)"
        },
        ar: {
            page_title: "تعديل بيانات المعلم",
            form_title: "تعديل بيانات المعلم",
            label_fullname: "الاسم الكامل",
            label_username: "اسم المستخدم",
            label_email: "البريد الإلكتروني (للعرص فقط)",
            label_status: "الحالة",
            label_phone: "الهاتف",
            label_alt_phone: "هاتف بديل",
            label_gender: "الجنس",
            label_dob: "تاريخ الميلاد",
            label_address: "العنوان",
            label_qualification: "المؤهل",
            label_experience: "سنوات الخبرة",
            label_prev_workplaces: "أماكن العمل السابقة",
            label_guarantor_name: "اسم الكفيل",
            label_guarantor_phone: "هاتف الكفيل",
            label_guarantor_relation: "صلة القرابة",
            label_guarantor_id: "صورة هوية الكفيل",
            label_base_salary: "الراتب الأساسي",
            label_hire_date: "تاريخ التوظيف",
            label_photo: "صورة المعلم",
            small_change_img: "قم بالتحديث إذا كنت تريد التغيير",
            btn_save: "حفظ التغييرات",
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