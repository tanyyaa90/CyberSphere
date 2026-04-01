<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.Map, java.text.SimpleDateFormat, java.util.UUID, java.util.Date" %>
<%
    // Generate unique certificate ID
    String certId = "CERT-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
    
    // Format current date if completion date is not provided
    SimpleDateFormat dateFormat = new SimpleDateFormat("MMMM dd, yyyy");
    String formattedDate = dateFormat.format(new Date());
%>
<!DOCTYPE html>
<html>
<head>
    <title>Certificate of Achievement | CyberSphere</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/html2canvas/1.4.1/html2canvas.min.js"></script>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 30px;
        }

        .certificate-wrapper {
            max-width: 1200px;
            width: 100%;
        }

        .certificate {
            background: white;
            padding: 40px 60px;
            border: 2px solid #1a3b5d;
            outline: 15px solid #f0f4fa;
            outline-offset: 8px;
            text-align: center;
            font-family: 'Segoe UI', Arial, sans-serif;
            box-shadow: 0 30px 50px rgba(0,0,0,0.3);
            margin-bottom: 30px;
            position: relative;
            background-image: linear-gradient(45deg, #f8faff 0%, #ffffff 100%);
            aspect-ratio: 1.414; /* Landscape ratio */
            width: 100%;
            display: flex;
            flex-direction: column;
            justify-content: center;
        }

        /* Decorative border lines */
        .certificate:before {
            content: '';
            position: absolute;
            top: 15px;
            left: 15px;
            right: 15px;
            bottom: 15px;
            border: 1px solid #c0c8d9;
            pointer-events: none;
        }

        /* Corner decorations */
        .corner-decoration {
            position: absolute;
            width: 30px;
            height: 30px;
            border: 3px solid #1a3b5d;
        }

        .corner-tl {
            top: 25px;
            left: 25px;
            border-right: none;
            border-bottom: none;
        }

        .corner-tr {
            top: 25px;
            right: 25px;
            border-left: none;
            border-bottom: none;
        }

        .corner-bl {
            bottom: 25px;
            left: 25px;
            border-right: none;
            border-top: none;
        }

        .corner-br {
            bottom: 25px;
            right: 25px;
            border-left: none;
            border-top: none;
        }

        .logo-section {
    display: flex;
    justify-content: center;
    align-items: center;
    margin-bottom: 20px;
}

.logo-img {
    width: 300px;
    max-width: 100%;
    height: auto;
}


        .program-name {
            font-size: 22px;
            color: #4a5568;
            letter-spacing: 2px;
            margin-bottom: 15px;
            font-weight: 400;
        }

        .certificate-title {
            font-size: 42px;
            font-weight: 700;
            color: #1a3b5d;
            margin: 15px 0;
            text-transform: uppercase;
            letter-spacing: 3px;
            text-shadow: 1px 1px 2px rgba(0,0,0,0.1);
        }

        .recipient-line {
            font-size: 18px;
            color: #4a5568;
            margin: 20px 0 5px;
        }

        .recipient-name {
            font-size: 40px;
            font-weight: 700;
            color: #2d3748;
            margin: 5px 0 10px;
            display: inline-block;
            padding: 0 20px;
        }

        .level-text {
            font-size: 24px;
            color: #2d3748;
            margin: 10px 0;
        }

        .level-text strong {
            color: #1a3b5d;
            font-weight: 700;
        }

        .grade-text {
            font-size: 32px;
            font-weight: 700;
            color: #c0a86a;
            margin: 10px 0;
        }

        .achievement-text {
            font-size: 16px;
            color: #2d3748;
            line-height: 1.6;
            max-width: 800px;
            margin: 20px auto;
            padding: 0 30px;
            text-align: center;
        }

        .achievement-text p {
            margin: 8px 0;
        }

        .footer {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-top: 30px;
            padding-top: 20px;
            border-top: 2px solid #e2e8f0;
        }

        .date-cert-id {
            text-align: left;
        }

        .date-cert-id p {
            margin: 3px 0;
            color: #4a5568;
            font-size: 15px;
        }

        .date-cert-id strong {
            color: #1a3b5d;
            font-weight: 600;
        }

        .authorized {
            text-align: right;
            font-size: 16px;
            color: #1a3b5d;
            font-weight: 600;
        }

        .authorized span {
            display: block;
            font-size: 14px;
            color: #718096;
            font-weight: normal;
        }

        .watermark {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%) rotate(-30deg);
            font-size: 100px;
            opacity: 0.03;
            color: #1a3b5d;
            font-weight: bold;
            pointer-events: none;
            white-space: nowrap;
        }

        .actions {
            display: flex;
            gap: 20px;
            justify-content: center;
            margin-top: 30px;
        }

        .btn {
            padding: 15px 40px;
            font-size: 18px;
            font-weight: 600;
            border: none;
            border-radius: 50px;
            cursor: pointer;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            gap: 10px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.2);
            text-decoration: none;
        }

        .btn-download {
            background: linear-gradient(135deg, #1a3b5d, #2c5282);
            color: white;
        }

        .btn-download:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 25px rgba(26, 59, 93, 0.4);
        }

        .btn-print {
            background: linear-gradient(135deg, #6b7280, #4b5563);
            color: white;
        }

        .btn-print:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 25px rgba(75, 85, 99, 0.4);
        }

        .btn-home {
            background: linear-gradient(135deg, #22c55e, #16a34a);
            color: white;
        }

        .btn-home:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 25px rgba(34, 197, 94, 0.4);
        }

        @media print {
            body {
                background: white;
                padding: 0;
            }
            .actions {
                display: none;
            }
            .certificate {
                box-shadow: none;
                outline: none;
                border: 2px solid #000;
            }
        }
    </style>
</head>
<body>
    <%
        String fullName = (String) request.getAttribute("fullName");
        String level = (String) request.getAttribute("level");
        Integer overallPercentage = (Integer) request.getAttribute("overallPercentage");
        String grade = (String) request.getAttribute("grade");
        java.util.Date completionDate = (java.util.Date) request.getAttribute("completionDate");
        
        // Format date
        if (completionDate != null) {
            formattedDate = dateFormat.format(completionDate);
        }
        
        // Get just the letter grade
        String gradeLetter = "";
        if (grade != null) {
            if (grade.contains("A")) gradeLetter = "A";
            else if (grade.contains("B")) gradeLetter = "B";
            else if (grade.contains("C")) gradeLetter = "C";
            else if (grade.contains("D")) gradeLetter = "D";
            else if (grade.contains("E")) gradeLetter = "E";
            else gradeLetter = grade;
        }
    %>

    <div class="certificate-wrapper">
        <div id="certificateContainer">
            <div class="certificate" id="certificate">
                <!-- Corner Decorations -->
                <div class="corner-decoration corner-tl"></div>
                <div class="corner-decoration corner-tr"></div>
                <div class="corner-decoration corner-bl"></div>
                <div class="corner-decoration corner-br"></div>
                
                <!-- Watermark -->
                <div class="watermark">CYBERSPHERE</div>
                
                <!-- Logo Section - Replace with your own logo -->
                <div class="logo-section">
                    <img src="${pageContext.request.contextPath}/images/logo.svg" alt="CyberSphere Logo" class="logo-img" onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';">
                    <div style="display:none; width:100px; height:100px; background:#1a3b5d; border-radius:50%; color:white; align-items:center; justify-content:center; font-size:40px;">
                        <i class="fas fa-shield-alt"></i>
                    </div>
                </div>
                
                <!-- Program Name -->
                <div class="program-name">
                    CYBERSECURITY AWARENESS PROGRAM
                </div>
                
                <!-- Certificate Title - One line -->
                <div class="certificate-title">
                    CERTIFICATE OF ACHIEVEMENT
                </div>
                
                <!-- Recipient -->
                <div class="recipient-line">
                    This is to certify that
                </div>
                <div class="recipient-name">
                    <%= fullName != null ? fullName : "Student Name" %>
                </div>
                
                <!-- Level and Grade in normal text with bold grade -->
                <div class="level-text">
                    has successfully completed the <strong><%= level != null ? level : "Beginner" %> Level</strong> with <strong><%= gradeLetter %></strong> grade      
                </div>
                
                
                
                <!-- Achievement Text -->
                <div class="achievement-text">
                    <p>at CyberSphere. This certification recognizes the participant's dedication, analytical skills,</p>
                    <p>and commitment to strengthening cybersecurity awareness and responsible digital practices.</p>
                    <p>The individual has demonstrated competence and determination in</p>
                    <p>successfully completing the required assessments and challenges.</p>
                </div>
                
                <!-- Footer with Date and Certificate ID -->
                <div class="footer">
                    <div class="date-cert-id">
                        <p><strong>Date:</strong> <%= formattedDate %></p>
                        <p><strong>Certificate ID:</strong> <%= certId %></p>
                    </div>
                    
                    <div class="authorized">
                        CyberSphere Team
                    </div>
                </div>
            </div>
        </div>

        <!-- Action Buttons -->
        <div class="actions">
            <button class="btn btn-download" onclick="downloadCertificate()">
                <i class="fas fa-download"></i> Download Certificate
            </button>
            <button class="btn btn-print" onclick="window.print()">
                <i class="fas fa-print"></i> Print Certificate
            </button>
            <a href="<%= request.getContextPath() %>/select_sublevel.jsp?level=<%= level %>" class="btn btn-home">
                <i class="fas fa-home"></i> Return to Levels
            </a>
        </div>
    </div>

    <script>
        function downloadCertificate() {
            const certificate = document.getElementById('certificate');
            
            html2canvas(certificate, {
                scale: 2,
                backgroundColor: '#ffffff',
                logging: false,
                allowTaint: true,
                useCORS: true
            }).then(canvas => {
                // Create download link
                const link = document.createElement('a');
                link.download = 'CyberSphere_Certificate_' + new Date().getTime() + '.png';
                link.href = canvas.toDataURL('image/png');
                link.click();
            }).catch(error => {
                console.error('Error generating certificate:', error);
                alert('Error generating certificate. Please try again.');
            });
        }

        // Animation on load
        document.addEventListener('DOMContentLoaded', function() {
            const certificate = document.querySelector('.certificate');
            if (certificate) {
                certificate.style.opacity = '0';
                certificate.style.transform = 'scale(0.95)';
                
                setTimeout(() => {
                    certificate.style.transition = 'all 0.5s ease';
                    certificate.style.opacity = '1';
                    certificate.style.transform = 'scale(1)';
                }, 100);
            }
        });
    </script>
</body>
</html>