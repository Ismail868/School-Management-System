<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %> 
<div class="sidebar">
        <div class="logo">
            <i class="fas fa-layer-group"></i> 
            <div>
                <span data-i18n="school_title" style="font-size:18px; font-weight:700; color:#fff;">SCHOOL</span>
                <span data-i18n="school_sub">MANAGEMENT SYSTEM</span>
            </div>
        </div>
        
        <div class="menu-items">
            <a href="dashboard.jsp" class="menu-item active"><i class="fas fa-desktop"></i> <span data-i18n="menu_dashboard">Dashboard</span></a>
            <a href="students.jsp" class="menu-item"><i class="fas fa-user-graduate"></i> <span data-i18n="menu_students">Students</span></a>
            <a href="teachers.jsp" class="menu-item"><i class="fas fa-chalkboard-teacher"></i> <span data-i18n="menu_teachers">Teachers</span></a>
            <a href="classes_subjects.jsp" class="menu-item"><i class="fas fa-door-open"></i> <span data-i18n="menu_classes">Classes & Subjects</span></a>
            <a href="payments.jsp" class="menu-item"><i class="fas fa-money-check-alt"></i> <span data-i18n="menu_payments">Payments</span></a>
            <a href="attendance.jsp" class="menu-item"><i class="fas fa-clipboard-user"></i> <span data-i18n="menu_attendance">Attendance</span></a>
            <a href="examinations.jsp" class="menu-item"><i class="fas fa-file-alt"></i> <span data-i18n="menu_examinations">Examinations</span></a>
            <a href="timetable.jsp" class="menu-item"><i class="fas fa-calendar-alt"></i> <span data-i18n="menu_timetable">Timetable</span></a>
            <a href="reports.jsp" class="menu-item"><i class="fas fa-chart-bar"></i> <span data-i18n="menu_reports">Reports</span></a>
            <a href="announcements.jsp" class="menu-item"><i class="fas fa-bullhorn"></i> <span data-i18n="menu_announcements">Announcements</span></a>
            <a href="settings.jsp" class="menu-item"><i class="fas fa-cog"></i> <span data-i18n="menu_settings">Settings</span></a>
        </div>

        <div class="sidebar-bottom">
            <div class="admin-profile-sidebar">
                <img src="https://ui-avatars.com/api/?name=Admin&background=fff&color=1a233a" alt="Admin">
                <div class="admin-info">
                    <h4>Admin</h4>
                    <p><span data-i18n="super_admin">Super Administrator</span> <span style="color:#10b981;">●</span></p>
                </div>
            </div>
            <a href="logout.jsp" class="menu-item" style="color: #94a3b8;"><i class="fas fa-sign-out-alt"></i> <span data-i18n="logout">Log out</span></a>
        </div>
    </div>