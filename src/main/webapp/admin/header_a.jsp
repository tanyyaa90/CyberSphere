<%@ page contentType="text/html;charset=UTF-8" %>
<%
    // Get current page from request
    String currentPage = request.getRequestURI();
    String pageName = currentPage.substring(currentPage.lastIndexOf("/") + 1);
    
    // Get user info from session
    String firstName = (String) session.getAttribute("firstName");
    String username = (String) session.getAttribute("username");
    if (firstName == null) firstName = username;
    
    // Get profile image from session
    String profileImage = (String) session.getAttribute("profileImage");
    if (profileImage == null) profileImage = "https://i.ibb.co/6RfWN4zJ/buddy-10158022.png";
    String ctxPath = request.getContextPath();

%>

<!-- CyberSphere Header with Logo -->
<header class="cybersphere-header">
    <div class="header-container">
        <!-- Logo with tagline - larger -->
        <div class="logo-section">
            <a href="<%= ctxPath %>/admin_home.jsp" class="logo-link">
                <img src="<%= ctxPath %>/images/logo.svg" alt="CyberSphere" class="logo-svg" 
                     onerror="this.onerror=null; this.src='<%= ctxPath %>/images/logo.png'">
                <span class="logo-fallback">🛡️ CyberSphere</span>
            </a>
        </div>

        <!-- Navigation Links - pushed to the right -->
        <nav class="header-nav">      
            <!-- Welcome Message -->
            <div class="welcome-message">
                <i class="fas fa-hand-wave"></i> Welcome, <%= firstName %>!
            </div>
            
            <!-- Profile Section with Image and Text -->
<a href="<%= ctxPath %>/profile" class="profile-section">
                <img src="<%= profileImage %>" alt="Profile" class="profile-image">
                <span class="profile-text">Profile</span>
            </a>
            
            <!-- Logout Button -->
            <a href="#" onclick="confirmLogout()" class="logout-btn">
                <i class="fas fa-sign-out-alt"></i> Logout
            </a>
        </nav>
    </div>
</header>

<!-- Font Awesome for icons -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

<style>
    /* CyberSphere Header Styles - Dark Theme */
    .cybersphere-header {
        background: #0f1115;
        border-bottom: 1px solid #1e1e1e;
        padding: 18px 0;
        position: sticky;
        top: 0;
        z-index: 1000;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.3);
    }

    .header-container {
        max-width: 1600px;
        margin: 0 auto;
        padding: 0 40px;
        display: flex;
        justify-content: space-between;
        align-items: center;
        gap: 40px;
    }

    /* Logo Section - larger */
    .logo-section {
        display: flex;
        align-items: center;
        gap: 20px;
        flex-shrink: 0;
    }

    .logo-link {
        display: flex;
        align-items: center;
        text-decoration: none;
    }

    .logo-svg {
        height: 50px;
        width: auto;
        max-width: 200px;
        filter: brightness(0) invert(1);
    }

    .logo-fallback {
        display: none;
        font-size: 28px;
        font-weight: 600;
        color: #ffffff;
        letter-spacing: -0.02em;
    }

    /* Show fallback if image fails to load */
    .logo-svg[src=""],
    .logo-svg:not([src]) {
        display: none;
    }

    .logo-svg[src=""] + .logo-fallback,
    .logo-svg:not([src]) + .logo-fallback {
        display: block;
    }

    /* Tagline - adjusted for larger logo */
    .tagline {
        color: #44634d;
        font-size: 14px;
        font-weight: 500;
        letter-spacing: 0.5px;
        border-left: 1px solid #2a2f3a;
        padding-left: 20px;
        text-transform: uppercase;
        white-space: nowrap;
    }

    /* Navigation - larger */
    .header-nav {
        display: flex;
        align-items: center;
        gap: 25px;
        margin-left: auto;
    }

    .nav-link {
        color: #9ca3af;
        text-decoration: none;
        font-weight: 500;
        padding: 10px 18px;
        border-radius: 8px;
        transition: all 0.2s ease;
        font-size: 16px;
        white-space: nowrap;
        display: inline-flex;
        align-items: center;
        gap: 8px;
    }

    .nav-link i {
        font-size: 14px;
    }

    .nav-link:hover {
        color: #ffffff;
        background: #1a1e24;
    }

    .nav-link.active {
        color: #44634d;
        background: #1a2a1a;
    }

    /* Logout Button - larger */
    .logout-btn {
        color: #f87171;
        text-decoration: none;
        font-weight: 500;
        padding: 10px 18px;
        border-radius: 8px;
        transition: all 0.2s ease;
        font-size: 16px;
        background: #1a1e24;
        border: 1px solid #2a2f3a;
        white-space: nowrap;
        display: inline-flex;
        align-items: center;
        gap: 8px;
    }

    .logout-btn i {
        font-size: 14px;
    }

    .logout-btn:hover {
        background: #2c1515;
        color: #ef4444;
        border-color: #ef4444;
    }

    /* Profile Section - new combined element */
    .profile-section {
        display: flex;
        align-items: center;
        gap: 12px;
        text-decoration: none;
        padding: 8px 18px 8px 12px;
        background: #1a1e24;
        border-radius: 50px;
        border: 1px solid #2a2f3a;
        transition: all 0.2s ease;
        white-space: nowrap;
    }

    .profile-section:hover {
        border-color: #44634d;
        background: #1f242b;
        transform: translateY(-1px);
    }

    .profile-image {
        width: 42px;
        height: 42px;
        border-radius: 50%;
        object-fit: cover;
        border: 2px solid #44634d;
        transition: all 0.2s ease;
    }

    .profile-section:hover .profile-image {
        border-color: #5a7e64;
    }

    .profile-text {
        color: #ffffff;
        font-weight: 500;
        font-size: 16px;
    }

    /* Welcome Message */
    .welcome-message {
        color: #ffffff;
        font-weight: 500;
        font-size: 16px;
        white-space: nowrap;
        background: #1a1e24;
        padding: 8px 20px;
        border-radius: 50px;
        border: 1px solid #2a2f3a;
        display: inline-flex;
        align-items: center;
        gap: 8px;
    }

    .welcome-message i {
        color: #44634d;
    }

    /* Responsive */
    @media (max-width: 1400px) {
        .header-container {
            padding: 0 30px;
            gap: 30px;
        }
        
        .header-nav {
            gap: 15px;
        }
    }

    @media (max-width: 1200px) {
        .header-container {
            flex-wrap: wrap;
            gap: 15px;
            padding: 0 20px;
        }
        
        .logo-section {
            width: 100%;
            justify-content: center;
        }
        
        .header-nav {
            width: 100%;
            justify-content: center;
            flex-wrap: wrap;
            margin-left: 0;
        }
        
        .profile-section {
            margin: 0 auto;
        }
        
        .welcome-message {
            width: 100%;
            text-align: center;
            justify-content: center;
        }
    }

    @media (max-width: 768px) {
        .cybersphere-header {
            padding: 15px 0;
        }
        
        .header-container {
            flex-direction: column;
            padding: 0 15px;
        }
        
        .logo-section {
            flex-direction: column;
            text-align: center;
            gap: 10px;
        }
        
        .tagline {
            border-left: none;
            padding-left: 0;
            border-top: 1px solid #2a2f3a;
            padding-top: 10px;
        }
        
        .logo-svg {
            height: 45px;
        }
        
        .logo-fallback {
            font-size: 24px;
        }
        
        .header-nav {
            flex-direction: column;
            width: 100%;
            gap: 10px;
        }
        
        .nav-link, .logout-btn {
            width: 100%;
            text-align: center;
            justify-content: center;
            padding: 12px;
        }
        
        .profile-section {
            width: 100%;
            justify-content: center;
            padding: 10px;
        }
        
        .profile-image {
            width: 40px;
            height: 40px;
        }
        
        .welcome-message {
            width: 100%;
            text-align: center;
            justify-content: center;
            padding: 10px;
        }
    }

    /* Logout confirmation modal */
    .logout-modal {
    display: none;
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0, 0, 0, 0.8);
    z-index: 9999; /* ← bump this up */
    justify-content: center;
    align-items: center;
    backdrop-filter: blur(5px);
}

    .logout-modal-content {
        background: #0f1115;
        padding: 35px;
        border-radius: 16px;
        border: 1px solid #1e1e1e;
        max-width: 400px;
        width: 90%;
        text-align: center;
        animation: slideDown 0.3s ease;
    }

    .logout-modal-content h3 {
        color: #ffffff;
        margin-bottom: 15px;
        font-size: 24px;
    }

    .logout-modal-content p {
        color: #9ca3af;
        margin-bottom: 25px;
        font-size: 16px;
    }

    .logout-modal-actions {
        display: flex;
        gap: 15px;
        justify-content: center;
    }

    .logout-confirm-btn {
        background: #ef4444;
        color: white;
        border: none;
        padding: 14px 35px;
        border-radius: 8px;
        font-weight: 600;
        font-size: 16px;
        cursor: pointer;
        transition: all 0.2s ease;
    }

    .logout-confirm-btn:hover {
        background: #dc2626;
        transform: translateY(-1px);
    }

    .logout-cancel-btn {
        background: #1a1e24;
        color: #9ca3af;
        border: 1px solid #2a2f3a;
        padding: 14px 35px;
        border-radius: 8px;
        font-weight: 600;
        font-size: 16px;
        cursor: pointer;
        transition: all 0.2s ease;
    }

    .logout-cancel-btn:hover {
        background: #1f242b;
        color: #ffffff;
        border-color: #44634d;
    }

    @keyframes slideDown {
        from {
            transform: translateY(-50px);
            opacity: 0;
        }
        to {
            transform: translateY(0);
            opacity: 1;
        }
    }
</style>

<!-- Logout Confirmation Modal -->
<div id="logoutModal" class="logout-modal">
    <div class="logout-modal-content">
        <h3>Confirm Logout</h3>
        <p>Are you sure you want to logout? You'll need to login again to access your account.</p>
        <div class="logout-modal-actions">
            <button class="logout-cancel-btn" onclick="closeLogoutModal()">Cancel</button>
            <button class="logout-confirm-btn" onclick="performLogout()">Logout</button>
        </div>
    </div>
</div>

<script>
function confirmLogout() {
    const modal = document.getElementById('logoutModal');
    document.body.appendChild(modal); 
    modal.style.display = 'flex';
}
    
    function closeLogoutModal() {
        document.getElementById('logoutModal').style.display = 'none';
    }
    
    function performLogout() {
        const form = document.createElement('form');
        form.method = 'POST';
        form.action = '<%= request.getContextPath() %>/logout';
        document.body.appendChild(form);
        form.submit();
    }
    
    window.onclick = function(event) {
        const modal = document.getElementById('logoutModal');
        if (event.target == modal) {
            modal.style.display = 'none';
        }
    }
    
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') {
            closeLogoutModal();
        }
    });
</script>