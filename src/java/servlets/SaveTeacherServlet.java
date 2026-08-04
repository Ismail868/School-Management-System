package servlets;

import java.io.File;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.Properties;

import javax.mail.Message;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;
import utils.DBConnection;

@WebServlet("/save_teacher")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2, // 2MB
    maxFileSize = 1024 * 1024 * 10,      // 10MB
    maxRequestSize = 1024 * 1024 * 50   // 50MB
)
public class SaveTeacherServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");

        // Soo qabashada Xogta Form-ka
        String fullName = request.getParameter("full_name");
        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String recoveryPin = request.getParameter("recovery_pin");
        String status = request.getParameter("status");

        String gender = request.getParameter("gender");
        String dob = request.getParameter("dob");
        String phone = request.getParameter("phone");
        String altPhone = request.getParameter("alt_phone");
        String address = request.getParameter("address");

        String qualification = request.getParameter("qualification");
        int experienceYears = Integer.parseInt(request.getParameter("experience_years"));
        String previousWorkplaces = request.getParameter("previous_workplaces");

        String guarantorName = request.getParameter("guarantor_name");
        String guarantorPhone = request.getParameter("guarantor_phone");
        String guarantorRelation = request.getParameter("guarantor_relation");

        String hireDate = request.getParameter("hire_date");
        String baseSalary = request.getParameter("base_salary");

        // Path-ka Sawirada lagu kaydinayo
        String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads" + File.separator + "teacher";

        Part photoPart = request.getPart("photo");
        Part gImagePart = request.getPart("guarantor_id_image");

        String photoFileName = uploadFile(photoPart, uploadPath);
        String gImageFileName = uploadFile(gImagePart, uploadPath);

        Connection conn = null;
        PreparedStatement stmtUser = null;
        PreparedStatement stmtTeacher = null;
        ResultSet rsKeys = null;

        try {
            // Xiriirka Database-ka oo laga keenayo Connection Pool-ka
            conn = DBConnection.getConnection();

            if (conn != null) {
                // Bilaw Transaction-ka adigoo isticmaalaya habka DBConnection
                DBConnection.beginTransaction(conn);

                // 1. Geli users table
                String userSql = "INSERT INTO users (full_name, username, email, password, recovery_pin, status, role) VALUES (?, ?, ?, ?, ?, ?, 'teacher')";
                stmtUser = conn.prepareStatement(userSql, Statement.RETURN_GENERATED_KEYS);
                stmtUser.setString(1, fullName);
                stmtUser.setString(2, username);
                stmtUser.setString(3, email);
                stmtUser.setString(4, password);
                stmtUser.setString(5, recoveryPin);
                stmtUser.setString(6, status);
                stmtUser.executeUpdate();

                rsKeys = stmtUser.getGeneratedKeys();
                int userId = 0;
                if (rsKeys.next()) {
                    userId = rsKeys.getInt(1);
                }

                // 2. Geli teachers table
                String teacherSql = "INSERT INTO teachers (user_id, gender, dob, phone, alt_phone, address, qualification, experience_years, previous_workplaces, guarantor_name, guarantor_phone, guarantor_relation, guarantor_id_image, photo, hire_date, base_salary) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                stmtTeacher = conn.prepareStatement(teacherSql);
                stmtTeacher.setInt(1, userId);
                stmtTeacher.setString(2, gender);
                stmtTeacher.setString(3, dob);
                stmtTeacher.setString(4, phone);
                stmtTeacher.setString(5, altPhone);
                stmtTeacher.setString(6, address);
                stmtTeacher.setString(7, qualification);
                stmtTeacher.setInt(8, experienceYears);
                stmtTeacher.setString(9, previousWorkplaces);
                stmtTeacher.setString(10, guarantorName);
                stmtTeacher.setString(11, guarantorPhone);
                stmtTeacher.setString(12, guarantorRelation);
                stmtTeacher.setString(13, gImageFileName);
                stmtTeacher.setString(14, photoFileName);
                stmtTeacher.setString(15, hireDate);
                stmtTeacher.setString(16, baseSalary);

                stmtTeacher.executeUpdate();

                // Dhameystir Transaction-ka
                DBConnection.commitTransaction(conn);

                // 3. U dir Email Macalinka
                boolean isEmailSent = sendWelcomeEmail(email, fullName, username, password);

                if (isEmailSent) {
                    response.sendRedirect("teachers.jsp?msg=success");
                } else {
                    response.sendRedirect("teachers.jsp?msg=success_but_email_failed");
                }
            } else {
                response.sendRedirect("teachers.jsp?msg=server_busy");
            }

        } catch (Exception e) {
            if (conn != null) {
                DBConnection.rollbackTransaction(conn);
            }
            e.printStackTrace();
            response.getWriter().println("<h3 style='color:red;'>Cilad ayaa dhacday: " + e.getMessage() + "</h3>");
        } finally {
            // Xir dhammaan kheyraadka adigoo isticmaalaya hababka DBConnection si Connection-ka loogu celiyo Pool-ka
            DBConnection.close(rsKeys);
            DBConnection.close(stmtUser);
            DBConnection.close(stmtTeacher);
            DBConnection.close(conn);
        }
    }

    private String uploadFile(Part part, String uploadPath) throws IOException {
        if (part == null || part.getSize() == 0 || part.getSubmittedFileName() == null || part.getSubmittedFileName().isEmpty()) {
            return null;
        }
        String fileName = System.currentTimeMillis() + "_" + part.getSubmittedFileName().replaceAll("\\s+", "_");
        File fileSaveDir = new File(uploadPath);
        if (!fileSaveDir.exists()) {
            fileSaveDir.mkdirs();
        }
        part.write(uploadPath + File.separator + fileName);
        return fileName;
    }

    // Function-ka dirida email-ka ee dib loo habeeyay
    private boolean sendWelcomeEmail(String toEmail, String fullName, String username, String password) {
        final String host = "smtp.gmail.com";
        final String fromEmail = "maxamedxusen652@gmail.com"; 
        final String emailPassword = "rgujrgbsrvyxxwwq";

        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", host);
        props.put("mail.smtp.port", "587");
        props.put("mail.smtp.ssl.trust", "smtp.gmail.com");
        props.put("mail.smtp.ssl.protocols", "TLSv1.2");
        Session mailSession = Session.getInstance(props, new javax.mail.Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(fromEmail, emailPassword);
            }
        });

        try {
            Message message = new MimeMessage(mailSession);
            message.setFrom(new InternetAddress(fromEmail));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject("Akaoonkaaga Macalinnimo waa la abuuray");

            String emailBody = "Ku: Macallin " + fullName + ",\n\n"
            + "Waxaan kuugu hambalyeynayaa shaqadaada cusub. Waxaa si guul leh lagaaga diiwangeliyay nidaamka (system-ka) iskuulka.\n\n"
            + "Halkan waa xogtaada aad ku geli lahayd iskuulka:\n"
            + "Username: " + username + "\n"
            + "Password: " + password + "\n\n"
            + "Fadlan password-kaaga si fiican u ilaasho.\n\n"
            + "Mar kale hambalyo,\n\n"
            + "Maamulka Iskuulka";

            message.setText(emailBody);
            Transport.send(message);
            return true;
        } catch (Exception e) {
            System.out.println("CILAD EMAIL-KA AH: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
}