<%@page import="java.sql.*, utils.DBConnection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // 1. HUBINTA SESSION-KA
    if (session.getAttribute("username") == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    // 2. SOO QABASHADA XOGTA FORM-KA
    String userType = request.getParameter("user_type");
    String userIdStr = request.getParameter("user_id");
    String billingMonth = request.getParameter("billing_month");
    String amountStr = request.getParameter("amount");

    // Validating input fields
    if (userType == null || userIdStr == null || billingMonth == null || amountStr == null ||
        userType.trim().isEmpty() || userIdStr.trim().isEmpty() || amountStr.trim().isEmpty()) {
        response.sendRedirect("payments.jsp?status=invalid_input");
        return;
    }

    int userId = 0;
    double newAmount = 0.0;

    try {
        userId = Integer.parseInt(userIdStr);
        newAmount = Double.parseDouble(amountStr);
    } catch (NumberFormatException e) {
        response.sendRedirect("payments.jsp?status=invalid_number");
        return;
    }

    Connection conn = null;
    PreparedStatement psCheck = null;
    PreparedStatement psAction = null;
    ResultSet rs = null;

    try {
        conn = DBConnection.getConnection();

        // -------------------------------------------------------------
        // A) XALINTA LACAGTA ARDAYDA (STUDENTS)
        // -------------------------------------------------------------
        if ("student".equalsIgnoreCase(userType)) {
            
            String checkSql = "SELECT id, paid_amount FROM student_payments WHERE student_id = ? AND month_year = ?";
            psCheck = conn.prepareStatement(checkSql);
            psCheck.setInt(1, userId);
            psCheck.setString(2, billingMonth);
            rs = psCheck.executeQuery();

            if (rs.next()) {
                // UPDATE: Haddii uu bishan horey u lahaa record
                String updateSql = "UPDATE student_payments SET paid_amount = paid_amount + ?, payment_date = NOW() WHERE student_id = ? AND month_year = ?";
                psAction = conn.prepareStatement(updateSql);
                psAction.setDouble(1, newAmount);
                psAction.setInt(2, userId);
                psAction.setString(3, billingMonth);
                psAction.executeUpdate();
            } else {
                // INSERT CUSUB: s.class ayaa lala barbardhigay c.class_name
                String insertSql = "INSERT INTO student_payments (student_id, total_amount, paid_amount, month_year, payment_date) " +
                                   "SELECT s.id, c.monthly_fee, ?, ?, NOW() " +
                                   "FROM students s " +
                                   "JOIN class c ON s.class = c.class_name " +
                                   "WHERE s.id = ?";
                psAction = conn.prepareStatement(insertSql);
                psAction.setDouble(1, newAmount);
                psAction.setString(2, billingMonth);
                psAction.setInt(3, userId);
                psAction.executeUpdate();
            }

        // -------------------------------------------------------------
        // B) XALINTA MUSHAARKA MACALIMIINTA (TEACHERS)
        // -------------------------------------------------------------
        } else if ("teacher".equalsIgnoreCase(userType)) {
            
            String checkSql = "SELECT id, paid_amount FROM teacher_payments WHERE teacher_id = ? AND month_year = ?";
            psCheck = conn.prepareStatement(checkSql);
            psCheck.setInt(1, userId);
            psCheck.setString(2, billingMonth);
            rs = psCheck.executeQuery();

            if (rs.next()) {
                // UPDATE
                String updateSql = "UPDATE teacher_payments SET paid_amount = paid_amount + ?, payment_date = NOW() WHERE teacher_id = ? AND month_year = ?";
                psAction = conn.prepareStatement(updateSql);
                psAction.setDouble(1, newAmount);
                psAction.setInt(2, userId);
                psAction.setString(3, billingMonth);
                psAction.executeUpdate();
            } else {
                // INSERT CUSUB
                String insertSql = "INSERT INTO teacher_payments " +
                                   "(teacher_id, salary_amount, paid_amount, month_year, payment_date, bonus, deductions) " +
                                   "SELECT id, base_salary, ?, ?, NOW(), 0, 0 FROM teachers WHERE id = ?";
                psAction = conn.prepareStatement(insertSql);
                psAction.setDouble(1, newAmount);
                psAction.setString(2, billingMonth);
                psAction.setInt(3, userId);
                psAction.executeUpdate();
            }
        }

        // Guul
        response.sendRedirect("payments.jsp?status=success");

    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect("payments.jsp?status=error&msg=" + java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException ignored) {}
        if (psCheck != null) try { psCheck.close(); } catch (SQLException ignored) {}
        if (psAction != null) try { psAction.close(); } catch (SQLException ignored) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignored) {}
    }
%>