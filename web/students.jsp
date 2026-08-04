<%@page import="java.sql.*, utils.DBConnection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // Hubinta Session-ka si loo sugo amniga
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
    <title>Ardayda - School Management</title>
    <!-- Waxaan soo kordhinay FontAwesome si aan Icons u isticmaalno -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        /* CSS Variables - Midabo casri ah oo indhaha soo jiidanaya */
        :root {
            --bg-main: #f0f4f8;
            --card-bg: #ffffff;
            --text-main: #2d3748;
            --text-muted: #718096;
            --border-color: #e2e8f0;
            --primary: #4f46e5;
            --primary-hover: #4338ca;
            --success: #10b981;
            --success-hover: #059669;
            --warning: #f59e0b;
            --warning-hover: #d97706;
            --danger: #ef4444;
            --danger-hover: #dc2626;
            --info: #0ea5e9;
            --badge-bg: #e0e7ff;
            --badge-text: #3730a3;
        }

        .dark-mode {
            --bg-main: #0f172a;
            --card-bg: #1e293b;
            --text-main: #f1f5f9;
            --text-muted: #94a3b8;
            --border-color: #334155;
            --badge-bg: #3730a3;
            --badge-text: #e0e7ff;
        }

        .rtl { direction: rtl; text-align: right; }
        .rtl .student-info-group { flex-direction: row-reverse; }
        .rtl .student-details { text-align: right; }
        .rtl .student-card { flex-direction: row-reverse; }
        .rtl .modal-content { text-align: right; }
        .rtl .header-actions { flex-direction: row-reverse; }

        body { 
            background-color: var(--bg-main); 
            color: var(--text-main); 
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
            margin: 0; 
            padding: 30px 20px;
            transition: all 0.3s ease;
        }

        .container { max-width: 1100px; margin: auto; }

        /* Qaybta Sare: Search iyo Add Student */
        .header-actions {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
            gap: 15px;
            flex-wrap: wrap;
        }

        .search-box { 
            flex: 1;
            min-width: 250px;
            padding: 14px 20px; 
            font-size: 16px;
            border: 2px solid var(--border-color); 
            border-radius: 10px; 
            background: var(--card-bg); 
            color: var(--text-main); 
            transition: all 0.3s ease;
            outline: none;
        }
        .search-box:focus { border-color: var(--primary); box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.2); }

        .btn-add {
            background-color: var(--success);
            color: white;
            padding: 14px 24px;
            font-size: 16px;
            font-weight: 600;
            border: none;
            border-radius: 10px;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            gap: 8px;
            box-shadow: 0 4px 6px -1px rgba(16, 185, 129, 0.2);
        }
        .btn-add:hover { background-color: var(--success-hover); transform: translateY(-2px); }

        /* Qaybta Liiska Ardayda */
        .student-list { display: flex; flex-direction: column; gap: 15px; }
        
        .student-card { 
            display: flex; 
            align-items: center; 
            justify-content: space-between; 
            background: var(--card-bg); 
            padding: 20px 25px; 
            border-radius: 16px; 
            box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05), 0 2px 4px -1px rgba(0,0,0,0.03); 
            border: 1px solid var(--border-color);
            transition: transform 0.2s ease, box-shadow 0.2s ease;
            flex-wrap: wrap;
            gap: 20px;
        }
        .student-card:hover { transform: translateY(-3px); box-shadow: 0 10px 15px -3px rgba(0,0,0,0.1); }

        .student-info-group { display: flex; align-items: center; gap: 20px; flex: 1; min-width: 300px; }
        
        .student-img { 
            width: 70px; height: 70px; 
            border-radius: 50%; 
            object-fit: cover; 
            border: 3px solid var(--primary);
            padding: 2px;
            background: var(--card-bg);
            flex-shrink: 0; 
        }
        
        .student-details h3 { margin: 0 0 8px 0; font-size: 18px; display: flex; align-items: center; gap: 10px; flex-wrap: wrap; }
        .student-details p { margin: 0; font-size: 14px; color: var(--text-muted); display: flex; align-items: center; gap: 6px; }

        .badge-id {
            background-color: var(--badge-bg);
            color: var(--badge-text);
            font-size: 12px;
            padding: 4px 10px;
            border-radius: 20px;
            font-weight: bold;
            letter-spacing: 0.5px;
        }

        .action-buttons { display: flex; gap: 10px; flex-wrap: wrap; }
        
        .btn-action { 
            padding: 10px 16px; 
            color: white; 
            font-size: 14px;
            font-weight: 500;
            border: none; 
            border-radius: 8px; 
            cursor: pointer; 
            transition: all 0.2s ease; 
            display: flex; align-items: center; gap: 6px;
        }
        .btn-details { background-color: var(--primary); }
        .btn-details:hover { background-color: var(--primary-hover); }
        
        .btn-edit { background-color: var(--warning); color: #fff; }
        .btn-edit:hover { background-color: var(--warning-hover); }

        .btn-delete { background-color: var(--danger); }
        .btn-delete:hover { background-color: var(--danger-hover); }

        /* Daaqada Details-ka (Modal Popup) oo la casriyeeyay */
        .modal { 
            display: none; /* Waxay noqon doontaa 'flex' marka la furo si bartamaha ay u timaado */
            position: fixed; z-index: 1000; left: 0; top: 0; 
            width: 100%; height: 100%; 
            background-color: rgba(0,0,0,0.6); 
            backdrop-filter: blur(5px); 
            align-items: center; 
            justify-content: center;
        }
        
        .modal-content { 
            background-color: var(--card-bg); 
            padding: 35px; 
            border-radius: 20px; 
            width: 90%; 
            max-width: 600px; 
            max-height: 85vh; /* Xalka dhibaatada dheeriga ah (Scrollable height) */
            overflow-y: auto; /* Daaqada gudaha ayey ka soconaysaa haddii xogtu badato */
            position: relative;
            box-shadow: 0 25px 50px -12px rgba(0,0,0,0.3);
            animation: scaleUp 0.3s ease-out;
        }
        @keyframes scaleUp { from { transform: scale(0.95); opacity: 0; } to { transform: scale(1); opacity: 1; } }

        /* Custom Scrollbar si bilicdu u qurux badnaato */
        .modal-content::-webkit-scrollbar { width: 8px; }
        .modal-content::-webkit-scrollbar-track { background: var(--bg-main); border-radius: 10px; }
        .modal-content::-webkit-scrollbar-thumb { background: var(--text-muted); border-radius: 10px; }
        .modal-content::-webkit-scrollbar-thumb:hover { background: var(--primary); }

        .close-btn { 
            position: absolute; top: 15px; right: 25px; 
            color: var(--text-muted); font-size: 28px; 
            cursor: pointer; transition: 0.2s; 
            background: var(--bg-main);
            width: 40px; height: 40px;
            display: flex; align-items: center; justify-content: center;
            border-radius: 50%;
        }
        .rtl .close-btn { right: auto; left: 25px; }
        .close-btn:hover { color: var(--danger); background: #fee2e2; }
        
        .modal-header-info { text-align: center; margin-bottom: 25px; padding-top: 10px; }
        .modal-img { width: 110px; height: 110px; border-radius: 50%; object-fit: cover; border: 4px solid var(--primary); padding: 3px; margin-bottom: 15px; }
        .modal-header-info h2 { margin: 0 0 5px 0; color: var(--text-main); font-size: 22px; }
        .modal-header-info .modal-badge { display: inline-block; background: var(--badge-bg); color: var(--badge-text); padding: 6px 18px; border-radius: 20px; font-weight: bold; margin-bottom: 10px; font-size: 14px;}

        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 15px;
            margin-top: 20px;
        }
        .info-item { background: var(--bg-main); padding: 16px; border-radius: 12px; border: 1px solid var(--border-color); }
        .info-item label { display: block; font-size: 11px; color: var(--text-muted); margin-bottom: 6px; text-transform: uppercase; font-weight: 700; letter-spacing: 0.5px; }
        .info-item span { font-size: 15px; color: var(--text-main); font-weight: 600; word-break: break-word; }

        .btn-natiijo {
            display: block;
            width: 100%;
            text-align: center;
            background-color: var(--info);
            color: white;
            padding: 16px;
            margin-top: 25px;
            border-radius: 12px;
            text-decoration: none;
            font-weight: bold;
            font-size: 16px;
            transition: 0.3s;
            border: none;
            cursor: pointer;
            box-shadow: 0 4px 6px -1px rgba(14, 165, 233, 0.2);
        }
        .btn-natiijo:hover { background-color: #0284c7; transform: translateY(-2px); }

        @media (max-width: 768px) {
            .header-actions { flex-direction: column; align-items: stretch; }
            .action-buttons { width: 100%; justify-content: space-between; }
            .btn-action { flex: 1; justify-content: center; }
            .modal-content { padding: 25px 20px; }
        }
    </style>
</head>
<body>

<div class="container">
    <div class="header-actions">
        <input type="text" id="searchInput" class="search-box" data-i18n-placeholder="search_student" placeholder="Raadi magaca ardayga ama ID-ga..." onkeyup="filterStudents()">
        <!-- Halkan waxaa ku xiran add_student.jsp, waa inaad file-kaas abuurtaa si uu u shaqeeyo -->
        <button class="btn-add" onclick="window.location.href='add_student.jsp'">
            <i class="fas fa-user-plus"></i> <span data-i18n="add_student">Ku dar Arday</span>
        </button>
    </div>

    <div class="student-list" id="studentList">
<%
    Connection conn = null;
    Statement stmt = null;
    ResultSet rs = null;
    try {
        conn = DBConnection.getConnection();
        String sql = "SELECT * FROM students ORDER BY CASE class " +
                     "WHEN 'F4' THEN 1 WHEN 'F3' THEN 2 WHEN 'F2' THEN 3 WHEN 'F1' THEN 4 " +
                     "WHEN '9aad' THEN 5 WHEN '8aad' THEN 6 WHEN '7aad' THEN 7 WHEN '6aad' THEN 8 " +
                     "WHEN '5aad' THEN 9 WHEN '4aad' THEN 10 WHEN '3aad' THEN 11 WHEN '2aad' THEN 12 " +
                     "WHEN '1aad' THEN 13 ELSE 14 END ASC";
                     
        stmt = conn.createStatement();
        rs = stmt.executeQuery(sql);
        
        while (rs.next()) {
            String id = rs.getString("id");
            String formattedID = rs.getString("student_id");
            
            String fullName = rs.getString("full_name");
            String studentClass = rs.getString("class");
            String photoName = rs.getString("photo"); 
            String gender = rs.getString("gender");
            String parentPhone = rs.getString("parent_phone");
            String address = rs.getString("address");
            
            String mName = rs.getString("mother_name");
            String mPhone = rs.getString("mother_phone");
            String sPhone = rs.getString("student_phone");
            String email = rs.getString("email");
            
            String imagePath = "";
            if (photoName == null || photoName.trim().isEmpty()) {
                imagePath = "uploads/students/default-avatar.png"; 
            } else {
                imagePath = (!photoName.startsWith("uploads/students/")) ? "uploads/students/" + photoName : photoName;
            }
%>
        <div class="student-card">
            <div class="student-info-group">
                <img src="<%= imagePath %>" alt="Sawir" class="student-img">
                <div class="student-details">
                    <h3 class="student-name">
                        <%= fullName %> 
                        <span class="badge-id" data-search-id="<%= formattedID %>"><%= formattedID %></span>
                    </h3>
                    <p class="student-class"><i class="fas fa-graduation-cap"></i> <span data-i18n="class_label">Fasalka:</span> &nbsp;<strong><%= studentClass %></strong></p>
                </div>
            </div>
            
            <div class="action-buttons">
                <!-- Halkan waxaa ku xiran edit_student.jsp -->
                <button class="btn-action btn-edit" title="Wax ka beddel" onclick="window.location.href='edit_student.jsp?id=<%= id %>'">
                    <i class="fas fa-edit"></i>
                </button>
                <!-- Halkan waxaa ku xiran delete_student.jsp oo hoos JS-ka ugu qoran -->
                <button class="btn-action btn-delete" title="Tir" onclick="deleteStudent('<%= id %>', '<%= fullName.replace("'", "\\'") %>')">
                    <i class="fas fa-trash"></i>
                </button>
                <button class="btn-action btn-details" onclick="openDetails(
                    '<%= id %>', '<%= formattedID %>', '<%= fullName.replace("'", "\\'") %>', '<%= studentClass %>', 
                    '<%= imagePath %>', '<%= gender %>', '<%= parentPhone %>', '<%= address %>',
                    '<%= (mName != null) ? mName.replace("'", "\\'") : "" %>', 
                    '<%= (mPhone != null) ? mPhone : "" %>', 
                    '<%= (sPhone != null) ? sPhone : "" %>', 
                    '<%= (email != null) ? email : "" %>'
                )">
                    <i class="fas fa-id-card"></i> <span data-i18n="btn_details">Details</span>
                </button>
            </div>
        </div>
        <%
                }
            } catch (Exception e) {
                out.println("<div style='padding:20px; background:#fee2e2; color:#991b1b; border-radius:10px;'>Cilad Database: " + e.getMessage() + "</div>");
            } finally {
                // Halkan ayaan ku xiraynaa kheyraadka si nidaamsan
                DBConnection.close(conn, stmt, rs);
            }
        %>
    </div>
</div>

<div id="detailsModal" class="modal">
    <div class="modal-content">
        <span class="close-btn" onclick="closeDetails()">&times;</span>
        
        <div class="modal-header-info">
            <img id="modalImg" src="" alt="Sawirka" class="modal-img">
            <h2 id="modalName">Magaca Ardayga</h2>
            <div class="modal-badge" id="modalID">STD-000</div>
        </div>
        
        <div class="info-grid">
            <div class="info-item">
                <label data-i18n="modal_class">Fasalka</label>
                <span id="modalClass"></span>
            </div>
            <div class="info-item">
                <label data-i18n="modal_gender">Jinsiga</label>
                <span id="modalGender"></span>
            </div>
            <div class="info-item">
                <label data-i18n="modal_phone">Tel Aabaha/Waalidka</label>
                <span id="modalPhone"></span>
            </div>
            <div class="info-item">
                <label data-i18n="modal_address">Cinwaanka</label>
                <span id="modalAddress"></span>
            </div>
            <div class="info-item">
                <label data-i18n="modal_mname">Magaca Hooyada</label>
                <span id="modalMName"></span>
            </div>
            <div class="info-item">
                <label data-i18n="modal_mphone">Tel Hooyada</label>
                <span id="modalMPhone"></span>
            </div>
            <div class="info-item">
                <label data-i18n="modal_sphone">Tel Ardayga</label>
                <span id="modalSPhone"></span>
            </div>
            <div class="info-item">
                <label data-i18n="modal_email">Email-ka Ardayga</label>
                <span id="modalEmail"></span>
            </div>
        </div>

        <button id="btnNatiijo" class="btn-natiijo" onclick="goToExams()">
            <i class="fas fa-file-alt"></i> <span data-i18n="btn_result">Fiiri Natiijada Imtixaanka</span>
        </button>
    </div>
</div>

<script>
    const pageTranslations = {
        en: { search_student: "Search student name or ID...", add_student: "Add Student", class_label: "Class:", btn_details: "Details", modal_class: "Class", modal_gender: "Gender", modal_phone: "Father/Parent Phone", modal_address: "Address", modal_mname: "Mother's Name", modal_mphone: "Mother's Phone", modal_sphone: "Student Phone", modal_email: "Email Address", btn_result: "View Examination Results", not_registered: "N/A" },
        so: { search_student: "Raadi magaca ardayga ama ID...", add_student: "Ku dar Arday", class_label: "Fasalka:", btn_details: "Faahfaahin", modal_class: "Fasalka", modal_gender: "Jinsiga", modal_phone: "Tel Waalidka", modal_address: "Cinwaanka", modal_mname: "Magaca Hooyada", modal_mphone: "Tel Hooyada", modal_sphone: "Tel Ardayga", modal_email: "Email-ka", btn_result: "Fiiri Natiijada Imtixaanka", not_registered: "Lama diiwaangelin" },
        ar: { search_student: "البحث عن اسم الطالب أو المعرف...", add_student: "إضافة طالب", class_label: "الفصل:", btn_details: "التفاصيل", modal_class: "الفصل", modal_gender: "الجنس", modal_phone: "هاتف ولي الأمر", modal_address: "العنوان", modal_mname: "اسم الأم", modal_mphone: "هاتف الأم", modal_sphone: "هاتف الطالب", modal_email: "البريد الإلكتروني", btn_result: "عرض نتائج الامتحانات", not_registered: "غير متوفر" }
    };

    const currentTheme = localStorage.getItem('app_theme') || 'light';
    const currentLang = localStorage.getItem('app_language') || 'en';
    let selectedStudentId = ""; 

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

    function filterStudents() {
        let input = document.getElementById('searchInput').value.toLowerCase();
        let cards = document.getElementsByClassName('student-card');
        
        for (let i = 0; i < cards.length; i++) {
            let name = cards[i].getElementsByClassName('student-name')[0].innerText.toLowerCase();
            let sClass = cards[i].getElementsByClassName('student-class')[0].innerText.toLowerCase();
            let stdId = cards[i].querySelector('.badge-id').innerText.toLowerCase();
            
            if (name.includes(input) || sClass.includes(input) || stdId.includes(input)) {
                cards[i].style.display = "flex";
            } else {
                cards[i].style.display = "none";
            }
        }
    }

    function openDetails(dbId, formatId, name, sClass, img, gender, phone, address, mName, mPhone, sPhone, email) {
        const notRegText = pageTranslations[currentLang].not_registered;
        selectedStudentId = dbId; 

        document.getElementById("modalImg").src = img;
        document.getElementById("modalName").innerText = name;
        document.getElementById("modalID").innerText = formatId;
        
        document.getElementById("modalClass").innerText = sClass;
        document.getElementById("modalGender").innerText = (gender !== 'null' && gender !== '') ? gender : notRegText;
        document.getElementById("modalPhone").innerText = (phone !== 'null' && phone !== '') ? phone : notRegText;
        document.getElementById("modalAddress").innerText = (address !== 'null' && address !== '') ? address : notRegText;
        
        document.getElementById("modalMName").innerText = (mName !== 'null' && mName !== '') ? mName : notRegText;
        document.getElementById("modalMPhone").innerText = (mPhone !== 'null' && mPhone !== '') ? mPhone : notRegText;
        document.getElementById("modalSPhone").innerText = (sPhone !== 'null' && sPhone !== '') ? sPhone : notRegText;
        document.getElementById("modalEmail").innerText = (email !== 'null' && email !== '') ? email : notRegText;
        
        // Halkan waxaan ka dhignay 'flex' beddelka 'block' si bartamaha ay u timaado
        document.getElementById("detailsModal").style.display = "flex";
    }

    function goToExams() {
        if(selectedStudentId !== "") {
            window.location.href = "examinations.jsp?student_id=" + selectedStudentId;
        }
    }

    function deleteStudent(id, name) {
        let msg = (currentLang === 'so') ? "Ma hubtaa inaad tirtirto ardaygan: " : 
                  (currentLang === 'ar') ? "هل أنت متأكد من حذف هذا الطالب: " : 
                  "Are you sure you want to delete this student: ";
                  
        if (confirm(msg + name + "?")) {
            window.location.href = "delete_student.jsp?id=" + id;
        }
    }

    function closeDetails() { document.getElementById("detailsModal").style.display = "none"; }
    window.onclick = function(event) {
        let modal = document.getElementById("detailsModal");
        if (event.target == modal) modal.style.display = "none";
    }
</script>

</body>
</html>