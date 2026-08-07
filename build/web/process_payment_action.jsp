<%@page import="java.sql.*, utils.DBConnection, java.text.SimpleDateFormat, java.util.Date"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // 1. HUBINTA SESSION-KA
    String adminUser = (String) session.getAttribute("username");
    if (adminUser == null) {
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

    // UNIFIED STATUSES
    final String STATUS_PAID = "Paid";
    final String STATUS_PARTIAL = "Partial";
    final String STATUS_UNPAID = "Unpaid";

    try {
        userId = Integer.parseInt(userIdStr);
        newAmount = Double.parseDouble(amountStr);
        
        if (bonusStr != null && !bonusStr.trim().isEmpty()) {
            bonus = Double.parseDouble(bonusStr);
        }
        if (deductionsStr != null && !deductionsStr.trim().isEmpty()) {
            deductions = Double.parseDouble(deductionsStr);
        }
        
        // SECURITY CHECK 1
        if (newAmount <= 0 && bonus <= 0 && deductions <= 0) {
            response.sendRedirect("payments.jsp?status=error&msg=" + java.net.URLEncoder.encode("Fadlan geli lacag sax ah, gunno, ama ganaax!", "UTF-8"));
            return;
        }
        
        if (newAmount < 0 || bonus < 0 || deductions < 0) {
            response.sendRedirect("payments.jsp?status=error&msg=" + java.net.URLEncoder.encode("Lacagtu ma noqon karto mid taban (Negative)!", "UTF-8"));
            return;
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
        conn.setAutoCommit(false); // TRANSACTION START

        // -------------------------------------------------------------
        // A) XALINTA LACAGTA ARDAYDA (STUDENTS)
        // -------------------------------------------------------------
        if ("student".equalsIgnoreCase(userType)) {
            
            String checkSql = "SELECT id, paid_amount, total_amount FROM student_payments WHERE student_id = ? AND month_year = ? FOR UPDATE";
            psCheck = conn.prepareStatement(checkSql);
            psCheck.setInt(1, userId);
            psCheck.setString(2, billingMonth);
            rs = psCheck.executeQuery();

            if (rs.next()) {
                double currentPaid = rs.getDouble("paid_amount");
                double totalAmount = rs.getDouble("total_amount");
                double backendBalance = totalAmount - currentPaid;
                
                if (newAmount > backendBalance) {
                    conn.rollback();
                    response.sendRedirect("payments.jsp?status=error&msg=" + java.net.URLEncoder.encode("Waa la diiday! Lacagta aad soo dirtay waxay ka badan tahay haraaga ardayga.", "UTF-8"));
                    return;
                }
                
                double totalPaidNow = currentPaid + newAmount;
                String newStatus = (totalPaidNow >= totalAmount) ? STATUS_PAID : STATUS_PARTIAL;

                String updateSql = "UPDATE student_payments SET paid_amount = ?, status = ?, payment_date = NOW() WHERE student_id = ? AND month_year = ?";
                psAction = conn.prepareStatement(updateSql);
                psAction.setDouble(1, totalPaidNow);
                psAction.setString(2, newStatus);
                psAction.setInt(3, userId);
                psAction.setString(4, billingMonth);
                psAction.executeUpdate();
            } else {
                double monthlyFee = 0.0;
                String feeSql = "SELECT c.monthly_fee FROM students s JOIN class c ON s.class = c.class_name WHERE s.id = ?";
                try (PreparedStatement psFee = conn.prepareStatement(feeSql)) {
                    psFee.setInt(1, userId);
                    try (ResultSet rsFee = psFee.executeQuery()) {
                        if (rsFee.next()) {
                            monthlyFee = rsFee.getDouble("monthly_fee");
                        }
                    }
                }

                if (newAmount > monthlyFee) {
                    conn.rollback();
                    response.sendRedirect("payments.jsp?status=error&msg=" + java.net.URLEncoder.encode("Waa la diiday! Lacagta la bixinayo way ka badan tahay khidmadda billaha ah ee ardayga.", "UTF-8"));
                    return;
                }

                String insertSql = "INSERT INTO student_payments (student_id, total_amount, paid_amount, status, month_year, payment_date) " +
                                   "VALUES (?, ?, ?, CASE WHEN ? >= ? THEN ? ELSE ? END, ?, NOW())";
                psAction = conn.prepareStatement(insertSql);
                psAction.setInt(1, userId);
                psAction.setDouble(2, monthlyFee);
                psAction.setDouble(3, newAmount);
                psAction.setDouble(4, newAmount);
                psAction.setDouble(5, monthlyFee);
                psAction.setString(6, STATUS_PAID);
                psAction.setString(7, STATUS_PARTIAL);
                psAction.setString(8, billingMonth);
                psAction.executeUpdate();
            }

        // -------------------------------------------------------------
        // B) XALINTA MUSHAARKA MACALIMIINTA (TEACHERS)
        // -------------------------------------------------------------
        } else if ("teacher".equalsIgnoreCase(userType)) {

            String checkSql = "SELECT id, salary_amount, paid_amount, bonus, deductions FROM teacher_payments WHERE teacher_id = ? AND month_year = ? FOR UPDATE";
            psCheck = conn.prepareStatement(checkSql);
            psCheck.setInt(1, userId);
            psCheck.setString(2, billingMonth);
            rs = psCheck.executeQuery();

            if (rs.next()) {
                double baseSalary = rs.getDouble("salary_amount");
                double currentPaid = rs.getDouble("paid_amount");
                double currentBonus = rs.getDouble("bonus");
                double currentDeductions = rs.getDouble("deductions");
                
                double totalBonus = currentBonus + bonus;
                double totalDeductions = currentDeductions + deductions;
                
                double updatedNetSalary = baseSalary + totalBonus - totalDeductions;
                double backendBalance = updatedNetSalary - currentPaid;
                double totalPaidNow = currentPaid + newAmount;

                if (totalDeductions > (baseSalary + totalBonus)) {
                    conn.rollback();
                    response.sendRedirect("payments.jsp?status=error&msg=" + java.net.URLEncoder.encode("Ganaaxa ayaa ka badan mushaarka macalinka!", "UTF-8"));
                    return;
                }

                if (newAmount > backendBalance) {
                    conn.rollback();
                    response.sendRedirect("payments.jsp?status=error&msg=" + java.net.URLEncoder.encode("Waa la diiday! Lacagtaan waxay ka badan tahay haraaga rasmiga ah ee macalinka!", "UTF-8"));
                    return;
                }

                String newStatus = (totalPaidNow >= updatedNetSalary) ? STATUS_PAID : STATUS_PARTIAL;

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
                rs.close();
                psCheck.close();

                double baseSalary = 0.0;
                String salarySql = "SELECT base_salary FROM teachers WHERE id = ?";
                psCheck = conn.prepareStatement(salarySql);
                psCheck.setInt(1, userId);
                rs = psCheck.executeQuery();
                if (rs.next()) {
                    baseSalary = rs.getDouble("base_salary");
                }

                double netSalary = baseSalary + bonus - deductions;

                if (deductions > (baseSalary + bonus)) {
                    conn.rollback();
                    response.sendRedirect("payments.jsp?status=error&msg=" + java.net.URLEncoder.encode("Ganaaxa ayaa ka badan mushaarka macalinka!", "UTF-8"));
                    return;
                }

                if (newAmount > netSalary) {
                    conn.rollback();
                    response.sendRedirect("payments.jsp?status=error&msg=" + java.net.URLEncoder.encode("Waa la diiday! Lacagtaan waxay ka badan tahay xaqqa/mushaarka macalinka!", "UTF-8"));
                    return;
                }

                String newStatus = (newAmount >= netSalary) ? STATUS_PAID : (newAmount > 0 ? STATUS_PARTIAL : STATUS_UNPAID);

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

        // =============================================================
        // C) DIIWAANGELINTA TAARIIKHDA RASIIDKA (PAYMENT HISTORY LOG)
        // =============================================================
        if (newAmount > 0 || bonus > 0 || deductions > 0) {
            // Samee Nambarka Rasiidka: Tusaale "PAY-20260807-153045" (Taariikhda + Waqtiga oo ilbiriqsi ah si uusan isku dhac u imaan)
            String timestamp = new SimpleDateFormat("yyyyMMdd-HHmmss").format(new Date());
            String receiptNo = "PAY-" + timestamp;

            String historySql = "INSERT INTO payment_history (receipt_no, user_type, user_id, amount, billing_month, processed_by) VALUES (?, ?, ?, ?, ?, ?)";
            try (PreparedStatement psHist = conn.prepareStatement(historySql)) {
                psHist.setString(1, receiptNo);
                psHist.setString(2, userType);
                psHist.setInt(3, userId);
                psHist.setDouble(4, newAmount); // Waa lacagta hadda tooska loo dhiibay
                psHist.setString(5, billingMonth);
                psHist.setString(6, adminUser); // Magaca Admin-ka lacagta qabtay
                psHist.executeUpdate();
            }
        }

        conn.commit(); // COMMIT GUUL AH (Xogta iyo Taariikhda labaduba waa la wada kaydiyay)
        response.sendRedirect("payments.jsp?status=success");

    } catch (Exception e) {
        if (conn != null) {
            try {
                conn.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        }
        
        if (e.getMessage() != null && e.getMessage().toLowerCase().contains("duplicate")) {
            response.sendRedirect("payments.jsp?status=error&msg=" + java.net.URLEncoder.encode("Fadlan sug waxyar oo dib u isku day. Nidaamka ayaa xakameeyay cilad isku-dhac ah.", "UTF-8"));
        } else {
            response.sendRedirect("payments.jsp?status=error&msg=" + java.net.URLEncoder.encode("Cilad ayaa dhacday: " + e.getMessage(), "UTF-8"));
        }
        e.printStackTrace();
        
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException ignored) {}
        if (psCheck != null) try { psCheck.close(); } catch (SQLException ignored) {}
        if (psAction != null) try { psAction.close(); } catch (SQLException ignored) {}
        if (conn != null) try { 
            conn.setAutoCommit(true); 
            conn.close(); 
        } catch (SQLException ignored) {}
    }
%>