package dao;

import model.Question;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class QuestionDAO {

    private static final String DB_URL  = "jdbc:mysql://localhost:3306/cybersphere";
    private static final String DB_USER = "root";
    private static final String DB_PASS = "root";

    public List<Question> getQuestionsByLevelAndSublevel(String level, String sublevel) {
        List<Question> questions = new ArrayList<>();
        String sql = "SELECT * FROM questions_new WHERE level = ? AND sub_level = ?";

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, level);
            ps.setString(2, sublevel);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Question q = new Question();
                q.setId(rs.getInt("question_id"));
                q.setQuestionText(rs.getString("question_text"));
                q.setOptionA(rs.getString("option1"));
                q.setOptionB(rs.getString("option2"));
                q.setOptionC(rs.getString("option3"));
                q.setOptionD(rs.getString("option4"));
                q.setCorrectAnswer(rs.getString("correct_option"));
                q.setTopic(rs.getString("topic"));
                q.setLevel(rs.getString("level"));
                q.setSublevel(rs.getString("sub_level"));
                q.setExplanation(rs.getString("explanation"));
                questions.add(q);
            }

            rs.close();
            ps.close();
            con.close();

        } catch (Exception e) {
            e.printStackTrace();
        }

        return questions;
    }

    public void saveQuizAttempt(Integer userId, String level, String sublevel,
                                int score, int total, int percentage) {
        // Insert new attempt — keeps full history so best score logic in
        // select_sublevel.jsp (MAX(percentage)) works correctly
        String sql = "INSERT INTO quiz_attempts (user_id, level, sub_level, score, total_questions, percentage) " +
                     "VALUES (?, ?, ?, ?, ?, ?)";

        Connection con = null;
        PreparedStatement ps = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
            ps  = con.prepareStatement(sql);
            ps.setInt(1, userId);
            ps.setString(2, level);
            ps.setString(3, sublevel);
            ps.setInt(4, score);
            ps.setInt(5, total);
            ps.setInt(6, percentage);
            ps.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (ps  != null) try { ps.close();  } catch (Exception e) {}
            if (con != null) try { con.close(); } catch (Exception e) {}
        }
    }
    public boolean checkCertificateExists(int userId, String level) {
        String sql = "SELECT id FROM certificates WHERE user_id = ? AND level = ?";
        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, level);
            ResultSet rs = ps.executeQuery();
            return rs.next();
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public void insertCertificate(int userId, String level) {
        String sql = "INSERT INTO certificates (user_id, level) VALUES (?, ?)";

        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setString(2, level);
            ps.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}