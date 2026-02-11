package controller;

import dao.QuestionDAO;
import model.Question;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.*;

@WebServlet("/ResultServlet")
public class ResultServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String level = request.getParameter("level");
        if (level == null || level.isEmpty()) {
            level = "Beginner";
        }

        QuestionDAO dao = new QuestionDAO();
        List<Question> questions = dao.getQuestionsByLevel(level);

        if (questions == null || questions.isEmpty()) {
            request.setAttribute("error", "No questions found for level: " + level);
            request.getRequestDispatcher("quiz.jsp").forward(request, response);
            return;
        }

        int score = 0;
        int total = questions.size();
        Set<String> weakTopics = new HashSet<>();

        for (Question q : questions) {
            String userAnswer = request.getParameter("q" + q.getId());

            if (userAnswer != null && userAnswer.equals(q.getCorrectAnswer())) {
                score++;
            } else {
                weakTopics.add(q.getTopic());
            }
        }
        
        request.setAttribute("score", score);
        request.setAttribute("total", total);
        request.setAttribute("weakTopics", weakTopics);
        request.setAttribute("level", level);
        request.getRequestDispatcher("result.jsp").forward(request, response);
    }
}