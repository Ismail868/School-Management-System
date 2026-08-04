<%@page import="java.sql.*"%>
<%@page import="java.io.*"%>
<%@page import="java.util.Scanner"%>
<%@page import="javax.servlet.http.Part"%>
<%@page import="utils.DBConnection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%!
    // Function loogu talagalay in lagu soo akhriyo Text Fields-ka marka foomku yahay multipart
    private String getFieldValue(HttpServletRequest request, String fieldName) {
        try {
            Part part = request.getPart(fieldName);
            if (part != null) {
                Scanner scanner = new Scanner(part.getInputStream(), "UTF-8");
                if (scanner.hasNextLine()) {
                    return scanner.nextLine().trim();
                }
            }
        } catch (Exception e) {
            // Haddii uu ku fashilmo, isku day habka caadiga ah
        }
        String val = request.getParameter(fieldName);
        return (val != null) ? val : "";
    }
%>
<%
    // Hubi in isticmaaluhu soo galay (Login Check)
    if (session.getAttribute("username") == null) {
        response.sendRedirect("index.jsp");
        return; 
    }

    String msg = "";
    
    // ==========================================
    // INSERT STUDENT LOGIC (POST REQUEST)
    // ==========================================
    if (request.getMethod().equalsIgnoreCase("post")) {
        Connection connPost = null;
        PreparedStatement pst = null;
        try {
            // Read form data using helper method
            String studentId = getFieldValue(request, "student_id");
            String fullName = getFieldValue(request, "full_name");
            String sClass = getFieldValue(request, "class");
            String gender = getFieldValue(request, "gender");
            String parentPhone = getFieldValue(request, "parent_phone");
            String motherName = getFieldValue(request, "mother_name");
            String motherPhone = getFieldValue(request, "mother_phone");
            String studentPhone = getFieldValue(request, "student_phone");
            String email = getFieldValue(request, "email");
            String address = getFieldValue(request, "address");
            
            // Photo upload handling
            String photoPath = "images/default-avatar.png"; 
            Part filePart = null;
            try {
                filePart = request.getPart("photo");
            } catch(Exception e) {
                // Ignore exception if multipart isn't natively configured
            }

            if (filePart != null && filePart.getSize() > 0 && filePart.getSubmittedFileName() != null && !filePart.getSubmittedFileName().isEmpty()) {
                String fileName = filePart.getSubmittedFileName();
                String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads" + File.separator + "students";
                
                File uploadDir = new File(uploadPath);
                if (!uploadDir.exists()) {
                    uploadDir.mkdirs(); 
                }
                
                filePart.write(uploadPath + File.separator + fileName);
                photoPath = "uploads/students/" + fileName;
            }

            // Database Insert Operation (Connection Pool)
            connPost = DBConnection.getConnection();
            String sql = "INSERT INTO students (student_id, full_name, class, gender, parent_phone, mother_name, mother_phone, student_phone, email, address, photo) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            pst = connPost.prepareStatement(sql);
            pst.setString(1, studentId);
            pst.setString(2, fullName);
            pst.setString(3, sClass);
            pst.setString(4, gender);
            pst.setString(5, parentPhone);
            pst.setString(6, motherName);
            pst.setString(7, motherPhone);
            pst.setString(8, studentPhone);
            pst.setString(9, email);
            pst.setString(10, address);
            pst.setString(11, photoPath);
            
            int i = pst.executeUpdate();
            if (i > 0) {
                response.sendRedirect("students.jsp?msg=success");
                return;
            }
        } catch (Exception e) {
            msg = "Error: " + e.getMessage();
        } finally {
            // Xirida kheyraadka si ku celinta Pool-ka ay u dhacdo
            DBConnection.close(connPost, pst, null);
        }
    }

    // ==========================================
    // AUTO-GENERATE NEXT STUDENT ID LOGIC
    // ==========================================
    int nextStudentId = 1000; 
    Connection connId = null;
    Statement stmtId = null;
    ResultSet rsId = null;
    try {
        connId = DBConnection.getConnection();
        stmtId = connId.createStatement();
        rsId = stmtId.executeQuery("SELECT MAX(student_id) FROM students");
        
        if (rsId.next() && rsId.getInt(1) > 0) {
            nextStudentId = rsId.getInt(1) + 1; 
        }
    } catch (Exception e) {
        System.out.println("Error generating ID: " + e.getMessage());
    } finally {
        DBConnection.close(connId, stmtId, rsId);
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title data-i18n="title_add_student">Add New Student</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <style>
        :root {
            /* Light Mode Variables */
            --primary-color: #4f46e5;
            --primary-hover: #4338ca;
            --bg-color: #f3f4f6;
            --card-bg: #ffffff;
            --text-main: #1f2937;
            --text-muted: #6b7280;
            --border-color: #e5e7eb;
            --input-bg: #f9fafb;
        }
        
        /* Dark Mode Styles */
        body.dark-mode {
            --bg-color: #0f172a;       
            --card-bg: #1e293b;        
            --text-main: #f8fafc;      
            --text-muted: #94a3b8;     
            --border-color: #334155;   
            --input-bg: #0f172a;       
        }
        
        /* RTL (Arabic) Styles */
        body.rtl {
            direction: rtl;
            text-align: right;
        }
        body.rtl .header-section {
            flex-direction: row-reverse;
        }
        body.rtl .btn-back i {
            transform: rotate(180deg);
        }
        body.rtl .error {
            border-left: none;
            border-right: 4px solid #ef4444;
        }

        * { box-sizing: border-box; margin: 0; padding: 0; }
        
        body { 
            background-color: var(--bg-color); 
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
            padding: 30px 15px; 
            color: var(--text-main);
            transition: background-color 0.3s ease, color 0.3s ease;
        }
        
        .form-container { 
            max-width: 900px; 
            margin: auto; 
            background: var(--card-bg); 
            padding: 40px; 
            border-radius: 16px; 
            box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.1), 0 8px 10px -6px rgba(0, 0, 0, 0.1); 
            transition: background-color 0.3s ease;
        }
        
        .header-section {
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 2px solid var(--border-color);
            padding-bottom: 15px;
            margin-bottom: 30px;
        }
        
        h2 { color: var(--text-main); font-size: 24px; display: flex; align-items: center; gap: 10px; }
        
        .btn-back { 
            display: flex; align-items: center; gap: 8px; 
            color: var(--text-muted); text-decoration: none; 
            font-weight: 600; transition: color 0.3s ease;
        }
        .btn-back:hover { color: var(--primary-color); }
        
        .form-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 24px; }
        
        .form-group { display: flex; flex-direction: column; }
        .form-group label { font-size: 14px; font-weight: 600; color: var(--text-main); margin-bottom: 8px; }
        
        .form-group input, .form-group select { 
            padding: 12px 16px; border: 1px solid var(--border-color); 
            border-radius: 8px; font-size: 15px; transition: all 0.3s ease;
            background-color: var(--input-bg);
            color: var(--text-main);
        }
        .form-group input:focus, .form-group select:focus { 
            border-color: var(--primary-color); 
            background-color: var(--card-bg);
            box-shadow: 0 0 0 4px rgba(79, 70, 229, 0.1); outline: none; 
        }

        /* Readonly Input Style */
        .readonly-input {
            background-color: var(--border-color) !important;
            cursor: not-allowed;
            color: var(--text-muted) !important;
            font-weight: bold;
        }
        
        .full-width { grid-column: 1 / -1; }
        
        /* Photo Upload Styling */
        .photo-upload-container {
            display: flex; align-items: center; gap: 20px;
            padding: 15px; border: 2px dashed var(--border-color);
            border-radius: 12px; background-color: var(--input-bg);
            transition: border-color 0.3s ease;
        }
        .photo-upload-container:hover { border-color: var(--primary-color); }
        
        .photo-preview {
            width: 80px; height: 80px; border-radius: 50%;
            object-fit: cover; border: 3px solid var(--card-bg);
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
            display: none;
            background-color: var(--border-color);
        }
        .file-input-wrapper input[type="file"] {
            padding: 8px; font-size: 14px; background: transparent; border: none;
            cursor: pointer; color: var(--text-main);
        }

        .btn-submit { 
            background: var(--primary-color); color: white; border: none; 
            padding: 16px 24px; font-size: 16px; font-weight: bold; 
            border-radius: 8px; cursor: pointer; margin-top: 30px; 
            width: 100%; transition: background-color 0.3s ease, transform 0.1s ease;
            display: flex; justify-content: center; align-items: center; gap: 10px;
        }
        .btn-submit:hover { background: var(--primary-hover); }
        .btn-submit:active { transform: scale(0.98); }
        
        .error { color: #b91c1c; background: #fef2f2; padding: 12px 16px; border-left: 4px solid #ef4444; border-radius: 6px; margin-bottom: 20px; font-weight: 500; }
        
        /* Responsive Grid for Mobile Devices */
        @media(max-width: 768px) { 
            .form-grid { grid-template-columns: 1fr; } 
            .form-container { padding: 20px; }
            .header-section { flex-direction: column; align-items: flex-start; gap: 15px; }
        }
    </style>
</head>
<body>
    <div class="form-container">
        <div class="header-section">
            <h2><i class="fas fa-user-plus"></i> <span data-i18n="title_add_student">Add New Student</span></h2>
            <a href="students.jsp" class="btn-back"><i class="fas fa-arrow-left"></i> <span data-i18n="btn_back">Back to List</span></a>
        </div>
        
        <% if(!msg.isEmpty()){ %> <div class="error"><i class="fas fa-exclamation-circle"></i> <%= msg %></div> <% } %>
        
        <form method="POST" enctype="multipart/form-data">
            <div class="form-grid">
                
                <!-- Student Photo Upload Section -->
                <div class="form-group full-width">
                    <label data-i18n="label_photo">Student Photo</label>
                    <div class="photo-upload-container">
                        <img id="photo-preview" class="photo-preview" src="" alt="Preview">
                        <div class="file-input-wrapper">
                            <input type="file" name="photo" accept="image/*" onchange="previewImage(event)">
                            <p style="font-size: 12px; color: var(--text-muted); margin-top: 5px;" data-i18n="photo_hint">Please select an image file (JPG, PNG)</p>
                        </div>
                    </div>
                </div>

                <div class="form-group">
                    <label data-i18n="label_student_id">Student ID (Auto Generated)</label>
                    <input type="text" name="student_id" class="readonly-input" value="<%= nextStudentId %>" readonly required>
                </div>

                <div class="form-group">
                    <label data-i18n="label_fullname">Full Name</label>
                    <input type="text" name="full_name" data-i18n-placeholder="placeholder_fullname" placeholder="Enter full name" required>
                </div>
                
                <!-- Dynamic Class Dropdown from Database -->
                <div class="form-group">
                    <label data-i18n="label_class">Class</label>
                    <select name="class" required>
                        <option value="" disabled selected data-i18n="placeholder_select_class">Select Class...</option>
                        <%
                            Connection connClass = null;
                            Statement stmtClass = null;
                            ResultSet rsClass = null;
                            try {
                                connClass = DBConnection.getConnection();
                                stmtClass = connClass.createStatement();
                                rsClass = stmtClass.executeQuery("SELECT class_name FROM class");
                                
                                while (rsClass.next()) {
                                    String className = rsClass.getString("class_name");
                        %>
                                    <option value="<%= className %>"><%= className %></option>
                        <%
                                }
                            } catch (Exception e) {
                                out.println("<option disabled>Error loading classes</option>");
                            } finally {
                                DBConnection.close(connClass, stmtClass, rsClass);
                            }
                        %>
                    </select>
                </div>

                <div class="form-group">
                    <label data-i18n="label_gender">Gender</label>
                    <select name="gender" required>
                        <option value="" disabled selected data-i18n="placeholder_select_gender">Select Gender...</option>
                        <option value="Male" data-i18n="opt_male">Male</option>
                        <option value="Female" data-i18n="opt_female">Female</option>
                    </select>
                </div>

                <div class="form-group">
                    <label data-i18n="label_parent_phone">Parent / Guardian Phone</label>
                    <input type="text" name="parent_phone" data-i18n-placeholder="placeholder_parent_phone" placeholder="e.g., 061XXXXXXX" required>
                </div>

                <div class="form-group">
                    <label data-i18n="label_student_phone">Student Phone (Optional)</label>
                    <input type="text" name="student_phone" data-i18n-placeholder="placeholder_student_phone" placeholder="Enter student phone if available">
                </div>

                <div class="form-group">
                    <label data-i18n="label_mother_name">Mother Name (Optional)</label>
                    <input type="text" name="mother_name" data-i18n-placeholder="placeholder_mother_name" placeholder="Enter mother name">
                </div>

                <div class="form-group">
                    <label data-i18n="label_mother_phone">Mother Phone (Optional)</label>
                    <input type="text" name="mother_phone" data-i18n-placeholder="placeholder_mother_phone" placeholder="Enter mother phone">
                </div>

                <div class="form-group">
                    <label data-i18n="label_email">Email Address</label>
                    <input type="email" name="email" data-i18n-placeholder="placeholder_email" placeholder="student@example.com">
                </div>

                <div class="form-group">
                    <label data-i18n="label_address">Address</label>
                    <input type="text" name="address" data-i18n-placeholder="placeholder_address" placeholder="e.g., Hodan, Mogadishu" required>
                </div>
            </div>

            <button type="submit" class="btn-submit">
                <i class="fas fa-save"></i> 
                <span data-i18n="btn_save">Save Student Record</span>
            </button>
        </form>
    </div>

    <!-- Script-ka Luqadaha iyo Syncing-ka -->
    <script>
        const translations = {
            en: {
                title_add_student: "Add New Student",
                btn_back: "Back to List",
                label_photo: "Student Photo",
                photo_hint: "Please select an image file (JPG, PNG)",
                label_student_id: "Student ID (Auto Generated)",
                label_fullname: "Full Name",
                label_class: "Class",
                label_gender: "Gender",
                label_parent_phone: "Parent / Guardian Phone",
                label_student_phone: "Student Phone (Optional)",
                label_mother_name: "Mother Name (Optional)",
                label_mother_phone: "Mother Phone (Optional)",
                label_email: "Email Address",
                label_address: "Address",
                btn_save: "Save Student Record",
                opt_male: "Male",
                opt_female: "Female",
                placeholder_fullname: "Enter full name",
                placeholder_select_class: "Select Class...",
                placeholder_select_gender: "Select Gender...",
                placeholder_parent_phone: "e.g., 061XXXXXXX",
                placeholder_student_phone: "Enter student phone if available",
                placeholder_mother_name: "Enter mother name",
                placeholder_mother_phone: "Enter mother phone",
                placeholder_email: "student@example.com",
                placeholder_address: "e.g., Hodan, Mogadishu"
            },
            so: {
                title_add_student: "Ku Dar Arday Cusub",
                btn_back: "Ku Laabto Liiska",
                label_photo: "Sawirka Ardayga",
                photo_hint: "Fadlan dooro fayl sawir ah (JPG, PNG)",
                label_student_id: "ID-ga Ardayga (Awtomaatik)",
                label_fullname: "Magaca Oo Buuxa",
                label_class: "Fasalka",
                label_gender: "Jinsiga",
                label_parent_phone: "Tel Waalidka / Aabbaha",
                label_student_phone: "Tel Ardayga (Koor)",
                label_mother_name: "Magaca Hooyada (Koor)",
                label_mother_phone: "Tel Hooyada (Koor)",
                label_email: "Email-ka",
                label_address: "Cinwaanka",
                btn_save: "Keydi Ardayga",
                opt_male: "Rag",
                opt_female: "Dumar",
                placeholder_fullname: "Geli magaca oo buuxa",
                placeholder_select_class: "Dooro Fasalka...",
                placeholder_select_gender: "Dooro Jinsiga...",
                placeholder_parent_phone: "Tusaale: 061XXXXXXX",
                placeholder_student_phone: "Geli telefonka ardayga haddii uu leeyahay",
                placeholder_mother_name: "Geli magaca hooyada",
                placeholder_mother_phone: "Geli telefonka hooyada",
                placeholder_email: "student@example.com",
                placeholder_address: "Tusaale: Hodan, Muqdisho"
            },
            ar: {
                title_add_student: "إضافة طالب جديد",
                btn_back: "العودة إلى القائمة",
                label_photo: "صورة الطالب",
                photo_hint: "يرجى اختيار ملف صورة (JPG, PNG)",
                label_student_id: "معرف الطالب (تلقائي)",
                label_fullname: "الاسم الكامل",
                label_class: "الفصل",
                label_gender: "الجنس",
                label_parent_phone: "هاتف ولي الأمر",
                label_student_phone: "هاتف الطالب (اختياري)",
                label_mother_name: "اسم الأم (اختياري)",
                label_mother_phone: "هاتف الأم (اختياري)",
                label_email: "البريد الإلكتروني",
                label_address: "العنوان",
                btn_save: "حفظ بيانات الطالب",
                opt_male: "ذكر",
                opt_female: "أنثى",
                placeholder_fullname: "أدخل الاسم الكامل",
                placeholder_select_class: "اختر الفصل...",
                placeholder_select_gender: "اختر الجنس...",
                placeholder_parent_phone: "مثال: 061XXXXXXX",
                placeholder_student_phone: "أدخل هاتف الطالب إن وجد",
                placeholder_mother_name: "أدخل اسم الأم",
                placeholder_mother_phone: "أدخل هاتف الأم",
                placeholder_email: "student@example.com",
                placeholder_address: "مثال: هودن، مقديشو"
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

            // Translate Text Content
            document.querySelectorAll('[data-i18n]').forEach(el => {
                const key = el.getAttribute('data-i18n');
                if (translations[lang] && translations[lang][key]) {
                    el.innerText = translations[lang][key];
                }
            });

            // Translate Placeholders
            document.querySelectorAll('[data-i18n-placeholder]').forEach(el => {
                const key = el.getAttribute('data-i18n-placeholder');
                if (translations[lang] && translations[lang][key]) {
                    el.placeholder = translations[lang][key];
                }
            });
        }

        document.addEventListener("DOMContentLoaded", () => {
            const currentTheme = localStorage.getItem('app_theme') || 'light';
            const currentLang = localStorage.getItem('app_language') || 'en';
            applyTheme(currentTheme);
            applyLanguage(currentLang);
        });

        // Event listener marka Dashboard-ka lagu baddalo luqadda ama Theme-ka
        window.addEventListener('storage', (e) => {
            if (e.key === 'app_language' && e.newValue) {
                applyLanguage(e.newValue);
            }
            if (e.key === 'app_theme' && e.newValue) {
                applyTheme(e.newValue);
            }
        });

        // Image Preview Function
        function previewImage(event) {
            var reader = new FileReader();
            reader.onload = function() {
                var output = document.getElementById('photo-preview');
                output.src = reader.result;
                output.style.display = 'block';
            };
            if(event.target.files[0]) {
                reader.readAsDataURL(event.target.files[0]);
            }
        }
    </script>
</body>
</html>