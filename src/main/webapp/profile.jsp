<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="header.jsp" %>
<%
    // Guard: must come through the servlet
    if (session.getAttribute("userId") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    // All data set by ProfileServlet via request.setAttribute()
    String attrFirstName   = (String)  request.getAttribute("firstName");
    String attrLastName    = (String)  request.getAttribute("lastName");
    String attrUsername    = (String)  request.getAttribute("username");
    String attrEmail       = (String)  request.getAttribute("email");
    String attrPhone       = (String)  request.getAttribute("phone");
    String attrProfileImg  = (String)  request.getAttribute("profileImage");

    // Safe fallbacks
    if (attrFirstName  == null) attrFirstName  = "";
    if (attrLastName   == null) attrLastName   = "";
    if (attrUsername   == null) attrUsername   = "";
    if (attrEmail      == null) attrEmail      = "";
    if (attrPhone      == null) attrPhone      = "";
    if (attrProfileImg == null) attrProfileImg = "https://i.ibb.co/6RfWN4zJ/buddy-10158022.png";

    // Edit mode: either ?edit=true in URL or set by servlet after validation error
    boolean isEditing = "true".equals(request.getParameter("edit"))
                     || Boolean.TRUE.equals(request.getAttribute("editMode"));

    // URL params for success / error toasts
    String successMsg = request.getParameter("success");
    String errorMsg   = request.getParameter("error");
    if (errorMsg == null) errorMsg = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Profile | CyberSphere</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        /* ── Reset & base ─────────────────────────────────────────── */
        *, *::before, *::after {
            margin: 0; padding: 0; box-sizing: border-box;
        }

        body {
            background: #0a0c10;
            min-height: 100vh;
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            position: relative;
        }

        /* Subtle cyber pattern */
        body::before {
            content: '';
            position: fixed; inset: 0;
            background-image: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="%2344634d" stroke-width="1" opacity="0.04"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/><circle cx="12" cy="12" r="3"/></svg>');
            background-size: 60px 60px;
            pointer-events: none;
            z-index: 0;
        }

        /* ── Layout ────────────────────────────────────────────────── */
        .page-wrap {
            position: relative;
            z-index: 1;
            max-width: 900px;
            margin: 40px auto;
            padding: 0 20px 60px;
        }

        /* ── Toast alerts ──────────────────────────────────────────── */
        .toast {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 14px 20px;
            border-radius: 10px;
            margin-bottom: 24px;
            font-size: 14px;
            font-weight: 500;
            animation: slideDown .3s ease;
        }
        .toast-success {
            background: #152a1a;
            color: #86efac;
            border: 1px solid #1e4a28;
        }
        .toast-error {
            background: #2a1515;
            color: #f87171;
            border: 1px solid #4a1e1e;
        }
        .toast i { font-size: 18px; }
        @keyframes slideDown {
            from { transform: translateY(-12px); opacity: 0; }
            to   { transform: translateY(0);     opacity: 1; }
        }

        /* ── Card ──────────────────────────────────────────────────── */
        .card {
            background: #0f1115;
            border: 1px solid #1e2228;
            border-radius: 20px;
            padding: 40px;
            box-shadow: 0 30px 60px rgba(0,0,0,.5);
        }

        /* ── Profile header ────────────────────────────────────────── */
        .profile-header {
            display: flex;
            align-items: center;
            gap: 36px;
            padding-bottom: 32px;
            border-bottom: 1px solid #1e2228;
            margin-bottom: 32px;
        }

        .avatar-wrap { text-align: center; flex-shrink: 0; }

        .avatar {
            width: 130px; height: 130px;
            border-radius: 50%;
            object-fit: cover;
            border: 3px solid #44634d;
            box-shadow: 0 8px 24px rgba(0,0,0,.4);
            cursor: pointer;
            transition: transform .2s, border-color .2s;
            display: block;
            margin-bottom: 12px;
        }
        .avatar:hover { transform: scale(1.04); border-color: #5a8066; }

        .change-photo-btn {
            background: #1a1e24;
            color: #9ca3af;
            border: 1px solid #2a2f3a;
            padding: 7px 16px;
            border-radius: 30px;
            font-size: 13px;
            font-weight: 500;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 7px;
            transition: all .2s;
        }
        .change-photo-btn:hover {
            background: #44634d; color: #fff; border-color: #44634d;
        }

        .profile-meta h1 {
            font-size: 28px; font-weight: 700;
            color: #fff; letter-spacing: -.02em;
            margin-bottom: 6px;
        }
        .profile-meta .handle {
            color: #9ca3af; font-size: 15px;
            display: flex; align-items: center; gap: 7px;
        }
        .profile-meta .handle i { color: #44634d; }

        /* ── Info grid (view mode) ──────────────────────────────────── */
        .info-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 20px;
        }

        .info-item {
            background: #13171d;
            border: 1px solid #1e2228;
            border-radius: 14px;
            padding: 20px 22px;
            transition: border-color .2s, transform .2s;
        }
        .info-item:hover {
            border-color: #44634d;
            transform: translateY(-2px);
        }

        .info-label {
            font-size: 11px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: .06em;
            color: #6b7280;
            display: flex;
            align-items: center;
            gap: 7px;
            margin-bottom: 8px;
        }
        .info-label i { color: #44634d; }

        .info-value {
            font-size: 16px;
            font-weight: 500;
            color: #e5e7eb;
        }

        /* ── Edit note ─────────────────────────────────────────────── */
        .edit-note {
            background: #13171d;
            border-left: 3px solid #44634d;
            border-radius: 10px;
            padding: 14px 18px;
            margin-bottom: 24px;
            font-size: 13px;
            color: #9ca3af;
            display: flex;
            align-items: flex-start;
            gap: 12px;
        }
        .edit-note i { color: #44634d; margin-top: 2px; flex-shrink: 0; }
        .edit-note strong { color: #86efac; }

        /* ── Form ──────────────────────────────────────────────────── */
        .form-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 20px;
        }

        .form-group label {
            display: block;
            font-size: 11px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: .06em;
            color: #6b7280;
            margin-bottom: 8px;
        }
        .form-group label i { color: #44634d; margin-right: 6px; }

        .form-control {
            width: 100%;
            padding: 11px 14px;
            background: #13171d;
            border: 1px solid #2a2f3a;
            border-radius: 9px;
            color: #e5e7eb;
            font-size: 15px;
            transition: border-color .2s, box-shadow .2s;
        }
        .form-control:focus {
            outline: none;
            border-color: #44634d;
            box-shadow: 0 0 0 3px rgba(68,99,77,.15);
        }
        .form-control.is-error   { border-color: #ef4444; }
        .form-control.is-success { border-color: #44634d; }
        .form-control[readonly] {
            background: #0d1014;
            color: #4b5563;
            cursor: not-allowed;
        }

        /* Username availability indicator */
        .avail {
            margin-top: 7px;
            font-size: 12px;
            display: flex;
            align-items: center;
            gap: 6px;
        }
        .avail-checking { color: #9ca3af; }
        .avail-ok       { color: #86efac; }
        .avail-taken    { color: #f87171; }
        .spin { animation: spin 1s linear infinite; }
        @keyframes spin { to { transform: rotate(360deg); } }

        /* ── Action buttons ────────────────────────────────────────── */
        .actions {
            margin-top: 32px;
            display: flex;
            justify-content: flex-end;
            gap: 12px;
        }

        .btn {
            padding: 11px 22px;
            border-radius: 9px;
            font-size: 14px;
            font-weight: 500;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            border: none;
            text-decoration: none;
            transition: all .2s;
        }
        .btn-primary {
            background: #44634d; color: #fff;
        }
        .btn-primary:hover:not(:disabled) {
            background: #365340;
            box-shadow: 0 8px 20px rgba(68,99,77,.25);
            transform: translateY(-1px);
        }
        .btn-primary:disabled {
            background: #1f2a22; color: #4b5563; cursor: not-allowed;
        }
        .btn-ghost {
            background: #13171d;
            color: #9ca3af;
            border: 1px solid #2a2f3a;
        }
        .btn-ghost:hover {
            background: #1a1e24; color: #fff; border-color: #44634d;
            transform: translateY(-1px);
        }

        /* ── Photo modal ───────────────────────────────────────────── */
        .modal-overlay {
            display: none;
            position: fixed; inset: 0;
            background: rgba(0,0,0,.85);
            backdrop-filter: blur(6px);
            z-index: 900;
            animation: fadeIn .25s ease;
        }
        @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }

        .modal {
            background: #0f1115;
            border: 1px solid #1e2228;
            border-radius: 20px;
            width: 90%;
            max-width: 860px;
            max-height: 85vh;
            overflow-y: auto;
            margin: 5vh auto;
            padding: 32px;
            animation: popUp .25s ease;
        }
        @keyframes popUp {
            from { transform: translateY(-30px); opacity: 0; }
            to   { transform: translateY(0);     opacity: 1; }
        }
        .modal::-webkit-scrollbar { width: 6px; }
        .modal::-webkit-scrollbar-track { background: #13171d; border-radius: 3px; }
        .modal::-webkit-scrollbar-thumb { background: #44634d; border-radius: 3px; }

        .modal-head {
            display: flex; justify-content: space-between; align-items: center;
            margin-bottom: 8px; padding-bottom: 16px; border-bottom: 1px solid #1e2228;
        }
        .modal-head h3 {
            font-size: 20px; font-weight: 600; color: #fff;
            display: flex; align-items: center; gap: 10px;
        }
        .modal-head h3 i { color: #44634d; }
        .close-btn {
            background: none; border: none; color: #6b7280;
            font-size: 26px; cursor: pointer; line-height: 1;
            transition: color .2s;
        }
        .close-btn:hover { color: #ef4444; }

        .modal-sub { color: #6b7280; font-size: 14px; margin-bottom: 22px; }

        .image-grid {
            display: grid;
            grid-template-columns: repeat(5, 1fr);
            gap: 16px;
        }

        .img-opt {
            background: #13171d;
            border: 1px solid #2a2f3a;
            border-radius: 14px;
            padding: 14px 10px;
            text-align: center;
            cursor: pointer;
            transition: all .2s;
        }
        .img-opt:hover {
            border-color: #44634d;
            transform: translateY(-4px);
            background: #181e25;
        }
        .img-opt.selected {
            border: 2px solid #44634d;
            background: #162119;
        }
        .img-opt img {
            width: 80px; height: 80px;
            border-radius: 50%;
            object-fit: cover;
            border: 2px solid #2a2f3a;
            margin-bottom: 8px;
        }
        .img-opt.selected img { border-color: #44634d; }
        .img-opt span { font-size: 12px; color: #d1d5db; font-weight: 500; }

        .modal-footer {
            display: flex; justify-content: flex-end; gap: 12px;
            margin-top: 24px; padding-top: 20px; border-top: 1px solid #1e2228;
        }

        /* ── Responsive ────────────────────────────────────────────── */
        @media (max-width: 700px) {
            .profile-header { flex-direction: column; text-align: center; }
            .info-grid, .form-grid { grid-template-columns: 1fr; }
            .image-grid { grid-template-columns: repeat(3, 1fr); }
            .card { padding: 24px 18px; }
        }
        @media (max-width: 440px) {
            .image-grid { grid-template-columns: repeat(2, 1fr); }
        }
    </style>
</head>
<body>

<div class="page-wrap">

    <%-- ── Toasts ──────────────────────────────────────────────── --%>
    <% if (successMsg != null && !successMsg.isEmpty()) { %>
        <div class="toast toast-success">
            <i class="fas fa-check-circle"></i> <%= successMsg %>
        </div>
    <% } %>
    <% if (errorMsg != null && !errorMsg.isEmpty()) { %>
        <div class="toast toast-error">
            <i class="fas fa-exclamation-circle"></i> <%= errorMsg %>
        </div>
    <% } %>

    <div class="card">

        <%-- ── Profile header ─────────────────────────────────── --%>
        <div class="profile-header">
            <div class="avatar-wrap">
                <img src="<%= attrProfileImg %>"
                     alt="Profile photo"
                     class="avatar"
                     onclick="openModal()"
                     onerror="this.src='https://i.ibb.co/6RfWN4zJ/buddy-10158022.png'">
                <button class="change-photo-btn" onclick="openModal()">
                    <i class="fas fa-camera"></i> Change Photo
                </button>
            </div>
            <div class="profile-meta">
                <h1><%= attrFirstName %> <%= attrLastName %></h1>
                <p class="handle">
                    <i class="fas fa-at"></i> @<%= attrUsername %>
                </p>
            </div>
        </div>

        <%-- ── View mode ───────────────────────────────────────── --%>
        <% if (!isEditing) { %>

            <div class="info-grid">
                <div class="info-item">
                    <div class="info-label"><i class="fas fa-user"></i> Username</div>
                    <div class="info-value">@<%= attrUsername.isEmpty() ? "—" : attrUsername %></div>
                </div>
                <div class="info-item">
                    <div class="info-label"><i class="fas fa-id-badge"></i> First Name</div>
                    <div class="info-value"><%= attrFirstName.isEmpty() ? "Not set" : attrFirstName %></div>
                </div>
                <div class="info-item">
                    <div class="info-label"><i class="fas fa-id-badge"></i> Last Name</div>
                    <div class="info-value"><%= attrLastName.isEmpty() ? "Not set" : attrLastName %></div>
                </div>
                <div class="info-item">
                    <div class="info-label"><i class="fas fa-envelope"></i> Email</div>
                    <div class="info-value"><%= attrEmail.isEmpty() ? "—" : attrEmail %></div>
                </div>
                <div class="info-item">
                    <div class="info-label"><i class="fas fa-phone"></i> Mobile</div>
                    <div class="info-value"><%= attrPhone.isEmpty() ? "Not provided" : attrPhone %></div>
                </div>
            </div>

            <div class="actions">
                <a href="<%= request.getContextPath() %>/profile?edit=true" class="btn btn-primary">
                    <i class="fas fa-edit"></i> Edit Profile
                </a>
                <button class="btn btn-ghost" onclick="alert('Password change coming soon!')">
                    <i class="fas fa-key"></i> Change Password
                </button>
            </div>

        <%-- ── Edit mode ───────────────────────────────────────── --%>
        <% } else { %>

            <div class="edit-note">
                <i class="fas fa-info-circle"></i>
                <div><strong>Note:</strong> Email and phone number cannot be changed.
                Contact support if you need to update them.</div>
            </div>

            <form method="post" action="<%= request.getContextPath() %>/profile" id="profileForm">
                <%-- No action param means servlet doPost handles profile update --%>
                <div class="form-grid">

                    <%-- Username --%>
                    <div class="form-group">
                        <label><i class="fas fa-user"></i> Username</label>
                        <input type="text"
                               id="username"
                               name="username"
                               class="form-control"
                               value="<%= attrUsername %>"
                               required minlength="3" maxlength="20"
                               pattern="[a-zA-Z0-9_]+"
                               title="Letters, numbers, and underscores only"
                               onkeyup="checkUsername()">
                        <div id="availMsg" class="avail" style="display:none;"></div>
                    </div>

                    <%-- First Name --%>
                    <div class="form-group">
                        <label><i class="fas fa-id-badge"></i> First Name</label>
                        <input type="text" name="firstName" class="form-control"
                               value="<%= attrFirstName %>" required>
                    </div>

                    <%-- Last Name --%>
                    <div class="form-group">
                        <label><i class="fas fa-id-badge"></i> Last Name</label>
                        <input type="text" name="lastName" class="form-control"
                               value="<%= attrLastName %>">
                    </div>

                    <%-- Email – read-only --%>
                    <div class="form-group">
                        <label><i class="fas fa-envelope"></i> Email</label>
                        <input type="email" class="form-control"
                               value="<%= attrEmail %>" readonly>
                    </div>

                    <%-- Phone – read-only --%>
                    <div class="form-group">
                        <label><i class="fas fa-phone"></i> Mobile</label>
                        <input type="tel" class="form-control"
                               value="<%= attrPhone %>" readonly>
                    </div>
                </div>

                <div class="actions">
                    <a href="<%= request.getContextPath() %>/profile" class="btn btn-ghost">
                        <i class="fas fa-times"></i> Cancel
                    </a>
                    <button type="submit" id="saveBtn" class="btn btn-primary" disabled>
                        <i class="fas fa-save"></i> Save Changes
                    </button>
                </div>
            </form>

            <script>
                const ORIGINAL_USERNAME = "<%= attrUsername %>";
                let usernameOk = true;
                let debounce;

                function checkUsername() {
                    const field  = document.getElementById('username');
                    const msgBox = document.getElementById('availMsg');
                    const saveBtn = document.getElementById('saveBtn');
                    const val = field.value.trim();

                    clearTimeout(debounce);
                    msgBox.style.display = 'none';
                    field.classList.remove('is-error', 'is-success');

                    if (val.length < 3) {
                        setMsg(msgBox, 'taken', 'At least 3 characters required');
                        field.classList.add('is-error');
                        saveBtn.disabled = true;
                        return;
                    }
                    if (!/^[a-zA-Z0-9_]+$/.test(val)) {
                        setMsg(msgBox, 'taken', 'Letters, numbers, and underscores only');
                        field.classList.add('is-error');
                        saveBtn.disabled = true;
                        return;
                    }
                    if (val === ORIGINAL_USERNAME) {
                        setMsg(msgBox, 'ok', 'Your current username');
                        field.classList.add('is-success');
                        saveBtn.disabled = false;
                        return;
                    }

                    setMsg(msgBox, 'checking', 'Checking availability…');

                    debounce = setTimeout(() => {
                        fetch('<%= request.getContextPath() %>/checkUsername?username='
                              + encodeURIComponent(val)
                              + '&currentUserId=<%= request.getAttribute("userId") %>')
                        .then(r => r.json())
                        .then(data => {
                            if (data.available) {
                                setMsg(msgBox, 'ok', data.message || 'Available!');
                                field.classList.add('is-success');
                                saveBtn.disabled = false;
                            } else {
                                setMsg(msgBox, 'taken', data.message || 'Already taken');
                                field.classList.add('is-error');
                                saveBtn.disabled = true;
                            }
                        })
                        .catch(() => {
                            setMsg(msgBox, 'taken', 'Could not check — please try again');
                            saveBtn.disabled = true;
                        });
                    }, 450);
                }

                function setMsg(el, type, text) {
                    const icons = {
                        checking: '<i class="fas fa-spinner spin"></i>',
                        ok:       '<i class="fas fa-check-circle"></i>',
                        taken:    '<i class="fas fa-exclamation-circle"></i>'
                    };
                    const classes = { checking: 'avail-checking', ok: 'avail-ok', taken: 'avail-taken' };
                    el.className = 'avail ' + classes[type];
                    el.innerHTML = icons[type] + ' ' + text;
                    el.style.display = 'flex';
                }

                // Enable save on page load (username is unchanged)
                document.addEventListener('DOMContentLoaded', () => checkUsername());
            </script>

        <% } %>
    </div>
</div>

<%-- ══ Photo selection modal ═══════════════════════════════════════ --%>
<div id="photoModal" class="modal-overlay" onclick="handleOverlayClick(event)">
    <div class="modal">
        <div class="modal-head">
            <h3><i class="fas fa-images"></i> Choose Profile Picture</h3>
            <button class="close-btn" onclick="closeModal()">&times;</button>
        </div>
        <p class="modal-sub">Pick an avatar that represents you best.</p>

        <form method="post" action="<%= request.getContextPath() %>/profile">
            <input type="hidden" name="action"        value="updateImage">
            <input type="hidden" name="selectedImage" id="selectedImage" value="<%= attrProfileImg %>">

            <div class="image-grid">
                <% String[][] avatars = {
                    {"https://i.ibb.co/6RfWN4zJ/buddy-10158022.png",    "Buddy"},
                    {"https://i.ibb.co/yFKRG8St/dog-1308845.png",       "Dog"},
                    {"https://i.ibb.co/BVbK97XP/fox-6273598.png",       "Fox"},
                    {"https://i.ibb.co/mVMwPNmR/girl-18663698.png",     "Girl"},
                    {"https://i.ibb.co/gZ3q4N8r/ikaros-4330351.png",    "Ikaros"},
                    {"https://i.ibb.co/Nbh8QFZ/man1.png",               "Man 1"},
                    {"https://i.ibb.co/YnxdrLy/man2.png",               "Man 2"},
                    {"https://i.ibb.co/RkwZQ8Tg/man3.png",              "Man 3"},
                    {"https://i.ibb.co/r2HFynkd/man4.png",              "Man 4"},
                    {"https://i.ibb.co/wZy01ByD/man5.png",              "Man 5"},
                    {"https://i.ibb.co/xKmJGVrv/people-14074487.png",   "People"},
                    {"https://i.ibb.co/TqBym0ZX/smile-16064030.png",    "Smile"},
                    {"https://i.ibb.co/F4b4xPhR/woman-6833605.png",     "Woman 1"},
                    {"https://i.ibb.co/hJLRgKY1/woman-6997662.png",     "Woman 2"},
                    {"https://i.ibb.co/prKpM2jD/woman-6997664.png",     "Woman 3"}
                };
                for (String[] av : avatars) {
                    String url  = av[0];
                    String name = av[1];
                    boolean isCurrent = url.equals(attrProfileImg);
                %>
                <div class="img-opt <%= isCurrent ? "selected" : "" %>"
                     onclick="selectAvatar(this, '<%= url %>')">
                    <img src="<%= url %>" alt="<%= name %>"
                         onerror="this.src='https://i.ibb.co/6RfWN4zJ/buddy-10158022.png'">
                    <span><%= name %></span>
                </div>
                <% } %>
            </div>

            <div class="modal-footer">
                <button type="button" class="btn btn-ghost" onclick="closeModal()">
                    <i class="fas fa-times"></i> Cancel
                </button>
                <button type="submit" class="btn btn-primary">
                    <i class="fas fa-check"></i> Save Photo
                </button>
            </div>
        </form>
    </div>
</div>

<script>
    function openModal()  { document.getElementById('photoModal').style.display = 'block'; }
    function closeModal() { document.getElementById('photoModal').style.display = 'none';  }
    function handleOverlayClick(e) {
        if (e.target === document.getElementById('photoModal')) closeModal();
    }
    function selectAvatar(el, url) {
        document.querySelectorAll('.img-opt').forEach(o => o.classList.remove('selected'));
        el.classList.add('selected');
        document.getElementById('selectedImage').value = url;
    }
</script>

</body>
</html>
