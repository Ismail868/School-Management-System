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
    
    String bonusStr = request.getParameter("bonus");
    String deductionsStr = request.getParameter("deductions");

    if (userType == null || userIdStr == null || billingMonth == null || amountStr == null ||
        userType.trim().isEmpty() || userIdStr.trim().isEmpty() || amountStr.trim().isEmpty()) {
        response.sendRedirect("payments.jsp?status=invalid_input");
        return;
    }

    int userId = 0;
    double newAmount = 0.0;
    double bonus = 0.0;
    double deductions = 0.0;

    try {
        userId = Integer.parseInt(userIdStr);
        newAmount = Double.parseDouble(amountStr);
        
        if (bonusStr != null && !bonusStr.trim().isEmpty()) {
            bonus = Double.parseDouble(bonusStr);
        }
        if (deductionsStr != null && !deductionsStr.trim().isEmpty()) {
            deductions = Double.parseDouble(deductionsStr);
        }
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
                String updateSql = "UPDATE student_payments SET paid_amount = paid_amount + ?, payment_date = NOW() WHERE student_id = ? AND month_year = ?";
                psAction = conn.prepareStatement(updateSql);
                psAction.setDouble(1, newAmount);
                psAction.setInt(2, userId);
                psAction.setString(3, billingMonth);
                psAction.executeUpdate();
            } else {
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
        // B) XALINTA MUSHAARKA MACALIMIINTA (TEACHERS) - (LAGU XAKAMEYAY GANAAXA IYO BIXINTA)
        // -------------------------------------------------------------
        } else if ("teacher".equalsIgnoreCase(userType)) {

            // 1. Hubi record-ka bishan taagan inuu jiro
            String checkSql = "SELECT id, salary_amount, paid_amount, bonus, deductions FROM teacher_payments WHERE teacher_id = ? AND month_year = ?";
            psCheck = conn.prepareStatement(checkSql);
            psCheck.setInt(1, userId);
            psCheck.setString(2, billingMonth);
            rs = psCheck.executeQuery();

            if (rs.next()) {
                // HADDII RECORD-KU JIRO (UPDATE / BIXIN HARAAGA)
                double baseSalary = rs.getDouble("salary_amount");
                double currentPaid = rs.getDouble("paid_amount");
                double currentBonus = rs.getDouble("bonus");
                double currentDeductions = rs.getDouble("deductions");
                
                // Isku geynta xogta cusub iyo tii hore
                double totalBonus = currentBonus + bonus;
                double totalDeductions = currentDeductions + deductions;
                
                double updatedNetSalary = baseSalary + totalBonus - totalDeductions;
                double totalPaidNow = currentPaid + newAmount;

                // Control Ganaaxa
                if (totalDeductions > (baseSalary + totalBonus)) {
                    response.sendRedirect("payments.jsp?status=error&msg=" + 
                        java.net.URLEncoder.encode("Ganaaxa ayaa ka badan mushaarka macalinka!", "UTF-8"));
                    return;
                }

                // Control Bixinta (Inaan laga badin Net Salary)
                if (totalPaidNow > updatedNetSalary) {
                    response.sendRedirect("payments.jsp?status=error&msg=" + 
                        java.net.URLEncoder.encode("Lacagtaan waxay ka badan tahay haraaga macalinka!", "UTF-8"));
                    return;
                }

                // Xisaabinta Status-ka
                String newStatus = (totalPaidNow >= updatedNetSalary) ? "Paid" : "Partial";

                // Update garaynta DB-ga
                String updateSql = "UPDATE teacher_payments SET paid_amount = ?, bonus = ?, deductions = ?, status = ?, payment_date = NOW() WHERE teacher_id = ? AND month_year = ?";
                psAction = conn.prepareStatement(updateSql);
                psAction.setDouble(1, totalPaidNow);
                psAction.setDouble(2, totalBonus);
                psAction.setDouble(3, totalDeductions);
                psAction.setString(4, newStatus);
                psAction.setInt(5, userId);
                psAction.setString(6, billingMonth);
                psAction.executeUpdate();

            } else {
                // HADDII AY TAHAY MARKII UGU HOREYSAY (INSERT)
                rs.close();
                psCheck.close();

                // Soo hel Base Salary-ga macalinka
                double baseSalary = 0.0;
                String salarySql = "SELECT base_salary FROM teachers WHERE id = ?";
                psCheck = conn.prepareStatement(salarySql);
                psCheck.setInt(1, userId);
                rs = psCheck.executeQuery();
                if (rs.next()) {
                    baseSalary = rs.getDouble("base_salary");
                }

                double netSalary = baseSalary + bonus - deductions;

                // Control Ganaaxa
                if (deductions > (baseSalary + bonus)) {
                    response.sendRedirect("payments.jsp?status=error&msg=" + 
                        java.net.URLEncoder.encode("Ganaaxa ayaa ka badan mushaarka macalinka!", "UTF-8"));
                    return;
                }

                // Control Bixinta
                if (newAmount > netSalary) {
                    response.sendRedirect("payments.jsp?status=error&msg=" + 
                        java.net.URLEncoder.encode("Lacagtaan waxay ka badan tahay haraaga macalinka!", "UTF-8"));
                    return;
                }

                // Xisaabinta Status-ka
                String newStatus = (newAmount >= netSalary) ? "Paid" : (newAmount > 0 ? "Partial" : "Unpaid");

                // Gelin cusub DB-ga
                String insertSql = "INSERT INTO teacher_payments (teacher_id, salary_amount, bonus, deductions, paid_amount, status, month_year, payment_date) VALUES (?, ?, ?, ?, ?, ?, ?, NOW())";
                psAction = conn.prepareStatement(insertSql);
                psAction.setInt(1, userId);
                psAction.setDouble(2, baseSalary);
                psAction.setDouble(3, bonus);
                psAction.setDouble(4, deductions);
                psAction.setDouble(5, newAmount);
                psAction.setString(6, newStatus);
                psAction.setString(7, billingMonth);
                psAction.executeUpdate();
            }
        }
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