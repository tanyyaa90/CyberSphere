<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>CyberSphere | Sign Up</title>

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
            margin-bottom:25px;
            color:#38bdf8;
        }

        label{
            font-size:14px;
            margin-top:14px;
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

        small{
            font-size:12px;
            color:#f87171;
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
        function togglePassword(id){
            let field = document.getElementById(id);
            field.type = field.type === "password" ? "text" : "password";
        }

        function validatePhone(){
            const phoneInput = document.getElementById("phone");
            const phoneError = document.getElementById("phoneError");

            let value = phoneInput.value;

            // +91 must stay
            if (!value.startsWith("+91")) {
                phoneInput.value = "+91";
                phoneError.innerText = "";
                return false;
            }

            // Extract digits after +91
            let digits = value.substring(3);

            // Ignore leading and trailing spaces
            let trimmed = digits.trim();

            // Spaces inside digits are not allowed
            if (trimmed.includes(" ")) {
                phoneError.innerText = "Remove spaces between digits";
                return false;
            }

            // Must contain only digits
            if (!/^\d*$/.test(trimmed)) {
                phoneError.innerText = "Only digits allowed";
                return false;
            }

            // Must be exactly 10 digits
            if (trimmed.length !== 10) {
                phoneError.innerText = "Phone number must contain exactly 10 digits";
                return false;
            }

            phoneError.innerText = "";
            phoneInput.value = "+91" + trimmed;
            return true;
        }

        function validateForm(){
            let email = document.forms["signup"]["email"].value;
            let password = document.forms["signup"]["password"].value;
            let confirm = document.forms["signup"]["confirmPassword"].value;

            let emailPattern = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.com$/;
            let passPattern = /^(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&]).{8,}$/;

            if(!emailPattern.test(email)){
                alert("Email must end with .com");
                return false;
            }

            if(!passPattern.test(password)){
                alert("Password must have 1 capital letter, 1 digit, and 1 special character");
                return false;
            }

            if(password !== confirm){
                alert("Passwords do not match");
                return false;
            }

            if(!validatePhone()){
                return false;
            }

            return true;
        }
    </script>
</head>

<body>

<div class="card">
    <h2>Create Account</h2>

    <form name="signup"
          action="<%= request.getContextPath() %>/SignUpServlet"
          method="post"
          onsubmit="return validateForm()">

        <label>First Name *</label>
        <input type="text" name="firstName" required>

        <label>Last Name</label>
        <input type="text" name="lastName">

        <label>Username *</label>
        <input type="text" name="username" required>

        <label>Email *</label>
        <input type="text" name="email" placeholder="example@gmail.com" required>

        <label>Phone *</label>
        <input type="text" id="phone" name="phone" value="+91" oninput="validatePhone()" required>
        <small id="phoneError"></small>

        <label>Password *</label>
        <div class="password-box">
            <input type="password" id="password" name="password" required>
            <span class="eye" onclick="togglePassword('password')">👁</span>
        </div>

        <label>Confirm Password *</label>
        <div class="password-box">
            <input type="password" id="confirmPassword" name="confirmPassword" required>
            <span class="eye" onclick="togglePassword('confirmPassword')">👁</span>
        </div>

        <button type="submit">Sign Up</button>
    </form>

    <div class="link">
        Already have an account?
        <a href="login.jsp">Login</a>
    </div>
</div>

</body>
</html>
