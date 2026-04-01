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
    <title>SSL Certificate Checker | CyberSphere</title>
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

        .domain-box {
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

        .days-bar-wrap {
            background: #0f1115;
            border-radius: 20px;
            height: 10px;
            margin: 6px 0;
            width: 100%;
            overflow: hidden;
        }

        .days-bar {
            height: 10px;
            border-radius: 20px;
            transition: width 0.4s;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 10px;
            font-size: 14px;
        }

        td {
            padding: 12px 8px;
            border-bottom: 1px solid #2a2f3a;
            color: #e5e7eb;
        }

        td:first-child {
            color: #9ca3af;
            width: 160px;
            font-weight: 500;
        }

        tr:last-child td {
            border-bottom: none;
        }

        .tag {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 12px;
            margin: 2px 4px 2px 0;
            font-weight: 500;
        }

        .tag-safe {
            background: #1a2e1a;
            color: #86efac;
            border: 1px solid #2a4a2a;
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

        .tip {
            font-size: 13px;
            margin-top: 12px;
            color: #9ca3af;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .tip i {
            color: #44634d;
        }


        @media (max-width: 768px) {
            .main-card {
                padding: 25px;
            }
            
            h2 {
                font-size: 24px;
            }
            
            td:first-child {
                width: 120px;
            }
            

        }
    </style>
</head>
<body>

<div class="container">
    <div class="main-card">
        <h2>
            <i class="fas fa-lock"></i>
            SSL Certificate Checker
        </h2>
        
        <div class="description">
            Check the SSL certificate of any website — expiry, issuer, protocol and more.
            Enter a domain name to analyze its security.
        </div>

        <form method="post" action="checkSsl">
            <div class="form-group">
                <label><i class="fas fa-globe"></i> Enter Domain</label>
                <div class="domain-box">
                    <input type="text" name="domain" id="domainInput" placeholder="google.com"
                           value="<%= request.getAttribute("domain") != null ? request.getAttribute("domain") : "" %>" required/>
                </div>
            </div>
            
            <button type="submit">
                <i class="fas fa-search"></i> Check SSL
            </button>
        </form>

        <%-- Generic error --%>
        <% if (request.getAttribute("error") != null) { %>
            <div class="danger" style="margin-top:20px;">
                <i class="fas fa-exclamation-circle" style="margin-right: 8px;"></i>
                <strong>Error:</strong> <%= request.getAttribute("error") %>
            </div>
        <% } %>

        <%-- Expired certificate error --%>
        <% if (Boolean.TRUE.equals(request.getAttribute("expiredError"))) { %>
            <div class="danger" style="margin-top:20px;">
                <i class="fas fa-skull-crosswind" style="margin-right: 8px;"></i>
                <strong>Certificate Expired!</strong> The SSL certificate for
                <strong><%= request.getAttribute("domain") %></strong> has expired.
                <div class="tip">
                    <i class="fas fa-lightbulb"></i>
                    Java rejected the connection because the certificate is no longer valid.
                    Visiting this site is unsafe — your connection cannot be trusted.
                </div>
            </div>
        <% } %>

        <%-- Self-signed certificate error --%>
        <% if (Boolean.TRUE.equals(request.getAttribute("selfSignedError"))) { %>
            <div class="danger" style="margin-top:20px;">
                <i class="fas fa-exclamation-triangle" style="margin-right: 8px;"></i>
                <strong>Self-Signed Certificate!</strong> The SSL certificate for
                <strong><%= request.getAttribute("domain") %></strong> is not trusted.
                <div class="tip">
                    <i class="fas fa-lightbulb"></i>
                    This certificate was not issued by a trusted authority — it was
                    self-signed by the site owner. This could mean the site is trying
                    to intercept your connection.
                </div>
            </div>
        <% } %>

        <%-- Valid certificate results --%>
        <% if (Boolean.TRUE.equals(request.getAttribute("checked"))) {
            boolean isExpired    = (boolean) request.getAttribute("isExpired");
            boolean expiringSoon = (boolean) request.getAttribute("expiringSoon");
            long daysLeft        = (long)    request.getAttribute("daysLeft");
            String protocol      = (String)  request.getAttribute("protocol");
            boolean weakProtocol = protocol.equals("TLSv1") || protocol.equals("TLSv1.1") || protocol.equals("SSLv3");
        %>

            <%-- Verdict banner --%>
            <% if (isExpired) { %>
                <div class="danger">
                    <i class="fas fa-skull-crosswind" style="margin-right: 10px; font-size: 18px;"></i>
                    <strong>Certificate Expired!</strong> This site's SSL certificate has expired.
                    Visiting it may be unsafe — your connection is not secure.
                </div>
            <% } else if (expiringSoon) { %>
                <div class="warning">
                    <i class="fas fa-exclamation-triangle" style="margin-right: 10px; font-size: 18px;"></i>
                    <strong>Expiring Soon!</strong> This certificate expires in
                    <strong><%= daysLeft %> days</strong>.
                    The site owner should renew it before it expires.
                </div>
            <% } else if (weakProtocol) { %>
                <div class="warning">
                    <i class="fas fa-exclamation-triangle" style="margin-right: 10px; font-size: 18px;"></i>
                    <strong>Weak Protocol Detected!</strong> This site uses
                    <strong><%= protocol %></strong> which is outdated and considered insecure.
                    Modern sites should use TLSv1.2 or TLSv1.3.
                </div>
            <% } else { %>
                <div class="safe">
                    <i class="fas fa-check-circle" style="margin-right: 10px; font-size: 18px;"></i>
                    <strong>Certificate is Valid!</strong> This site has a healthy SSL certificate
                    with <strong><%= daysLeft %> days</strong> remaining.
                </div>
            <% } %>

            <%-- Detail table --%>
            <div class="detail-card">
                <table>
                    <tr>
                        <td>Domain</td>
                        <td><strong><%= request.getAttribute("domain") %></strong></td>
                    </tr>
                    <tr>
                        <td>Issued to</td>
                        <td><%= request.getAttribute("cn") %></td>
                    </tr>
                    <tr>
                        <td>Issued by</td>
                        <td><%= request.getAttribute("issuerOrg") %></td>
                    </tr>
                    <tr>
                        <td>Valid from</td>
                        <td><%= request.getAttribute("validFrom") %></td>
                    </tr>
                    <tr>
                        <td>Valid to</td>
                        <td><%= request.getAttribute("validTo") %></td>
                    </tr>
                    <tr>
                        <td>Days remaining</td>
                        <td>
                            <%
                                long days = daysLeft;
                                long barWidth = days <= 0 ? 0 : Math.min(days, 365) * 100 / 365;
                                String barColor = days <= 0 ? "#ef4444" : days <= 30 ? "#fbbf24" : "#86efac";
                            %>
                            <div class="days-bar-wrap">
                                <div class="days-bar" style="width:<%= barWidth %>%;background:<%= barColor %>;"></div>
                            </div>
                            <span style="color: <%= barColor %>; font-weight: 600;">
                                <%= days <= 0 ? "Expired" : days + " days" %>
                            </span>
                        </td>
                    </tr>
                    <tr>
                        <td>Protocol</td>
                        <td>
                            <span class="tag <%= weakProtocol ? "tag-danger" : "tag-safe" %>">
                                <%= protocol %>
                            </span>
                        </td>
                    </tr>
                    <tr>
                        <td>Cipher suite</td>
                        <td style="font-size:12px; color: #9ca3af;"><%= request.getAttribute("cipher") %></td>
                    </tr>
                    <tr>
                        <td>Alt names (SANs)</td>
                        <td style="font-size:12px; color: #9ca3af;"><%= request.getAttribute("sans") %></td>
                    </tr>
                </table>
            </div>

        <% } %>
    </div>
</div>

<script>
    // Prevent browser back button from showing previous domains
    (function() {
        // Push a new state to the history
        window.history.pushState(null, null, window.location.href);
        
        // Handle back button press
        window.onpopstate = function() {
            // Redirect to detection tools page
            window.location.href = 'detectiontools.jsp';
        };
        
        // Clear domain input on page load for privacy
        window.addEventListener('load', function() {
            const domainInput = document.getElementById('domainInput');
            if (domainInput) {
                // Only clear if there's no result (meaning it's a fresh page)
                <% if (request.getAttribute("checked") == null && 
                       request.getAttribute("error") == null && 
                       request.getAttribute("expiredError") == null && 
                       request.getAttribute("selfSignedError") == null) { %>
                    domainInput.value = '';
                <% } %>
            }
        });
    })();
</script>

</body>
</html>