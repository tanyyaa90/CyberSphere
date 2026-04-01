package controller;

import java.io.IOException;
import java.sql.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet("/CertificateEligibilityServlet")
public class CertificateEligibilityServlet extends HttpServlet {

	private static final String DB_URL = System.getenv("DB_URL");
	private static final String DB_USER = System.getenv("DB_USER");
	private static final String DB_PASS = System.getenv("DB_PASS");

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Integer userId = (Integer) session.getAttribute("userId");

        if (userId == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // FIX 5: read the level param so we can pass it forward
        String level = request.getParameter("level");
        if (level == null || level.isEmpty()) {
            response.sendRedirect("select_level.jsp");
            return;
        }

        boolean eligible = checkCertificateEligibility(userId, level);

        if (eligible) {
            // FIX 5: pass level to CertificateServlet
            response.sendRedirect("CertificateServlet?level=" + level);
        } else {
            response.sendRedirect("select_sublevel.jsp?level=" + level
                + "&error=Complete+all+5+sublevels+with+35%25+score+first");
        }
    }

    // FIX 4: query quiz_attempts (correct table) instead of user_progress
    private boolean checkCertificateEligibility(int userId, String level) {
        String sql = "SELECT COUNT(DISTINCT sub_level) AS completed_subs " +
                     "FROM quiz_attempts " +
                     "WHERE user_id = ? AND level = ? AND percentage >= 35";

        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setString(2, level);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getInt("completed_subs") >= 5;
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}