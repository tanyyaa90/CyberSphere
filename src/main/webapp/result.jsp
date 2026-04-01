<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.Set, java.util.Map, java.util.LinkedHashSet" %>
<%
    // Guard: must be logged in
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Try request attributes first (fresh forward from QuizServlet)
    Integer score      = (Integer)   request.getAttribute("score");
    Integer total      = (Integer)   request.getAttribute("total");
    Integer percentage = (Integer)   request.getAttribute("percentage");
    Boolean canProceed = (Boolean)   request.getAttribute("canProceed");
    Set<String> weakTopics = (Set<String>) request.getAttribute("weakTopics");
    String quizLevel   = (String)    request.getAttribute("level");
    String sublevel    = (String)    request.getAttribute("sublevel");

    // Fall back to session if request attributes missing (page refresh / revisit)
    if (score == null) {
        Map<String, Object> lastResult =
            (Map<String, Object>) session.getAttribute("lastQuizResult");

        if (lastResult == null) {
            response.sendRedirect("home.jsp");
            return;
        }

        score      = (Integer)     lastResult.get("score");
        total      = (Integer)     lastResult.get("total");
        percentage = (Integer)     lastResult.get("percentage");
        canProceed = (Boolean)     lastResult.get("canProceed");
        weakTopics = (Set<String>) lastResult.get("weakTopics");
        quizLevel  = (String)      lastResult.get("level");
        sublevel   = (String)      lastResult.get("sublevel");
    }

    // Final null guard
    if (score == null || total == null) {
        response.sendRedirect("home.jsp");
        return;
    }

    double calculatedPercentage = (score * 100.0) / total;
    int    wrongCount           = total - score;

    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    String levelDisplay = (quizLevel != null)
        ? quizLevel.substring(0,1).toUpperCase() + quizLevel.substring(1)
        : "General";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Quiz Results | CyberSphere</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.1/chart.umd.min.js"></script>
    <style>
        *, *::before, *::after { margin:0; padding:0; box-sizing:border-box; }

        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            background: #0a0c10;
            min-height: 100vh;
            color: #e5e7eb;
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
            max-width: 860px;
            margin: 40px auto;
            padding: 0 20px 60px;
            position: relative;
            z-index: 1;
        }

        /* ── Header ── */
        .page-header {
            text-align: center;
            margin-bottom: 32px;
        }
        .page-header h1 {
            font-size: 26px;
            font-weight: 700;
            color: #fff;
            letter-spacing: -.02em;
        }
        .page-header p {
            font-size: 14px;
            color: #6b7280;
            margin-top: 6px;
        }
        .level-pill {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            background: #162119;
            border: 1px solid #2a4a2a;
            color: #86efac;
            font-size: 12px;
            font-weight: 600;
            padding: 4px 12px;
            border-radius: 20px;
            margin-bottom: 14px;
        }

        /* ── Cards ── */
        .card {
            background: #0f1115;
            border: 1px solid #1e2228;
            border-radius: 20px;
            padding: 28px;
            margin-bottom: 20px;
        }
        .card-title {
            font-size: 14px;
            font-weight: 600;
            color: #6b7280;
            text-transform: uppercase;
            letter-spacing: .06em;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .card-title i { color: #44634d; }

        /* ── Hero score row ── */
        .hero-row {
            display: grid;
            grid-template-columns: 220px 1fr;
            gap: 32px;
            align-items: center;
        }

        .donut-wrap {
            position: relative;
            width: 200px;
            height: 200px;
            margin: 0 auto;
        }
        .donut-wrap canvas { display: block; }
        .donut-center {
            position: absolute;
            inset: 0;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            pointer-events: none;
        }
        .donut-pct {
            font-size: 36px;
            font-weight: 700;
            color: #fff;
            line-height: 1;
        }
        .donut-label {
            font-size: 12px;
            color: #6b7280;
            margin-top: 4px;
        }

        .score-meta { display: flex; flex-direction: column; gap: 16px; }

        .meta-stat {
            display: flex;
            align-items: center;
            gap: 14px;
        }
        .meta-icon {
            width: 44px; height: 44px;
            border-radius: 12px;
            display: flex; align-items: center; justify-content: center;
            font-size: 18px;
            flex-shrink: 0;
        }
        .meta-icon.green  { background:#162119; color:#86efac; }
        .meta-icon.red    { background:#2c1515; color:#f87171; }
        .meta-icon.yellow { background:#2c2415; color:#fbbf24; }

        .meta-info .val { font-size: 22px; font-weight: 700; color: #fff; }
        .meta-info .lbl { font-size: 12px; color: #6b7280; margin-top: 2px; }

        /* ── Threshold banner ── */
        .banner {
            border-radius: 14px;
            padding: 16px 20px;
            display: flex;
            align-items: flex-start;
            gap: 14px;
            font-size: 14px;
            margin-bottom: 20px;
            border: 1px solid;
            animation: slideIn .4s ease;
        }
        .banner-pass { background:#0d1f12; border-color:#1e4a28; color:#86efac; }
        .banner-fail { background:#2c1515; border-color:#3f1f1f; color:#f87171; }
        .banner i { font-size: 20px; flex-shrink: 0; margin-top: 1px; }
        .banner strong { color: #fff; }

        @keyframes slideIn {
            from { opacity:0; transform:translateY(-8px); }
            to   { opacity:1; transform:translateY(0); }
        }

        /* ── Topic breakdown chart ── */
        .topics-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 24px;
            align-items: center;
        }
        .topic-chart-wrap {
            position: relative;
            width: 100%;
            max-width: 260px;
            margin: 0 auto;
        }

        .topic-legend { display: flex; flex-direction: column; gap: 10px; }
        .legend-item {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 10px 14px;
            background: #13171d;
            border: 1px solid #1e2228;
            border-radius: 10px;
            font-size: 13px;
            transition: border-color .2s;
            cursor: default;
        }
        .legend-item:hover { border-color: #44634d; }
        .legend-dot {
            width: 10px; height: 10px;
            border-radius: 50%;
            flex-shrink: 0;
        }
        .legend-item .topic-name { flex: 1; color: #e5e7eb; font-weight: 500; }
        .legend-item .topic-tag {
            font-size: 11px;
            font-weight: 600;
            padding: 2px 8px;
            border-radius: 8px;
        }
        .tag-wrong { background:#2c1515; color:#f87171; }
        .tag-right { background:#162119; color:#86efac; }

        /* ── Performance message ── */
        .perf-msg {
            text-align: center;
            padding: 18px 24px;
            border-radius: 14px;
            font-size: 16px;
            font-weight: 500;
            border: 1px solid;
            margin-bottom: 20px;
        }
        .perf-excellent  { background:#0d1f12; border-color:#1e4a28; color:#86efac; }
        .perf-good       { background:#2c2415; border-color:#3f341f; color:#fbbf24; }
        .perf-improve    { background:#2c1515; border-color:#3f1f1f; color:#f87171; }
        .perf-perfect    { background:#0d1f12; border-color:#1e4a28; color:#86efac; }

        /* ── Weak topics list ── */
        .topic-list { list-style: none; display: flex; flex-direction: column; gap: 8px; }
        .topic-list li {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 12px 16px;
            background: #13171d;
            border: 1px solid #1e2228;
            border-left: 3px solid #ef4444;
            border-radius: 10px;
            color: #f87171;
            font-size: 14px;
            font-weight: 500;
            transition: transform .15s;
        }
        .topic-list li:hover { transform: translateX(4px); }
        .topic-list li i { color: #ef4444; font-size: 13px; }

        /* ── Buttons ── */
        .btn-group {
            display: flex;
            justify-content: center;
            gap: 12px;
            flex-wrap: wrap;
            margin-top: 10px;
        }
        .btn {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 13px 24px;
            border-radius: 12px;
            font-size: 14px;
            font-weight: 500;
            cursor: pointer;
            text-decoration: none;
            border: 1px solid #2a2f3a;
            background: #13171d;
            color: #e5e7eb;
            transition: all .2s;
        }
        .btn:hover { border-color: #44634d; transform: translateY(-2px); }
        .btn-primary { background: #44634d; border-color: #44634d; color: #fff; }
        .btn-primary:hover { background: #365340; border-color: #365340; }

        /* ── Learn btn inside card ── */
        .learn-btn-wrap { margin-top: 20px; }

        /* ── Back warning toast ── */
        .back-warning {
            display: none;
            position: fixed;
            bottom: 20px; right: 20px;
            background: #2c2415;
            border: 1px solid #fbbf24;
            border-radius: 10px;
            padding: 12px 16px;
            font-size: 13px;
            color: #fbbf24;
            z-index: 1000;
        }

        @media (max-width: 640px) {
            .hero-row    { grid-template-columns: 1fr; }
            .topics-grid { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>
<div class="page">

    <!-- Header -->
    <div class="page-header">
        <div class="level-pill">
            <i class="fas fa-shield-halved"></i>
            <%= levelDisplay %> Level · Level <%= sublevel %>
        </div>
        <h1><i class="fas fa-chart-bar" style="color:#44634d; margin-right:10px;"></i>Quiz Results</h1>
        <p>Here's how you performed — review your weak areas and keep improving.</p>
    </div>

    <!-- ── Score hero card ── -->
    <div class="card">
        <div class="card-title"><i class="fas fa-trophy"></i> Your Score</div>
        <div class="hero-row">
            <div class="donut-wrap">
                <canvas id="scoreDonut" width="200" height="200"></canvas>
                <div class="donut-center">
                    <div class="donut-pct"><%= String.format("%.0f", calculatedPercentage) %>%</div>
                    <div class="donut-label"><%= score %>/<%= total %> correct</div>
                </div>
            </div>
            <div class="score-meta">
                <div class="meta-stat">
                    <div class="meta-icon green"><i class="fas fa-check"></i></div>
                    <div class="meta-info">
                        <div class="val"><%= score %></div>
                        <div class="lbl">Correct answers</div>
                    </div>
                </div>
                <div class="meta-stat">
                    <div class="meta-icon red"><i class="fas fa-times"></i></div>
                    <div class="meta-info">
                        <div class="val"><%= wrongCount %></div>
                        <div class="lbl">Wrong answers</div>
                    </div>
                </div>
                <div class="meta-stat">
                    <div class="meta-icon yellow"><i class="fas fa-percent"></i></div>
                    <div class="meta-info">
                        <div class="val"><%= String.format("%.1f", calculatedPercentage) %>%</div>
                        <div class="lbl">Overall percentage</div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- ── Threshold banner ── -->
    <% if (percentage != null) {
        if (canProceed != null && canProceed) { %>
    <div class="banner banner-pass">
        <i class="fas fa-circle-check"></i>
        <div>
            <strong>Well done!</strong> You scored <strong><%= percentage %>%</strong> — that meets the 35% requirement.
            The next sublevel is now unlocked.
        </div>
    </div>
    <%  } else { %>
    <div class="banner banner-fail">
        <i class="fas fa-triangle-exclamation"></i>
        <div>
            <strong>Sublevel locked.</strong> You scored <strong><%= percentage %>%</strong> — you need at least
            <strong>35%</strong> to proceed. Review the topics below and try again.
        </div>
    </div>
    <%  }
    } %>

    <!-- ── Performance message ── -->
    <%
    String perfMsg   = "";
    String perfClass = "";
    if (calculatedPercentage >= 100) { perfMsg = "🌟 Perfect score! Outstanding!";             perfClass = "perf-perfect"; }
    else if (calculatedPercentage >= 80) { perfMsg = "🌟 Excellent! You're a cybersecurity pro!"; perfClass = "perf-excellent"; }
    else if (calculatedPercentage >= 60) { perfMsg = "📚 Good job! Keep learning and improving!"; perfClass = "perf-good"; }
    else { perfMsg = "💪 Keep practicing! Review the topics below.";                             perfClass = "perf-improve"; }
    %>
    <div class="perf-msg <%= perfClass %>"><%= perfMsg %></div>

    <!-- ── Topic breakdown chart ── -->
    <% if (weakTopics != null && !weakTopics.isEmpty()) { %>
    <div class="card">
        <div class="card-title"><i class="fas fa-chart-pie"></i> Topic Breakdown</div>
        <div class="topics-grid">
            <div class="topic-chart-wrap">
                <canvas id="topicPie"></canvas>
            </div>
            <div class="topic-legend" id="topicLegend">
                <%
                // Build JS arrays and legend in one pass
                int topicCount = weakTopics.size();
                // All topics attempted = total questions; approximate right topics = score
                // We show weak (wrong) topics vs "other" (correct bucket)
                StringBuilder jsLabels = new StringBuilder();
                StringBuilder jsData   = new StringBuilder();
                StringBuilder jsColors = new StringBuilder();

                // Palette for wrong topics
                String[] palette = {
                    "#f87171","#fb923c","#fbbf24","#e879f9",
                    "#60a5fa","#34d399","#a78bfa","#f472b6"
                };

                int pi = 0;
                for (String topic : weakTopics) {
                    if (pi > 0) { jsLabels.append(","); jsData.append(","); jsColors.append(","); }
                    jsLabels.append("\"").append(topic.replace("\"","\\\"")).append("\"");
                    jsData.append("1");   // each wrong topic = 1 unit
                    jsColors.append("\"").append(palette[pi % palette.length]).append("\"");

                    String col = palette[pi % palette.length];
                %>
                <div class="legend-item">
                    <div class="legend-dot" style="background:<%= col %>"></div>
                    <span class="topic-name"><%= topic %></span>
                    <span class="topic-tag tag-wrong">Weak</span>
                </div>
                <%
                    pi++;
                }
                // Add correct bucket
                if (score > 0) {
                    if (pi > 0) { jsLabels.append(","); jsData.append(","); jsColors.append(","); }
                    jsLabels.append("\"Correct answers\"");
                    jsData.append(score);
                    jsColors.append("\"#44634d\"");
                %>
                <div class="legend-item">
                    <div class="legend-dot" style="background:#44634d"></div>
                    <span class="topic-name">Correct answers</span>
                    <span class="topic-tag tag-right"><%= score %> / <%= total %></span>
                </div>
                <% } %>
            </div>
        </div>

        <!-- Weak topic list -->
        <div style="margin-top:28px">
            <div class="card-title" style="margin-bottom:14px"><i class="fas fa-exclamation-triangle"></i> Topics to Improve</div>
            <p style="font-size:13px; color:#6b7280; margin-bottom:14px;">Based on your answers, focus on these areas:</p>
            <ul class="topic-list">
                <% for (String topic : weakTopics) { %>
                <li><i class="fas fa-circle" style="font-size:7px"></i> <%= topic %></li>
                <% } %>
            </ul>
        </div>

        <div class="learn-btn-wrap">
            <form action="LearningServlet" method="get">
                <% for (String topic : weakTopics) { %>
                <input type="hidden" name="topic" value="<%= topic %>">
                <% } %>
                <button type="submit" class="btn btn-primary">
                    <i class="fas fa-graduation-cap"></i> Learn These Topics
                </button>
            </form>
        </div>
    </div>

    <script>
    // ── Topic pie chart ──────────────────────────────────────────
    (function() {
        const ctx = document.getElementById('topicPie').getContext('2d');
        const labels = [<%= jsLabels %>];
        const data   = [<%= jsData %>];
        const colors = [<%= jsColors %>];

        new Chart(ctx, {
            type: 'pie',
            data: {
                labels: labels,
                datasets: [{
                    data: data,
                    backgroundColor: colors,
                    borderColor: '#0a0c10',
                    borderWidth: 3,
                    hoverOffset: 10
                }]
            },
            options: {
                responsive: true,
                animation: { animateRotate: true, duration: 900, easing: 'easeInOutQuart' },
                plugins: {
                    legend: { display: false },
                    tooltip: {
                        backgroundColor: '#0f1115',
                        borderColor: '#1e2228',
                        borderWidth: 1,
                        titleColor: '#fff',
                        bodyColor: '#9ca3af',
                        padding: 12,
                        callbacks: {
                            label: function(ctx) {
                                const total = ctx.dataset.data.reduce((a,b)=>a+b,0);
                                const pct   = ((ctx.parsed / total)*100).toFixed(1);
                                return ' ' + ctx.label + ': ' + pct + '%';
                            }
                        }
                    }
                }
            }
        });
    })();
    </script>

    <% } else { %>
    <!-- Perfect score — no weak topics -->
    <div class="card" style="text-align:center; padding:40px">
        <div style="font-size:52px; margin-bottom:16px">🏆</div>
        <h3 style="color:#86efac; font-size:22px; margin-bottom:8px">Perfect Score!</h3>
        <p style="color:#6b7280; font-size:14px">You answered every question correctly. No weak topics detected.</p>
    </div>
    <% } %>

    <!-- ── Navigation buttons ── -->
    <div class="btn-group">
        <a href="select_level.jsp" class="btn" onclick="return confirmNavigate()">
            <i class="fas fa-redo-alt"></i> Try Another Quiz
        </a>
        <a href="home.jsp" class="btn btn-primary" onclick="return confirmNavigate()">
            <i class="fas fa-home"></i> Return to Home
        </a>
    </div>

</div>

<!-- ── Score donut chart ── -->
<script>
(function() {
    const ctx   = document.getElementById('scoreDonut').getContext('2d');
    const score = <%= score %>;
    const wrong = <%= wrongCount %>;

    new Chart(ctx, {
        type: 'doughnut',
        data: {
            labels: ['Correct', 'Wrong'],
            datasets: [{
                data: [score, wrong],
                backgroundColor: ['#44634d', '#2c1515'],
                borderColor:     ['#5a8066', '#3f1f1f'],
                borderWidth: 2,
                hoverOffset: 6
            }]
        },
        options: {
            cutout: '72%',
            responsive: false,
            animation: { animateRotate: true, duration: 800, easing: 'easeInOutQuart' },
            plugins: {
                legend: { display: false },
                tooltip: {
                    backgroundColor: '#0f1115',
                    borderColor: '#1e2228',
                    borderWidth: 1,
                    titleColor: '#fff',
                    bodyColor: '#9ca3af',
                    padding: 10
                }
            }
        }
    });
})();
</script>

<!-- Back button prevention -->
<script>
    window.history.replaceState(null, null, window.location.href);
    window.history.pushState({page: "result"}, "Result", window.location.href);
    window.addEventListener('popstate', function() { window.location.replace('home.jsp'); });
    window.addEventListener('pageshow', function(e) { if (e.persisted) window.location.replace('home.jsp'); });
    function confirmNavigate() { return true; }
    document.addEventListener('keydown', function(e) {
        if (e.key === 'F5' || (e.ctrlKey && e.key === 'r')) {
            e.preventDefault();
            window.location.replace('home.jsp');
        }
    });
</script>

<div class="back-warning" id="backWarning">
    <i class="fas fa-exclamation-triangle"></i> You cannot go back to the quiz
</div>
</body>
</html>