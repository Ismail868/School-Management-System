<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>  
        <!-- Dashboard Body -->
        <div class="dashboard-container">
            
            <!-- KPIs -->
            <div class="kpi-grid">
                <div class="kpi-card">
                    <div class="kpi-icon icon-blue"><i class="fas fa-users"></i></div>
                    <div class="kpi-details">
                        <h3 data-i18n="kpi_total_students">Total Students</h3>
                        <h2>1,248</h2>
                        <div class="kpi-trend"><i class="fas fa-arrow-up"></i> 12.5% <span data-i18n="kpi_from_last_month">from last month</span></div>
                    </div>
                </div>
                <div class="kpi-card">
                    <div class="kpi-icon icon-green"><i class="fas fa-chalkboard-teacher"></i></div>
                    <div class="kpi-details">
                        <h3 data-i18n="kpi_total_teachers">Total Teachers</h3>
                        <h2>86</h2>
                        <div class="kpi-trend"><i class="fas fa-arrow-up"></i> 8.3% <span data-i18n="kpi_from_last_month">from last month</span></div>
                    </div>
                </div>
                <div class="kpi-card">
                    <div class="kpi-icon icon-orange"><i class="fas fa-book-open"></i></div>
                    <div class="kpi-details">
                        <h3 data-i18n="kpi_total_classes">Total Classes</h3>
                        <h2>42</h2>
                        <div class="kpi-trend"><i class="fas fa-arrow-up"></i> 5.7% <span data-i18n="kpi_from_last_month">from last month</span></div>
                    </div>
                </div>
                <div class="kpi-card">
                    <div class="kpi-icon icon-red"><i class="fas fa-dollar-sign"></i></div>
                    <div class="kpi-details">
                        <h3 data-i18n="kpi_total_payments">Total Payments</h3>
                        <h2>SOM 125,430</h2>
                        <div class="kpi-trend"><i class="fas fa-arrow-up"></i> 15.8% <span data-i18n="kpi_from_last_month">from last month</span></div>
                    </div>
                </div>
            </div>

            <!-- Middle Section -->
            <div class="middle-grid">
                <!-- Payment Overview -->
                <div class="card">
                    <div class="card-header">
                        <h3 data-i18n="payment_overview">Payment Overview</h3>
                        <select class="dropdown"><option data-i18n="option_this_month">This Month</option></select>
                    </div>
                    <div style="display: flex; align-items: center; gap: 20px;">
                        <div class="chart-container" style="width: 150px; height: 150px; margin: 0 auto;">
                            <canvas id="paymentChart"></canvas>
                        </div>
                        <div class="payment-details" style="flex: 1;">
                            <div class="payment-item">
                                <span class="label"><div class="dot" style="background: #10b981;"></div> <span data-i18n="full_fee_paid">Full Fee Paid</span></span>
                                <strong>SOM 75,200 (60%)</strong>
                            </div>
                            <div class="payment-item">
                                <span class="label"><div class="dot" style="background: #3b82f6;"></div> <span data-i18n="partial_paid">Partial Paid</span></span>
                                <strong>SOM 30,150 (24%)</strong>
                            </div>
                            <div class="payment-item">
                                <span class="label"><div class="dot" style="background: #f59e0b;"></div> <span data-i18n="pending">Pending</span></span>
                                <strong>SOM 20,080 (16%)</strong>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Attendance Overview -->
                <div class="card">
                    <div class="card-header">
                        <h3 data-i18n="attendance_overview">Attendance Overview</h3>
                        <select class="dropdown"><option data-i18n="option_this_week">This Week</option></select>
                    </div>
                    <div class="chart-container">
                        <canvas id="attendanceChart"></canvas>
                    </div>
                </div>

                <!-- Recent Activities -->
                <div class="card">
                    <div class="card-header">
                        <h3 data-i18n="recent_activities">Recent Activities</h3>
                    </div>
                    <ul class="activity-list">
                        <li class="activity-item">
                            <div class="activity-icon bg-blue"><i class="far fa-user"></i></div>
                            <div class="activity-content">
                                <h4 data-i18n="act_1_title">New student registered</h4>
                                <p>Abdi Rahman</p>
                            </div>
                            <span class="activity-time" data-i18n="act_1_time">10 mins ago</span>
                        </li>
                        <li class="activity-item">
                            <div class="activity-icon bg-green"><i class="fas fa-money-bill"></i></div>
                            <div class="activity-content">
                                <h4 data-i18n="act_2_title">Payment received</h4>
                                <p>SOM 350 - Abdi Hassan</p>
                            </div>
                            <span class="activity-time" data-i18n="act_2_time">25 mins ago</span>
                        </li>
                        <li class="activity-item">
                            <div class="activity-icon bg-orange"><i class="fas fa-clipboard-check"></i></div>
                            <div class="activity-content">
                                <h4 data-i18n="act_3_title">Attendance marked</h4>
                                <p><span data-i18n="grade_8">Grade 8</span> - <span data-i18n="math">Mathematics</span></p>
                            </div>
                            <span class="activity-time" data-i18n="act_3_time">1 hour ago</span>
                        </li>
                        <li class="activity-item">
                            <div class="activity-icon bg-purple"><i class="fas fa-user-tie"></i></div>
                            <div class="activity-content">
                                <h4 data-i18n="act_4_title">New teacher registered</h4>
                                <p>Ayaan Mohamed</p>
                            </div>
                            <span class="activity-time" data-i18n="act_4_time">2 hours ago</span>
                        </li>
                        <li class="activity-item">
                            <div class="activity-icon bg-red"><i class="far fa-calendar-alt"></i></div>
                            <div class="activity-content">
                                <h4 data-i18n="act_5_title">Class updated</h4>
                                <p><span data-i18n="grade_10">Grade 10</span> - <span data-i18n="science">Science</span></p>
                            </div>
                            <span class="activity-time" data-i18n="act_5_time">3 hours ago</span>
                        </li>
                    </ul>
                </div>
            </div>

            <!-- Bottom Section -->
            <div class="bottom-grid">
                <!-- Students by Classes -->
                <div class="card">
                    <div class="card-header">
                        <h3 data-i18n="students_by_classes">Students by Classes</h3>
                        <select class="dropdown"><option data-i18n="option_this_month">This Month</option></select>
                    </div>
                    <div class="chart-container" style="height: 180px;">
                        <canvas id="studentsBarChart"></canvas>
                    </div>
                </div>

                <!-- Top Fee Payers -->
                <div class="card">
                    <div class="card-header">
                        <h3 data-i18n="top_fee_payers">Top Fee Payers</h3>
                        <select class="dropdown"><option data-i18n="option_this_month">This Month</option></select>
                    </div>
                    <table>
                        <thead>
                            <tr>
                                <th data-i18n="th_num">#</th>
                                <th data-i18n="th_name">Student Name</th>
                                <th data-i18n="th_class">Class</th>
                                <th data-i18n="th_amount">Amount (SOM)</th>
                                <th data-i18n="th_status">Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td>1</td>
                                <td>Abdi Hassan</td>
                                <td>Grade 10</td>
                                <td>SOM 450</td>
                                <td><span class="status status-paid" data-i18n="status_paid">Paid</span></td>
                            </tr>
                            <tr>
                                <td>2</td>
                                <td>Ayaan Ali</td>
                                <td>Grade 9</td>
                                <td>SOM 450</td>
                                <td><span class="status status-paid" data-i18n="status_paid">Paid</span></td>
                            </tr>
                            <tr>
                                <td>3</td>
                                <td>Mohamed Yusuf</td>
                                <td>Grade 8</td>
                                <td>SOM 450</td>
                                <td><span class="status status-paid" data-i18n="status_paid">Paid</span></td>
                            </tr>
                            <tr>
                                <td>4</td>
                                <td>Fatima Abdullahi</td>
                                <td>Grade 7</td>
                                <td>SOM 450</td>
                                <td><span class="status status-paid" data-i18n="status_paid">Paid</span></td>
                            </tr>
                            <tr>
                                <td>5</td>
                                <td>Omar Farah</td>
                                <td>Grade 6</td>
                                <td>SOM 450</td>
                                <td><span class="status status-paid" data-i18n="status_paid">Paid</span></td>
                            </tr>
                        </tbody>
                    </table>
                </div>

                <!-- Academic Year Banner -->
                <div class="academic-card">
                    <i class="fas fa-graduation-cap academic-graphic"></i>
                    <h4 data-i18n="academic_year">Academic Year</h4>
                    <h2>2024 - 2025</h2>
                    <p data-i18n="second_term">Second Term</p>
                    <button class="btn-report" data-i18n="btn_report">View Full Report</button>
                </div>
            </div>

        </div>
    