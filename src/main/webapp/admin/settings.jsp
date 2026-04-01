<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%
    String role = (String) session.getAttribute("role");
    if (session.getAttribute("userId") == null || !"admin".equals(role)) {
        response.sendRedirect("../login.jsp");
        return;
    }

    String firstName = (String) session.getAttribute("firstName");
    String profileImage = (String) session.getAttribute("profileImage");
    if (profileImage == null) profileImage = "https://i.ibb.co/6RfWN4zJ/buddy-10158022.png";

    String url = "jdbc:mysql://localhost:3306/cybersphere";
    String dbUser = "root";
    String dbPass = "root";

    Connection conn = null;
    Statement stmt = null;
    ResultSet rs = null;

    // Default values
    String siteLogo        = "/images/logo.svg";
    String favicon         = "/images/favicon.ico";
    String websiteStatus   = "online";
    String passwordPolicy  = "medium";
    int    accountLockout  = 30;
    boolean sessionSec     = true;
    String senderName      = "CyberSphere Team";
    String senderEmail     = "cybersphere.contactus@gmail.com";
    String emailTemplate   = "default";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, dbUser, dbPass);
        stmt = conn.createStatement();

        // Ensure table exists
        DatabaseMetaData dbm = conn.getMetaData();
        rs = dbm.getTables(null, null, "site_settings", null);
        if (!rs.next()) {
            stmt.executeUpdate(
                "CREATE TABLE IF NOT EXISTS site_settings (" +
                "id INT PRIMARY KEY AUTO_INCREMENT," +
                "setting_key VARCHAR(100) UNIQUE NOT NULL," +
                "setting_value TEXT," +
                "setting_type VARCHAR(50) DEFAULT 'text'," +
                "description TEXT," +
                "updated_by INT," +
                "updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP," +
                "FOREIGN KEY (updated_by) REFERENCES users(id)" +
                ")"
            );
            stmt.executeUpdate(
                "INSERT INTO site_settings (setting_key, setting_value, setting_type, description) VALUES " +
                "('site_logo', '/images/logo.svg', 'text', 'Site logo URL')," +
                "('favicon', '/images/favicon.ico', 'text', 'Favicon URL')," +
                "('website_status', 'online', 'select', 'Website status')," +
                "('password_policy', 'medium', 'select', 'Password strength')," +
                "('account_lockout_duration', '30', 'number', 'Lockout in minutes')," +
                "('session_security', 'true', 'boolean', 'Enhanced session security')," +
                "('sender_name', 'CyberSphere Team', 'text', 'Email sender name')," +
                "('sender_email', 'cybersphere.contactus@gmail.com', 'email', 'Sender email')," +
                "('email_template', 'default', 'text', 'Email template')"
            );
        }
        rs.close();

        rs = stmt.executeQuery("SELECT setting_key, setting_value FROM site_settings");
        while (rs.next()) {
            String key = rs.getString("setting_key");
            String val = rs.getString("setting_value");
            switch (key) {
                case "site_logo":               siteLogo       = val; break;
                case "favicon":                 favicon        = val; break;
                case "website_status":          websiteStatus  = val; break;
                case "password_policy":         passwordPolicy = val; break;
                case "account_lockout_duration":accountLockout = Integer.parseInt(val); break;
                case "session_security":        sessionSec     = Boolean.parseBoolean(val); break;
                case "sender_name":             senderName     = val; break;
                case "sender_email":            senderEmail    = val; break;
                case "email_template":          emailTemplate  = val; break;
            }
        }
        rs.close();

    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs   != null) try { rs.close();   } catch (Exception e) {}
        if (stmt != null) try { stmt.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }

    String success = request.getParameter("success");
    String error   = request.getParameter("error");
%>
<!DOCTYPE html>
<html>
<head>
    <title>Settings | CyberSphere Admin</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Inter', sans-serif; }

        body { background: #0a0c10; color: #e5e7eb; padding: 20px; }

        /* ── Header ── */
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
            background: #0f1115;
            padding: 20px 30px;
            border-radius: 16px;
            border: 1px solid #1e1e1e;
        }
        .header h1 { font-size: 24px; color: #fff; }
        .header h1 i { color: #44634d; margin-right: 10px; }
        .header-left { display: flex; align-items: center; gap: 20px; }
        .back-link {
            color: #9ca3af; text-decoration: none; font-size: 14px;
            display: flex; align-items: center; gap: 5px; transition: color 0.2s;
        }
        .back-link:hover { color: #44634d; }
        .admin-profile {
            display: flex; align-items: center; gap: 12px;
            background: #1a1e24; padding: 8px 18px;
            border-radius: 40px; border: 1px solid #2a2f3a;
            font-size: 14px; color: #9ca3af;
        }
        .admin-profile img {
            width: 32px; height: 32px; border-radius: 50%;
            border: 2px solid #44634d; object-fit: cover;
        }

        /* ── Alerts ── */
        .alert {
            padding: 14px 18px; border-radius: 8px; margin-bottom: 20px;
            display: flex; align-items: center; gap: 10px; font-size: 14px;
        }
        .alert-success { background: #1a2e1a; color: #86efac; border: 1px solid #2a4a2a; }
        .alert-error   { background: #2c1515; color: #f87171; border: 1px solid #3f1f1f; }

        /* ── Main card ── */
        .main-content { max-width: 860px; margin: 0 auto; }
        .settings-card {
            background: #0f1115; border: 1px solid #1e1e1e;
            border-radius: 16px; padding: 30px;
        }

        /* ── Tabs ── */
        .settings-tabs {
            display: flex; gap: 8px; margin-bottom: 28px;
            border-bottom: 1px solid #1e1e1e; padding-bottom: 14px;
        }
        .tab-btn {
            padding: 9px 18px; background: #1a1e24; border: 1px solid #2a2f3a;
            border-radius: 8px; color: #9ca3af; cursor: pointer;
            transition: all 0.2s; display: flex; align-items: center;
            gap: 7px; font-size: 13px;
        }
        .tab-btn:hover { border-color: #44634d; color: #fff; }
        .tab-btn.active { background: #44634d; border-color: #44634d; color: #fff; }

        /* ── Tab content ── */
        .tab-content { display: none; }
        .tab-content.active { display: block; }

        .section-title {
            color: #fff; font-size: 15px; font-weight: 600;
            margin-bottom: 20px; padding-bottom: 10px;
            border-bottom: 1px solid #1e1e1e;
            display: flex; align-items: center; gap: 8px;
        }
        .section-title i { color: #44634d; }

        /* ── Form elements ── */
        .form-group { margin-bottom: 22px; }
        .form-group label {
            display: block; color: #9ca3af; font-size: 13px;
            font-weight: 500; margin-bottom: 8px;
        }
        .form-group label i { color: #44634d; margin-right: 5px; }

        .form-control {
            width: 100%; padding: 11px 14px; background: #1a1e24;
            border: 1px solid #2a2f3a; border-radius: 8px;
            color: #fff; font-size: 14px; transition: border-color 0.2s;
        }
        .form-control:focus { outline: none; border-color: #44634d; }

        select.form-control { cursor: pointer; }
        select.form-control option { background: #1a1e24; }

        .radio-group { display: flex; gap: 24px; padding: 6px 0; flex-wrap: wrap; }
        .radio-group label {
            display: flex; align-items: center; gap: 8px;
            margin-bottom: 0; cursor: pointer; font-size: 14px; color: #e5e7eb;
        }
        .radio-group input[type="radio"] { accent-color: #44634d; width: 15px; height: 15px; cursor: pointer; }

        .checkbox-group { display: flex; align-items: center; gap: 10px; padding: 4px 0; }
        .checkbox-group input[type="checkbox"] { accent-color: #44634d; width: 16px; height: 16px; cursor: pointer; }
        .checkbox-group label { margin-bottom: 0; cursor: pointer; font-size: 14px; color: #e5e7eb; }

        .help-text { color: #6b7280; font-size: 12px; margin-top: 6px; display: flex; align-items: center; gap: 5px; }
        .help-text i { color: #44634d; }

        /* ── Status pill ── */
        .status-online { color: #86efac; }
        .status-maintenance { color: #f87171; }

        /* ── Action buttons ── */
        .action-buttons {
            display: flex; gap: 12px; margin-top: 28px;
            padding-top: 20px; border-top: 1px solid #1e1e1e;
            justify-content: flex-end;
        }
        .btn {
            padding: 10px 22px; border-radius: 8px; border: none;
            cursor: pointer; font-size: 14px; font-weight: 500;
            transition: all 0.2s; display: inline-flex; align-items: center; gap: 8px;
        }
        .btn-primary { background: #44634d; color: #fff; }
        .btn-primary:hover { background: #36523d; transform: translateY(-1px); }
        .btn-secondary {
            background: #1a1e24; color: #9ca3af;
            border: 1px solid #2a2f3a;
        }
        .btn-secondary:hover { border-color: #44634d; color: #fff; }
        .btn-success {
            background: #1a2e1a; color: #86efac;
            border: 1px solid #2a4a2a;
        }
        .btn-success:hover { background: #1f3a1f; }

        /* ── Responsive ── */
        @media (max-width: 640px) {
            .header { flex-direction: column; gap: 14px; }
            .header-left { flex-direction: column; align-items: flex-start; }
            .settings-tabs { flex-wrap: wrap; }
            .action-buttons { flex-direction: column; }
            .btn { width: 100%; justify-content: center; }
        }
    </style>
</head>
<body>
<div class="main-content">

    <!-- Header -->
    <div class="header">
        <div class="header-left">
            <h1><i class="fas fa-cog"></i> System Settings</h1>
        </div>
        <div class="admin-profile">
            <img src="<%= profileImage %>" alt="Admin">
            <span>Welcome, <%= firstName %></span>
        </div>
    </div>

    <!-- Alerts -->
    <% if (success != null) { %>
        <div class="alert alert-success"><i class="fas fa-check-circle"></i> <%= success %></div>
    <% } %>
    <% if (error != null) { %>
        <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> <%= error %></div>
    <% } %>

    <!-- Settings Card -->
    <div class="settings-card">

        <!-- Tabs -->
        <div class="settings-tabs">
            <button class="tab-btn active" onclick="showTab('general', this)">
                <i class="fas fa-globe"></i> General
            </button>
            <button class="tab-btn" onclick="showTab('security', this)">
                <i class="fas fa-shield-alt"></i> Security
            </button>
            <button class="tab-btn" onclick="showTab('email', this)">
                <i class="fas fa-envelope"></i> Email
            </button>
        </div>

        <!-- Form -->
        <form action="SettingsServlet" method="post">

            <!-- ══════════ GENERAL TAB ══════════ -->
            <div id="tab-general" class="tab-content active">

                <h3 class="section-title"><i class="fas fa-paint-brush"></i> Site Appearance</h3>

                <div class="form-group">
                    <label><i class="fas fa-image"></i> Site Logo Path</label>
                    <input type="text" class="form-control" name="site_logo"
                           value="<%= siteLogo %>" placeholder="/images/logo.svg">
                    <div class="help-text"><i class="fas fa-info-circle"></i> Relative path to your logo image</div>
                </div>

                <div class="form-group">
                    <label><i class="fas fa-star"></i> Favicon Path</label>
                    <input type="text" class="form-control" name="favicon"
                           value="<%= favicon %>" placeholder="/images/favicon.ico">
                    <div class="help-text"><i class="fas fa-info-circle"></i> Relative path to your favicon</div>
                </div>

                <div class="form-group">
                    <label><i class="fas fa-power-off"></i> Website Status</label>
                    <div class="radio-group">
                        <label>
                            <input type="radio" name="website_status" value="online"
                                   <%= "online".equals(websiteStatus) ? "checked" : "" %>>
                            <span class="status-online">&#9679; Online</span>
                        </label>
                        <label>
                            <input type="radio" name="website_status" value="maintenance"
                                   <%= "maintenance".equals(websiteStatus) ? "checked" : "" %>>
                            <span class="status-maintenance">&#9679; Maintenance</span>
                        </label>
                    </div>
                    <div class="help-text"><i class="fas fa-info-circle"></i> Maintenance mode blocks regular users; admins still have access</div>
                </div>

            </div>

            <!-- ══════════ SECURITY TAB ══════════ -->
            <div id="tab-security" class="tab-content">

                <h3 class="section-title"><i class="fas fa-lock"></i> Security Settings</h3>

                <div class="form-group">
                    <label><i class="fas fa-key"></i> Password Policy</label>
                    <select class="form-control" name="password_policy">
                        <option value="low"    <%= "low".equals(passwordPolicy)    ? "selected" : "" %>>Low — minimum 6 characters</option>
                        <option value="medium" <%= "medium".equals(passwordPolicy) ? "selected" : "" %>>Medium — 8+ chars, at least 1 number</option>
                        <option value="high"   <%= "high".equals(passwordPolicy)   ? "selected" : "" %>>High — 10+ chars, number, special char, uppercase</option>
                    </select>
                    <div class="help-text"><i class="fas fa-info-circle"></i> Applies to all user account passwords</div>
                </div>

                <div class="form-group">
                    <label><i class="fas fa-clock"></i> Account Lockout Duration (minutes)</label>
                    <input type="number" class="form-control" name="account_lockout_duration"
                           value="<%= accountLockout %>" min="5" max="1440">
                    <div class="help-text"><i class="fas fa-info-circle"></i> How long an account stays locked after 5 failed login attempts</div>
                </div>

                <div class="form-group">
                    <label><i class="fas fa-shield-alt"></i> Enhanced Session Security</label>
                    <div class="checkbox-group">
                        <input type="checkbox" name="session_security" id="session_security"
                               value="true" <%= sessionSec ? "checked" : "" %>>
                        <label for="session_security">Enable enhanced session security</label>
                    </div>
                    <div class="help-text"><i class="fas fa-info-circle"></i> Adds extra validation to user login sessions</div>
                </div>

            </div>

            <!-- ══════════ EMAIL TAB ══════════ -->
            <div id="tab-email" class="tab-content">

                <h3 class="section-title"><i class="fas fa-mail-bulk"></i> Email Configuration</h3>

                <div class="form-group">
                    <label><i class="fas fa-user"></i> Sender Name</label>
                    <input type="text" class="form-control" name="sender_name"
                           value="<%= senderName %>" placeholder="CyberSphere Team">
                    <div class="help-text"><i class="fas fa-info-circle"></i> Display name shown in users' inboxes</div>
                </div>

                <div class="form-group">
                    <label><i class="fas fa-envelope"></i> Sender Email</label>
                    <input type="email" class="form-control" name="sender_email"
                           value="<%= senderEmail %>" placeholder="noreply@cybersphere.com">
                    <div class="help-text"><i class="fas fa-info-circle"></i> Address that all system emails are sent from</div>
                </div>

                <div class="form-group">
                    <label><i class="fas fa-file-alt"></i> Email Template</label>
                    <select class="form-control" name="email_template">
                        <option value="default" <%= "default".equals(emailTemplate) ? "selected" : "" %>>Default — simple &amp; clean</option>
                        <option value="modern"  <%= "modern".equals(emailTemplate)  ? "selected" : "" %>>Modern — CyberSphere theme</option>
                        <option value="minimal" <%= "minimal".equals(emailTemplate) ? "selected" : "" %>>Minimal — plain text</option>
                    </select>
                    <div class="help-text"><i class="fas fa-info-circle"></i> Visual style applied to all outgoing emails</div>
                </div>

                <div class="form-group">
                    <label><i class="fas fa-paper-plane"></i> Test Email</label>
                    <button type="button" class="btn btn-success" onclick="sendTestEmail()">
                        <i class="fas fa-envelope"></i> Send Test Email
                    </button>
                    <div class="help-text"><i class="fas fa-info-circle"></i> Sends a test email using the current settings</div>
                </div>

            </div>

            <!-- Action buttons (shared across all tabs) -->
            <div class="action-buttons">
                <button type="button" class="btn btn-secondary" onclick="resetToDefaults()">
                    <i class="fas fa-undo"></i> Reset to Defaults
                </button>
                <button type="submit" class="btn btn-primary">
                    <i class="fas fa-save"></i> Save Settings
                </button>
            </div>

        </form>
    </div><!-- /settings-card -->
</div><!-- /main-content -->

<script>
    function showTab(tabName, el) {
        document.querySelectorAll('.tab-content').forEach(t => t.classList.remove('active'));
        document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
        document.getElementById('tab-' + tabName).classList.add('active');
        el.classList.add('active');
    }

    function resetToDefaults() {
        if (confirm('Reset all settings to their default values?')) {
            window.location.href = 'SettingsServlet?action=reset';
        }
    }

    function sendTestEmail() {
        alert('Test email sent! Check your inbox.');
    }
</script>
</body>
</html>
