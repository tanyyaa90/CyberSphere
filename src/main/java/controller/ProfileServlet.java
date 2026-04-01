package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/profile")
public class ProfileServlet extends HttpServlet {

	private static final String DB_URL = System.getenv("DB_URL");
	private static final String DB_USER = System.getenv("DB_USER");
	private static final String DB_PASS = System.getenv("DB_PASS");
    // ─── GET: Load profile page ───────────────────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Integer userId = (Integer) session.getAttribute("userId");

        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        loadUserProfile(request, userId);
        request.getRequestDispatcher("/profile.jsp").forward(request, response);
    }

    // ─── POST: Update profile fields ─────────────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Integer userId = (Integer) session.getAttribute("userId");

        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String action = request.getParameter("action");

        if ("updateImage".equals(action)) {
            handleImageUpdate(request, response, session, userId);
        } else {
            handleProfileUpdate(request, response, session, userId);
        }
    }

    // ─── Load user from DB into request attributes ────────────────────────────
    private void loadUserProfile(HttpServletRequest request, int userId) {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);

            String sql = "SELECT id, first_name, last_name, username, email, phone, profile_image " +
                         "FROM users WHERE id = ?";
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, userId);
            rs = stmt.executeQuery();

            if (rs.next()) {
                request.setAttribute("userId",    rs.getInt("id"));
                request.setAttribute("firstName", rs.getString("first_name"));
                request.setAttribute("lastName",  rs.getString("last_name"));
                request.setAttribute("username",  rs.getString("username"));
                request.setAttribute("email",     rs.getString("email"));
                request.setAttribute("phone",     rs.getString("phone"));

                String profileImage = rs.getString("profile_image");
                if (profileImage == null || profileImage.trim().isEmpty()) {
                    profileImage = "https://i.ibb.co/6RfWN4zJ/buddy-10158022.png";
                }
                request.setAttribute("profileImage", profileImage);

                // Keep session in sync
                request.getSession().setAttribute("profileImage", profileImage);
                request.getSession().setAttribute("firstName",    rs.getString("first_name"));
                request.getSession().setAttribute("username",     rs.getString("username"));

                System.out.println("✅ Profile loaded for: " + rs.getString("username"));
            } else {
                System.out.println("❌ No user found with ID: " + userId);
                request.setAttribute("error", "User not found.");
            }

        } catch (ClassNotFoundException e) {
            System.out.println("❌ Driver error: " + e.getMessage());
            request.setAttribute("error", "Database driver error.");
        } catch (SQLException e) {
            System.out.println("❌ SQL error: " + e.getMessage());
            request.setAttribute("error", "Database error: " + e.getMessage());
        } finally {
            close(rs, stmt, conn);
        }
    }

    // ─── Handle profile info update ───────────────────────────────────────────
    private void handleProfileUpdate(HttpServletRequest request,
                                     HttpServletResponse response,
                                     HttpSession session,
                                     int userId)
            throws ServletException, IOException {

        String username  = request.getParameter("username");
        String firstName = request.getParameter("firstName");
        String lastName  = request.getParameter("lastName");

        // Basic validation
        if (username == null || username.trim().length() < 3) {
            request.setAttribute("error", "Username must be at least 3 characters.");
            loadUserProfile(request, userId);
            request.setAttribute("editMode", true);
            request.getRequestDispatcher("profile.jsp").forward(request, response);
            return;
        }

        if (!username.matches("[a-zA-Z0-9_]+")) {
            request.setAttribute("error", "Username can only contain letters, numbers, and underscores.");
            loadUserProfile(request, userId);
            request.setAttribute("editMode", true);
            request.getRequestDispatcher("profile.jsp").forward(request, response);
            return;
        }

        Connection conn = null;
        PreparedStatement stmt = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);

            // Check username uniqueness (excluding current user)
            PreparedStatement checkStmt = conn.prepareStatement(
                "SELECT id FROM users WHERE username = ? AND id != ?"
            );
            checkStmt.setString(1, username.trim());
            checkStmt.setInt(2, userId);
            ResultSet checkRs = checkStmt.executeQuery();

            if (checkRs.next()) {
                checkRs.close();
                checkStmt.close();
                request.setAttribute("error", "Username '" + username + "' is already taken.");
                loadUserProfile(request, userId);
                request.setAttribute("editMode", true);
                request.getRequestDispatcher("profile.jsp").forward(request, response);
                return;
            }
            checkRs.close();
            checkStmt.close();

            // Update the user record
            String sql = "UPDATE users SET username = ?, first_name = ?, last_name = ? WHERE id = ?";
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, username.trim());
            stmt.setString(2, firstName != null ? firstName.trim() : "");
            stmt.setString(3, lastName  != null ? lastName.trim()  : "");
            stmt.setInt(4, userId);
            stmt.executeUpdate();

            // Sync session
            session.setAttribute("firstName", firstName != null ? firstName.trim() : "");
            session.setAttribute("username",  username.trim());

            System.out.println("✅ Profile updated for user ID: " + userId);
            response.sendRedirect(request.getContextPath() + "/profile?success=Profile+updated+successfully!");

        } catch (ClassNotFoundException | SQLException e) {
            System.out.println("❌ Update error: " + e.getMessage());
            request.setAttribute("error", "Failed to update profile: " + e.getMessage());
            loadUserProfile(request, userId);
            request.setAttribute("editMode", true);
            request.getRequestDispatcher("profile.jsp").forward(request, response);
        } finally {
            close(null, stmt, conn);
        }
    }

    // ─── Handle profile image update ──────────────────────────────────────────
    private void handleImageUpdate(HttpServletRequest request,
                                   HttpServletResponse response,
                                   HttpSession session,
                                   int userId)
            throws IOException {

        String selectedImage = request.getParameter("selectedImage");

        if (selectedImage == null || selectedImage.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/profile?error=No+image+selected.");
            return;
        }

        Connection conn = null;
        PreparedStatement stmt = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);

            String sql = "UPDATE users SET profile_image = ? WHERE id = ?";
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, selectedImage.trim());
            stmt.setInt(2, userId);
            stmt.executeUpdate();

            session.setAttribute("profileImage", selectedImage.trim());
            System.out.println("✅ Profile image updated for user ID: " + userId);
            response.sendRedirect(request.getContextPath() + "/profile?success=Profile+photo+updated!");

        } catch (ClassNotFoundException | SQLException e) {
            System.out.println("❌ Image update error: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/profile?error=Failed+to+update+photo.");
        } finally {
            close(null, stmt, conn);
        }
    }

    // ─── Utility: close DB resources ─────────────────────────────────────────
    private void close(ResultSet rs, PreparedStatement stmt, Connection conn) {
        try { if (rs   != null) rs.close();   } catch (SQLException ignored) {}
        try { if (stmt != null) stmt.close(); } catch (SQLException ignored) {}
        try { if (conn != null) conn.close(); } catch (SQLException ignored) {}
    }
}