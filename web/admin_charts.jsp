 <script>
        // --- Mobile Sidebar Toggle Logic ---
const menuBtn = document.querySelector('.fa-bars');
const sidebar = document.querySelector('.sidebar');

// Marka la taabto astaanta menu-ga
menuBtn.addEventListener('click', (e) => {
    e.stopPropagation(); // Wuxuu ka hortagayaa in taabashadu ay meel kale u gudubto
    sidebar.classList.toggle('show');
});

// Marka meel ka baxsan sidebar-ka la taabto si uu u xirmo
document.addEventListener('click', (e) => {
    // Hubi in shaashaddu tahay mobeel (cabirkeedu yahay 768px ama ka yar)
    if (window.innerWidth <= 768) {
        // Haddii meesha la taabtay aysan ku dhex jirin sidebar-ka ama aysan ahayn menu button-ka
        if (!sidebar.contains(e.target) && e.target !== menuBtn) {
            sidebar.classList.remove('show');
        }
    }
});
        Chart.defaults.font.family = "'Inter', sans-serif";
        Chart.defaults.color = '#64748b';

        // Payment Doughnut Chart
        const ctxPayment = document.getElementById('paymentChart').getContext('2d');
        var paymentChart = new Chart(ctxPayment, {
            type: 'doughnut',
            data: {
                labels: ['Full Fee', 'Partial', 'Pending'],
                datasets: [{
                    data: [60, 24, 16],
                    backgroundColor: ['#10b981', '#3b82f6', '#f59e0b'],
                    borderWidth: 0,
                    cutout: '75%'
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: { 
                    legend: { display: false } 
                }
            },
            plugins: [{
                id: 'textCenter',
                beforeDraw: function(chart) {
                    var width = chart.width, height = chart.height, ctx = chart.ctx;
                    ctx.restore();
                    ctx.font = "bold 14px Inter";
                    ctx.textBaseline = "middle";
                    ctx.fillStyle = "#1e293b";
                    var text = "SOM 125,430",
                        textX = Math.round((width - ctx.measureText(text).width) / 2),
                        textY = height / 2 - 5;
                    ctx.fillText(text, textX, textY);
                    
                    ctx.font = "10px Inter";
                    ctx.fillStyle = "#64748b";
                    var text2 = translations[currentLang] ? translations[currentLang].total_collected_text : "Total Collected",
                        text2X = Math.round((width - ctx.measureText(text2).width) / 2),
                        text2Y = height / 2 + 10;
                    ctx.fillText(text2, text2X, text2Y);
                    ctx.save();
                }
            }]
        });

        // Attendance Line Chart
        const ctxAttendance = document.getElementById('attendanceChart').getContext('2d');
        var attendanceChart = new Chart(ctxAttendance, {
            type: 'line',
            data: {
                labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
                datasets: [
                    {
                        label: translations[currentLang].chart_students_att,
                        data: [72, 80, 62, 78, 83, 58],
                        borderColor: '#3b82f6',
                        backgroundColor: '#3b82f6',
                        tension: 0.4,
                        borderWidth: 2,
                        pointBackgroundColor: '#fff',
                        pointBorderColor: '#3b82f6',
                        pointBorderWidth: 2,
                        pointRadius: 4
                    },
                    {
                        label: translations[currentLang].chart_teachers_att,
                        data: [55, 65, 46, 62, 65, 38],
                        borderColor: '#10b981',
                        backgroundColor: '#10b981',
                        tension: 0.4,
                        borderWidth: 2,
                        pointBackgroundColor: '#fff',
                        pointBorderColor: '#10b981',
                        pointBorderWidth: 2,
                        pointRadius: 4
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'bottom',
                        labels: { boxWidth: 8, usePointStyle: true, pointStyle: 'circle', padding: 20 }
                    }
                },
                scales: {
                    y: {
                        min: 0,
                        max: 100,
                        ticks: { stepSize: 25, callback: function(value) { return value + '%'; } },
                        border: { display: false },
                        grid: { color: '#f1f5f9' }
                    },
                    x: {
                        grid: { display: false },
                        border: { display: false }
                    }
                }
            }
        });

        // Students Bar Chart
        const ctxStudents = document.getElementById('studentsBarChart').getContext('2d');
        new Chart(ctxStudents, {
            type: 'bar',
            data: {
                labels: ['Grade 1', 'Grade 2', 'Grade 3', 'Grade 4', 'Grade 5', 'Grade 6', 'Grade 7', 'Grade 8', 'Grade 9', 'Grade 10'],
                datasets: [{
                    data: [120, 80, 150, 110, 130, 170, 100, 90, 120, 145],
                    backgroundColor: '#3b82f6',
                    borderRadius: 2,
                    barPercentage: 0.6
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: { legend: { display: false } },
                scales: {
                    y: {
                        min: 0,
                        max: 200,
                        ticks: { stepSize: 50 },
                        border: { display: false },
                        grid: { color: '#f1f5f9' }
                    },
                    x: {
                        grid: { display: false },
                        border: { display: false },
                        ticks: { font: { size: 10 } }
                    }
                }
            }
        });
    </script>