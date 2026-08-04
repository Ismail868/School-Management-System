<%@page import="java.sql.*, utils.DBConnection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    if (session.getAttribute("username") == null) {
        response.sendRedirect("index.jsp");
        return; 
    }

    String subjectId = request.getParameter("id");
    if (subjectId == null || subjectId.isEmpty()) {
        response.sendRedirect("classes_subjects.jsp");
        return;
    }

    String message = "";
    String msgType = "";
    Connection conn = null;

    try {
        conn = DBConnection.getConnection();

        // Nidaamka Form-ka marka la Submit-gareeyo (POST Requests)
        String action = request.getParameter("action");
        if (action != null) {
            if (action.equals("update_subject")) {
                // 1. Bedelida Magaca iyo Code-ka Maadada
                String newName = request.getParameter("subject_name");
                String newCode = request.getParameter("subject_code");
                
                String updateSql = "UPDATE subjects SET subject_name = ?, subject_code = ? WHERE id = ?";
                PreparedStatement psUpdate = conn.prepareStatement(updateSql);
                psUpdate.setString(1, newName);
                psUpdate.setString(2, newCode);
                psUpdate.setString(3, subjectId);
                
                if (psUpdate.executeUpdate() > 0) {
                    message = "Xogta Maadada si guul ah ayaa loo cusbooneysiiyay!";
                    msgType = "success";
                }
                psUpdate.close();

            } else if (action.equals("assign_teacher")) {
                // 2. Dhiibida ama Wareejinta Macalinka
                String classId = request.getParameter("class_id");
                String teacherId = request.getParameter("teacher_id");

                // Ugu horeyn, aan hubino in class_subjects uu jiro (Fasalka iyo Maadada isku xiran)
                String checkCsSql = "SELECT id FROM class_subjects WHERE class_id = ? AND subject_id = ?";
                PreparedStatement psCs = conn.prepareStatement(checkCsSql);
                psCs.setString(1, classId);
                psCs.setString(2, subjectId);
                ResultSet rsCs = psCs.executeQuery();
                
                String classSubjectId = "";
                if (rsCs.next()) {
                    classSubjectId = rsCs.getString("id");
                } else {
                    // Haddii uusan jirin, aan abuurno isku xirka fasalka iyo maadada
                    String insertCsSql = "INSERT INTO class_subjects (class_id, subject_id) VALUES (?, ?)";
                    PreparedStatement psInsertCs = conn.prepareStatement(insertCsSql, Statement.RETURN_GENERATED_KEYS);
                    psInsertCs.setString(1, classId);
                    psInsertCs.setString(2, subjectId);
                    psInsertCs.executeUpdate();
                    ResultSet generatedKeys = psInsertCs.getGeneratedKeys();
                    if (generatedKeys.next()) {
                        classSubjectId = generatedKeys.getString(1);
                    }
                    psInsertCs.close();
                }
                rsCs.close();
                psCs.close();

                // Hadda aan hubino in macalin horay loogu dhiibay class_subject-gan
                String checkAllocationSql = "SELECT id FROM teacher_allocations WHERE class_subject_id = ?";
                PreparedStatement psCheckAlloc = conn.prepareStatement(checkAllocationSql);
                psCheckAlloc.setString(1, classSubjectId);
                ResultSet rsAlloc = psCheckAlloc.executeQuery();

                if (rsAlloc.next()) {
                    // Macalin hore ayaa jira -> UPDATE (Wareejin)
                    String allocId = rsAlloc.getString("id");
                    String updateAllocSql = "UPDATE teacher_allocations SET teacher_id = ? WHERE id = ?";
                    PreparedStatement psUpdateAlloc = conn.prepareStatement(updateAllocSql);
                    psUpdateAlloc.setString(1, teacherId);
                    psUpdateAlloc.setString(2, allocId);
                    psUpdateAlloc.executeUpdate();
                    psUpdateAlloc.close();
                    message = "Maadada waxaa si guul ah loogu wareejiyay macalinka cusub!";
                } else {
                    // Macalin hore ma jiro -> INSERT (Dhiibid cusub)
                    String insertAllocSql = "INSERT INTO teacher_allocations (teacher_id, class_subject_id) VALUES (?, ?)";
                    PreparedStatement psInsertAlloc = conn.prepareStatement(insertAllocSql);
                    psInsertAlloc.setString(1, teacherId);
                    psInsertAlloc.setString(2, classSubjectId);
                    psInsertAlloc.executeUpdate();
                    psInsertAlloc.close();
                    message = "Macalinka si guul ah ayaa loogu dhiibay maadada!";
                }
                msgType = "success";
                rsAlloc.close();
                psCheckAlloc.close();
            }
        }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Subject - School Management</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root {
            --bg-main: #f0f4f8; --card-bg: #ffffff; --text-main: #2d3748;
            --text-muted: #718096; --border-color: #e2e8f0; --primary: #4f46e5;
            --primary-hover: #4338ca; --success: #10b981; --warning: #f59e0b;
            --danger: #ef4444; --badge-bg: #e0e7ff; --badge-text: #3730a3;
        }
        .dark-mode {
            --bg-main: #0f172a; --card-bg: #1e293b; --text-main: #f1f5f9;
            --text-muted: #94a3b8; --border-color: #334155;
            --badge-bg: #3730a3; --badge-text: #e0e7ff;
        }

        /* CSS-ka Luuqada Carabiga (RTL) */
        .rtl { direction: rtl; text-align: right; }
        .rtl .header { flex-direction: row-reverse; }
        .rtl .btn-back i { transform: rotate(180deg); }
        .rtl .grid-container { direction: rtl; }
        .rtl .card h2 { flex-direction: row; }
        .rtl .form-group label { text-align: right; }
        .rtl .alert { text-align: right; }

        body { background-color: var(--bg-main); color: var(--text-main); font-family: 'Segoe UI', sans-serif; margin: 0; padding: 30px 20px; transition: all 0.3s; }
        .container { max-width: 1000px; margin: auto; }

        .header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 25px; }
        .btn-back { background: var(--text-muted); color: white; padding: 10px 20px; text-decoration: none; border-radius: 8px; font-weight: bold; display: inline-flex; align-items: center; gap: 8px; }
        .btn-back:hover { background: #4a5568; }

        .grid-container { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
        @media (max-width: 768px) { .grid-container { grid-template-columns: 1fr; } }

        .card { background: var(--card-bg); padding: 25px; border-radius: 12px; border: 1px solid var(--border-color); box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05); }
        .card h2 { margin-top: 0; display: flex; align-items: center; gap: 10px; color: var(--primary); font-size: 20px; margin-bottom: 20px; border-bottom: 2px solid var(--border-color); padding-bottom: 10px;}
        
        .form-group { margin-bottom: 15px; }
        .form-group label { display: block; font-weight: bold; margin-bottom: 8px; color: var(--text-main); }
        .form-control { width: 100%; padding: 12px; font-size: 15px; border: 1px solid var(--border-color); border-radius: 8px; background: var(--bg-main); color: var(--text-main); box-sizing: border-box; }
        .form-control:focus { outline: none; border-color: var(--primary); }
        
        .btn-submit { width: 100%; background: var(--primary); color: white; border: none; padding: 12px; font-size: 16px; font-weight: bold; border-radius: 8px; cursor: pointer; transition: 0.3s; margin-top: 10px; }
        .btn-submit:hover { background: var(--primary-hover); }

        .alert { padding: 15px; border-radius: 8px; margin-bottom: 20px; font-weight: bold; text-align: center; }
        .alert-success { background: #d1fae5; color: #065f46; border: 1px solid #34d399; }
        .alert-danger { background: #fee2e2; color: #991b1b; border: 1px solid #f87171; }

        .status-badge { display: inline-block; padding: 8px 12px; border-radius: 6px; font-size: 14px; background: var(--bg-main); border: 1px solid var(--border-color); margin-top: 5px; width: 100%; box-sizing: border-box;}
        .has-teacher { background: #fffbeb; border-color: #fcd34d; color: #92400e; font-weight: bold; }
    </style>
</head>
<body>

<div class="container">
    <div class="header">
        <h1 style="margin: 0; font-size: 24px;" data-i18n="subject_management">Maamulka Maadada</h1>
        <a href="classes_subjects.jsp" class="btn-back"><i class="fas fa-arrow-left"></i> <span data-i18n="go_back">Dib ugu Noqo</span></a>
    </div>

    <% if (!message.isEmpty()) { %>
        <div class="alert alert-<%= msgType %>">
            <%= message %>
        </div>
    <% } %>

    <%
        // Fetch Subject Details
        String subName = "";
        String subCode = "";
        PreparedStatement psSub = conn.prepareStatement("SELECT * FROM subjects WHERE id = ?");
        psSub.setString(1, subjectId);
        ResultSet rsSub = psSub.executeQuery();
        if (rsSub.next()) {
            subName = rsSub.getString("subject_name");
            subCode = rsSub.getString("subject_code");
        } else {
            out.println("<div class='alert alert-danger' data-i18n='subject_not_found'>Maadadan lama helin!</div>");
            return;
        }
    %>

    <div class="grid-container">
        <!-- QEYBTA 1AAD: Bedelida Magaca & Code-ka -->
        <div class="card">
            <h2><i class="fas fa-edit"></i> <span data-i18n="edit_subject">Wax ka bedel Maadada</span></h2>
            <form action="edit_subject.jsp?id=<%= subjectId %>" method="POST">
                <input type="hidden" name="action" value="update_subject">
                
                <div class="form-group">
                    <label data-i18n="subject_name">Magaca Maadada</label>
                    <input type="text" name="subject_name" class="form-control" value="<%= subName %>" required>
                </div>
                
                <div class="form-group">
                    <label data-i18n="subject_code">Code-ka Maadada</label>
                    <input type="text" name="subject_code" class="form-control" value="<%= subCode %>" required>
                </div>
                
                <button type="submit" class="btn-submit" data-i18n="save_changes">Keydi Isbedelka</button>
            </form>
        </div>

        <!-- QEYBTA 2AAD: Dhiibida / Wareejinta Macalinka -->
        <div class="card">
            <h2><i class="fas fa-user-tie"></i> <span data-i18n="assign_teacher">U Dhiib Macalin</span></h2>
            <form action="edit_subject.jsp?id=<%= subjectId %>" method="POST" id="assignForm" onsubmit="return confirmAssignment(event)">
                <input type="hidden" name="action" value="assign_teacher">
                
                <div class="form-group">
                    <label data-i18n="select_class">Dooro Fasalka (Class)</label>
                    <select name="class_id" id="classSelect" class="form-control" required onchange="checkExistingTeacher()">
                        <option value="" data-i18n="choose_class">-- Dooro Fasal --</option>
                        <%
                            Statement stmtClass = conn.createStatement();
                            ResultSet rsClass = stmtClass.executeQuery("SELECT * FROM class ORDER BY id ASC");
                            while (rsClass.next()) {
                        %>
                                <option value="<%= rsClass.getString("id") %>"><%= rsClass.getString("class_name") %></option>
                        <%
                            }
                            rsClass.close();
                            stmtClass.close();
                        %>
                    </select>
                    <!-- Halkaan ayaa lagu soo bandhigi doonaa haddii macalin horey loogu dhiibay -->
                    <div id="teacherStatus" class="status-badge" style="display: none;"></div>
                </div>

                <div class="form-group">
                    <label data-i18n="select_new_teacher">Dooro Macalinka Cusub</label>
                    <select name="teacher_id" id="teacherSelect" class="form-control" required>
                        <option value="" data-i18n="choose_teacher">-- Dooro Macalin --</option>
                        <%
                            Statement stmtTeacher = conn.createStatement();
                            ResultSet rsTeacher = stmtTeacher.executeQuery("SELECT t.id, u.full_name FROM teachers t JOIN users u ON t.user_id = u.id ORDER BY u.full_name ASC");
                            while (rsTeacher.next()) {
                        %>
                                <option value="<%= rsTeacher.getString("id") %>"><%= rsTeacher.getString("full_name") %></option>
                        <%
                            }
                            rsTeacher.close();
                            stmtTeacher.close();
                        %>
                    </select>
                </div>

                <button type="submit" class="btn-submit" style="background: var(--warning); color: #000;">
                    <i class="fas fa-exchange-alt"></i> <span data-i18n="assign_transfer">Dhiib / Wareeji</span>
                </button>
            </form>
        </div>
    </div>
    
    <%
        // Diyaarinta xogta macalimiinta hada maadadan dhiga (si JavaScript-ka u ogaado)
        StringBuilder jsAllocations = new StringBuilder("{");
        String qryAlloc = "SELECT c.id as class_id, u.full_name as teacher_name, t.id as teacher_id " +
                          "FROM class_subjects cs " +
                          "JOIN teacher_allocations ta ON cs.id = ta.class_subject_id " +
                          "JOIN teachers t ON ta.teacher_id = t.id " +
                          "JOIN users u ON t.user_id = u.id " +
                          "JOIN class c ON cs.class_id = c.id " +
                          "WHERE cs.subject_id = " + subjectId;
        Statement stmtAlloc = conn.createStatement();
        ResultSet rsA = stmtAlloc.executeQuery(qryAlloc);
        boolean first = true;
        while(rsA.next()) {
            if(!first) jsAllocations.append(",");
            jsAllocations.append("\"" + rsA.getString("class_id") + "\": {");
            jsAllocations.append("name: \"" + rsA.getString("teacher_name").replace("\"", "\\\"") + "\",");
            jsAllocations.append("id: \"" + rsA.getString("teacher_id") + "\"");
            jsAllocations.append("}");
            first = false;
        }
        jsAllocations.append("}");
        rsA.close();
        stmtAlloc.close();
    %>

</div>

<script>
    // --- NIDAAMKA LUUQADAHA IYO DARK MODE EE LAGU DARAY ---
    const pageTranslations = {
        en: {
            subject_management: "Subject Management",
            go_back: "Go Back",
            subject_not_found: "Subject not found!",
            edit_subject: "Edit Subject",
            subject_name: "Subject Name",
            subject_code: "Subject Code",
            save_changes: "Save Changes",
            assign_teacher: "Assign Teacher",
            select_class: "Select Class",
            choose_class: "-- Choose Class --",
            select_new_teacher: "Select New Teacher",
            choose_teacher: "-- Choose Teacher --",
            assign_transfer: "Assign / Transfer",
            warning: "Warning",
            teacher_assigned: "Teacher {teacher} is already assigned to this class.",
            already_assigned: "This teacher is already assigned to this class!",
            confirm_transfer: "This subject is already assigned to Teacher {old_teacher}.\n\nAre you sure you want to transfer it to Teacher {new_teacher}?"
        },
        so: {
            subject_management: "Maamulka Maadada",
            go_back: "Dib ugu Noqo",
            subject_not_found: "Maadadan lama helin!",
            edit_subject: "Wax ka bedel Maadada",
            subject_name: "Magaca Maadada",
            subject_code: "Code-ka Maadada",
            save_changes: "Keydi Isbedelka",
            assign_teacher: "U Dhiib Macalin",
            select_class: "Dooro Fasalka (Class)",
            choose_class: "-- Dooro Fasal --",
            select_new_teacher: "Dooro Macalinka Cusub",
            choose_teacher: "-- Dooro Macalin --",
            assign_transfer: "Dhiib / Wareeji",
            warning: "Fiiro Gaar ah",
            teacher_assigned: "Macalin {teacher} ayaa horay loogu dhiibay fasalkan.",
            already_assigned: "Macalinkan asiga ayaa horay u haystay fasalkan!",
            confirm_transfer: "Maadadan fasalkan waxaa horay ugu qornaa Macalin {old_teacher}.\n\nMa hubtaa inaad ka wareejiso oo aad u dhiibto Macalin {new_teacher}?"
        },
        ar: {
            subject_management: "إدارة المواد",
            go_back: "رجوع",
            subject_not_found: "لم يتم العثور على المادة!",
            edit_subject: "تعديل المادة",
            subject_name: "اسم المادة",
            subject_code: "رمز المادة",
            save_changes: "حفظ التغييرات",
            assign_teacher: "تعيين معلم",
            select_class: "اختر الفصل",
            choose_class: "-- اختر الفصل --",
            select_new_teacher: "اختر المعلم الجديد",
            choose_teacher: "-- اختر المعلم --",
            assign_transfer: "تعيين / نقل",
            warning: "تحذير",
            teacher_assigned: "المعلم {teacher} معين مسبقاً لهذا الفصل.",
            already_assigned: "هذا المعلم معين مسبقاً لهذا الفصل!",
            confirm_transfer: "هذه المادة معينة مسبقاً للمعلم {old_teacher}.\n\nهل أنت متأكد أنك تريد نقلها إلى المعلم {new_teacher}؟"
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

    // --- SHAQADA XOGTA IYO HUBINTA ---
    const existingAllocations = <%= jsAllocations.toString() %>;

    function checkExistingTeacher() {
        const classId = document.getElementById("classSelect").value;
        const statusDiv = document.getElementById("teacherStatus");
        
        if (classId && existingAllocations[classId]) {
            const currentTeacherName = existingAllocations[classId].name;
            const warnText = pageTranslations[currentLang].warning;
            const msgText = pageTranslations[currentLang].teacher_assigned.replace("{teacher}", "<b>" + currentTeacherName + "</b>");
            
            // XALKA: Halkan ayaan ka saarnay si uusan JSP-ga u qasin
            statusDiv.innerHTML = '<i class="fas fa-exclamation-triangle"></i> <b>' + warnText + ':</b> ' + msgText;
            
            statusDiv.className = "status-badge has-teacher";
            statusDiv.style.display = "block";
        } else {
            statusDiv.style.display = "none";
            statusDiv.className = "status-badge";
        }
    }

    function confirmAssignment(event) {
        const classId = document.getElementById("classSelect").value;
        const selectedTeacherId = document.getElementById("teacherSelect").value;
        const selectedTeacherName = document.getElementById("teacherSelect").options[document.getElementById("teacherSelect").selectedIndex].text;

        // Haddii uu jiro macalin hore
        if (classId && existingAllocations[classId]) {
            const currentTeacherId = existingAllocations[classId].id;
            const currentTeacherName = existingAllocations[classId].name;

            // Haddii macalinka cusub iyo kii hore ay isku mid yihiin
            if (currentTeacherId === selectedTeacherId) {
                alert(pageTranslations[currentLang].already_assigned);
                event.preventDefault();
                return false;
            }

            // Waydiinta Wareejinta oo ku saleysan luuqadda (Transfer Confirmation)
            const confirmTemplate = pageTranslations[currentLang].confirm_transfer;
            const confirmMsg = confirmTemplate.replace("{old_teacher}", currentTeacherName).replace("{new_teacher}", selectedTeacherName);
            
            if (!confirm(confirmMsg)) {
                event.preventDefault(); 
                return false;
            }
        }
        return true; 
    }
</script>

<%
    } catch (Exception e) {
        out.println("<div class='container'><div class='alert alert-danger'>Cilad Database: " + e.getMessage() + "</div></div>");
    } finally {
        if (conn != null) {
            try { conn.close(); } catch (SQLException e) { }
        }
    }
%>
</body>
</html>