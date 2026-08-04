<%@page import="java.sql.*"%>
<%@page import="utils.DBConnection"%>
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
    <title>Teacher - School Management</title>
    <!-- FontAwesome Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        /* CSS Variables - Qaan-gaar ah oo la mid ah student.jsp */
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
            --badge-active-bg: #d1fae5;
            --badge-active-text: #065f46;
            --badge-inactive-bg: #fee2e2;
            --badge-inactive-text: #991b1b;
        }

        .dark-mode {
            --bg-main: #0f172a;
            --card-bg: #1e293b;
            --text-main: #f1f5f9;
            --text-muted: #94a3b8;
            --border-color: #334155;
            --badge-bg: #3730a3;
            --badge-text: #e0e7ff;
            --badge-active-bg: #064e3b;
            --badge-active-text: #a7f3d0;
            --badge-inactive-bg: #7f1d1d;
            --badge-inactive-text: #fecaca;
        }

        .rtl { direction: rtl; text-align: right; }
        .rtl .teacher-info-group { flex-direction: row-reverse; }
        .rtl .teacher-details { text-align: right; }
        .rtl .teacher-card { flex-direction: row-reverse; }
        .rtl .modal-content { text-align: right; }
        .rtl .header-actions { flex-direction: row-reverse; }
        .rtl .info-item { border-left: none; border-right: 4px solid var(--primary); }
        .rtl .section-title::after { left: auto; right: 0; }

        body { 
            background-color: var(--bg-main); 
            color: var(--text-main); 
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
            margin: 0; 
            padding: 30px 20px;
            transition: all 0.3s ease;
        }

        .container { max-width: 1100px; margin: auto; }

        /* Qaybta Sare: Search iyo Add Teacher */
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
        .btn-add:hover { background-color: var(--success-hover); transform: translateY(-2px); box-shadow: 0 6px 10px -1px rgba(16, 185, 129, 0.3); }

        /* Qaybta Liiska Macalimiinta */
        .teacher-list { display: flex; flex-direction: column; gap: 15px; }
        
        .teacher-card { 
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
        .teacher-card:hover { transform: translateY(-3px); box-shadow: 0 10px 15px -3px rgba(0,0,0,0.1); }

        .teacher-info-group { display: flex; align-items: center; gap: 20px; flex: 1; min-width: 300px; }
        
        .teacher-img { 
            width: 70px; height: 70px; 
            border-radius: 50%; 
            object-fit: cover; 
            border: 3px solid var(--primary);
            padding: 2px;
            background: var(--card-bg);
            flex-shrink: 0; 
        }
        
        .teacher-details h3 { margin: 0 0 6px 0; font-size: 18px; display: flex; align-items: center; gap: 10px; flex-wrap: wrap; }
        .teacher-details p { margin: 3px 0; font-size: 14px; color: var(--text-muted); display: flex; align-items: center; gap: 6px; }

        .badge-id {
            background-color: var(--badge-bg);
            color: var(--badge-text);
            font-size: 12px;
            padding: 4px 10px;
            border-radius: 20px;
            font-weight: bold;
            letter-spacing: 0.5px;
        }

        .badge-status {
            font-size: 11px;
            padding: 3px 8px;
            border-radius: 12px;
            font-weight: 700;
            text-transform: uppercase;
        }
        .status-active { background-color: var(--badge-active-bg); color: var(--badge-active-text); }
        .status-inactive { background-color: var(--badge-inactive-bg); color: var(--badge-inactive-text); }

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
        .btn-details:hover { background-color: var(--primary-hover); transform: translateY(-2px); }
        
        .btn-edit { background-color: var(--warning); color: #fff; }
        .btn-edit:hover { background-color: var(--warning-hover); transform: translateY(-2px); }

        .btn-delete { background-color: var(--danger); }
        .btn-delete:hover { background-color: var(--danger-hover); transform: translateY(-2px); }

        /* Modal Popup - QURXINTA CUSUB */
        .modal { 
            display: none; 
            position: fixed; z-index: 1000; left: 0; top: 0; 
            width: 100%; height: 100%; 
            background-color: rgba(0,0,0,0.6); 
            backdrop-filter: blur(6px); 
            align-items: center; 
            justify-content: center;
            padding: 20px;
            box-sizing: border-box;
        }
        
        .modal-content { 
            background-color: var(--card-bg); 
            padding: 0 0 35px 0; 
            border-radius: 20px; 
            width: 100%; 
            max-width: 750px; 
            max-height: 90vh; 
            overflow-y: auto; 
            position: relative;
            box-shadow: 0 25px 50px -12px rgba(0,0,0,0.5);
            animation: scaleUp 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
            border: 1px solid var(--border-color);
        }
        @keyframes scaleUp { from { transform: scale(0.9); opacity: 0; } to { transform: scale(1); opacity: 1; } }

        .modal-content::-webkit-scrollbar { width: 8px; }
        .modal-content::-webkit-scrollbar-track { background: var(--bg-main); border-radius: 10px; margin: 10px; }
        .modal-content::-webkit-scrollbar-thumb { background: var(--text-muted); border-radius: 10px; }
        .modal-content::-webkit-scrollbar-thumb:hover { background: var(--primary); }

        .close-btn { 
            position: absolute; top: 15px; right: 20px; 
            color: var(--text-muted); font-size: 24px; 
            cursor: pointer; transition: 0.2s; 
            background: rgba(255,255,255,0.8);
            width: 40px; height: 40px;
            display: flex; align-items: center; justify-content: center;
            border-radius: 50%;
            z-index: 10;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }
        .rtl .close-btn { right: auto; left: 20px; }
        .close-btn:hover { color: var(--danger); background: #fee2e2; transform: rotate(90deg); }
        
        /* Modal Header Styling Cusub */
        .modal-header-info { 
            text-align: center; 
            padding: 40px 20px 25px 20px; 
            background: linear-gradient(135deg, var(--badge-bg) 0%, var(--bg-main) 100%);
            border-bottom: 1px solid var(--border-color);
            border-radius: 20px 20px 0 0;
            margin-bottom: 30px;
            position: relative;
        }
        .modal-img { 
            width: 130px; height: 130px; 
            border-radius: 50%; 
            object-fit: cover; 
            border: 5px solid var(--card-bg); 
            box-shadow: 0 8px 15px rgba(0,0,0,0.1);
            background-color: var(--card-bg);
            margin-bottom: 15px; 
        }
        .modal-header-info h2 { margin: 0 0 8px 0; color: var(--text-main); font-size: 24px; font-weight: 700; }
        .modal-header-info .modal-badge { display: inline-block; background: var(--primary); color: white; padding: 6px 18px; border-radius: 20px; font-weight: bold; margin-bottom: 10px; font-size: 14px; box-shadow: 0 4px 6px rgba(79, 70, 229, 0.2);}

        /* Qaybta Xogta (Sections) */
        .modal-body-content { padding: 0 35px; }

        .section-title {
            font-size: 15px;
            font-weight: 700;
            color: var(--primary);
            margin: 25px 0 15px 0;
            padding-bottom: 8px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            display: flex;
            align-items: center;
            gap: 10px;
            position: relative;
        }
        .section-title::after {
            content: '';
            position: absolute;
            left: 0; bottom: 0;
            height: 3px; width: 60px;
            background: var(--primary);
            border-radius: 3px;
        }
        .section-title i { font-size: 18px; }

        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 15px;
        }
        
        /* Stylings for Info Items (Cards yaryar) */
        .info-item { 
            background: var(--card-bg); 
            padding: 15px; 
            border-radius: 12px; 
            border: 1px solid var(--border-color); 
            border-left: 4px solid var(--primary);
            box-shadow: 0 2px 4px rgba(0,0,0,0.02);
            transition: transform 0.2s, box-shadow 0.2s;
        }
        .info-item:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 10px rgba(0,0,0,0.08);
        }
        .info-item label { 
            display: flex; 
            align-items: center;
            gap: 8px;
            font-size: 11px; 
            color: var(--text-muted); 
            margin-bottom: 8px; 
            text-transform: uppercase; 
            font-weight: 700; 
            letter-spacing: 0.5px; 
        }
        .info-item label i { color: var(--primary); font-size: 13px; }
        .info-item span { font-size: 15px; color: var(--text-main); font-weight: 600; word-break: break-word; display: block;}

        .full-width { grid-column: 1 / -1; }

        @media (max-width: 768px) {
            .header-actions { flex-direction: column; align-items: stretch; }
            .action-buttons { width: 100%; justify-content: space-between; }
            .btn-action { flex: 1; justify-content: center; }
            .modal-content { padding: 0 0 25px 0; }
            .modal-body-content { padding: 0 20px; }
            .info-grid { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>

<div class="container">
    <div class="header-actions">
        <input type="text" id="searchInput" class="search-box" data-i18n-placeholder="search_teacher" placeholder="Raadi magaca macalinka, email ama maaddada..." onkeyup="filterTeachers()">
        <!-- Link-ga lagu darayo macalin cusub -->
        <button class="btn-add" onclick="window.location.href='add_teacher.jsp'">
            <i class="fas fa-user-plus"></i> <span data-i18n="add_teacher">Ku dar Macalin</span>
        </button>
    </div>

    <div class="teacher-list" id="teacherList">
<%
    Connection conn = null;
    Statement stmt = null;
    ResultSet rs = null;

    try {
        // Halkan waxa uu isticmaalayaa Connection Pool-kii aad samaysay
        conn = DBConnection.getConnection();
        
        if(conn != null) {
            String sql = "SELECT t.id AS teacher_id, t.user_id, u.full_name, u.username, u.email, u.password, u.recovery_pin, u.status, " +
                         "t.gender, t.dob, t.phone, t.alt_phone, t.address, " +
                         "t.qualification, t.experience_years, t.previous_workplaces, " +
                         "t.guarantor_name, t.guarantor_phone, t.guarantor_relation, t.guarantor_id_image, t.photo, " +
                         "t.hire_date, t.base_salary, " +
                         "GROUP_CONCAT(CONCAT(c.class_name, ' - ', s.subject_name) SEPARATOR ', ') AS assigned_classes " +
                         "FROM teachers t " +
                         "JOIN users u ON t.user_id = u.id " +
                         "LEFT JOIN teacher_allocations ta ON t.id = ta.teacher_id " +
                         "LEFT JOIN class_subjects cs ON ta.class_subject_id = cs.id " +
                         "LEFT JOIN class c ON cs.class_id = c.id " +
                         "LEFT JOIN subjects s ON cs.subject_id = s.id " +
                         "GROUP BY t.id, u.id " +
                         "ORDER BY t.id DESC";
                         
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);
            
            while (rs.next()) {
                String teacherId = rs.getString("teacher_id");
                String userId = rs.getString("user_id");
                String formattedID = "TCH-" + String.format("%03d", Integer.parseInt(teacherId));
                
                String fullName = rs.getString("full_name");
                String username = rs.getString("username");
                String email = rs.getString("email");
                String password = rs.getString("password");
                String recoveryPin = rs.getString("recovery_pin");
                String status = rs.getString("status");
                String gender = rs.getString("gender");
                String dob = rs.getString("dob");
                String phone = rs.getString("phone");
                String altPhone = rs.getString("alt_phone");
                String address = rs.getString("address");
                
                String qualification = rs.getString("qualification");
                int experienceYears = rs.getInt("experience_years");
                String previousWorkplaces = rs.getString("previous_workplaces");
                
                String guarantorName = rs.getString("guarantor_name");
                String guarantorPhone = rs.getString("guarantor_phone");
                String guarantorRelation = rs.getString("guarantor_relation");
                String guarantorIdImage = rs.getString("guarantor_id_image");
                
                String photoName = rs.getString("photo");
                String hireDate = rs.getString("hire_date");
                String baseSalary = rs.getString("base_salary");
                
                String assignedClasses = rs.getString("assigned_classes");
                if (assignedClasses == null || assignedClasses.trim().isEmpty()) {
                    assignedClasses = "Wali fasal ama maado lagu ma xirin";
                }
                
                String imagePath = "";
                if (photoName == null || photoName.trim().isEmpty()) {
                    imagePath = "uploads/teacher/default-avatar.png"; 
                } else {
                    imagePath = (!photoName.startsWith("uploads/teacher/")) ? "uploads/teacher/" + photoName : photoName;
                }
                
                String statusClass = ("active".equalsIgnoreCase(status)) ? "status-active" : "status-inactive";
%>
        <div class="teacher-card">
            <div class="teacher-info-group">
                <img src="<%= imagePath %>" alt="Sawir" class="teacher-img">
                <div class="teacher-details">
                    <h3 class="teacher-name">
                        <%= fullName %> 
                        <span class="badge-id"><%= formattedID %></span>
                        <span class="badge-status <%= statusClass %>"><%= status %></span>
                    </h3>
                    <p class="teacher-email"><i class="fas fa-envelope"></i> <%= email %></p>
                    <p class="teacher-classes"><i class="fas fa-chalkboard-teacher"></i> <span data-i18n="subjects_taught">Fasalada & Maadooyinka:</span> &nbsp;<strong><%= assignedClasses %></strong></p>
                </div>
            </div>
            
            <div class="action-buttons">
                <!-- Wax ka beddelka macalinka -->
                <button class="btn-action btn-edit" title="Wax ka beddel" onclick="window.location.href='edit_teacher.jsp?id=<%= teacherId %>'">
                    <i class="fas fa-edit"></i>
                </button>
                <!-- Tirtirista Macalinka -->
                <button class="btn-action btn-delete" title="Tir" onclick="deleteTeacher('<%= userId %>', '<%= fullName.replace("'", "\\'") %>')">
                    <i class="fas fa-trash"></i>
                </button>
                <button class="btn-action btn-details" onclick="openDetails(
                    '<%= teacherId %>', '<%= formattedID %>', '<%= fullName.replace("'", "\\'") %>', '<%= username.replace("'", "\\'") %>', 
                    '<%= email.replace("'", "\\'") %>', '<%= password.replace("'", "\\'") %>', '<%= (recoveryPin != null) ? recoveryPin : "" %>', 
                    '<%= status %>', '<%= imagePath %>', '<%= gender %>', '<%= (dob != null) ? dob : "" %>', 
                    '<%= phone %>', '<%= (altPhone != null) ? altPhone : "" %>', '<%= address.replace("'", "\\'") %>',
                    '<%= qualification.replace("'", "\\'") %>', '<%= experienceYears %>', 
                    '<%= (previousWorkplaces != null) ? previousWorkplaces.replace("'", "\\'") : "" %>',
                    '<%= guarantorName.replace("'", "\\'") %>', '<%= guarantorPhone %>', '<%= guarantorRelation.replace("'", "\\'") %>', '<%= (guarantorIdImage != null) ? guarantorIdImage.replace("'", "\\'") : "" %>',
                    '<%= (hireDate != null) ? hireDate : "" %>', '<%= (baseSalary != null) ? baseSalary : "" %>',
                    '<%= assignedClasses.replace("'", "\\'") %>'
                )">
                    <i class="fas fa-id-card"></i> <span data-i18n="btn_details">Details</span>
                </button>
            </div>
        </div>
<%
            } // Dhamaadka While Loop
        } else {
            out.println("<div style='padding:20px; background:#fee2e2; color:#991b1b; border-radius:10px;'>Cilad Database: Ma jiro Connection bannaan xilligan (Pool was full/unavailable)</div>");
        }
    } catch (Exception e) {
        out.println("<div style='padding:20px; background:#fee2e2; color:#991b1b; border-radius:10px;'>Cilad Database: " + e.getMessage() + "</div>");
    } finally {
        // Qaybtani waxay hubinaysaa in Connection-ka dib loogu celiyo Pool-ka si qof kale u isticmaalo.
        DBConnection.close(conn, stmt, rs);
    }
%>
    </div>
</div>

<!-- Modal Dialog - Details-ka Macalinka -->
<div id="detailsModal" class="modal">
    <div class="modal-content">
        <span class="close-btn" onclick="closeDetails()">&times;</span>
        
        <div class="modal-header-info">
            <img id="modalImg" src="" alt="Sawirka" class="modal-img">
            <h2 id="modalName">Magaca Macalinka</h2>
            <div class="modal-badge" id="modalID">TCH-000</div>
            <div><span id="modalStatus" class="badge-status">Active</span></div>
        </div>
        
        <div class="modal-body-content">
            <!-- Qaybta Xogta System Login-ka -->
            <div class="section-title"><i class="fas fa-desktop"></i> <span data-i18n="sec_system_login">Xogta Login-ka (Users Table)</span></div>
            <div class="info-grid">
                <div class="info-item">
                    <label><i class="fas fa-user-circle"></i> <span data-i18n="modal_username">Username</span></label>
                    <span id="modalUsername"></span>
                </div>
                <div class="info-item">
                    <label><i class="fas fa-key"></i> <span data-i18n="modal_password">Password</span></label>
                    <span id="modalPassword"></span>
                </div>
                <div class="info-item">
                    <label><i class="fas fa-unlock-alt"></i> <span data-i18n="modal_recovery_pin">Recovery PIN</span></label>
                    <span id="modalRecoveryPin"></span>
                </div>
                <div class="info-item">
                    <label><i class="fas fa-envelope"></i> <span data-i18n="modal_email">Email Address</span></label>
                    <span id="modalEmail"></span>
                </div>
            </div>

            <!-- Xogta Shaqsiga ah -->
            <div class="section-title"><i class="fas fa-user"></i> <span data-i18n="sec_personal">Xogta Shaqsiga ah</span></div>
            <div class="info-grid">
                <div class="info-item">
                    <label><i class="fas fa-phone-alt"></i> <span data-i18n="modal_phone">Tel-ka Macalinka</span></label>
                    <span id="modalPhone"></span>
                </div>
                <div class="info-item">
                    <label><i class="fas fa-mobile-alt"></i> <span data-i18n="modal_alt_phone">Tel Labaad</span></label>
                    <span id="modalAltPhone"></span>
                </div>
                <div class="info-item">
                    <label><i class="fas fa-venus-mars"></i> <span data-i18n="modal_gender">Jinsiga</span></label>
                    <span id="modalGender"></span>
                </div>
                <div class="info-item">
                    <label><i class="fas fa-calendar-alt"></i> <span data-i18n="modal_dob">Taariikhda Dhalashada</span></label>
                    <span id="modalDOB"></span>
                </div>
                <div class="info-item full-width">
                    <label><i class="fas fa-map-marker-alt"></i> <span data-i18n="modal_address">Cinwaanka</span></label>
                    <span id="modalAddress"></span>
                </div>
            </div>

            <!-- Xirfadda & Khibradda -->
            <div class="section-title"><i class="fas fa-graduation-cap"></i> <span data-i18n="sec_professional">Xirfadda & Khibradda</span></div>
            <div class="info-grid">
                <div class="info-item">
                    <label><i class="fas fa-certificate"></i> <span data-i18n="modal_qualification">Shahaadada/Aqoonta</span></label>
                    <span id="modalQualification"></span>
                </div>
                <div class="info-item">
                    <label><i class="fas fa-briefcase"></i> <span data-i18n="modal_experience">Khibradda (Sano)</span></label>
                    <span id="modalExperience"></span>
                </div>
                <div class="info-item full-width">
                    <label><i class="fas fa-building"></i> <span data-i18n="modal_workplaces">Meelihii Soo Shaqeeyay</span></label>
                    <span id="modalWorkplaces"></span>
                </div>
                <div class="info-item full-width" style="border-left-color: var(--warning);">
                    <label><i class="fas fa-chalkboard-teacher"></i> <span data-i18n="modal_assigned">Fasalada iyo Maadooyinka Uu Dhigo</span></label>
                    <span id="modalAssigned" style="color: var(--primary); font-size: 16px;"></span>
                </div>
            </div>

            <!-- Xogta Damiinka -->
            <div class="section-title"><i class="fas fa-user-shield"></i> <span data-i18n="sec_guarantor">Xogta Damiinka (Guarantor)</span></div>
            <div class="info-grid">
                <div class="info-item">
                    <label><i class="fas fa-user-tie"></i> <span data-i18n="modal_guarantor_name">Magaca Damiinka</span></label>
                    <span id="modalGName"></span>
                </div>
                <div class="info-item">
                    <label><i class="fas fa-phone"></i> <span data-i18n="modal_guarantor_phone">Tel-ka Damiinka</span></label>
                    <span id="modalGPhone"></span>
                </div>
                <div class="info-item">
                    <label><i class="fas fa-people-arrows"></i> <span data-i18n="modal_guarantor_relation">Xiriirka Damiinka</span></label>
                    <span id="modalGRelation"></span>
                </div>
                <div class="info-item full-width">
                    <label><i class="fas fa-id-card"></i> <span data-i18n="modal_guarantor_id_image">Sawirka Aqoonsiga Damiinka</span></label>
                    <div id="modalGIdImage" style="margin-top: 10px;"></div>
                </div>
            </div>

            <!-- Maamulka Iskuulka -->
            <div class="section-title"><i class="fas fa-file-invoice-dollar"></i> <span data-i18n="sec_admin">Maamulka Iskuulka</span></div>
            <div class="info-grid">
                <div class="info-item">
                    <label><i class="fas fa-calendar-check"></i> <span data-i18n="modal_hire_date">Taariikhda Shaqaalaysiinta</span></label>
                    <span id="modalHireDate"></span>
                </div>
                <div class="info-item" style="border-left-color: var(--success);">
                    <label><i class="fas fa-money-bill-wave"></i> <span data-i18n="modal_salary">Mushaarka Asalka Ah</span></label>
                    <span id="modalSalary" style="color: var(--success); font-size: 18px;"></span>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    const pageTranslations = {
        en: { 
            search_teacher: "Search teacher name, email or subject...", 
            add_teacher: "Add Teacher", 
            subjects_taught: "Classes & Subjects:", 
            btn_details: "Details", 
            sec_system_login: "System Login Details (Users Table)",
            sec_personal: "Personal Information",
            sec_professional: "Professional & Experience",
            sec_guarantor: "Guarantor Information",
            sec_admin: "Administrative Details",
            modal_username: "Username",
            modal_password: "Password",
            modal_recovery_pin: "Recovery PIN",
            modal_email: "Email Address",
            modal_phone: "Phone Number", 
            modal_alt_phone: "Alt Phone", 
            modal_gender: "Gender", 
            modal_dob: "Date of Birth",
            modal_address: "Address", 
            modal_qualification: "Qualification", 
            modal_experience: "Experience (Years)", 
            modal_workplaces: "Previous Workplaces", 
            modal_assigned: "Assigned Subjects & Classes",
            modal_guarantor_name: "Guarantor Name", 
            modal_guarantor_phone: "Guarantor Phone", 
            modal_guarantor_relation: "Relation",
            modal_guarantor_id_image: "Guarantor ID Image", 
            modal_hire_date: "Hire Date", 
            modal_salary: "Base Salary ($)",
            not_registered: "N/A" 
        },
        so: { 
            search_teacher: "Raadi magaca macalinka, email ama maaddada...", 
            add_teacher: "Ku dar Macalin", 
            subjects_taught: "Fasalada & Maadooyinka:", 
            btn_details: "Faahfaahin", 
            sec_system_login: "Xogta Login-ka System-ka (Users Table)",
            sec_personal: "Xogta Shaqsiga ah",
            sec_professional: "Xirfadda & Khibradda",
            sec_guarantor: "Xogta Damiinka (Guarantor)",
            sec_admin: "Maamulka Iskuulka",
            modal_username: "Magaca Isticmaalaha (Username)",
            modal_password: "Furaha Sireed (Password)",
            modal_recovery_pin: "Pin-ka Soo Celinta (Recovery PIN)",
            modal_email: "Email-ka",
            modal_phone: "Tel-ka Macalinka", 
            modal_alt_phone: "Tel Labaad", 
            modal_gender: "Jinsiga", 
            modal_dob: "Taariikhda Dhalashada",
            modal_address: "Cinwaanka", 
            modal_qualification: "Shahaadada/Aqoonta", 
            modal_experience: "Khibradda (Sano)", 
            modal_workplaces: "Meelihii Soo Shaqeeyay", 
            modal_assigned: "Fasalada iyo Maadooyinka Uu Dhigo",
            modal_guarantor_name: "Magaca Damiinka", 
            modal_guarantor_phone: "Tel-ka Damiinka", 
            modal_guarantor_relation: "Xiriirka Damiinka",
            modal_guarantor_id_image: "Sawirka Aqoonsiga Damiinka",
            modal_hire_date: "Taariikhda Shaqaalaysiinta", 
            modal_salary: "Mushaarka Asalka Ah ($)",
            not_registered: "Lama diiwaangelin" 
        },
        ar: { 
            search_teacher: "البحث عن اسم المعلم، البريد الإلكتروني أو المادة...", 
            add_teacher: "إضافة معلم", 
            subjects_taught: "الفصول والمواد:", 
            btn_details: "التفاصيل", 
            sec_system_login: "معلومات تسجيل الدخول (جدول users)",
            sec_personal: "المعلومات الشخصية",
            sec_professional: "المؤهلات والخبرة",
            sec_guarantor: "معلومات الضامن",
            sec_admin: "التفاصيل الإدارية",
            modal_username: "اسم المستخدم",
            modal_password: "كلمة المرور",
            modal_recovery_pin: "رمز الاسترداد",
            modal_email: "البريد الإلكتروني",
            modal_phone: "رقم الهاتف", 
            modal_alt_phone: "هاتف إضافي", 
            modal_gender: "الجنس", 
            modal_dob: "تاريخ الميلاد",
            modal_address: "العنوان", 
            modal_qualification: "المؤهل العلمي", 
            modal_experience: "الخبرة (سنوات)", 
            modal_workplaces: "أماكن العمل السابقة", 
            modal_assigned: "الفصول والمواد الموكلة",
            modal_guarantor_name: "اسم الضامن", 
            modal_guarantor_phone: "هاتف الضامن", 
            modal_guarantor_relation: "صلة القرابة",
            modal_guarantor_id_image: "صورة هوية الضامن",
            modal_hire_date: "تاريخ التعيين", 
            modal_salary: "الراتب الأساسي ($)",
            not_registered: "غير متوفر" 
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

    function filterTeachers() {
        let input = document.getElementById('searchInput').value.toLowerCase();
        let cards = document.getElementsByClassName('teacher-card');
        
        for (let i = 0; i < cards.length; i++) {
            let name = cards[i].getElementsByClassName('teacher-name')[0].innerText.toLowerCase();
            let email = cards[i].getElementsByClassName('teacher-email')[0].innerText.toLowerCase();
            let tClasses = cards[i].getElementsByClassName('teacher-classes')[0].innerText.toLowerCase();
            let tId = cards[i].querySelector('.badge-id').innerText.toLowerCase();
            
            if (name.includes(input) || email.includes(input) || tClasses.includes(input) || tId.includes(input)) {
                cards[i].style.display = "flex";
            } else {
                cards[i].style.display = "none";
            }
        }
    }

    function deleteTeacher(userId, fullName) {
        // 1. Waxaan samaynaynaa fariin xaqiijin ah oo magaca macalinka wadata
        var fariin = "Ma hubtaa inaad rabto inaad tirtirto macalin: " + fullName + "?\n\nFadlan ogsoonow xogtani dib usoo noqon mayso!";
        
        // 2. Wuxuu soo saarayaa Popup uu user-ka ku dooranayo OK ama Cancel
        var isConfirmed = confirm(fariin);
        
        // 3. Haddii uu user-ku 'OK' taabto, waxaan u diraynaa Servlet-ka
        if (isConfirmed) {
            // Tani waxay wacaysaa Servlet-kii aan horay u samaynay, waxayna u dhiibaysaa ID-ga
            window.location.href = "DeleteTeacherServlet?id=" + userId;
        }
    }

    function closeDetails() {
        document.getElementById("detailsModal").style.display = "none";
    }

    // Modal-ka marka banaanka laga gujiyo inuu xirmo
    window.onclick = function(event) {
        let modal = document.getElementById("detailsModal");
        if (event.target == modal) {
            closeDetails();
        }
    }

    function openDetails(tId, formatId, name, username, email, password, recoveryPin, status, img, gender, dob, phone, altPhone, address, qual, exp, workplaces, gName, gPhone, gRel, gIdImage, hireDate, salary, assigned) {
        const notRegText = `<span style="color: var(--text-muted); font-style: italic;">${pageTranslations[currentLang].not_registered}</span>`;

        document.getElementById("modalImg").src = img;
        document.getElementById("modalName").innerText = name;
        document.getElementById("modalID").innerText = formatId;
        
        const statusEl = document.getElementById("modalStatus");
        statusEl.innerText = status;
        statusEl.className = "badge-status " + ((status.toLowerCase() === 'active') ? 'status-active' : 'status-inactive');
        
        // Xogta Users Table
        document.getElementById("modalUsername").innerHTML = (username !== 'null' && username !== '') ? username : notRegText;
        document.getElementById("modalPassword").innerHTML = (password !== 'null' && password !== '') ? "********" : notRegText;
        document.getElementById("modalRecoveryPin").innerHTML = (recoveryPin !== 'null' && recoveryPin !== '') ? recoveryPin : notRegText;
        document.getElementById("modalEmail").innerHTML = (email !== 'null' && email !== '') ? email : notRegText;

        // Xogta Shaqsiga ah
        document.getElementById("modalPhone").innerHTML = (phone !== 'null' && phone !== '') ? phone : notRegText;
        document.getElementById("modalAltPhone").innerHTML = (altPhone !== 'null' && altPhone !== '') ? altPhone : notRegText;
        document.getElementById("modalGender").innerHTML = (gender !== 'null' && gender !== '') ? gender : notRegText;
        document.getElementById("modalDOB").innerHTML = (dob !== 'null' && dob !== '') ? dob : notRegText;
        document.getElementById("modalAddress").innerHTML = (address !== 'null' && address !== '') ? address : notRegText;
        
        // Xirfadda & Khibradda
        document.getElementById("modalQualification").innerHTML = (qual !== 'null' && qual !== '') ? qual : notRegText;
        document.getElementById("modalExperience").innerText = exp + " Sano / Years";
        document.getElementById("modalWorkplaces").innerHTML = (workplaces !== 'null' && workplaces !== '') ? workplaces : notRegText;
        document.getElementById("modalAssigned").innerHTML = (assigned !== 'null' && assigned !== '') ? assigned : notRegText;
        
        // Xogta Damiinka
        document.getElementById("modalGName").innerHTML = (gName !== 'null' && gName !== '') ? gName : notRegText;
        document.getElementById("modalGPhone").innerHTML = (gPhone !== 'null' && gPhone !== '') ? gPhone : notRegText;
        document.getElementById("modalGRelation").innerHTML = (gRel !== 'null' && gRel !== '') ? gRel : notRegText;
        
        // Sawirka Damiinka
        if (gIdImage !== 'null' && gIdImage !== '') {
            let gImgPath = (!gIdImage.startsWith("uploads/teacher/")) ? "uploads/teacher/" + gIdImage : gIdImage;
            document.getElementById("modalGIdImage").innerHTML = '<img src="' + gImgPath + '" alt="Sawirka Damiinka" style="max-width: 100%; max-height: 200px; border-radius: 8px; border: 2px solid var(--border-color); box-shadow: 0 4px 6px rgba(0,0,0,0.1); display: block; object-fit: cover;">';
        } else {
            document.getElementById("modalGIdImage").innerHTML = notRegText;
        }

        // Maamulka Iskuulka
        document.getElementById("modalHireDate").innerHTML = (hireDate !== 'null' && hireDate !== '') ? hireDate : notRegText;
        document.getElementById("modalSalary").innerHTML = (salary !== 'null' && salary !== '') ? "$" + salary : notRegText;

        document.getElementById("detailsModal").style.display = "flex";
    }
</script>
</body>
</html>