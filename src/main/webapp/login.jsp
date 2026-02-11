<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>CyberSphere | Login</title>

    <style>
        body{
            margin:0;
            height:100vh;
            display:flex;
            justify-content:center;
            align-items:center;
            background:#0f172a;
            font-family:Arial, sans-serif;
            color:#e5e7eb;
        }

        .card{
            background:#020617;
            padding:35px;
            border-radius:12px;
            width:380px;
            box-shadow:0 10px 25px rgba(0,0,0,0.6);
        }

        h2{
            text-align:center;
            margin-bottom:20px;
            color:#38bdf8;
        }

        label{
            font-size:14px;
            margin-top:15px;
            display:block;
        }

        input{
            width:100%;
            padding:10px;
            margin-top:6px;
            border-radius:6px;
            border:none;
            outline:none;
            background:#0f172a;
            color:white;
        }

        .password-box{
            position:relative;
        }

        .eye{
            position:absolute;
            right:10px;
            top:50%;
            transform:translateY(-50%);
            cursor:pointer;
            color:#94a3b8;
        }

        .captcha-box{
            display:flex;
            justify-content:space-between;
            align-items:center;
            margin-top:8px;
        }

        .captcha{
            font-size:18px;
            font-weight:bold;
            letter-spacing:3px;
            background:#020617;
            padding:8px 12px;
            border-radius:6px;
            color:#38bdf8;
        }

        .error{
            background:#7f1d1d;
            color:#fecaca;
            padding:10px;
            border-radius:6px;
            font-size:14px;
            margin-bottom:15px;
            text-align:center;
        }

        button{
            margin-top:25px;
            width:100%;
            padding:12px;
            background:#2563eb;
            color:white;
            border:none;
            border-radius:6px;
            font-size:15px;
            cursor:pointer;
        }

        button:hover{
            background:#1d4ed8;
        }

        .link{
            text-align:center;
            margin-top:18px;
            font-size:14px;
        }

        .link a{
            color:#38bdf8;
            text-decoration:none;
        }
    </style>

    <script>
        function togglePassword(){
            let p = document.getElementById("password");
            p.type = p.type === "password" ? "text" : "password";
        }

        function generateCaptcha(){
            let chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
            let captcha = "";
            for(let i = 0; i < 6; i++){
                captcha += chars.charAt(Math.floor(Math.random() * chars.length));
            }
            document.getElementById("captchaText").innerText = captcha;
        }

        function validateCaptcha(){
            let entered = document.getElementById("captchaInput").value;
            let actual = document.getElementById("captchaText").innerText;

            if(entered !== actual){
                alert("Wrong captcha");
                generateCaptcha();
                return false;
            }
            return true;
        }

        window.onload = generateCaptcha;
    </script>
</head>

<body>

<div class="card">
    <h2>Login</h2>

    <% 
        String error = request.getParameter("error");
        if(error != null){
    %>
        <div class="error">
            <%= error %>
        </div>
    <% } %>

    <form action="<%= request.getContextPath() %>/LoginServlet"
          method="post"
          onsubmit="return validateCaptcha()">

        <label>Username or Email</label>
        <input type="text" name="loginInput" required>

        <label>Password</label>
        <div class="password-box">
            <input type="password" id="password" name="password" required>
            <span class="eye" onclick="togglePassword()">👁</span>
        </div>

        <label>Captcha</label>
        <div class="captcha-box">
            <span class="captcha" id="captchaText"></span>
            <button type="button" onclick="generateCaptcha()">↻</button>
        </div>

        <input type="text" id="captchaInput" name="captchaInput"
               placeholder="Enter captcha" required>

        <button type="submit">Login</button>
    </form>

    <div class="link">
        Don't have an account?
        <a href="signup.jsp">Sign up</a>
    </div>
</div>

</body>
</html>
