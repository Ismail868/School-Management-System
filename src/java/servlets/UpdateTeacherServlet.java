package servlets;

import java.io.*;
import java.sql.*;
import java.util.Properties;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;

import javax.mail.*;
import javax.mail.internet.*;
import utils.DBConnection;

@WebServlet("/UpdateTeacherServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,  // 2MB
    maxFileSize = 1024 * 1024 * 10,        // 10MB
    maxRequestSize = 1024 * 1024 * 50      // 50MB
)
public class UpdateTeacherServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        // Soo aqriso xogta
        String teacherId = request.getParameter("teacher_id");
        String userId = request.getParameter("user_id");
        String fullName = request.getParameter("full_name");
        String username = request.getParameter("username");
        String email = request.getParameter("email"); 
        String status = request.getParameter("status");
        
        String phone = request.getParameter("phone");
        String altPhone = request.getParameter("alt_phone");
        String gender = request.getParameter("gender");
        String dob = request.getParameter("dob");
        String address = request.getParameter("address");
        String qualification = request.getParameter("qualification");
        String experience = request.getParameter("experience_years");
        String previousWorkplaces = request.getParameter("previous_workplaces");
        
        String guarantorName = request.getParameter("guarantor_name");
        String guarantorPhone = request.getParameter("guarantor_phone");
        String guarantorRelation = request.getParameter("guarantor_relation");
        String baseSalary = request.getParameter("base_salary");
        String hireDate = request.getParameter("hire_date");

        // Sawirada Upload-garayntooda
        String oldPhoto = request.getParameter("old_photo");
        String newPhoto = uploadFile(request.getPart("photo"), "uploads/teacher/", request);
        String finalPhoto = (newPhoto != null && !newPhoto.isEmpty()) ? newPhoto : oldPhoto;

        String oldGuarantorId = request.getParameter("old_guarantor_id");
        String newGuarantorId = uploadFile(request.getPart("guarantor_id_image"), "uploads/guarantor/", request);
        String finalGuarantorId = (newGuarantorId != null && !newGuarantorId.isEmpty()) ? newGuarantorId : oldGuarantorId;

        Connection conn = null;
        PreparedStatement pstUser = null;
        PreparedStatement pstTeacher = null;

        try {
            // Xiriirka oo laga keenayo Connection Pool-ka
            conn = DBConnection.getConnection();

            if (conn != null) {
                // Bilaw Transaction-ka si haddii cillad timaado xogtu u soo laabato (Rollback)
                DBConnection.beginTransaction(conn);

                // 1. Update Users Table
                String sqlUser = "UPDATE users SET full_name=?, username=?, status=? WHERE id=?";
                pstUser = conn.prepareStatement(sqlUser);
                pstUser.setString(1, fullName);
                pstUser.setString(2, username);
                pstUser.setString(3, status);
                pstUser.setString(4, userId);
                pstUser.executeUpdate();

                // 2. Update Teachers Table
                String sqlTeacher = "UPDATE teachers SET phone=?, alt_phone=?, gender=?, dob=?, address=?, "
                        + "qualification=?, experience_years=?, previous_workplaces=?, guarantor_name=?, "
                        + "guarantor_phone=?, guarantor_relation=?, base_salary=?, hire_date=?, photo=?, guarantor_id_image=? "
                        + "WHERE id=?";
                pstTeacher = conn.prepareStatement(sqlTeacher);
                pstTeacher.setString(1, phone);
                pstTeacher.setString(2, altPhone);
                pstTeacher.setString(3, gender);
                pstTeacher.setString(4, dob);
                pstTeacher.setString(5, address);
                pstTeacher.setString(6, qualification);
                pstTeacher.setInt(7, experience != null && !experience.isEmpty() ? Integer.parseInt(experience) : 0);
                pstTeacher.setString(8, previousWorkplaces);
                pstTeacher.setString(9, guarantorName);
                pstTeacher.setString(10, guarantorPhone);
                pstTeacher.setString(11, guarantorRelation);
                pstTeacher.setString(12, baseSalary);
                pstTeacher.setString(13, hireDate);
                pstTeacher.setString(14, finalPhoto);
                pstTeacher.setString(15, finalGuarantorId);
                pstTeacher.setString(16, teacherId);
                
                int isUpdated = pstTeacher.executeUpdate();

                if (isUpdated > 0) {
                    // Dhameystir Transaction-ka
                    DBConnection.commitTransaction(conn);

                    // Email u dir macalinka
                    sendEmailNotification(email, fullName);
                    
                    // Ku celi bogga macalimiinta
                    response.sendRedirect("teachers.jsp?msg=update_success");
                } else {
                    DBConnection.rollbackTransaction(conn);
                    response.sendRedirect("teachers.jsp?msg=update_error");
                }
            } else {
                response.sendRedirect("teachers.jsp?msg=server_busy");
            }

        } catch (Exception e) {
            if (conn != null) {
                DBConnection.rollbackTransaction(conn);
            }
            e.printStackTrace();
            response.getWriter().println("Cilad: " + e.getMessage());
        } finally {
            // Xir PreparedStatement-yada oo Connection-ka dib ugu celi Pool-ka
            DBConnection.close(pstUser);
            DBConnection.close(pstTeacher);
            DBConnection.close(conn);
        }
    }

    private String uploadFile(Part part, String uploadDir, HttpServletRequest request) throws IOException {
        if (part != null && part.getSize() > 0) {
            String fileName = getFileName(part);
            String applicationPath = request.getServletContext().getRealPath("");
            String uploadFilePath = applicationPath + File.separator + uploadDir;
            
            File fileSaveDir = new File(uploadFilePath);
            if (!fileSaveDir.exists()) {
                fileSaveDir.mkdirs();
            }
            
            part.write(uploadFilePath + File.separator + fileName);
            return fileName;
        }
        return null;
    }

    private String getFileName(Part part) {
        for (String content : part.getHeader("content-disposition").split(";")) {
            if (content.trim().startsWith("filename")) {
                return content.substring(content.indexOf('=') + 1).trim().replace("\"", "");
            }
        }
        return null;
    }

    private void sendEmailNotification(String toEmail, String teacherName) {
        final String fromEmail = "maxamedxusen652@gmail.com"; 
        final String password = "rgujrgbsrvyxxwwq"; 

        Properties props = new Properties();
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.ssl.trust", "smtp.gmail.com");
        props.put("mail.smtp.ssl.protocols", "TLSv1.2");

        Session session = Session.getInstance(props, new javax.mail.Authenticator() {
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(fromEmail, password);
            }
        });

        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(fromEmail));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject("Ogeysiis: Xogtaada waa la cusbooneysiiyay");
            
            String emailBody =
    "Ku: Macallin " + teacherName + ",\n\n"
    + "Assalaamu Calaykum, waxaan rajaynayaa inaad fiican tahay.\n\n"
    + "Waxaan kuu xaqiijinaybaa in xogtaada macallinimo ee ku jirta kaydka xogta (Database-ka) ee iskuulka si guul leh loo cusboonaysiiyay.\n\n"
    + "Haddii aad adigu codsatay isbeddelkan, wax tallaabo ah lagaama rabo.\n\n"
    + "Haddii aadan adigu samayn isbeddelkan ama aad ka shakisan tahay, fadlan si degdeg ah ula xiriir maamulka iskuulka si loo ilaaliyo amniga akoonkaaga.\n\n"
    + "Waad ku mahadsan tahay kalsoonida aad nagu qabto.\n\n"
    + "Mahadsanid,\n\n"
    + "Maamulka Iskuulka\n";
                    
            message.setText(emailBody);
            Transport.send(message);
            
        } catch (MessagingException e) {
            e.printStackTrace();
        }
    }
}