<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<script>
    // --- Dark/Light Mode Logic ---
    const themeToggleBtn = document.getElementById('themeToggleBtn');
    const themeIcon = document.getElementById('themeIcon');
    let currentTheme = localStorage.getItem('app_theme') || 'light';

    function applyTheme(theme) {
        if (theme === 'dark') {
            document.body.classList.add('dark-mode');
            if (themeIcon) {
                themeIcon.classList.remove('fa-moon');
                themeIcon.classList.add('fa-sun');
            }
        } else {
            document.body.classList.remove('dark-mode');
            if (themeIcon) {
                themeIcon.classList.remove('fa-sun');
                themeIcon.classList.add('fa-moon');
            }
        }
    }

    // Marka button-ka Dark Mode la taabto
    if (themeToggleBtn) {
        themeToggleBtn.addEventListener('click', () => {
            currentTheme = currentTheme === 'light' ? 'dark' : 'light';
            localStorage.setItem('app_theme', currentTheme);
            applyTheme(currentTheme);
        });
    }

    const translations = {
        en: {
            school_title: "SCHOOL",
            school_sub: "MANAGEMENT SYSTEM",
            menu_dashboard: "Dashboard",
            menu_students: "Students",
            menu_teachers: "Teachers",
            menu_classes: "Classes & Subjects",
            menu_payments: "Payments",
            menu_attendance: "Attendance",
            menu_examinations: "Examinations",
            menu_timetable: "Timetable",
            menu_reports: "Reports",
            menu_announcements: "Announcements",
            menu_settings: "Settings",
            super_admin: "Super Administrator",
            super_admin_short: "Super Admin",
            logout: "Log out",
            search_placeholder: "Search for students, teachers, classes...",
            kpi_total_students: "Total Students",
            kpi_total_teachers: "Total Teachers",
            kpi_total_classes: "Total Classes",
            kpi_total_payments: "Total Payments",
            kpi_from_last_month: "from last month",
            payment_overview: "Payment Overview",
            option_this_month: "This Month",
            option_this_week: "This Week",
            full_fee_paid: "Full Fee Paid",
            partial_paid: "Partial Paid",
            pending: "Pending",
            total_collected_text: "Total Collected",
            attendance_overview: "Attendance Overview",
            recent_activities: "Recent Activities",
            act_1_title: "New student registered",
            act_1_time: "10 mins ago",
            act_2_title: "Payment received",
            act_2_time: "25 mins ago",
            act_3_title: "Attendance marked",
            act_3_time: "1 hour ago",
            act_4_title: "New teacher registered",
            act_4_time: "2 hours ago",
            act_5_title: "Class updated",
            act_5_time: "3 hours ago",
            grade_8: "Grade 8",
            math: "Mathematics",
            grade_10: "Grade 10",
            science: "Science",
            students_by_classes: "Students by Classes",
            top_fee_payers: "Top Fee Payers",
            th_num: "#",
            th_name: "Student Name",
            th_class: "Class",
            th_amount: "Amount (SOM)",
            th_status: "Status",
            status_paid: "Paid",
            academic_year: "Academic Year",
            second_term: "Second Term",
            btn_report: "View Full Report",
            chart_students_att: "Students Attendance",
            chart_teachers_att: "Teachers Attendance"
        },
        so: {
            school_title: "ISKUULKA",
            school_sub: "NIDAAMKA MAAMULKA",
            menu_dashboard: "Dashboordka",
            menu_students: "Ardayda",
            menu_teachers: "Macallimiinta",
            menu_classes: "Fasallada & Madoyinka",
            menu_payments: "Bixinta Lacagaha",
            menu_attendance: "Joogteynta",
            menu_examinations: "Imtixaanaadka",
            menu_timetable: "Jadwalka",
            menu_reports: "Warbixinnada",
            menu_announcements: "Ogeysiisyada",
            menu_settings: "Settings-ka",
            super_admin: "Maamulaha Guud",
            super_admin_short: "Maamule Guud",
            logout: "Ka bax",
            search_placeholder: "Dheeho ardayda, macallimiinta, fasallada...",
            kpi_total_students: "Kullaan Ardayda",
            kpi_total_teachers: "Kullaan Macallimiinta",
            kpi_total_classes: "Kullaan Fasallada",
            kpi_total_payments: "Kullaan Bixinta",
            kpi_from_last_month: "bixii hore kasoo bilaabo",
            payment_overview: "Sifaynta Bixinta",
            option_this_month: "Bishan",
            option_this_week: "Toddobaadkan",
            full_fee_paid: "Bixiyay Buuxa",
            partial_paid: "Bixiyay Qeyb",
            pending: "Dhiman",
            total_collected_text: "Warta La Ururiyay",
            attendance_overview: "Sifaynta Joogteynta",
            recent_activities: "Hawllaha Ugu Dambeeyay",
            act_1_title: "Arday cusub ayaa la diwaan geliyay",
            act_1_time: "10 daqiiqo ka hor",
            act_2_title: "Bixin ayaa la helay",
            act_2_time: "25 daqiiqo ka hor",
            act_3_title: "Joogteynta waa la calaamadeeyay",
            act_3_time: "1 saac ka hor",
            act_4_title: "Macallin cusub ayaa la diwaan geliyay",
            act_4_time: "2 saac ka hor",
            act_5_title: "Fasalka waa la cusbooneysiiyay",
            act_5_time: "3 saac ka hor",
            grade_8: "Fasalka 8aad",
            math: "Xisaab",
            grade_10: "Fasalka 10aad",
            science: "Saynis",
            students_by_classes: "Ardayda Fasallada Ku Kala Qeybsan",
            top_fee_payers: "Ardayda Ugu Bixinta Badnaa",
            th_num: "#",
            th_name: "Magaca Ardayga",
            th_class: "Fasalka",
            th_amount: "Caddadka (SOM)",
            th_status: "Xaaladda",
            status_paid: "Bixiyay",
            academic_year: "Sannad Dugsiyedka",
            second_term: "Term-ka 2aad",
            btn_report: "Eeg Warbixinta Buuxda",
            chart_students_att: "Joogteynta Ardayda",
            chart_teachers_att: "Joogteynta Macallimiinta"
        },
        ar: {
            school_title: "المدرسة",
            school_sub: "نظام الإدارة",
            menu_dashboard: "لوحة التحكم",
            menu_students: "الطلاب",
            menu_teachers: "المعلمون",
            menu_classes: "الفصول والمواد",
            menu_payments: "المدفوعات",
            menu_attendance: "الحضور والغياب",
            menu_examinations: "الامتحانات",
            menu_timetable: "الجدول الزمني",
            menu_reports: "التقارير",
            menu_announcements: "الإعلانات",
            menu_settings: "الإعدادات",
            super_admin: "المسؤول العام",
            super_admin_short: "مدير عام",
            logout: "تسجيل الخروج",
            search_placeholder: "البحث عن الطلاب، المعلمين، الفصول...",
            kpi_total_students: "إجمالي الطلاب",
            kpi_total_teachers: "إجمالي المعلمين",
            kpi_total_classes: "إجمالي الفصول",
            kpi_total_payments: "إجمالي المدفوعات",
            kpi_from_last_month: "مقارنة بالشهر الماضي",
            payment_overview: "نظرة عامة على المدفوعات",
            option_this_month: "هذا الشهر",
            option_this_week: "هذا الأسبوع",
            full_fee_paid: "مدفوع بالكامل",
            partial_paid: "مدفوع جزئياً",
            pending: "معلق",
            total_collected_text: "المبلغ المحصل",
            attendance_overview: "نظرة عامة على الحضور",
            recent_activities: "الأنشطة الأخيرة",
            act_1_title: "تم تسجيل طالب جديد",
            act_1_time: "منذ 10 دقائق",
            act_2_title: "تم استلام الدفعة",
            act_2_time: "منذ 25 دقيقة",
            act_3_title: "تم تسجيل الحضور",
            act_3_time: "منذ ساعة واحدة",
            act_4_title: "تم تسجيل معلم جديد",
            act_4_time: "منذ ساعتين",
            act_5_title: "تم تحديث الفصل",
            act_5_time: "منذ 3 ساعات",
            grade_8: "الصف الثامن",
            math: "الرياضيات",
            grade_10: "الصف العاشر",
            science: "العلوم",
            students_by_classes: "الطلاب حسب الفصول",
            top_fee_payers: "أعلى الدافعين للرسوم",
            th_num: "#",
            th_name: "اسم الطالب",
            th_class: "الفصل",
            th_amount: "المبلغ (SOM)",
            th_status: "الحالة",
            status_paid: "مدفوع",
            academic_year: "العام الدراسي",
            second_term: "الفصل الثاني",
            btn_report: "عرض التقرير الكامل",
            chart_students_att: "حضور الطلاب",
            chart_teachers_att: "حضور المعلمين"
        }
    };

    let currentLang = localStorage.getItem('app_language') || 'en';

    const langData = {
        en: { name: 'English', flag: 'https://flagcdn.com/w20/us.png' },
        so: { name: 'Soomaali', flag: 'https://flagcdn.com/w20/so.png' },
        ar: { name: 'العربية', flag: 'https://flagcdn.com/w20/sa.png' }
    };

    function changeLanguage(lang) {
        currentLang = lang;
        localStorage.setItem('app_language', lang);
        
        // Update Text Nodes
        document.querySelectorAll('[data-i18n]').forEach(el => {
            const key = el.getAttribute('data-i18n');
            if (translations[lang] && translations[lang][key]) {
                el.innerText = translations[lang][key];
            }
        });

        // Update Input Placeholders
        document.querySelectorAll('[data-i18n-placeholder]').forEach(el => {
            const key = el.getAttribute('data-i18n-placeholder');
            if (translations[lang] && translations[lang][key]) {
                el.placeholder = translations[lang][key];
            }
        });

        // Update UI Dropdown
        const currentLangText = document.getElementById('currentLangText');
        const currentLangFlag = document.getElementById('currentLangFlag');
        if (currentLangText && langData[lang]) {
            currentLangText.innerText = langData[lang].name;
        }
        if (currentLangFlag && langData[lang]) {
            currentLangFlag.src = langData[lang].flag;
        }

        // Handle RTL for Arabic
        if (lang === 'ar') {
            document.body.classList.add('rtl');
        } else {
            document.body.classList.remove('rtl');
        }

        // Hide options
        const langOptions = document.getElementById('langOptions');
        if (langOptions) {
            langOptions.classList.remove('show');
        }

        // Update Chart Legends/Texts
        if (typeof attendanceChart !== 'undefined' && attendanceChart) {
            attendanceChart.data.datasets[0].label = translations[lang].chart_students_att;
            attendanceChart.data.datasets[1].label = translations[lang].chart_teachers_att;
            attendanceChart.update();
        }

        if (typeof paymentChart !== 'undefined' && paymentChart) {
            paymentChart.update();
        }
    }

    // Dropdown toggle
    const langSelectBtn = document.getElementById('langSelectBtn');
    const langOptions = document.getElementById('langOptions');

    if (langSelectBtn && langOptions) {
        langSelectBtn.addEventListener('click', (e) => {
            e.stopPropagation();
            langOptions.classList.toggle('show');
        });
    }

    document.addEventListener('click', () => {
        if (langOptions) {
            langOptions.classList.remove('show');
        }
    });

    // Initialize Page Load (Dark Mode & Language)
    document.addEventListener('DOMContentLoaded', () => {
        applyTheme(currentTheme);
        changeLanguage(currentLang);
    });
</script>