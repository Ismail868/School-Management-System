<%@page import="java.sql.*, utils.DBConnection"%>
<%
    // 1. Hubi in isticmaalu uu Login yahay
    if (session.getAttribute("username") == null) {
        response.sendRedirect("index.jsp");
        return; 
    }

    // 2. Soo qabso ID-ga maadada la tirtirayo (Waa ID-ga ka muuqda table-ka subjects ee sawirka)
    String idStr = request.getParameter("id");
    
    if (idStr != null && !idStr.trim().isEmpty()) {
        Connection conn = null;
        PreparedStatement ps1 = null;
        PreparedStatement ps2 = null;
        PreparedStatement ps3 = null;

        try {
            int subjectId = Integer.parseInt(idStr);
            conn = DBConnection.getConnection();

            if (conn != null) {
                // Biloow Transaction-ka si ay xogtu u badbaaddo
                DBConnection.beginTransaction(conn);

                // TALAABADA 1: Ka tirtir xiriirka maadada iyo macalinka (teacher_allocations)
                ps1 = conn.prepareStatement("DELETE FROM teacher_allocations WHERE class_subject_id IN (SELECT id FROM class_subjects WHERE subject_id = ?)");
                ps1.setInt(1, subjectId);
                ps1.executeUpdate();

                // TALAABADA 2: Ka tirtir xiriirka maadada iyo fasalka (class_subjects)
                ps2 = conn.prepareStatement("DELETE FROM class_subjects WHERE subject_id = ?");
                ps2.setInt(1, subjectId);
                ps2.executeUpdate();

                // TALAABADA 3: Tirtir maadada lafteeda (subjects) iyadoo la isticmaalayo 'id'
                ps3 = conn.prepareStatement("DELETE FROM subjects WHERE id = ?");
                ps3.setInt(1, subjectId);
                ps3.executeUpdate();

                // Kaydi dhammaan isbedellada (Commit)
                DBConnection.commitTransaction(conn);
            }
        } catch (Exception e) {
            // Haddii ay cillad dhacdo, jooji tirtiridda si database-ku uusan u kharribmin (Rollback)
            if (conn != null) {
                DBConnection.rollbackTransaction(conn);
            }
            e.printStackTrace();
        } finally {
            // Xir xiriirada Database-ka
            DBConnection.close(ps1);
            DBConnection.close(ps2);
            DBConnection.close(ps3);
            DBConnection.close(conn);
        }
    }

    // 3. Dib u celi boggii hore si toos ah (Referer trick)
    String referer = request.getHeader("Referer");
    if (referer != null) {
        response.sendRedirect(referer);
    } else {
        // Haddii uusan aqoonsan boggii hore, wuxuu ku celinayaa bogga hoose (Magaca waad bedeli kartaa)
        response.sendRedirect("classes_subjects.jsp");
    }
%>