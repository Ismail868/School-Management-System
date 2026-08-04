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
    <title>Ku dar Macalin - School Management</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
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
            --danger: #ef4444;
            --input-bg: #f8fafc;
        }

        .dark-mode {
            --bg-main: #0f172a;
            --card-bg: #1e293b;
            --text-main: #f1f5f9;
            --text-muted: #94a3b8;
            --border-color: #334155;
            --input-bg: #0f172a;
        }

        .rtl { direction: rtl; text-align: right; }
        .rtl .section-title::after { left: auto; right: 0; }
        .rtl .btn-group { flex-direction: row-reverse; }

        body { 
            background-color: var(--bg-main); 
            color: var(--text-main); 
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
            margin: 0; 
            padding: 30px 20px;
            transition: all 0.3s ease;
        }

        .container { max-width: 900px; margin: auto; }

        .form-card {
            background: var(--card-bg);
            border-radius: 20px;
            padding: 35px;
            box-shadow: 0 10px 25px -5px rgba(0,0,0,0.05);
            border: 1px solid var(--border-color);
        }

        .form-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
            border-bottom: 2px solid var(--border-color);
            padding-bottom: 15px;
        }

        .form-header h2 { margin: 0; color: var(--primary); font-size: 24px; }
        .btn-back {
            background: var(--border-color);
            color: var(--text-main);
            padding: 10px 18px;
            border-radius: 8px;
            text-decoration: none;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 8px;
            transition: 0.2s;
        }
        .btn-back:hover { background: var(--text-muted); color: white; }

        .section-title {
            font-size: 16px;
            font-weight: 700;
            color: var(--primary);
            margin: 30px 0 20px 0;
            padding-bottom: 8px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            position: relative;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .section-title::after {
            content: '';
            position: absolute;
            left: 0; bottom: 0;
            height: 3px; width: 50px;
            background: var(--primary);
            border-radius: 3px;
        }

        .form-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
            gap: 20px;
        }

        .form-group { display: flex; flex-direction: column; gap: 8px; }
        .full-width { grid-column: 1 / -1; }

        .form-group label {
            font-size: 13px;
            font-weight: 600;
            color: var(--text-main);
            display: flex;
            align-items: center;
            gap: 6px;
        }
        .form-group label i { color: var(--primary); }

        .form-control {
            padding: 12px 15px;
            border: 1.5px solid var(--border-color);
            border-radius: 10px;
            background: var(--input-bg);
            color: var(--text-main);
            font-size: 14px;
            outline: none;
            transition: all 0.3s ease;
        }
        .form-control:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.15);
        }

        .btn-submit {
            background-color: var(--success);
            color: white;
            padding: 14px 30px;
            font-size: 16px;
            font-weight: 600;
            border: none;
            border-radius: 10px;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            gap: 10px;
            box-shadow: 0 4px 6px -1px rgba(16, 185, 129, 0.2);
        }
        .btn-submit:hover { background-color: var(--success-hover); transform: translateY(-2px); }

        .btn-group { display: flex; justify-content: flex-end; gap: 15px; margin-top: 30px; }

        .img-preview {
            width: 80px;
            height: 80px;
            border-radius: 50%;
            object-fit: cover;
            border: 2px solid var(--primary);
            margin-top: 10px;
            display: none;
        }

        @media (max-width: 600px) {
            .form-grid { grid-template-columns: 1fr; }
            .form-header { flex-direction: column; align-items: flex-start; gap: 10px; }
        }
    </style>
</head>
<body>

<div class="container">
    <div class="form-card">
        <div class="form-header">
            <h2><i class="fas fa-user-plus"></i> <span data-i18n="add_teacher_title">Ku dar Macalin Cusub</span></h2>
            <a href="teachers.jsp" class="btn-back"><i class="fas fa-arrow-left"></i> <span data-i18n="btn_back">Soo Laab</span></a>
        </div>

        <form action="save_teacher" method="POST" enctype="multipart/form-data">
            
            <!-- System Login Section -->
            <div class="section-title"><i class="fas fa-desktop"></i> <span data-i18n="sec_login">1. Xogta Login-ka System-ka</span></div>
            <div class="form-grid">
                <div class="form-group">
                    <label><i class="fas fa-id-card"></i> <span data-i18n="lbl_fullname">Magaca Dhammaystiran</span> *</label>
                    <input type="text" name="full_name" class="form-control" required placeholder="Tusaale: Ahmed Mohamed Ali">
                </div>
                <div class="form-group">
                    <label><i class="fas fa-user"></i> <span data-i18n="lbl_username">Username</span> *</label>
                    <input type="text" name="username" class="form-control" required placeholder="Tusaale: ahmed123">
                </div>
                <div class="form-group">
                    <label><i class="fas fa-envelope"></i> <span data-i18n="lbl_email">Email Address</span> *</label>
                    <input type="email" name="email" class="form-control" required placeholder="ahmed@gmail.com">
                </div>
                <div class="form-group">
                    <label><i class="fas fa-key"></i> <span data-i18n="lbl_password">Password</span> *</label>
                    <input type="password" name="password" class="form-control" required placeholder="******">
                </div>
                <div class="form-group">
                    <label><i class="fas fa-unlock-alt"></i> <span data-i18n="lbl_pin">Recovery PIN (4 Digits)</span> *</label>
                    <input type="text" name="recovery_pin" maxlength="4" pattern="\d{4}" class="form-control" required placeholder="1234">
                </div>
                <div class="form-group">
                    <label><i class="fas fa-toggle-on"></i> <span data-i18n="lbl_status">Status</span></label>
                    <select name="status" class="form-control">
                        <option value="active">Active</option>
                        <option value="inactive">Inactive</option>
                    </select>
                </div>
            </div>

            <!-- Personal Info Section -->
            <div class="section-title"><i class="fas fa-user-circle"></i> <span data-i18n="sec_personal">2. Xogta Shaqsiga ah</span></div>
            <div class="form-grid">
                <div class="form-group">
                    <label><i class="fas fa-venus-mars"></i> <span data-i18n="lbl_gender">Jinsiga</span></label>
                    <select name="gender" class="form-control" required>
                        <option value="Male">Male</option>
                        <option value="Female">Female</option>
                    </select>
                </div>
                <div class="form-group">
                    <label><i class="fas fa-calendar-alt"></i> <span data-i18n="lbl_dob">Taariikhda Dhalashada</span></label>
                    <input type="date" name="dob" class="form-control" required>
                </div>
                <div class="form-group">
                    <label><i class="fas fa-phone"></i> <span data-i18n="lbl_phone">Phone Number</span> *</label>
                    <input type="text" name="phone" class="form-control" required placeholder="+25261xxxxxxx">
                </div>
                <div class="form-group">
                    <label><i class="fas fa-mobile-alt"></i> <span data-i18n="lbl_alt_phone">Phone Labaad</span></label>
                    <input type="text" name="alt_phone" class="form-control" placeholder="+25261xxxxxxx">
                </div>
                <div class="form-group full-width">
                    <label><i class="fas fa-map-marker-alt"></i> <span data-i18n="lbl_address">Cinwaanka (Address)</span></label>
                    <input type="text" name="address" class="form-control" required placeholder="Mogadishu, Somalia">
                </div>
                <div class="form-group full-width">
                    <label><i class="fas fa-camera"></i> <span data-i18n="lbl_photo">Sawirka Macalinka</span></label>
                    <input type="file" name="photo" class="form-control" accept="image/*" onchange="previewImage(this, 'photoPreview')">
                    <img id="photoPreview" class="img-preview" alt="Preview">
                </div>
            </div>

            <!-- Professional & Experience Section -->
            <div class="section-title"><i class="fas fa-graduation-cap"></i> <span data-i18n="sec_professional">3. Xirfadda & Khibradda</span></div>
            <div class="form-grid">
                <div class="form-group">
                    <label><i class="fas fa-certificate"></i> <span data-i18n="lbl_qualification">Shahaadada/Aqoonta</span></label>
                    <input type="text" name="qualification" class="form-control" placeholder="Bachelor of Education" required>
                </div>
                <div class="form-group">
                    <label><i class="fas fa-briefcase"></i> <span data-i18n="lbl_experience">Khibradda (Sano)</span></label>
                    <input type="number" name="experience_years" class="form-control" value="0" min="0" required>
                </div>
                <div class="form-group full-width">
                    <label><i class="fas fa-building"></i> <span data-i18n="lbl_workplaces">Meelihii Soo Shaqeeyay</span></label>
                    <textarea name="previous_workplaces" class="form-control" rows="2" placeholder="Skeno School, Horn Academy..."></textarea>
                </div>
            </div>

            <!-- Guarantor Details Section -->
            <div class="section-title"><i class="fas fa-user-shield"></i> <span data-i18n="sec_guarantor">4. Xogta Damiinka (Guarantor)</span></div>
            <div class="form-grid">
                <div class="form-group">
                    <label><i class="fas fa-user-tie"></i> <span data-i18n="lbl_gname">Magaca Damiinka</span> *</label>
                    <input type="text" name="guarantor_name" class="form-control" required placeholder="Magaca Damiinka">
                </div>
                <div class="form-group">
                    <label><i class="fas fa-phone"></i> <span data-i18n="lbl_gphone">Tel-ka Damiinka</span> *</label>
                    <input type="text" name="guarantor_phone" class="form-control" required placeholder="+25261xxxxxxx">
                </div>
                <div class="form-group">
                    <label><i class="fas fa-people-arrows"></i> <span data-i18n="lbl_grelation">Xiriirka Damiinka</span></label>
                    <input type="text" name="guarantor_relation" class="form-control" placeholder="Tusaale: Adeer, Aabe..." required>
                </div>
                <div class="form-group">
                    <label><i class="fas fa-id-card"></i> <span data-i18n="lbl_gimage">Sawirka Aqoonsiga Damiinka (ID/Passport)</span></label>
                    <input type="file" name="guarantor_id_image" class="form-control" accept="image/*">
                </div>
            </div>

            <!-- Administrative Details -->
            <div class="section-title"><i class="fas fa-file-invoice-dollar"></i> <span data-i18n="sec_admin">5. Maamulka Iskuulka</span></div>
            <div class="form-grid">
                <div class="form-group">
                    <label><i class="fas fa-calendar-check"></i> <span data-i18n="lbl_hire_date">Taariikhda Shaqaalaysiinta</span></label>
                    <input type="date" name="hire_date" class="form-control" required>
                </div>
                <div class="form-group">
                    <label><i class="fas fa-money-bill-wave"></i> <span data-i18n="lbl_salary">Mushaarka Asalka Ah ($)</span></label>
                    <input type="number" step="0.01" name="base_salary" class="form-control" required placeholder="300.00">
                </div>
            </div>

            <div class="btn-group">
                <button type="submit" class="btn-submit">
                    <i class="fas fa-save"></i> <span data-i18n="btn_save">Diiwaangeli Macalinka</span>
                </button>
            </div>
        </form>
    </div>
</div>

<script>
    const translations = {
        en: {
            add_teacher_title: "Add New Teacher",
            btn_back: "Back",
            sec_login: "1. System Login Details",
            sec_personal: "2. Personal Information",
            sec_professional: "3. Professional & Experience",
            sec_guarantor: "4. Guarantor Details",
            sec_admin: "5. Administrative Details",
            lbl_fullname: "Full Name",
            lbl_username: "Username",
            lbl_email: "Email Address",
            lbl_password: "Password",
            lbl_pin: "Recovery PIN (4 Digits)",
            lbl_status: "Status",
            lbl_gender: "Gender",
            lbl_dob: "Date of Birth",
            lbl_phone: "Phone Number",
            lbl_alt_phone: "Alternative Phone",
            lbl_address: "Address",
            lbl_photo: "Teacher Photo",
            lbl_qualification: "Qualification",
            lbl_experience: "Experience (Years)",
            lbl_workplaces: "Previous Workplaces",
            lbl_gname: "Guarantor Name",
            lbl_gphone: "Guarantor Phone",
            lbl_grelation: "Guarantor Relation",
            lbl_gimage: "Guarantor ID Photo",
            lbl_hire_date: "Hire Date",
            lbl_salary: "Base Salary ($)",
            btn_save: "Register Teacher"
        },
        so: {
            add_teacher_title: "Ku dar Macalin Cusub",
            btn_back: "Soo Laab",
            sec_login: "1. Xogta Login-ka System-ka",
            sec_personal: "2. Xogta Shaqsiga ah",
            sec_professional: "3. Xirfadda & Khibradda",
            sec_guarantor: "4. Xogta Damiinka (Guarantor)",
            sec_admin: "5. Maamulka Iskuulka",
            lbl_fullname: "Magaca Dhammaystiran",
            lbl_username: "Username",
            lbl_email: "Email Address",
            lbl_password: "Password",
            lbl_pin: "Recovery PIN (4 Digits)",
            lbl_status: "Status",
            lbl_gender: "Jinsiga",
            lbl_dob: "Taariikhda Dhalashada",
            lbl_phone: "Phone Number",
            lbl_alt_phone: "Phone Labaad",
            lbl_address: "Cinwaanka (Address)",
            lbl_photo: "Sawirka Macalinka",
            lbl_qualification: "Shahaadada/Aqoonta",
            lbl_experience: "Khibradda (Sano)",
            lbl_workplaces: "Meelihii Soo Shaqeeyay",
            lbl_gname: "Magaca Damiinka",
            lbl_gphone: "Tel-ka Damiinka",
            lbl_grelation: "Xiriirka Damiinka",
            lbl_gimage: "Sawirka Aqoonsiga Damiinka",
            lbl_hire_date: "Taariikhda Shaqaalaysiinta",
            lbl_salary: "Mushaarka Asalka Ah ($)",
            btn_save: "Diiwaangeli Macalinka"
        },
        ar: {
            add_teacher_title: "إضافة معلم جديد",
            btn_back: "رجوع",
            sec_login: "1. تفاصيل تسجيل الدخول",
            sec_personal: "2. المعلومات الشخصية",
            sec_professional: "3. المؤهلات والخبرة",
            sec_guarantor: "4. تفاصيل الضامن",
            sec_admin: "5. التفاصيل الإدارية",
            lbl_fullname: "الاسم الكامل",
            lbl_username: "اسم المستخدم",
            lbl_email: "البريد الإلكتروني",
            lbl_password: "كلمة المرور",
            lbl_pin: "رمز الاسترداد (4 أرقام)",
            lbl_status: "الحالة",
            lbl_gender: "الجنس",
            lbl_dob: "تاريخ الميلاد",
            lbl_phone: "رقم الهاتف",
            lbl_alt_phone: "هاتف إضافي",
            lbl_address: "العنوان",
            lbl_photo: "صورة المعلم",
            lbl_qualification: "المؤهل العلمي",
            lbl_experience: "الخبرة (سنوات)",
            lbl_workplaces: "أماكن العمل السابقة",
            lbl_gname: "اسم الضامن",
            lbl_gphone: "هاتف الضامن",
            lbl_grelation: "صلة القرابة",
            lbl_gimage: "صورة هوية الضامن",
            lbl_hire_date: "تاريخ التعيين",
            lbl_salary: "الراتب الأساسي ($)",
            btn_save: "تسجيل المعلم"
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
            if (translations[lang] && translations[lang][key]) {
                el.innerText = translations[lang][key];
            }
        });
    }

    function previewImage(input, previewId) {
        const preview = document.getElementById(previewId);
        if (input.files && input.files[0]) {
            const reader = new FileReader();
            reader.onload = function(e) {
                preview.src = e.target.result;
                preview.style.display = 'block';
            }
            reader.readAsDataURL(input.files[0]);
        }
    }
</script>
</body>
</html>