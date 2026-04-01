<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ include file="header.jsp" %>
<%!
    private static String escHtml(String s) {
        if(s == null) return "";
        return s.replace("&","&amp;")
                .replace("<","&lt;")
                .replace(">","&gt;")
                .replace("\"","&quot;")
                .replace("'","&#x27;");
    }
%>
<%
String level = request.getParameter("level");
if(level == null){ response.sendRedirect("select_level.jsp"); return; }

Integer userId = (Integer) session.getAttribute("userId");
if(userId == null){ response.sendRedirect("login.jsp"); return; }

String levelSafe    = escHtml(level);
String levelDisplay = escHtml(level.substring(0,1).toUpperCase() + level.substring(1));

String url    = "jdbc:mysql://localhost:3306/cybersphere";
String dbUser = "root";
String dbPass = "root";

Connection con = null;
PreparedStatement ps = null;
ResultSet rs = null;

boolean[] completed      = new boolean[5];
int[]     sublevelScores = new int[5];

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    con = DriverManager.getConnection(url, dbUser, dbPass);

    String sql = "SELECT sub_level, " +
                 "MAX(percentage) AS best_score, " +
                 "CASE WHEN MAX(percentage) >= 35 THEN 1 ELSE 0 END AS is_completed " +
                 "FROM quiz_attempts " +
                 "WHERE user_id = ? AND level = ? " +
                 "GROUP BY sub_level";
    ps = con.prepareStatement(sql);
    ps.setInt(1, userId);
    ps.setString(2, level);
    rs = ps.executeQuery();

    while(rs.next()) {
        int sub  = rs.getInt("sub_level");
        int score = rs.getInt("best_score");
        boolean pass = rs.getBoolean("is_completed");
        if(sub >= 1 && sub <= 5) {
            sublevelScores[sub - 1] = score;
            completed[sub - 1]      = pass;
        }
    }

} catch(Exception e) {
    e.printStackTrace();
} finally {
    if(rs  != null) try { rs.close();  } catch(Exception e){}
    if(ps  != null) try { ps.close();  } catch(Exception e){}
    if(con != null) try { con.close(); } catch(Exception e){}
}

int completedCount = 0;
for(int i = 0; i < 5; i++) if(completed[i]) completedCount++;
boolean levelCompleted = (completedCount == 5);
int progressPct = (completedCount * 100) / 5;

Integer lastQuizPercentage    = (Integer) session.getAttribute("lastQuizPercentage");
Boolean canProceedToNextLevel = (Boolean) session.getAttribute("canProceedToNextLevel");
String  lastCompletedLevel    = (String)  session.getAttribute("lastCompletedLevel");
String  lastCompletedSublevel = (String)  session.getAttribute("lastCompletedSublevel");

if(lastQuizPercentage == null) {
    lastQuizPercentage    = 100;
    canProceedToNextLevel = true;
}

boolean showWarning = lastCompletedLevel != null
    && lastCompletedLevel.equals(level)
    && canProceedToNextLevel != null
    && !canProceedToNextLevel
    && lastQuizPercentage < 35;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= levelDisplay %> | CyberSphere</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        *, *::before, *::after { margin:0; padding:0; box-sizing:border-box; }

        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            background: #0a0c10;
            min-height: 100vh;
            color: #e5e7eb;
            position: relative;
        }

        body::before {
            content: '';
            position: fixed; inset: 0;
            background-image: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="%2344634d" stroke-width="1" opacity="0.04"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/><circle cx="12" cy="12" r="3"/></svg>');
            background-size: 60px 60px;
            pointer-events: none;
            z-index: 0;
        }

        .page {
            max-width: 1100px;
            margin: 36px auto;
            padding: 0 24px 60px;
            position: relative;
            z-index: 1;
        }

        .back-link {
            display: inline-flex;
            align-items: center;
            gap: 7px;
            color: #6b7280;
            text-decoration: none;
            font-size: 14px;
            margin-bottom: 28px;
            transition: color .2s;
        }
        .back-link:hover { color: #44634d; }

        .layout {
            display: grid;
            grid-template-columns: 300px 1fr;
            gap: 24px;
            align-items: start;
        }

        .sidebar { display: flex; flex-direction: column; gap: 18px; position: sticky; top: 24px; }

        .card {
            background: #0f1115;
            border: 1px solid #1e2228;
            border-radius: 18px;
            padding: 26px;
        }

        .level-identity { text-align: center; }

        .level-icon {
            width: 70px; height: 70px;
            border-radius: 50%;
            background: #162119;
            border: 2px solid #44634d;
            display: flex; align-items: center; justify-content: center;
            margin: 0 auto 14px;
            font-size: 28px;
        }

        .level-identity h1 {
            font-size: 22px;
            font-weight: 600;
            color: #fff;
            letter-spacing: -.02em;
            margin-bottom: 4px;
        }
        .level-identity p { font-size: 13px; color: #6b7280; }

        .prog-wrap {
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 14px;
        }

        .prog-labels {
            width: 100%;
            display: flex;
            justify-content: space-between;
            font-size: 12px;
            color: #6b7280;
        }
        .prog-labels strong { color: #e5e7eb; }

        .prog-bar-bg {
            width: 100%;
            height: 8px;
            background: #1e2228;
            border-radius: 10px;
            overflow: hidden;
        }
        .prog-bar-fill {
            height: 100%;
            background: linear-gradient(90deg, #44634d, #5a8066);
            border-radius: 10px;
            width: <%= progressPct %>%;
            transition: width .6s ease;
        }

        .prog-stat {
            font-size: 28px;
            font-weight: 600;
            color: #fff;
            text-align: center;
        }
        .prog-stat span { font-size: 14px; color: #6b7280; font-weight: 400; }

        .stats-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 10px;
        }
        .stat-chip {
            background: #13171d;
            border: 1px solid #1e2228;
            border-radius: 10px;
            padding: 12px;
            text-align: center;
        }
        .stat-chip .num { font-size: 22px; font-weight: 600; color: #fff; }
        .stat-chip .lbl { font-size: 11px; color: #6b7280; margin-top: 2px; }

        .cert-card {
            border-radius: 18px;
            padding: 24px;
            text-align: center;
            position: relative;
            overflow: hidden;
        }
        .cert-card.locked  { background: #0f1115; border: 1px solid #1e2228; }
        .cert-card.unlocked {
            background: #0d1f12;
            border: 2px solid #44634d;
            animation: certGlow 3s ease-in-out infinite;
        }

        @keyframes certGlow {
            0%, 100% { box-shadow: 0 0 20px rgba(68,99,77,.2); }
            50%       { box-shadow: 0 0 40px rgba(68,99,77,.5); }
        }

        .cert-icon { font-size: 36px; margin-bottom: 10px; display: block; }
        .cert-card h3 { font-size: 15px; font-weight: 600; color: #fff; margin-bottom: 6px; }
        .cert-card p  { font-size: 12px; color: #6b7280; margin-bottom: 16px; line-height: 1.5; }

        .cert-btn {
            width: 100%;
            padding: 11px;
            border: none;
            border-radius: 10px;
            font-size: 13px;
            font-weight: 500;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 7px;
            transition: all .2s;
        }
        .cert-btn.active        { background: #44634d; color: #fff; }
        .cert-btn.active:hover  { background: #365340; transform: translateY(-1px); }
        .cert-btn.disabled-btn  { background: #1e2228; color: #4b5563; cursor: not-allowed; }

        .main { display: flex; flex-direction: column; gap: 16px; }

        .warning-banner {
            background: #2c2415;
            border: 1px solid #3f341f;
            border-left: 4px solid #fbbf24;
            border-radius: 12px;
            padding: 14px 18px;
            display: flex;
            align-items: flex-start;
            gap: 12px;
            font-size: 13px;
            color: #fbbf24;
        }
        .warning-banner i      { margin-top: 1px; flex-shrink: 0; }
        .warning-banner strong { color: #fde68a; }

        .sublevel-card {
            background: #0f1115;
            border: 1px solid #1e2228;
            border-radius: 16px;
            padding: 20px 22px;
            display: grid;
            grid-template-columns: 56px 1fr auto auto;
            align-items: center;
            gap: 16px;
            transition: border-color .2s, transform .2s;
        }
        .sublevel-card:hover:not(.card-locked) {
            border-color: #44634d;
            transform: translateX(4px);
        }
        .sublevel-card.card-locked { opacity: .55; }

        .score-ring          { position: relative; width: 56px; height: 56px; flex-shrink: 0; }
        .score-ring svg      { transform: rotate(-90deg); }
        .score-ring .ring-num {
            position: absolute; inset: 0;
            display: flex; align-items: center; justify-content: center;
            font-size: 13px; font-weight: 600; color: #fff;
        }
        .score-ring .ring-num.small { font-size: 11px; }

        .card-info h3 { font-size: 16px; font-weight: 600; color: #fff; margin-bottom: 4px; }
        .card-info p  { font-size: 12px; color: #6b7280; }

        .status-badge {
            font-size: 11px;
            font-weight: 600;
            padding: 4px 12px;
            border-radius: 20px;
            white-space: nowrap;
        }
        .badge-done   { background:#162119; color:#86efac; border:1px solid #1e4a28; }
        .badge-retry  { background:#2c1515; color:#f87171; border:1px solid #3f1f1f; }
        .badge-avail  { background:#13171d; color:#9ca3af; border:1px solid #2a2f3a; }
        .badge-locked { background:#13171d; color:#4b5563; border:1px solid #1e2228; }

        .play-btn {
            width: 44px; height: 44px;
            border-radius: 50%;
            border: 1px solid #2a2f3a;
            background: #13171d;
            color: #44634d;
            font-size: 16px;
            cursor: pointer;
            display: flex; align-items: center; justify-content: center;
            flex-shrink: 0;
            transition: all .2s;
        }
        .play-btn:hover:not(:disabled) {
            background: #44634d;
            color: #fff;
            border-color: #44634d;
            transform: scale(1.08);
        }
        .play-btn:disabled { color: #2a2f3a; cursor: not-allowed; }

        @media (max-width: 860px) {
            .layout { grid-template-columns: 1fr; }
            .sidebar { position: static; }
            .stats-row { grid-template-columns: repeat(4, 1fr); }
        }
        @media (max-width: 560px) {
            .sublevel-card { grid-template-columns: 48px 1fr; }
            .status-badge, .play-btn { display: none; }
            .sublevel-card { cursor: pointer; }
        }
    </style>
</head>
<body>

<div class="page">
    <div class="layout">

        <!-- ══ SIDEBAR ══════════════════════════════ -->
        <aside class="sidebar">

            <div class="card level-identity">
                <div class="level-icon">
                    <% if("beginner".equalsIgnoreCase(level)) { %>
                        <i class="fas fa-seedling"      style="color:#86efac"></i>
                    <% } else if("intermediate".equalsIgnoreCase(level)) { %>
                        <i class="fas fa-bolt"          style="color:#fbbf24"></i>
                    <% } else if("advanced".equalsIgnoreCase(level)) { %>
                        <i class="fas fa-fire"          style="color:#f87171"></i>
                    <% } else { %>
                        <i class="fas fa-shield-halved" style="color:#86efac"></i>
                    <% } %>
                </div>
                <h1><%= levelDisplay %></h1>
                <p>Cybersecurity quiz track</p>
            </div>

            <div class="card prog-wrap">
                <div class="prog-stat">
                    <%= completedCount %><span> / 5</span>
                </div>
                <div style="width:100%">
                    <div class="prog-labels">
                        <span>Progress</span>
                        <strong><%= progressPct %>%</strong>
                    </div>
                    <div style="margin-top:8px" class="prog-bar-bg">
                        <div class="prog-bar-fill"></div>
                    </div>
                </div>
                <div class="stats-row" style="width:100%">
                    <div class="stat-chip">
                        <div class="num" style="color:#86efac"><%= completedCount %></div>
                        <div class="lbl">Completed</div>
                    </div>
                    <div class="stat-chip">
                        <div class="num" style="color:#f87171"><%= 5 - completedCount %></div>
                        <div class="lbl">Remaining</div>
                    </div>
                </div>
            </div>

            <div class="cert-card <%= levelCompleted ? "unlocked" : "locked" %>">
    <span class="cert-icon"><%= levelCompleted ? "🏆" : "🔒" %></span>
    <h3><%= levelDisplay %> Certificate</h3>
    <% if (levelCompleted) { %>
        <p style="color:#86efac">All 5 levels passed! Claim your certificate.</p>
        <form action="CertificateServlet" method="get">
            <input type="hidden" name="level" value="<%= levelSafe %>">
            <button type="submit" class="cert-btn active">
                <i class="fas fa-certificate"></i> Get Certificate
            </button>
        </form>
    <% } else { %>
        <p>Complete all 5 sub-levels with 35%+ to earn this certificate.</p>
        <button class="cert-btn disabled-btn" disabled>
            <i class="fas fa-lock"></i> Locked
        </button>
    <% } %>
</div>
        </aside>

        <!-- ══ MAIN ═══════════════════════════════════ -->
        <div class="main">

            <% if(showWarning) { %>
            <div class="warning-banner">
                <i class="fas fa-exclamation-triangle"></i>
                <div>
                    <strong>Level locked —</strong> you scored <%= lastQuizPercentage %>% on the previous level.
                    You need at least <strong>35%</strong> to unlock the next one.
                    Review the material and try again.
                </div>
            </div>
            <% } %>

            <%
            final double CIRC = 2 * Math.PI * 22;

            for(int i = 1; i <= 5; i++) {
                int idx = i - 1;

                boolean isCompleted = completed[idx];

                boolean isLocked   = false;
                String  lockReason = "";

                if(i > 1) {
                    boolean prevCompleted = completed[i - 2];
                    if(!prevCompleted) {
                        isLocked   = true;
                        lockReason = "Complete Level " + (i - 1) + " with 35%+ first";
                    } else if(showWarning &&
                              lastCompletedSublevel != null &&
                              lastCompletedSublevel.equals(String.valueOf(i - 1))) {
                        isLocked   = true;
                        lockReason = "Scored " + lastQuizPercentage + "% — need 35%";
                    }
                }

                int     sc        = sublevelScores[idx];
                boolean showRetry = !isCompleted && !isLocked && sc > 0 && sc < 35;
                boolean canTake   = !isLocked && !isCompleted;

                String ringColor;
                if(isCompleted)    ringColor = "#86efac";
                else if(showRetry) ringColor = "#f87171";
                else if(canTake)   ringColor = "#44634d";
                else               ringColor = "#2a2f3a";

                double dash   = (sc / 100.0) * CIRC;
                double remain = CIRC - dash;

                String badgeClass, badgeText;
                if(isCompleted)    { badgeClass = "badge-done";   badgeText = "✓ Completed"; }
                else if(showRetry) { badgeClass = "badge-retry";  badgeText = "↻ Retry";     }
                else if(canTake)   { badgeClass = "badge-avail";  badgeText = "Available";   }
                else               { badgeClass = "badge-locked"; badgeText = "🔒 Locked";   }

                String infoLine;
                if(isCompleted)   infoLine = "Completed with " + sc + "%";
                else if(sc > 0)   infoLine = "Previous attempt: " + sc + "% — try again";
                else if(isLocked) infoLine = lockReason;
                else              infoLine = "5 questions · Multiple choice";
            %>

            <div class="sublevel-card <%= isLocked ? "card-locked" : "" %>"
                 <% if(canTake) { %>onclick="document.getElementById('form<%= i %>').submit()"<% } %>>

                <div class="score-ring">
                    <svg width="56" height="56" viewBox="0 0 56 56">
                        <circle cx="28" cy="28" r="22" fill="none" stroke="#1e2228" stroke-width="5"/>
                        <circle cx="28" cy="28" r="22" fill="none"
                            stroke="<%= ringColor %>" stroke-width="5"
                            stroke-dasharray="<%= String.format("%.1f", dash) %> <%= String.format("%.1f", remain) %>"
                            stroke-linecap="round"/>
                    </svg>
                    <div class="ring-num <%= sc == 0 ? "small" : "" %>">
                        <%= sc > 0 ? sc + "%" : (isCompleted ? "✓" : (canTake ? "▶" : "🔒")) %>
                    </div>
                </div>

                <div class="card-info">
                    <h3>Level <%= i %></h3>
                    <p><%= infoLine %></p>
                </div>

                <span class="status-badge <%= badgeClass %>"><%= badgeText %></span>

                <% if(canTake) { %>
                    <form id="form<%= i %>" action="QuizServlet" method="get" style="margin:0">
                        <input type="hidden" name="level"    value="<%= levelSafe %>">
                        <input type="hidden" name="sublevel" value="<%= i %>">
                        <button type="submit" class="play-btn" onclick="event.stopPropagation()">
                            <i class="fas fa-<%= showRetry ? "rotate-right" : "play" %>"></i>
                        </button>
                    </form>
                <% } else { %>
                    <button class="play-btn" disabled>
                        <i class="fas fa-lock"></i>
                    </button>
                <% } %>

            </div>

            <% } %>

        </div>
    </div>
</div>

</body>
</html>