package controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.mindrot.jbcrypt.BCrypt;

@WebServlet("/SignUpServlet")
public class SignUpServlet extends HttpServlet {

	private static final String DB_URL = System.getenv("DB_URL");
	private static final String DB_USER = System.getenv("DB_USER");
	private static final String DB_PASS = System.getenv("DB_PASS");
    
    // Default profile image
    private static final String DEFAULT_PROFILE_IMAGE = "https://i.ibb.co/6RfWN4zJ/buddy-10158022.png";

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // DEBUG: Print all parameters
        System.out.println("========== DEBUG: ALL PARAMETERS ==========");
        java.util.Enumeration<String> paramNames = request.getParameterNames();
        while (paramNames.hasMoreElements()) {
            String paramName = paramNames.nextElement();
            String paramValue = request.getParameter(paramName);
            System.out.println(paramName + " = " + paramValue);
        }
        System.out.println("==========================================");

        String firstName = request.getParameter("firstName");
        String lastName = request.getParameter("lastName");
        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String password = request.getParameter("password");// FIXED: Match JSP form
        String confirm = request.getParameter("confirmPassword");

        // DEBUG: Log each field
        System.out.println("firstName: '" + firstName + "'");
        System.out.println("lastName: '" + lastName + "'");
        System.out.println("username: '" + username + "'");
        System.out.println("email: '" + email + "'");
        System.out.println("phone: '" + phone + "'");
        System.out.println("password: '" + password + "'");
        System.out.println("confirm: '" + confirm + "'");

        // Check each field individually
        if (firstName == null || firstName.trim().isEmpty()) {
            System.out.println("❌ firstName is empty!");
            response.sendRedirect("signup.jsp?error=First name is required");
            return;
        }
        if (username == null || username.trim().isEmpty()) {
            System.out.println("❌ username is empty!");
            response.sendRedirect("signup.jsp?error=Username is required");
            return;
        }
        if (email == null || email.trim().isEmpty()) {
            System.out.println("❌ email is empty!");
            response.sendRedirect("signup.jsp?error=Email is required");
            return;
        }
        if (password == null || password.trim().isEmpty()) {
            System.out.println("❌ password is empty!");
            response.sendRedirect("signup.jsp?error=Password is required");
            return;
        }

        Connection con = null;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
            
            // Check if username already exists
            PreparedStatement ps1 = con.prepareStatement("SELECT id FROM users WHERE username=?");
            ps1.setString(1, username);
            ResultSet rs1 = ps1.executeQuery();

            if (rs1.next()) {
                System.out.println("❌ Username already exists: " + username);
                response.sendRedirect("signup.jsp?error=Username already taken");
                rs1.close();
                ps1.close();
                con.close();
                return;
            }
            rs1.close();
            ps1.close();

            // Check if email already exists
            PreparedStatement ps2 = con.prepareStatement("SELECT id FROM users WHERE email=?");
            ps2.setString(1, email);
            ResultSet rs2 = ps2.executeQuery();

            if (rs2.next()) {
                System.out.println("❌ Email already exists: " + email);
                response.sendRedirect("signup.jsp?error=Email already registered");
                rs2.close();
                ps2.close();
                con.close();
                return;
            }
            rs2.close();
            ps2.close();

            // Check if phone already exists (optional)
            if (phone != null && !phone.trim().isEmpty()) {
                PreparedStatement ps3 = con.prepareStatement("SELECT id FROM users WHERE phone=?");
                ps3.setString(1, phone);
                ResultSet rs3 = ps3.executeQuery();

                if (rs3.next()) {
                    System.out.println("❌ Phone number already exists: " + phone);
                    response.sendRedirect("signup.jsp?error=Phone number already registered");
                    rs3.close();
                    ps3.close();
                    con.close();
                    return;
                }
                rs3.close();
                ps3.close();
            }

            // Insert new user with profile_image field
            String sql = "INSERT INTO users(first_name, last_name, username, email, phone, password, profile_image) VALUES(?, ?, ?, ?, ?, ?, ?)";
            PreparedStatement ps = con.prepareStatement(sql);

            ps.setString(1, firstName);
            ps.setString(2, lastName);
            ps.setString(3, username);
            ps.setString(4, email);
            ps.setString(5, phone);
            
            // Hash password
            String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt(12));
            ps.setString(6, hashedPassword);
            
            // Set default profile image
            ps.setString(7, DEFAULT_PROFILE_IMAGE);

            int rowsInserted = ps.executeUpdate();
            
            if (rowsInserted > 0) {
                System.out.println("✅ User registered successfully: " + username);
                response.sendRedirect("login.jsp?success=Account created successfully! Please login.");
            } else {
                System.out.println("❌ Failed to insert user");
                response.sendRedirect("signup.jsp?error=Registration failed");
            }

            ps.close();

        } catch (Exception e) {
            System.out.println("❌ Error during signup: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("signup.jsp?error=Something went wrong: " + e.getMessage());
            
        } finally {
            try {
                if (con != null) con.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
}