<%@ page contentType="text/html;charset=UTF-8" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if (session.getAttribute("userId") == null) {
        response.sendRedirect(request.getContextPath() + "/home");
        return;
    }
    
    // Get user role and permissions from session
    String userRole = (String) session.getAttribute("role");
    boolean isAdmin = "admin".equals(userRole);
    
    // Get admin permissions (default to false if not set)
    Boolean canManageUsers = (Boolean) session.getAttribute("can_manage_users");
    Boolean canManageQuizzes = (Boolean) session.getAttribute("can_manage_quizzes");
    Boolean canManageContent = (Boolean) session.getAttribute("can_manage_content");
    Boolean canManageMessages = (Boolean) session.getAttribute("can_manage_messages");
    Boolean canViewLogs = (Boolean) session.getAttribute("can_view_logs");
    Boolean isMainAdmin = (Boolean) session.getAttribute("isMainAdmin");
    
    // Default to false if null
    if (canManageUsers == null) canManageUsers = false;
    if (canManageQuizzes == null) canManageQuizzes = false;
    if (canManageContent == null) canManageContent = false;
    if (canManageMessages == null) canManageMessages = false;
    if (canViewLogs == null) canViewLogs = false;
    if (isMainAdmin == null) isMainAdmin = false;
    
    // Check if admin has any permissions (to show admin section)
    boolean hasAnyAdminPermission = isMainAdmin || canManageUsers || canManageQuizzes || canManageContent || canManageMessages || canViewLogs;
%>
<!DOCTYPE html>
<html>
<head>
    <title>Home | CyberSphere</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <%@ include file="header.jsp" %>
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
    }

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

    .hero-section {
        text-align: center;
        color: #ffffff;
        padding: 40px 20px 20px 20px;
    }

    .hero-section h1 {
        font-size: 42px;
        margin-bottom: 15px;
        font-weight: 600;
        letter-spacing: -0.02em;
        color: #ffffff;
    }

    .hero-section p {
        font-size: 18px;
        color: #9ca3af;
        margin-bottom: 30px;
    }

    .features-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
        gap: 30px;
        margin-top: 40px;
    }

    .feature-card {
        background: #0f1115;
        padding: 35px 30px;
        border-radius: 16px;
        text-align: center;
        transition: transform 0.2s ease, border-color 0.2s ease;
        border: 1px solid #1e1e1e;
        box-shadow: 0 10px 30px rgba(0,0,0,0.3);
    }

    .feature-card:hover {
        transform: translateY(-5px);
        border-color: #44634d;
        box-shadow: 0 20px 40px rgba(68, 99, 77, 0.1);
    }

    .feature-card i {
        font-size: 48px;
        color: #44634d;
        margin-bottom: 20px;
    }

    .feature-card h3 {
        color: #ffffff;
        margin-bottom: 12px;
        font-size: 20px;
        font-weight: 600;
    }

    .feature-card p {
        color: #9ca3af;
        margin-bottom: 25px;
        line-height: 1.6;
        font-size: 15px;
    }

    .feature-btn {
        display: inline-block;
        padding: 12px 30px;
        background: #1a1e24;
        color: #ffffff;
        text-decoration: none;
        border-radius: 8px;
        font-weight: 500;
        font-size: 14px;
        transition: all 0.2s ease;
        border: 1px solid #2a2f3a;
    }

    .feature-btn:hover {
        background: #44634d;
        border-color: #44634d;
        transform: translateY(-1px);
        box-shadow: 0 10px 20px -10px rgba(68, 99, 77, 0.3);
    }

    /* Admin Card - Special styling for admin panel */
    .admin-card {
        border-color: #44634d;
        background: linear-gradient(135deg, #0f1115 0%, #1a1a1a 100%);
    }
    
    .admin-card i {
        color: #fbbf24;
    }
    
    .admin-card .feature-btn {
        background: #44634d;
        border-color: #44634d;
    }
    
    .admin-card .feature-btn:hover {
        background: #5a7f66;
        transform: translateY(-1px);
    }

    /* Admin Section Header */
    .admin-section-header {
        margin-top: 50px;
        margin-bottom: 20px;
        padding-bottom: 10px;
        border-bottom: 1px solid #44634d;
    }
    
    .admin-section-header h2 {
        color: #fbbf24;
        font-size: 24px;
        display: flex;
        align-items: center;
        gap: 10px;
    }
    
    .admin-section-header h2 i {
        color: #fbbf24;
    }
    
    .admin-section-header p {
        color: #9ca3af;
        font-size: 14px;
        margin-top: 5px;
    }

    .stats-bar {
        display: flex;
        justify-content: center;
        gap: 40px;
        margin-top: 60px;
        padding: 20px;
        border-top: 1px solid #1e1e1e;
    }

    .stat-item {
        display: flex;
        align-items: center;
        gap: 8px;
        color: #9ca3af;
        font-size: 14px;
    }

    .dot {
        width: 8px;
        height: 8px;
        background: #44634d;
        border-radius: 50%;
        display: inline-block;
    }

    .stat-value {
        color: #44634d;
        font-weight: 500;
    }

    /* Modal styles for logout confirmation */
    .modal {
        display: none;
        position: fixed;
        z-index: 1000;
        left: 0;
        top: 0;
        width: 100%;
        height: 100%;
        background-color: rgba(0,0,0,0.7);
        backdrop-filter: blur(4px);
    }

    .modal-content {
        background: #0f1115;
        border-radius: 16px;
        width: 90%;
        max-width: 400px;
        text-align: center;
        border: 1px solid #44634d;
        box-shadow: 0 20px 40px rgba(0,0,0,0.4);
        animation: slideDown 0.3s ease;
        position: absolute;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
    }

    @keyframes slideDown {
        from {
            opacity: 0;
            transform: translate(-50%, -60%);
        }
        to {
            opacity: 1;
            transform: translate(-50%, -50%);
        }
    }

    .modal-header {
        padding: 20px;
        border-bottom: 1px solid #1e1e1e;
    }

    .modal-header i {
        font-size: 48px;
        color: #fbbf24;
        margin-bottom: 10px;
    }

    .modal-header h3 {
        color: #ffffff;
        font-size: 20px;
        margin: 10px 0;
    }

    .modal-body {
        padding: 20px;
        color: #9ca3af;
        font-size: 14px;
        line-height: 1.6;
    }

    .modal-footer {
        padding: 15px 20px 20px;
        display: flex;
        gap: 12px;
        justify-content: center;
    }

    .modal-btn {
        padding: 10px 24px;
        border: none;
        border-radius: 8px;
        font-size: 14px;
        font-weight: 500;
        cursor: pointer;
        transition: all 0.2s ease;
    }

    .modal-btn.confirm {
        background: #dc2626;
        color: white;
    }

    .modal-btn.confirm:hover {
        background: #b91c1c;
        transform: translateY(-1px);
    }

    .modal-btn.cancel {
        background: #1a1e24;
        color: #ffffff;
        border: 1px solid #2a2f3a;
    }

    .modal-btn.cancel:hover {
        background: #2a2f3a;
        transform: translateY(-1px);
    }

    /* Responsive Design */
    @media (max-width: 768px) {
        .hero-section h1 {
            font-size: 32px;
        }
        
        .features-grid {
            grid-template-columns: 1fr;
        }
        
        .stats-bar {
            flex-direction: column;
            align-items: center;
            gap: 15px;
        }
        
        .modal-content {
            width: 95%;
        }
        
        .container {
            margin: 20px auto;
            padding: 15px;
        }
        
        .feature-card {
            padding: 25px 20px;
        }
        
        .hero-section {
            padding: 20px 15px 15px 15px;
        }
        
        .admin-section-header h2 {
            font-size: 20px;
        }
    }

    /* Small Mobile Devices */
    @media (max-width: 480px) {
        .hero-section h1 {
            font-size: 28px;
        }
        
        .hero-section p {
            font-size: 16px;
        }
        
        .feature-card h3 {
            font-size: 18px;
        }
        
        .feature-card p {
            font-size: 14px;
        }
        
        .feature-btn {
            padding: 10px 24px;
            font-size: 13px;
        }
        
        .modal-btn {
            padding: 8px 20px;
            font-size: 13px;
        }
        
        .modal-header i {
            font-size: 40px;
        }
        
        .modal-header h3 {
            font-size: 18px;
        }
        
        .modal-body {
            font-size: 13px;
        }
    }

    /* Tablet Devices */
    @media (min-width: 769px) and (max-width: 1024px) {
        .container {
            max-width: 900px;
        }
        
        .features-grid {
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 25px;
        }
    }

    /* Large Desktop Devices */
    @media (min-width: 1400px) {
        .container {
            max-width: 1400px;
        }
        
        .features-grid {
            grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
        }
        
        .hero-section h1 {
            font-size: 48px;
        }
        
        .hero-section p {
            font-size: 20px;
        }
    }

    /* Print Styles */
    @media print {
        body::before {
            display: none;
        }
        
        .feature-btn,
        .modal {
            display: none;
        }
        
        .feature-card {
            break-inside: avoid;
            page-break-inside: avoid;
        }
    }

    /* Accessibility - Focus Styles */
    .feature-btn:focus-visible,
    .modal-btn:focus-visible {
        outline: 2px solid #44634d;
        outline-offset: 2px;
    }

    /* Loading Animation (Optional) */
    @keyframes pulse {
        0% {
            opacity: 1;
        }
        50% {
            opacity: 0.6;
        }
        100% {
            opacity: 1;
        }
    }

    .loading {
        animation: pulse 1.5s ease-in-out infinite;
    }

    /* Scrollbar Styling */
    ::-webkit-scrollbar {
        width: 10px;
        height: 10px;
    }

    ::-webkit-scrollbar-track {
        background: #0f1115;
    }

    ::-webkit-scrollbar-thumb {
        background: #44634d;
        border-radius: 5px;
    }

    ::-webkit-scrollbar-thumb:hover {
        background: #5a7f66;
    }

    /* Selection Color */
    ::selection {
        background: #44634d;
        color: #ffffff;
    }

    ::-moz-selection {
        background: #44634d;
        color: #ffffff;
    }
</style>
</head>
<body>

<div class="container">
    <div class="hero-section">
        <h1>Welcome to CyberSphere</h1>
        <p>Your comprehensive cybersecurity learning and awareness platform</p>
    </div>

    <div class="features-grid">
        <!-- Quiz Card - Visible to all users -->
        <div class="feature-card">
            <i class="fas fa-question-circle"></i>
            <h3>Cybersecurity Quiz</h3>
            <p>Test your knowledge with our interactive quizzes at different difficulty levels</p>
            <a href="select_level.jsp" class="feature-btn">Take Quiz →</a>
        </div>

        <!-- Detection Tools Card - Visible to all users -->
        <div class="feature-card">
            <i class="fas fa-shield-alt"></i>
            <h3>Detection Tools</h3>
            <p>Analyze emails, check passwords, scan URLs, and verify SSL certificates</p>
            <a href="detectiontools.jsp" class="feature-btn">Try Detectors →</a>
        </div>

        <!-- Learning Hub Card - Visible to all users -->
        <div class="feature-card">
            <i class="fas fa-graduation-cap"></i>
            <h3>Learning Hub</h3>
            <p>Access curated resources, videos, and articles about cybersecurity</p>
            <a href="learningHub" class="feature-btn">Explore →</a>
        </div>
    </div>
    
    <!-- Admin Section - Only visible if user is admin and has at least one permission -->
    <% if (isAdmin && hasAnyAdminPermission) { %>
    <div class="admin-section-header">
        <h2><i class="fas fa-user-shield"></i> Admin Controls</h2>
        <p>Manage and monitor the CyberSphere platform</p>
    </div>
    
    <div class="features-grid">
        <!-- Manage Users Card - Only if admin has user management permission -->
        <% if (isMainAdmin || canManageUsers) { %>
        <div class="feature-card admin-card">
            <i class="fas fa-users"></i>
            <h3>Manage Users</h3>
            <p>View, edit, and manage all registered users</p>
            <a href="admin/manageUsers.jsp" class="feature-btn">Manage Users →</a>
        </div>
        <% } %>
        
        <!-- Manage Quizzes Card - Only if admin has quiz management permission -->
        <% if (isMainAdmin || canManageQuizzes) { %>
        <div class="feature-card admin-card">
            <i class="fas fa-question-circle"></i>
            <h3>Manage Quizzes</h3>
            <p>Add, edit, or delete quiz questions</p>
            <a href="admin/manageQuizzes.jsp" class="feature-btn">Manage Quizzes →</a>
        </div>
        <% } %>
        
        <!-- Manage Content Card - Only if admin has content management permission -->
        <% if (isMainAdmin || canManageContent) { %>
        <div class="feature-card admin-card">
            <i class="fas fa-newspaper"></i>
            <h3>Manage Content</h3>
            <p>Add, edit, or delete learning hub content</p>
            <a href="admin/manageContent.jsp" class="feature-btn">Manage Content →</a>
        </div>
        <% } %>
        
        <!-- Manage Messages Card - Only if admin has message management permission -->
        <% if (isMainAdmin || canManageMessages) { %>
        <div class="feature-card admin-card">
            <i class="fas fa-envelope"></i>
            <h3>Manage Messages</h3>
            <p>View and respond to contact messages</p>
            <a href="admin/manageMessages.jsp" class="feature-btn">Manage Messages →</a>
        </div>
        <% } %>
        
        <!-- View Logs Card - Only if admin has log viewing permission -->
        <% if (isMainAdmin || canViewLogs) { %>
        <div class="feature-card admin-card">
            <i class="fas fa-chart-line"></i>
            <h3>Activity Logs</h3>
            <p>View user activity, quiz attempts, and detection tool usage</p>
            <a href="admin/activityLogs.jsp" class="feature-btn">View Logs →</a>
        </div>
        <% } %>
        
        <!-- Manage Admins Card - ONLY main admin can see this -->
        <% if (isMainAdmin) { %>
        <div class="feature-card admin-card">
            <i class="fas fa-user-shield"></i>
            <h3>Manage Admins</h3>
            <p>Add or remove administrators and assign permissions</p>
            <a href="admin/makeAdmin.jsp" class="feature-btn">Manage Admins →</a>
        </div>
        <% } %>
    </div>
    <% } %>
</div>

<!-- Logout Confirmation Modal -->
<div id="logoutModal" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <i class="fas fa-sign-out-alt"></i>
            <h3>Logout Confirmation</h3>
        </div>
        <div class="modal-body">
            <p>Do you want to logout from CyberSphere?</p>
            <p style="font-size: 12px; margin-top: 10px;">You will be redirected to the welcome page if you confirm.</p>
        </div>
        <div class="modal-footer">
            <button class="modal-btn cancel" onclick="closeModal()">No, Stay Here</button>
            <button class="modal-btn confirm" onclick="logoutUser()">Yes, Logout</button>
        </div>
    </div>
</div>

<script>
    let backButtonPressed = false;
    let initialLoad = true;
    
    // Function to show the logout confirmation modal
    function showLogoutModal() {
        const modal = document.getElementById('logoutModal');
        if (modal) {
            modal.style.display = 'block';
        }
    }
    
    // Function to close the modal
    function closeModal() {
        const modal = document.getElementById('logoutModal');
        if (modal) {
            modal.style.display = 'none';
        }
        // Push additional state to prevent immediate back navigation again
        setTimeout(() => {
            history.pushState(null, null, window.location.href);
            history.pushState(null, null, window.location.href);
        }, 100);
    }
    
    // Function to logout the user
    function logoutUser() {
        window.location.href = 'logout';
    }
    
    // Close modal when clicking outside
    window.onclick = function(event) {
        const modal = document.getElementById('logoutModal');
        if (event.target == modal) {
            closeModal();
        }
    }
    
    // Track initial page load
    if (window.performance && window.performance.navigation.type === window.performance.navigation.TYPE_NAVIGATE) {
        initialLoad = false;
    }
    
    // Create a deep history stack with more states for better back button handling
    if (!sessionStorage.getItem('historyPushed')) {
        history.replaceState(null, null, window.location.href);
        for (let i = 0; i < 5; i++) {
            history.pushState(null, null, window.location.href);
        }
        sessionStorage.setItem('historyPushed', 'true');
    }
    
    // Handle popstate (back/forward navigation)
    let popstateCount = 0;
    window.addEventListener('popstate', function(event) {
        popstateCount++;
        
        // Prevent immediate back navigation on initial load
        if (initialLoad && popstateCount === 1) {
            history.pushState(null, null, window.location.href);
            initialLoad = false;
            return;
        }
        
        // Show the logout confirmation modal
        showLogoutModal();
        
        // Immediately push a new state to stay on the current page
        setTimeout(() => {
            history.pushState(null, null, window.location.href);
            // Push extra states to create buffer
            for (let i = 0; i < 3; i++) {
                history.pushState(null, null, window.location.href);
            }
        }, 10);
        
        // Prevent default back navigation
        event.preventDefault();
    });
    
    // Initial push to ensure we're at the top of the history stack
    if (history.state === null) {
        history.replaceState(null, null, window.location.href);
    }
    
    // Session check every 30 seconds
    setInterval(function() {
        fetch('checkSession')
            .then(function(res) {
                if (res.status === 401) {
                    window.location.replace('login.jsp');
                }
            });
    }, 30000);
</script>

</body>
</html>