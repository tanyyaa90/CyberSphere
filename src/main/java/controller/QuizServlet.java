package controller;

import dao.QuestionDAO;
import model.Question;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.*;

@WebServlet("/QuizServlet")
public class QuizServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();

        String level    = request.getParameter("level");
        String sublevel = request.getParameter("sublevel");

        if (level == null || level.isEmpty()) {
            response.sendRedirect("select_level.jsp");
            return;
        }
        if (sublevel == null || sublevel.isEmpty()) sublevel = "Level_1";
        if (!sublevel.startsWith("Level_")) sublevel = "Level_" + sublevel;

        session.removeAttribute("quizCompleted");
        session.removeAttribute("lastQuizPercentage");
        session.removeAttribute("canProceedToNextLevel");
        session.removeAttribute("lastCompletedLevel");
        session.removeAttribute("lastCompletedSublevel");

        session.setAttribute("quizLevel",    level);
        session.setAttribute("quizSublevel", sublevel);

        QuestionDAO dao = new QuestionDAO();
        List<Question> questions = dao.getQuestionsByLevelAndSublevel(level, sublevel);

        if (questions == null || questions.isEmpty()) {
            response.sendRedirect("select_sublevel.jsp?error=No+questions+found");
            return;
        }

        request.setAttribute("questions", questions);
        request.setAttribute("level",     level);
        request.setAttribute("sublevel",  sublevel);
        request.getRequestDispatcher("quiz.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();

        Integer userId = (Integer) session.getAttribute("userId");
        if (userId == null) { response.sendRedirect("login.jsp"); return; }

        String level    = (String) session.getAttribute("quizLevel");
        String sublevel = (String) session.getAttribute("quizSublevel");
        if (level == null || sublevel == null) { response.sendRedirect("select_level.jsp"); return; }

        String sublevelNum = sublevel.startsWith("Level_") ? sublevel.substring(6) : sublevel;

        QuestionDAO dao = new QuestionDAO();
        List<Question> questions = dao.getQuestionsByLevelAndSublevel(level, sublevel);
        if (questions == null || questions.isEmpty()) {
            response.sendRedirect("select_sublevel.jsp?error=Session+expired");
            return;
        }

        // ── Score ──────────────────────────────────────────────────
        int score = 0;
        Set<String> weakTopics = new LinkedHashSet<>();
        for (Question q : questions) {
            String userAnswer    = request.getParameter("answer_" + q.getId());
            String correctAnswer = q.getCorrectAnswer();
            if (userAnswer != null && userAnswer.trim().equalsIgnoreCase(
                    correctAnswer != null ? correctAnswer.trim() : "")) {
                score++;
            } else {
                if (q.getTopic() != null && !q.getTopic().isEmpty()) weakTopics.add(q.getTopic());
            }
        }

        int     total      = questions.size();
        int     percentage = (total > 0) ? (score * 100) / total : 0;
        boolean canProceed = (percentage >= 35);

        // ── Save attempt ───────────────────────────────────────────
        dao.saveQuizAttempt(userId, level, sublevelNum, score, total, percentage);

        // ── Session state ──────────────────────────────────────────
        session.setAttribute("quizCompleted",         canProceed);
        session.setAttribute("lastQuizPercentage",    percentage);
        session.setAttribute("canProceedToNextLevel", canProceed);
        session.setAttribute("lastCompletedLevel",    level);
        session.setAttribute("lastCompletedSublevel", sublevelNum);

        Map<String, Object> lastResult = new HashMap<>();
        lastResult.put("score", score); lastResult.put("total", total);
        lastResult.put("percentage", percentage); lastResult.put("canProceed", canProceed);
        lastResult.put("weakTopics", weakTopics); lastResult.put("level", level);
        lastResult.put("sublevel", sublevelNum);
        session.setAttribute("lastQuizResult", lastResult);

        // ── FIX: Certificate insert BEFORE forward() ───────────────
        if (percentage >= 35 && "5".equals(sublevelNum)) {
            System.out.println("Reached certificate logic");

            if (!dao.checkCertificateExists(userId, level)) {
                dao.insertCertificate(userId, level);
                System.out.println("Certificate inserted!");
            } else {
                System.out.println("Certificate already exists");
            }
        }

        // ── Forward to result ──────────────────────────────────────
        request.setAttribute("score",      score);
        request.setAttribute("total",      total);
        request.setAttribute("percentage", percentage);
        request.setAttribute("canProceed", canProceed);
        request.setAttribute("weakTopics", weakTopics);
        request.setAttribute("level",      level);
        request.setAttribute("sublevel",   sublevelNum);
        request.getRequestDispatcher("result.jsp").forward(request, response);
    }
}