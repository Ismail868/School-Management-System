<%@page import="java.sql.*, utils.DBConnection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    if (session.getAttribute("username") == null) {
        response.sendRedirect("index.jsp");
        return; 
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Classes & Subjects - School Management</title>
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
        .rtl .header-actions { flex-direction: row-reverse; }
        .rtl .tabs { flex-direction: row-reverse; }
        .rtl .item-card { flex-direction: row-reverse; }
        .rtl .item-info { flex-direction: row-reverse; text-align: right; }
        .rtl .action-buttons { flex-direction: row-reverse; }
        .rtl .option-box { flex-direction: row-reverse; text-align: right; }
        .rtl .student-row { flex-direction: row-reverse; text-align: right; }
        .rtl .close-btn { right: auto; left: 20px; }

        body { background-color: var(--bg-main); color: var(--text-main); font-family: 'Segoe UI', sans-serif; margin: 0; padding: 30px 20px; transition: all 0.3s; }
        .container { max-width: 1100px; margin: auto; }

        .header-actions { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; gap: 15px; flex-wrap: wrap; }
        .search-box { flex: 1; min-width: 250px; padding: 12px 20px; font-size: 16px; border: 2px solid var(--border-color); border-radius: 10px; background: var(--card-bg); color: var(--text-main); outline: none; }
        .search-box:focus { border-color: var(--primary); }
        .btn-add { background-color: var(--success); color: white; padding: 12px 24px; font-size: 16px; font-weight: bold; border: none; border-radius: 10px; cursor: pointer; display: flex; align-items: center; gap: 8px; }

        .tabs { display: flex; gap: 10px; margin-bottom: 20px; border-bottom: 2px solid var(--border-color); padding-bottom: 10px; }
        .tab-btn { padding: 10px 20px; font-size: 16px; font-weight: bold; background: none; border: none; color: var(--text-muted); cursor: pointer; border-radius: 8px; transition: 0.3s; }
        .tab-btn.active { background: var(--primary); color: white; }
        .tab-content { display: none; }
        .tab-content.active { display: block; }

        .item-list { display: flex; flex-direction: column; gap: 15px; }
        .item-card { display: flex; align-items: center; justify-content: space-between; background: var(--card-bg); padding: 15px 20px; border-radius: 12px; border: 1px solid var(--border-color); flex-wrap: wrap; gap: 15px; }
        .item-info { display: flex; align-items: center; gap: 15px; flex: 1; }
        .item-icon { width: 55px; height: 55px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 24px; color: var(--primary); background: var(--badge-bg); }
        .item-details h3 { margin: 0 0 5px 0; font-size: 18px; }
        .item-details p { margin: 0; font-size: 14px; color: var(--text-muted); }
        .badge { background: var(--badge-bg); color: var(--badge-text); padding: 4px 10px; border-radius: 20px; font-size: 12px; font-weight: bold; }

        .action-buttons { display: flex; gap: 8px; }
        .btn-action { padding: 8px 15px; color: white; border: none; border-radius: 6px; cursor: pointer; font-size: 14px; display: flex; align-items: center; gap: 5px;}
        .btn-details { background: var(--primary); }
        .btn-edit { background: var(--warning); }
        .btn-delete { background: var(--danger); }

        .modal { display: none; position: fixed; z-index: 1000; left: 0; top: 0; width: 100%; height: 100%; background-color: rgba(0,0,0,0.6); align-items: center; justify-content: center; backdrop-filter: blur(4px); }
        .modal-content { background: var(--card-bg); padding: 30px; border-radius: 16px; width: 90%; max-width: 600px; max-height: 80vh; overflow-y: auto; position: relative; }
        .close-btn { position: absolute; top: 15px; right: 20px; font-size: 24px; cursor: pointer; color: var(--text-muted); }
        
        .option-box { display: flex; align-items: center; gap: 15px; padding: 20px; background: var(--bg-main); border: 2px solid var(--border-color); border-radius: 12px; margin-bottom: 15px; cursor: pointer; transition: 0.2s; text-decoration: none; color: var(--text-main); }
        .option-box:hover { border-color: var(--primary); background: var(--badge-bg); }
        .option-icon { font-size: 30px; color: var(--primary); }
        .option-text h3 { margin: 0 0 5px 0; }
        .option-text p { margin: 0; font-size: 13px; color: var(--text-muted); }

        .student-row { display: flex; align-items: center; gap: 15px; padding: 10px; border-bottom: 1px solid var(--border-color); }
        .student-photo { width: 50px; height: 50px; border-radius: 50%; object-fit: cover; border: 2px solid var(--primary); background-color: #ccc; }
        .student-info h4 { margin: 0; font-size: 15px; color: var(--text-main); }
        .student-info span { font-size: 13px; color: var(--text-muted); }
        .empty-state { text-align: center; padding: 20px; color: var(--text-muted); font-style: italic; }
    </style>
</head>
<body>

<div class="container">
    <div class="header-actions">
        <input type="text" id="searchInput" class="search-box" data-i18n-placeholder="search_placeholder" placeholder="Raadi fasal, maado, ama macalin..." onkeyup="filterItems()">
        <button class="btn-add" onclick="openAddOptions()">
            <i class="fas fa-plus-circle"></i> <span data-i18n="add_btn">Add Class/Subject</span>
        </button>
    </div>

    <div class="tabs">
        <button class="tab-btn active" id="btn-classes" onclick="switchTab('classes')" data-i18n="tab_classes">Fasalada (Classes)</button>
        <button class="tab-btn" id="btn-subjects" onclick="switchTab('subjects')" data-i18n="tab_subjects">Maadooyinka (Subjects)</button>
    </div>

    <%
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
    %>

    <div id="tab-classes" class="tab-content active">
        <div class="item-list">
        <%
            String classSql = "SELECT * FROM class ORDER BY id ASC"; 
            try {
                Statement stmtClass = conn.createStatement();
                ResultSet rsClass = stmtClass.executeQuery(classSql);
                while (rsClass.next()) {
                    String classId = rsClass.getString("id");
                    String className = rsClass.getString("class_name"); 
        %>
            <div class="item-card searchable">
                <div class="item-info">
                    <div class="item-icon"><i class="fas fa-chalkboard"></i></div>
                    <div class="item-details">
                        <h3 class="search-name"><%= className %></h3>
                        <p data-i18n="class_registered">Fasal Diiwaangashan</p>
                    </div>
                </div>
                <div class="action-buttons">
                    <button class="btn-action btn-details" onclick="showClassStudents('<%= className.replace("'", "\\'") %>')">
                        <i class="fas fa-users"></i> <span data-i18n="btn_students">Ardayda</span>
                    </button>
                    <button class="btn-action btn-delete" onclick="deleteClass('<%= classId %>')">
                        <i class="fas fa-trash"></i> <span data-i18n="btn_delete">Delete</span>
                    </button>
                </div>
            </div>
        <% 
                } 
                rsClass.close();
                stmtClass.close();
            } catch (Exception e) {
                out.println("<p style='color:red;'>Fadlan hubi in table-ka 'class' uu jiro, leeyahayna column la yiraahdo 'class_name'. Error: " + e.getMessage() + "</p>");
            }
        %>
        </div>
    </div>

    <div id="tab-subjects" class="tab-content">
        <div class="item-list">
        <%
            String subjectSql = "SELECT s.id, s.subject_name, s.subject_code, " +
                                "(SELECT u.full_name FROM class_subjects cs " +
                                "JOIN teacher_allocations ta ON cs.id = ta.class_subject_id " +
                                "JOIN teachers t ON ta.teacher_id = t.id " +
                                "JOIN users u ON t.user_id = u.id " +
                                "WHERE cs.subject_id = s.id LIMIT 1) as teacher_name " +
                                "FROM subjects s ORDER BY s.id DESC";
            try {
                Statement stmtSub = conn.createStatement();
                ResultSet rsSub = stmtSub.executeQuery(subjectSql);
                while (rsSub.next()) {
                    String subId = rsSub.getString("id");
                    String subName = rsSub.getString("subject_name");
                    String subCode = rsSub.getString("subject_code");
                    String teacher = rsSub.getString("teacher_name");
                    
                    if (teacher == null || teacher.isEmpty()) {
                        teacher = "<span style='color: var(--danger);' data-i18n='no_teacher'>Wali macalin looma dhiibin</span>";
                    }
        %>
            <div class="item-card searchable">
                <div class="item-info">
                    <div class="item-icon"><i class="fas fa-book"></i></div>
                    <div class="item-details">
                        <h3 class="search-name"><%= subName %> <span class="badge"><%= subCode %></span></h3>
                        <p class="search-teacher"><i class="fas fa-chalkboard-teacher"></i> <span data-i18n="teacher_label">Macalinka:</span> <%= teacher %></p>
                    </div>
                </div>
                <div class="action-buttons">
                    <button class="btn-action btn-edit" onclick="window.location.href='edit_subject.jsp?id=<%= subId %>'"><i class="fas fa-edit"></i> <span data-i18n="btn_edit">Edit</span></button>
                    <button class="btn-action btn-delete" onclick="deleteSubject('<%= subId %>')"><i class="fas fa-trash"></i> <span data-i18n="btn_delete">Delete</span></button>
                </div>
            </div>
        <% 
                } 
                rsSub.close();
                stmtSub.close();
            } catch (Exception e) {
                out.println("<p style='color:red;'>Cilad baa ka dhacday Maadooyinka: " + e.getMessage() + "</p>");
            }
        %>
        </div>
    </div>

    <script>
        const allStudents = [
        <%
            try {
                Statement stmtStu = conn.createStatement();
                ResultSet rsStu = stmtStu.executeQuery("SELECT student_id, full_name, class, photo FROM students");
                while (rsStu.next()) {
                    String sId = rsStu.getString("student_id");
                    sId = (sId != null) ? sId.trim() : "N/A";
                    
                    String sName = rsStu.getString("full_name");
                    sName = (sName != null) ? sName.trim() : "Magac Ma Laha";
                    
                    String sClass = rsStu.getString("class");
                    sClass = (sClass != null) ? sClass.trim() : "";
                    
                    String photoName = rsStu.getString("photo");
                    String sPhoto = "";
                    if (photoName == null || photoName.trim().isEmpty()) {
                        sPhoto = "uploads/students/default-avatar.png"; 
                    } else {
                        sPhoto = (!photoName.startsWith("uploads/students/")) ? "uploads/students/" + photoName.trim() : photoName.trim();
                    }

                    sId = sId.replace("\\", "\\\\").replace("\"", "\\\"").replace("'", "\\'").replace("\n", " ").replace("\r", "");
                    sName = sName.replace("\\", "\\\\").replace("\"", "\\\"").replace("'", "\\'").replace("\n", " ").replace("\r", "");
                    sClass = sClass.replace("\\", "\\\\").replace("\"", "\\\"").replace("'", "\\'").replace("\n", "").replace("\r", "");
                    sPhoto = sPhoto.replace("\\", "\\\\").replace("\"", "\\\"").replace("'", "\\'").replace("\n", "").replace("\r", "");
        %>
            {
                id: "<%= sId %>",
                name: "<%= sName %>",
                className: "<%= sClass %>",
                photo: "<%= sPhoto %>"
            },
        <%      
                } 
                rsStu.close();
                stmtStu.close();
            } catch(Exception e) {
                System.out.println("Cilad dhanka ardayda ah: " + e.getMessage());
            }
        %>
        ];
    </script>
    
    <%
        } catch (Exception e) {
            out.println("<div style='color:red; padding:20px;'>Cilad Database: " + e.getMessage() + "</div>");
        } finally {
            if (conn != null) conn.close();
        }
    %>
</div>

<div id="addOptionsModal" class="modal">
    <div class="modal-content">
        <span class="close-btn" onclick="closeModal('addOptionsModal')">&times;</span>
        <h2 style="margin-top:0;" data-i18n="modal_add_title">Fadlan Dooro:</h2>
        <a href="add_class.jsp" class="option-box">
            <div class="option-icon"><i class="fas fa-chalkboard"></i></div>
            <div class="option-text">
                <h3 data-i18n="add_class_title">Ku dar Fasal Cusub</h3>
                <p data-i18n="add_class_desc">Diiwaangeli fasal cusub (sida F1, F2, iwm) si ardayda loogu xiro.</p>
            </div>
        </a>
        <a href="add_subject.jsp" class="option-box">
            <div class="option-icon"><i class="fas fa-book-medical"></i></div>
            <div class="option-text">
                <h3 data-i18n="add_sub_title">Ku dar Maado Cusub</h3>
                <p data-i18n="add_sub_desc">Ku dar database-ka maado cusub oo uusan iskuulku horay u lahayn.</p>
            </div>
        </a>
    </div>
</div>

<div id="classStudentsModal" class="modal">
    <div class="modal-content">
        <span class="close-btn" onclick="closeModal('classStudentsModal')">&times;</span>
        <h2 id="modalClassNameTitle" style="margin-top:0; color: var(--text-main);">Ardayda Fasalka</h2>
        <div id="studentsContainer" style="margin-top: 20px;"></div>
    </div>
</div>

<script>
    // NIDAAMKA LUUQADAHA EE LAGU DARAY
    const pageTranslations = {
        en: {
            search_placeholder: "Search class, subject, or teacher...",
            add_btn: "Add Class/Subject",
            tab_classes: "Classes",
            tab_subjects: "Subjects",
            class_registered: "Registered Class",
            btn_students: "Students",
            btn_delete: "Delete",
            btn_edit: "Edit",
            teacher_label: "Teacher:",
            no_teacher: "No teacher assigned",
            modal_add_title: "Please Choose:",
            add_class_title: "Add New Class",
            add_class_desc: "Register a new class (e.g. F3, F4, etc.) to link students.",
            add_sub_title: "Add New Subject",
            add_sub_desc: "Add a new subject to the System.",
            modal_students_title: "Students of Class: ",
            empty_students: "No students registered in this class yet.",
            confirm_delete_class: "Are you sure you want to delete this class?",
            confirm_delete_subject: "Are you sure you want to delete this subject?"
        },
        so: {
            search_placeholder: "Raadi fasal, maado, ama macalin...",
            add_btn: "Add Class/Subject",
            tab_classes: "Fasalada (Classes)",
            tab_subjects: "Maadooyinka (Subjects)",
            class_registered: "Fasal Diiwaangashan",
            btn_students: "Ardayda",
            btn_delete: "Delete",
            btn_edit: "Edit",
            teacher_label: "Macalinka:",
            no_teacher: "Wali macalin looma dhiibin",
            modal_add_title: "Fadlan Dooro:",
            add_class_title: "Ku dar Fasal Cusub",
            add_class_desc: "Diiwaangeli fasal cusub (sida F4, F3, iwm) si ardayda loogu xiro.",
            add_sub_title: "Ku dar Maado Cusub",
            add_sub_desc: "Ku dar System-ka maado cusub oo uusan iskuulku horay u lahayn.",
            modal_students_title: "Ardayda Fasalka: ",
            empty_students: "Fasalkan majiraan arday wali la diiwaangeliyay.",
            confirm_delete_class: "Ma hubtaa inaad tirtirto fasalkan?",
            confirm_delete_subject: "Ma hubtaa inaad tirtirto maadadan?"
        },
        ar: {
            search_placeholder: "ابحث عن فصل، مادة، أو معلم...",
            add_btn: "إضافة فصل/مادة",
            tab_classes: "الفصول",
            tab_subjects: "المواد",
            class_registered: "فصل مسجل",
            btn_students: "الطلاب",
            btn_delete: "حذف",
            btn_edit: "تعديل",
            teacher_label: "المعلم:",
            no_teacher: "لم يتم تعيين معلم",
            modal_add_title: "الرجاء الاختيار:",
            add_class_title: "إضافة فصل جديد",
            add_class_desc: "تسجيل فصل جديد لربط الطلاب به.",
            add_sub_title: "إضافة مادة جديدة",
            add_sub_desc: "إضافة مادة جديدة إلى قاعدة البيانات.",
            modal_students_title: "طلاب الفصل: ",
            empty_students: "لا يوجد طلاب مسجلين في هذا الفصل بعد.",
            confirm_delete_class: "هل أنت متأكد من حذف هذا الفصل؟",
            confirm_delete_subject: "هل أنت متأكد من حذف هذه المادة؟"
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
        filterItems();
    }

    function filterItems() {
        let input = document.getElementById('searchInput').value.toLowerCase();
        let activeTab = document.querySelector('.tab-content.active');
        let cards = activeTab.getElementsByClassName('searchable');
        
        for (let i = 0; i < cards.length; i++) {
            let name = cards[i].querySelector('.search-name').innerText.toLowerCase();
            let teacherEl = cards[i].querySelector('.search-teacher');
            let teacher = teacherEl ? teacherEl.innerText.toLowerCase() : "";
            
            if (name.includes(input) || teacher.includes(input)) {
                cards[i].style.display = "flex";
            } else {
                cards[i].style.display = "none";
            }
        }
    }

    function openAddOptions() {
        document.getElementById('addOptionsModal').style.display = 'flex';
    }

    // Shaqooyinka Delete oo la waafajiyay luuqadaha
    function deleteClass(id) {
        if (confirm(pageTranslations[currentLang].confirm_delete_class)) {
            window.location.href = 'delete_class.jsp?id=' + id;
        }
    }

    function deleteSubject(id) {
        if (confirm(pageTranslations[currentLang].confirm_delete_subject)) {
            window.location.href = 'delete_subject.jsp?id=' + id;
        }
    }

    function showClassStudents(className) {
        document.getElementById('modalClassNameTitle').innerText = pageTranslations[currentLang].modal_students_title + className;
        const container = document.getElementById('studentsContainer');
        container.innerHTML = ""; 
        
        const classStudents = allStudents.filter(s => 
            s.className.trim().toUpperCase() === className.trim().toUpperCase()
        );
        
        if (classStudents.length === 0) {
            container.innerHTML = `<div class='empty-state'>${pageTranslations[currentLang].empty_students}</div>`;
        } else {
            classStudents.forEach(student => {
                const row = document.createElement('div');
                row.className = 'student-row';
                row.innerHTML = `
                    <img src="\${student.photo}" alt="Sawir" class="student-photo" onerror="this.src='uploads/students/default-avatar.png'">
                    <div class="student-info">
                        <h4>\${student.name}</h4>
                        <span>ID: \${student.id}</span>
                    </div>
                `;
                container.appendChild(row);
            });
        }
        
        document.getElementById('classStudentsModal').style.display = 'flex';
    }

    function closeModal(modalId) {
        document.getElementById(modalId).style.display = 'none';
    }

    window.onclick = function(event) {
        if (event.target.classList.contains('modal')) {
            event.target.style.display = "none";
        }
    }
</script>

</body>
</html>