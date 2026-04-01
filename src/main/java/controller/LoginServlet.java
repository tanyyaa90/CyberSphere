package controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import org.mindrot.jbcrypt.BCrypt;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

	private static final String DB_URL = System.getenv("DB_URL");
	private static final String DB_USER = System.getenv("DB_USER");
	private static final String DB_PASS = System.getenv("DB_PASS");

    protected void doPost(HttpServletRequest request,
            HttpServletResponse response) throws ServletException, IOException {

        String loginInput = request.getParameter("loginInput");
        String enteredPassword = request.getParameter("password");

        System.out.println("========== LOGIN ATTEMPT ==========");
        System.out.println("Login Input: " + loginInput);
        System.out.println("Password length: " + (enteredPassword != null ? enteredPassword.length() : 0));
        System.out.println("===================================");

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            System.out.println("MySQL Driver loaded successfully");

            Connection con = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
            System.out.println("Database connected successfully");

            // Get user details including is_main_admin
            String sql = "SELECT id, username, first_name, last_name, email, phone, password, profile_image, role, is_main_admin FROM users WHERE email=? OR username=?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, loginInput);
            ps.setString(2, loginInput);

            System.out.println("Executing query with parameter: " + loginInput);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                System.out.println("User found in database");
                String storedHashedPassword = rs.getString("password");

                if (BCrypt.checkpw(enteredPassword, storedHashedPassword)) {
                    System.out.println("Password MATCHED! Login successful");

                    HttpSession session = request.getSession();

                    int userId = rs.getInt("id");
                    String role = rs.getString("role");
                    if (role == null) role = "user";
                    
                    // Get is_main_admin from database
                    boolean isMainAdmin = rs.getBoolean("is_main_admin");
                    
                    System.out.println("is_main_admin from database: " + isMainAdmin);
                    
                    // Store basic user info
                    session.setAttribute("userId", userId);
                    session.setAttribute("username", rs.getString("username"));
                    session.setAttribute("firstName", rs.getString("first_name"));
                    session.setAttribute("lastName", rs.getString("last_name"));
                    session.setAttribute("email", rs.getString("email"));
                    session.setAttribute("phone", rs.getString("phone"));
                    session.setAttribute("profileImage", rs.getString("profile_image"));
                    session.setAttribute("role", role);
                    session.setAttribute("isMainAdmin", isMainAdmin);
                    
                    // ========== LOAD PERMISSIONS FOR ADMIN USERS ==========
                    if ("admin".equals(role)) {
                        // If this is the main admin, give full permissions
                        if (isMainAdmin) {
                            session.setAttribute("can_manage_users", true);
                            session.setAttribute("can_manage_content", true);
                            session.setAttribute("can_manage_quizzes", true);
                            session.setAttribute("can_manage_messages", true);
                            session.setAttribute("can_view_logs", true);
                            session.setAttribute("can_manage_settings", true);
                            session.setAttribute("can_manage_admins", true);
                            System.out.println("👑 Main Admin - granted FULL permissions");
                        } else {
                            // Load permissions for sub-admin from admin_permissions table
                            String permSql = "SELECT can_manage_users, can_manage_content, can_manage_quizzes, can_manage_messages, can_view_logs FROM admin_permissions WHERE user_id = ?";
                            PreparedStatement permPs = con.prepareStatement(permSql);
                            permPs.setInt(1, userId);
                            ResultSet permRs = permPs.executeQuery();
                            
                            if (permRs.next()) {
                                // Store permissions in session
                                session.setAttribute("can_manage_users", permRs.getBoolean("can_manage_users"));
                                session.setAttribute("can_manage_content", permRs.getBoolean("can_manage_content"));
                                session.setAttribute("can_manage_quizzes", permRs.getBoolean("can_manage_quizzes"));
                                session.setAttribute("can_manage_messages", permRs.getBoolean("can_manage_messages"));
                                session.setAttribute("can_view_logs", permRs.getBoolean("can_view_logs"));
                                
                                // Sub-admins cannot manage settings or other admins
                                session.setAttribute("can_manage_settings", false);
                                session.setAttribute("can_manage_admins", false);
                                
                                System.out.println("✅ Loaded permissions for sub-admin ID: " + userId);
                                System.out.println("  - Manage Users: " + permRs.getBoolean("can_manage_users"));
                                System.out.println("  - Manage Content: " + permRs.getBoolean("can_manage_content"));
                                System.out.println("  - Manage Quizzes: " + permRs.getBoolean("can_manage_quizzes"));
                                System.out.println("  - Manage Messages: " + permRs.getBoolean("can_manage_messages"));
                                System.out.println("  - View Logs: " + permRs.getBoolean("can_view_logs"));
                            } else {
                                // No permissions found - set all to false
                                session.setAttribute("can_manage_users", false);
                                session.setAttribute("can_manage_content", false);
                                session.setAttribute("can_manage_quizzes", false);
                                session.setAttribute("can_manage_messages", false);
                                session.setAttribute("can_view_logs", false);
                                session.setAttribute("can_manage_settings", false);
                                session.setAttribute("can_manage_admins", false);
                                System.out.println("⚠️ No permissions found for sub-admin ID: " + userId);
                            }
                            permRs.close();
                            permPs.close();
                        }
                    }
                    // =======================================================
                    
                    // Record user session
                    String sessionSql = "INSERT INTO user_sessions (user_id, login_time, ip_address) VALUES (?, NOW(), ?)";
                    try (PreparedStatement sessionStmt = con.prepareStatement(sessionSql)) {
                        sessionStmt.setInt(1, userId);
                        sessionStmt.setString(2, request.getRemoteAddr());
                        sessionStmt.executeUpdate();
                        System.out.println("✅ Session recorded for user ID: " + userId);
                    } catch (Exception e) {
                        System.out.println("⚠️ Could not record session: " + e.getMessage());
                    }

                    // Update last_login timestamp
                    String updateSql = "UPDATE users SET last_login = NOW() WHERE id = ?";
                    try (PreparedStatement updateStmt = con.prepareStatement(updateSql)) {
                        updateStmt.setInt(1, userId);
                        updateStmt.executeUpdate();
                        System.out.println("✅ Updated last_login for user ID: " + userId);
                    } catch (Exception e) {
                        System.out.println("⚠️ Could not update last_login: " + e.getMessage());
                    }

                    System.out.println("Session attributes set:");
                    System.out.println(" - userId: " + userId);
                    System.out.println(" - username: " + rs.getString("username"));
                    System.out.println(" - firstName: " + rs.getString("first_name"));
                    System.out.println(" - email: " + rs.getString("email"));
                    System.out.println(" - role: " + role);
                    System.out.println(" - isMainAdmin: " + isMainAdmin);

                    rs.close();
                    ps.close();
                    con.close();

                    // ========== REDIRECT BASED ON ADMIN TYPE ==========
                    if ("admin".equals(role)) {
                        if (isMainAdmin) {
                            // Main Admin - redirect to full admin dashboard
                            System.out.println("👑 Main Admin - redirecting to admin_home.jsp");
                            response.sendRedirect("admin/admin_home.jsp");
                        } else {
                            // Sub-Admin - redirect to regular home.jsp (they will see their limited admin buttons)
                            System.out.println("🔹 Sub-Admin - redirecting to home.jsp");
                            response.sendRedirect("home.jsp");
                        }
                    } else {
                        // Regular user - redirect to home.jsp
                        System.out.println("👤 Regular user - redirecting to home.jsp");
                        response.sendRedirect("home.jsp");
                    }
                    // ===================================================

                } else {
                    System.out.println("Password DID NOT match");
                    rs.close();
                    ps.close();
                    con.close();
                    response.sendRedirect("login.jsp?error=Username or password incorrect");
                }
            } else {
                System.out.println("No user found with: " + loginInput);
                rs.close();
                ps.close();
                con.close();
                response.sendRedirect("login.jsp?error=Username or password incorrect");
            }

        } catch (Exception e) {
            e.printStackTrace();
            System.out.println("EXCEPTION: " + e.getMessage());
            response.sendRedirect("login.jsp?error=Something went wrong");
        }
    }

    protected void doGet(HttpServletRequest request,
            HttpServletResponse response) throws ServletException, IOException {
        response.sendRedirect("login.jsp");
    }
}