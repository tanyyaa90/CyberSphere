<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="header.jsp" %>
<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Phishing Detector | CyberSphere</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        /* CyberSphere dark theme */
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            background: #0a0c10;  /* Dark charcoal background */
            min-height: 100vh;
            position: relative;
        }

        /* Cyber icons background pattern */
        body::before {
            content: '';
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-image: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="%2344634d" stroke-width="1" opacity="0.05"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/><circle cx="12" cy="12" r="3"/></svg>');
            background-repeat: repeat;
            background-size: 60px 60px;
            pointer-events: none;
            z-index: 0;
        }

        .container {
            max-width: 1200px;
            margin: 40px auto;
            padding: 20px;
            position: relative;
            z-index: 1;
        }

        .main-card {
            background: #0f1115;
            padding: 40px;
            border-radius: 24px;
            border: 1px solid #1e1e1e;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
            margin-bottom: 40px;
        }

        .main-card h2 {
            color: #44634d;
            font-size: 28px;
            font-weight: 600;
            margin-bottom: 25px;
            border-left: 3px solid #44634d;
            padding-left: 15px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .main-card h2 i {
            color: #44634d;
        }

        textarea {
            width: 100%;
            padding: 20px;
            border-radius: 12px;
            border: 1px solid #2a2f3a;
            background: #1a1e24;
            color: #ffffff;
            resize: vertical;
            margin-bottom: 20px;
            font-family: 'Courier New', monospace;
            font-size: 14px;
            line-height: 1.6;
        }

        textarea:focus {
            outline: none;
            border-color: #44634d;
            box-shadow: 0 0 0 3px rgba(68, 99, 77, 0.1);
        }

        textarea::placeholder {
            color: #4b5563;
        }

        button {
            padding: 14px 28px;
            border: none;
            border-radius: 10px;
            background: #44634d;
            color: white;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s ease;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            font-size: 15px;
        }

        button:hover:not(:disabled) {
            background: #36523d;
            transform: translateY(-1px);
            box-shadow: 0 10px 20px -10px rgba(68, 99, 77, 0.3);
        }

        button:disabled {
            opacity: 0.5;
            cursor: not-allowed;
            background: #2a2f3a;
        }

        .result-card {
            margin-top: 30px;
            padding: 30px;
            border-radius: 16px;
            background: #1a1e24;
            display: none;
            border: 1px solid #2a2f3a;
        }

        .result-card.show {
            display: block;
        }

        .percentage {
            font-size: 60px;
            font-weight: 700;
            text-align: center;
        }

        #riskLabel {
            text-align: center;
            font-size: 18px;
            margin-bottom: 20px;
        }

        .progress-bar {
            width: 100%;
            height: 10px;
            background: #2a2f3a;
            border-radius: 5px;
            margin: 20px 0;
        }

        .progress-fill {
            height: 100%;
            width: 0%;
            border-radius: 5px;
            transition: width 0.3s ease;
        }

        .factor {
            background: #0f1115;
            padding: 15px;
            border-left: 4px solid #ef4444;
            margin-top: 10px;
            border-radius: 8px;
            color: #f87171;
            border: 1px solid #2a2f3a;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .factor strong {
            color: #ffffff;
        }

        .factor .points {
            background: #2c1515;
            padding: 4px 10px;
            border-radius: 20px;
            font-size: 12px;
            color: #f87171;
            border: 1px solid #3f1f1f;
        }

        /* Samples Section */
        .samples-section {
            margin-top: 40px;
        }

        .samples-title {
            font-size: 24px;
            color: #ffffff;
            margin-bottom: 25px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .samples-title i {
            color: #44634d;
        }

        .samples-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 25px;
        }

        .sample-card {
            background: #0f1115;
            border-radius: 16px;
            overflow: hidden;
            border: 1px solid #1e1e1e;
            transition: all 0.2s ease;
        }

        .sample-card:hover {
            transform: translateY(-5px);
            border-color: #44634d;
            box-shadow: 0 20px 30px -10px rgba(68, 99, 77, 0.2);
        }

        .card-header {
            background: #1a1e24;
            padding: 15px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid #2a2f3a;
        }

        .card-title {
            color: #ffffff;
            font-weight: 600;
            font-size: 14px;
            display: flex;
            align-items: center;
            gap: 6px;
        }

        .card-title i {
            color: #44634d;
        }

        .copy-btn {
            background: #2a2f3a;
            border: none;
            color: #9ca3af;
            padding: 6px 12px;
            border-radius: 6px;
            font-size: 12px;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 5px;
            transition: all 0.2s ease;
        }

        .copy-btn:hover {
            background: #44634d;
            color: white;
        }

        .copy-btn.copied {
            background: #44634d;
            color: white;
        }

        .card-content {
            padding: 15px;
            max-height: 250px;
            overflow-y: auto;
            background: #1a1e24;
            font-size: 12px;
            line-height: 1.6;
            color: #9ca3af;
            border-bottom: 1px solid #2a2f3a;
            font-family: 'Courier New', monospace;
            white-space: pre-wrap;
            word-break: break-all;
        }

        /* Custom scrollbar */
        .card-content::-webkit-scrollbar {
            width: 6px;
        }
        
        .card-content::-webkit-scrollbar-track {
            background: #1a1e24;
        }
        
        .card-content::-webkit-scrollbar-thumb {
            background: #44634d;
            border-radius: 3px;
        }

        .card-footer {
            padding: 12px 15px;
            background: #0f1115;
            font-size: 12px;
            color: #9ca3af;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .phishing-badge {
            display: inline-block;
            padding: 4px 10px;
            border-radius: 20px;
            font-size: 11px;
            font-weight: 600;
        }

        .badge-high {
            background: #2c1515;
            color: #f87171;
            border: 1px solid #3f1f1f;
        }

        .badge-low {
            background: #1a2e1a;
            color: #86efac;
            border: 1px solid #2a4a2a;
        }

        .badge-medium {
            background: #2c2415;
            color: #fbbf24;
            border: 1px solid #3f341f;
        }

        /* Copy Notification */
        .copy-notification {
            position: fixed;
            bottom: 20px;
            right: 20px;
            background: #44634d;
            color: white;
            padding: 12px 24px;
            border-radius: 8px;
            font-size: 14px;
            transform: translateY(100px);
            opacity: 0;
            transition: all 0.3s ease;
            z-index: 1000;
            box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.3);
            display: flex;
            align-items: center;
            gap: 10px;
            border: 1px solid #5a7e64;
        }

        .copy-notification.show {
            transform: translateY(0);
            opacity: 1;
        }

        .copy-notification i {
            font-size: 18px;
        }

        /* Responsive */
        @media (max-width: 768px) {
            .samples-grid {
                grid-template-columns: 1fr;
            }
            
            .main-card {
                padding: 25px;
            }
        }
    </style>
</head>

<body>

<div class="container">
    <div class="main-card">
        <h2>
            <i class="fas fa-shield-halved"></i> 
            Phishing Email Detector
        </h2>
        <textarea id="emailContent" rows="6"
            placeholder="Paste email content here..."></textarea>

        <button onclick="analyzeEmail()" id="analyzeBtn">
            <i class="fas fa-search"></i> Analyze Email
        </button>

        <div id="resultCard" class="result-card">
            <div class="percentage" id="phishPercentage">0%</div>
            <div id="riskLabel">Not Analyzed</div>

            <div class="progress-bar">
                <div id="progressFill" class="progress-fill"></div>
            </div>

            <h4 style="color: #ffffff; margin-bottom: 15px; display: flex; align-items: center; gap: 8px;">
                <i class="fas fa-exclamation-triangle" style="color: #44634d;"></i>
                Risk Factors:
            </h4>
            <div id="riskFactors"></div>
        </div>
    </div>

    <!-- Sample Email Cards Section -->
    <div class="samples-section">
        <h2 class="samples-title">
            <i class="fas fa-envelope-open-text"></i>
            Sample Emails
        </h2>
        
        <div class="samples-grid">
            <!-- Card 1: Urgent Account Suspension (High Risk) -->
            <div class="sample-card">
                <div class="card-header">
                    <span class="card-title"><i class="fas fa-exclamation-triangle"></i> Urgent Account Suspension</span>
                    <button class="copy-btn" onclick="copySample(1, this)">
                        <span><i class="fas fa-copy"></i></span> Copy
                    </button>
                </div>
                <div class="card-content" id="sample1">From: "PayPal Security" &lt;security@paypa1.com&gt;
Reply-To: "PayPal Verification" &lt;verify@paypa1.com&gt;
To: "Customer" &lt;customer@gmail.com&gt;
Date: Fri, 20 Feb 2026 09:45:23 +0530
Subject: URGENT: Your Account Has Been Suspended

Dear Valued Customer,

We have detected unusual activity on your account. 
Your access has been temporarily suspended.

Click here to verify your identity immediately:
http://paypa1-verify.com/login?token=8x7f9k2m

Failure to verify within 24 hours will result in 
permanent account closure.

This is an automated message. Please do not reply.

Thank you,
PayPal Security Team
---
Note: This email is from paypa1.com (not paypal.com)</div>
                <div class="card-footer">
                    <span class="phishing-badge badge-high">High Risk</span>
                    <span>Fake domain, urgency, link manipulation</span>
                </div>
            </div>

            <!-- Card 2: Nigerian Prince Inheritance (High Risk) -->
            <div class="sample-card">
                <div class="card-header">
                    <span class="card-title"><i class="fas fa-crown"></i> Nigerian Prince Inheritance</span>
                    <button class="copy-btn" onclick="copySample(2, this)">
                        <span><i class="fas fa-copy"></i></span> Copy
                    </button>
                </div>
                <div class="card-content" id="sample2">From: "Prince Abdullah" &lt;prince.abdullah@yahoo.co.uk&gt;
To: "Dear Friend" &lt;recipient@gmail.com&gt;
Date: Thu, 19 Feb 2026 14:30:00 +0100
Subject: CONFIDENTIAL BUSINESS PROPOSAL

Dear Friend,

I am Prince Abdullah, son of the late King of Nigeria.
I have $25,000,000 USD stuck in a bank account due to
political instability.

I need your assistance to transfer these funds to your
account. In return, you will receive 30% ($7,500,000).

To proceed, please provide:
- Your full bank account details
- Your full name and address
- A processing fee of $500 for legal documents

This is completely safe and legal.

Awaiting your urgent response,

Prince Abdullah
Email: prince.abdullah@yahoo.co.uk
Phone: +234 803 456 7890</div>
                <div class="card-footer">
                    <span class="phishing-badge badge-high">High Risk</span>
                    <span>Advance fee fraud, requests bank details</span>
                </div>
            </div>

            <!-- Card 3: Legitimate Newsletter (Low Risk) -->
            <div class="sample-card">
                <div class="card-header">
                    <span class="card-title"><i class="fas fa-newspaper"></i> Tech Newsletter</span>
                    <button class="copy-btn" onclick="copySample(3, this)">
                        <span><i class="fas fa-copy"></i></span> Copy
                    </button>
                </div>
                <div class="card-content" id="sample3">From: "Medium Daily Digest" &lt;newsletter@medium.com&gt;
Reply-To: "Medium" &lt;support@medium.com&gt;
To: "Subscriber" &lt;subscriber@gmail.com&gt;
Date: Fri, 20 Feb 2026 08:00:05 -0800
Subject: Your Weekly Tech Digest - Feb 20, 2026

Hi there,

Here are this week's top stories curated for you:

📌 **Tech News**
• OpenAI releases GPT-5 with 1M context window
• Apple announces M3 Ultra chip for Mac Pro
• Google's new AI detects phishing emails

📌 **Cybersecurity**
• 10 tips to protect your online accounts
• New ransomware targeting healthcare
• How to enable 2FA everywhere

📌 **Programming**
• Python 3.13 features you should know
• Rust vs Go: Which one to learn in 2026
• JavaScript framework trends

Read the full articles on our website:
https://medium.com/daily-digest/feb-2026

Happy reading,
The Medium Team

---
To unsubscribe: https://medium.com/preferences
Questions? support@medium.com</div>
                <div class="card-footer">
                    <span class="phishing-badge badge-low">Low Risk</span>
                    <span>Legitimate newsletter, clear unsubscribe link</span>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Copy Notification Toast -->
<div id="copyNotification" class="copy-notification">
    <i class="fas fa-check-circle"></i> Sample copied to clipboard!
</div>

<script>
window.history.pushState(null, null, window.location.href);
window.onpopstate = function () {
    window.location.replace("detectiontools.jsp");
};

function analyzeEmail(){
    const content = document.getElementById("emailContent").value;

    if(content.trim().length < 5){
        alert("Enter email content first.");
        return;
    }

    const btn = document.getElementById("analyzeBtn");
    btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Analyzing...';
    btn.disabled = true;

    fetch("<%= request.getContextPath() %>/PhishingServlet",{
        method:"POST",
        headers:{
            "Content-Type":"application/x-www-form-urlencoded"
        },
        body:"emailContent="+encodeURIComponent(content)
    })
    .then(response => response.json())
    .then(data => {
        document.getElementById("phishPercentage").innerText =
            data.percentage + "%";

        document.getElementById("riskLabel").innerText =
            data.riskLabel;

        document.getElementById("phishPercentage").style.color =
            data.color;

        document.getElementById("riskLabel").style.color =
            data.color;

        const progress = document.getElementById("progressFill");
        progress.style.width = data.percentage + "%";
        progress.style.background = data.color;

        const factorsDiv = document.getElementById("riskFactors");
        factorsDiv.innerHTML = "";

        if(data.factors.length === 0){
            factorsDiv.innerHTML =
                "<div style='color:#86efac; background: #1a2e1a; padding: 15px; border-radius: 8px; border: 1px solid #2a4a2a;'>" +
                "<i class='fas fa-check-circle' style='margin-right: 8px;'></i>No phishing patterns detected.</div>";
        }else{
            data.factors.forEach(f => {
                const div = document.createElement("div");
                div.className = "factor";
                div.innerHTML =
                    "<div><strong>"+f.desc+"</strong></div>" +
                    "<div class='points'>+"+f.points+"%</div>";
                factorsDiv.appendChild(div);
            });
        }

        document.getElementById("resultCard").classList.add("show");
    })
    .catch(err=>{
        alert("Error connecting to servlet.");
        console.error(err);
    })
    .finally(()=>{
        btn.innerHTML = '<i class="fas fa-search"></i> Analyze Email';
        btn.disabled=false;
    });
}

// Copy function with visual feedback
function copySample(sampleId, button) {
    const sampleContent = document.getElementById('sample' + sampleId).innerText;
    
    navigator.clipboard.writeText(sampleContent).then(() => {
        // Show notification
        const notification = document.getElementById('copyNotification');
        notification.classList.add('show');
        
        // Visual feedback on button
        button.classList.add('copied');
        const originalText = button.innerHTML;
        button.innerHTML = '<i class="fas fa-check"></i> Copied!';
        
        setTimeout(() => {
            notification.classList.remove('show');
        }, 2000);
        
        setTimeout(() => {
            button.classList.remove('copied');
            button.innerHTML = originalText;
        }, 2000);
        
        // Paste into textarea
        document.getElementById('emailContent').value = sampleContent;
        
    }).catch(err => {
        alert('Failed to copy: ' + err);
    });
}
</script>

</body>
</html>