<%@ page contentType="text/html;charset=UTF-8" isELIgnored="true" %>
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
    <title>URL Scanner - CyberSphere</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
        }

        body {
            background: #0a0c10;
            min-height: 100vh;
            position: relative;
            color: #e5e7eb;
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
            max-width: 800px;
            margin: 40px auto;
            padding: 0 20px;
            position: relative;
            z-index: 1;
        }

        .main-card {
            background: #0f1115;
            border: 1px solid #1e1e1e;
            border-radius: 24px;
            padding: 40px;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
            margin-bottom: 30px;
        }

        h2 {
            color: #44634d;
            font-size: 28px;
            font-weight: 600;
            margin-bottom: 10px;
            border-left: 3px solid #44634d;
            padding-left: 15px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        h2 i {
            color: #44634d;
        }

        .description {
            color: #9ca3af;
            font-size: 15px;
            line-height: 1.6;
            margin-bottom: 30px;
            margin-left: 10px;
        }

        .form-group {
            margin-bottom: 20px;
        }

        label {
            font-size: 13px;
            font-weight: 500;
            margin-bottom: 8px;
            display: block;
            color: #9ca3af;
            text-transform: uppercase;
            letter-spacing: 0.03em;
        }

        label i {
            color: #44634d;
            margin-right: 8px;
        }

        .url-box {
            position: relative;
            display: flex;
            align-items: center;
        }

        input[type=text] {
            width: 100%;
            padding: 14px 16px;
            font-size: 15px;
            background: #1a1e24;
            border: 1px solid #2a2f3a;
            border-radius: 10px;
            color: #ffffff;
            transition: all 0.2s ease;
        }

        input[type=text]:focus {
            outline: none;
            border-color: #44634d;
            box-shadow: 0 0 0 3px rgba(68, 99, 77, 0.1);
        }

        input[type=text]::placeholder {
            color: #4b5563;
        }

        button {
            margin-top: 10px;
            padding: 14px 28px;
            background: #44634d;
            color: white;
            border: none;
            border-radius: 10px;
            cursor: pointer;
            font-size: 15px;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: all 0.2s ease;
            width: 100%;
            justify-content: center;
        }

        button:hover {
            background: #36523d;
            transform: translateY(-2px);
            box-shadow: 0 10px 20px -10px rgba(68, 99, 77, 0.3);
        }

        button i {
            font-size: 16px;
        }

        .error-message {
            background: #2c1515;
            color: #f87171;
            padding: 12px 16px;
            border-radius: 8px;
            font-size: 14px;
            margin-top: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
            border-left: 3px solid #ef4444;
            border: 1px solid #3f1f1f;
        }

        .error-message i {
            color: #f87171;
        }

        .safe {
            background: #1a2e1a;
            border: 1px solid #2a4a2a;
            padding: 20px 25px;
            border-radius: 16px;
            color: #86efac;
            margin-top: 20px;
            line-height: 1.6;
        }

        .danger {
            background: #2c1515;
            border: 1px solid #3f1f1f;
            padding: 20px 25px;
            border-radius: 16px;
            color: #f87171;
            margin-top: 20px;
            line-height: 1.6;
        }

        .warning {
            background: #2c2415;
            border: 1px solid #3f341f;
            padding: 20px 25px;
            border-radius: 16px;
            color: #fbbf24;
            margin-top: 20px;
            line-height: 1.6;
        }

        .detail-card {
            background: #1a1e24;
            border: 1px solid #2a2f3a;
            border-radius: 16px;
            padding: 20px;
            margin-top: 20px;
            font-size: 14px;
        }

        .risk-bar-wrap {
            background: #0f1115;
            border-radius: 20px;
            height: 12px;
            margin: 10px 0;
            overflow: hidden;
        }

        .risk-bar {
            height: 12px;
            border-radius: 20px;
            transition: width 0.4s;
        }

        .tag {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 12px;
            margin: 2px 4px 2px 0;
            font-weight: 500;
        }

        .tag-danger {
            background: #2c1515;
            color: #f87171;
            border: 1px solid #3f1f1f;
        }

        .tag-warning {
            background: #2c2415;
            color: #fbbf24;
            border: 1px solid #3f341f;
        }

        .tag-safe {
            background: #1a2e1a;
            color: #86efac;
            border: 1px solid #2a4a2a;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 10px;
            font-size: 14px;
        }

        td {
            padding: 10px 8px;
            border-bottom: 1px solid #2a2f3a;
            color: #e5e7eb;
        }

        td:first-child {
            color: #9ca3af;
            width: 140px;
            font-weight: 500;
        }

        tr:last-child td {
            border-bottom: none;
        }

        @media (max-width: 768px) {
            .main-card {
                padding: 25px;
            }
            
            h2 {
                font-size: 24px;
            }
            
            td:first-child {
                width: 100px;
            }
            
            .stats-footer {
                flex-direction: column;
                align-items: center;
                gap: 15px;
            }
        }
    </style>
</head>
<body>

<div class="container">
    <div class="main-card">
        <h2>
            <i class="fas fa-search"></i>
            URL Scanner
        </h2>
        
        <div class="description">
            Check any URL for malware, phishing, fraud, and other threats using IPQualityScore.
            Enter a URL below to analyze its safety.
        </div>

        <form method="post" action="scanUrl">
            <div class="form-group">
                <label><i class="fas fa-link"></i> Enter URL</label>
                <div class="url-box">
                    <input type="text" name="url" placeholder="https://example.com"
                           value="<%= request.getAttribute("scannedUrl") != null ? request.getAttribute("scannedUrl") : "" %>" required/>
                </div>
            </div>
            
            <button type="submit">
                <i class="fas fa-shield-halved"></i> Scan URL
            </button>
        </form>

        <% if (request.getAttribute("error") != null) { %>
            <div class="error-message">
                <i class="fas fa-exclamation-circle"></i>
                <%= request.getAttribute("error") %>
            </div>
        <% } %>

        <% if (request.getAttribute("resultJson") != null) { %>
        <div id="result"></div>
        <script>
    // Prevent browser back button from showing scanned URLs
    (function() {
        // Push a new state to the history
        window.history.pushState(null, null, window.location.href);
        
        // Handle back button press
        window.onpopstate = function() {
            // Redirect to detection tools page
            window.location.href = 'detectiontools.jsp';
        };
        
        // Clear URL input on page load for privacy
        window.addEventListener('load', function() {
            const urlInput = document.getElementById('urlInput');
            if (urlInput) {
                // Only clear if there's no result (meaning it's a fresh page)
                <% if (request.getAttribute("resultJson") == null) { %>
                    urlInput.value = '';
                <% } %>
            }
        });
    })();

    <% if (request.getAttribute("resultJson") != null) { %>
        var raw = <%= request.getAttribute("resultJson") %>;
        var el  = document.getElementById('result');

        if (!raw.success) {
            el.innerHTML = '<div class="warning"><i class="fas fa-exclamation-triangle" style="margin-right: 8px;"></i><strong>Could not analyse URL.</strong> ' + (raw.message || '') + '</div>';
        } else {
            var score = raw.risk_score || 0;
            var unsafe = raw.unsafe || false;
            var phishing = raw.phishing || false;
            var malware = raw.malware || false;
            var spam = raw.spamming || false;
            var parking = raw.parking || false;

            // Risk bar color
            var barColor = score >= 71 ? '#ef4444' : score >= 36 ? '#fbbf24' : '#86efac';

            // Verdict box
            var verdictHtml = '';
            // new thresholds: 1-35 low, 36-70 medium, 71-100 high
            if (score >= 71 || phishing || malware) {
                verdictHtml = '<div class="danger">' +
                    '<i class="fas fa-skull-crosswind" style="margin-right: 10px; font-size: 18px;"></i>' +
                    '<strong>High Risk (Score: ' + score + '/100) — Do not visit this URL!</strong><br>' +
                    (phishing ? 'Phishing site detected. ' : '') +
                    (malware  ? 'Malware distribution detected. ' : '') +
                    (score >= 71 && !phishing && !malware ? 'This URL has a very high risk score.' : '') +
                    '</div>';
            } else if (score >= 36 || unsafe) {
                verdictHtml = '<div class="warning">' +
                    '<i class="fas fa-exclamation-triangle" style="margin-right: 10px; font-size: 18px;"></i>' +
                    '<strong>Medium Risk (Score: ' + score + '/100) — Proceed with caution.</strong><br>' +
                    'This URL shows some suspicious signals but is not confirmed malicious.</div>';
            } else {
                verdictHtml = '<div class="safe">' +
                    '<i class="fas fa-check-circle" style="margin-right: 10px; font-size: 18px;"></i>' +
                    '<strong>Low Risk (Score: ' + score + '/100) — URL appears safe.</strong><br>' +
                    'No major threats detected. Always stay cautious with unknown links.</div>';
            }

            // Flags
            var flags = '';
            if (phishing) flags += '<span class="tag tag-danger"><i class="fas fa-fish" style="margin-right: 4px;"></i> Phishing</span>';
            if (malware)  flags += '<span class="tag tag-danger"><i class="fas fa-virus" style="margin-right: 4px;"></i> Malware</span>';
            if (spam)     flags += '<span class="tag tag-warning"><i class="fas fa-envelope" style="margin-right: 4px;"></i> Spam</span>';
            if (parking)  flags += '<span class="tag tag-warning"><i class="fas fa-parking" style="margin-right: 4px;"></i> Parked</span>';
            if (raw.suspicious) flags += '<span class="tag tag-warning"><i class="fas fa-eye" style="margin-right: 4px;"></i> Suspicious</span>';
            if (!phishing && !malware && !spam && !raw.suspicious)
                            flags += '<span class="tag tag-safe"><i class="fas fa-check" style="margin-right: 4px;"></i> Clean</span>';

            // Detail table
            var details =
                '<tr><td>Risk score</td><td>' +
                    '<div class="risk-bar-wrap"><div class="risk-bar" style="width:' + score + '%;background:' + barColor + '"></div></div>' +
                    '<span style="color: #e5e7eb; margin-left: 5px;">' + score + ' / 100</span>' +
                '</td></tr>' +
                '<tr><td>Domain</td><td>' + (raw.domain || '-') + '</td></tr>' +
                '<tr><td>IP address</td><td>' + (raw.ip_address || '-') + '</td></tr>' +
                '<tr><td>Country</td><td>' + (raw.country_code || '-') + '</td></tr>' +
                '<tr><td>Server</td><td>' + (raw.server || '-') + '</td></tr>' +
                '<tr><td>Domain age</td><td>' + (raw.domain_age ? raw.domain_age.human : '-') + '</td></tr>' +
                '<tr><td>HTTPS</td><td>' + (raw.https ? '<span style="color: #86efac;">Yes</span>' : '<span style="color: #f87171;">No</span>') + '</td></tr>' +
                '<tr><td>Redirected</td><td>' + (raw.redirected ? '<span style="color: #fbbf24;">Yes</span> — to ' + (raw.final_url || '?') : '<span style="color: #9ca3af;">No</span>') + '</td></tr>' +
                '<tr><td>Flags</td><td>' + flags + '</td></tr>';

            el.innerHTML = verdictHtml +
                '<div class="detail-card"><table>' + details + '</table></div>';
        }
    <% } %>
</script>
        <% } %>
    </div>

</div>

</body>
</html>