package controller;
import java.io.IOException;
import java.sql.*;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Map;


import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet("/SubmitQuizServlet")
public class SubmitQuizServlet extends HttpServlet {

	private static final String DB_URL = System.getenv("DB_URL");
	private static final String DB_USER = System.getenv("DB_USER");
	private static final String DB_PASS = System.getenv("DB_PASS");

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();

        Integer userId = (Integer) session.getAttribute("userId");
        if (userId == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // Level + SubLevel from quiz.jsp hidden fields
        String currentLevel    = request.getParameter("level");
        String currentSubLevel = request.getParameter("subLevel");

        int totalQuestions = 0;
        int correctAnswers = 0;

        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS)) {

            // Insert / Update progress
            String insertSQL =
                    "INSERT INTO user_progress " +
                    "(user_id, question_id, answered_option, is_correct, level, sub_level, topic, completed) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, 1) " +
                    "ON DUPLICATE KEY UPDATE " +
                    "answered_option = VALUES(answered_option), " +
                    "is_correct = VALUES(is_correct), " +
                    "completed = 1";

            PreparedStatement psInsert = conn.prepareStatement(insertSQL);

            Enumeration<String> params = request.getParameterNames();

            while (params.hasMoreElements()) {

                String param = params.nextElement();

                // All question inputs must be q1, q2, q3...
                if (param.startsWith("q")) {

                    int questionId = Integer.parseInt(param.substring(1));
                    String selectedAnswer = request.getParameter(param);

                    // Fetch correct answer + meta
                    String qSQL =
                            "SELECT correct_option, level, sub_level, topic " +
                            "FROM questions_new WHERE question_id = ?";

                    try (PreparedStatement psQ = conn.prepareStatement(qSQL)) {

                        psQ.setInt(1, questionId);

                        try (ResultSet rs = psQ.executeQuery()) {

                            if (rs.next()) {

                                String correctOption = rs.getString("correct_option");
                                boolean isCorrect =
                                        selectedAnswer != null &&
                                        selectedAnswer.equals(correctOption);

                                String level    = rs.getString("level");
                                String subLevel = rs.getString("sub_level");
                                String topic    = rs.getString("topic");

                                // Insert batch
                                psInsert.setInt(1, userId);
                                psInsert.setInt(2, questionId);
                                psInsert.setString(3, selectedAnswer);
                                psInsert.setBoolean(4, isCorrect);
                                psInsert.setString(5, level);
                                psInsert.setString(6, subLevel);
                                psInsert.setString(7, topic);
                                psInsert.addBatch();

                                totalQuestions++;
                                if (isCorrect) correctAnswers++;
                            }
                        }
                    }
                }
            }

            psInsert.executeBatch();

            // Score %
            int scorePercentage =
                    totalQuestions > 0
                            ? (correctAnswers * 100) / totalQuestions
                            : 0;

            // Store score in session
            String scoreKey =
                    currentLevel + "_" + currentSubLevel + "_score";

            session.setAttribute(scoreKey, scorePercentage);

            // Track completed sublevels
            Map<String, Boolean> completedSublevels =
                    (Map<String, Boolean>) session.getAttribute("completedSublevels");

            if (completedSublevels == null)
                completedSublevels = new HashMap<>();

            completedSublevels.put(scoreKey, true);
            session.setAttribute("completedSublevels", completedSublevels);

            // 🎓 CERTIFICATE LOGIC
            if ("Hard".equalsIgnoreCase(currentLevel)) {

                boolean allCompleted =
                        checkAllSublevelsCompleted(conn, userId, currentLevel);

                if (allCompleted) {

                    int overallScore =
                            calculateOverallScore(conn, userId);

                    session.setAttribute("certificateUnlocked", true);
                    session.setAttribute("overallScore", overallScore);
                    session.setAttribute("completionDate", new java.util.Date());

                    String fullName =
                            getUserName(conn, userId);

                    if (fullName != null) {

                        String[] parts = fullName.split(" ", 2);

                        session.setAttribute("firstName", parts[0]);

                        if (parts.length > 1)
                            session.setAttribute("lastName", parts[1]);
                    }

                    session.setAttribute("showCertificate", true);
                }
            }

            session.setAttribute("quizCompleted", true);

            response.sendRedirect("quizResult.jsp?score=" + scorePercentage);

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("Error saving progress.");
        }
    }

    // ✅ Check all sublevels completed
    private boolean checkAllSublevelsCompleted(
            Connection conn,
            int userId,
            String level) throws SQLException {

        String sql =
                "SELECT COUNT(DISTINCT sub_level) AS cnt " +
                "FROM user_progress " +
                "WHERE user_id=? AND level=? AND completed=1";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setString(2, level);

            try (ResultSet rs = ps.executeQuery()) {

                if (rs.next()) {
                    return rs.getInt("cnt") >= 5; // 5 sublevels
                }
            }
        }
        return false;
    }

    // ✅ Overall score
    private int calculateOverallScore(
            Connection conn,
            int userId) throws SQLException {

        String sql =
                "SELECT " +
                "(SUM(CASE WHEN is_correct=1 THEN 1 ELSE 0 END)*100/COUNT(*)) AS pct " +
                "FROM user_progress " +
                "WHERE user_id=? AND completed=1";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next())
                    return rs.getInt("pct");
            }
        }
        return 0;
    }

    // ✅ Get user name (FIXED for your table)
    private String getUserName(
            Connection conn,
            int userId) throws SQLException {

        String sql =
                "SELECT first_name, last_name " +
                "FROM users WHERE id=?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {

                if (rs.next()) {

                    return rs.getString("first_name")
                            + " "
                            + rs.getString("last_name");
                }
            }
        }
        return null;
    }
}