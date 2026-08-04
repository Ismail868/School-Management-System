package servlets;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import utils.DBConnection;

@WebServlet("/DeleteTeacherServlet")
public class DeleteTeacherServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String userId = request.getParameter("id"); // Waa ID-ga u dhigma user_id

        if (userId != null && !userId.isEmpty()) {
            Connection con = null;
            PreparedStatement ps1 = null;
            PreparedStatement ps2 = null;
            
            try {
                // 1. Ka hel Connection Pool-ka
                con = DBConnection.getConnection();
                
                if (con != null) {
                    // Bilow Transaction si xogta labada miis looga tirtiro si isku mid ah (Atomic)
                    DBConnection.beginTransaction(con);

                    // 2. Marka hore ka tirtir miiska 'teachers' halka user_id uu ka yahay ID-ga yimid
                    String sql1 = "DELETE FROM teachers WHERE user_id = ?";
                    ps1 = con.prepareStatement(sql1);
                    ps1.setString(1, userId);
                    int rowTeacher = ps1.executeUpdate();

                    // 3. Kadibna ka tirtir miiska 'users' (Akownkiisa)
                    String sql2 = "DELETE FROM users WHERE id = ?";
                    ps2 = con.prepareStatement(sql2);
                    ps2.setString(1, userId);
                    int rowUser = ps2.executeUpdate();

                    // Haddii ugu yaraan mid ka mid ah tirtirmo
                    if (rowTeacher > 0 || rowUser > 0) {
                        DBConnection.commitTransaction(con);
                        response.sendRedirect("teachers.jsp?msg=deleted");
                    } else {
                        DBConnection.rollbackTransaction(con);
                        response.sendRedirect("teachers.jsp?msg=error");
                    }
                } else {
                    response.sendRedirect("teachers.jsp?msg=server_busy");
                }

            } catch (Exception e) {
                e.printStackTrace();
                if (con != null) {
                    DBConnection.rollbackTransaction(con);
                }
                response.sendRedirect("teachers.jsp?msg=exception");
            } finally {
                // Xir PreparedStatement-yada oo Connection-ka dib ugu celi Pool-ka adigoo isticmaalaya hababka DBConnection
                DBConnection.close(ps1);
                DBConnection.close(ps2);
                DBConnection.close(con);
            }
        } else {
            response.sendRedirect("teachers.jsp");
        }
    }
}