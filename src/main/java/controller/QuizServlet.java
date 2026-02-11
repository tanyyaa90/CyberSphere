package controller;

import dao.QuestionDAO;
import model.Question;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet("/QuizServlet")
public class QuizServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String level = request.getParameter("level");
        QuestionDAO dao = new QuestionDAO();
        List<Question> questions;
        
        if (level != null && !level.isEmpty()) {
            questions = dao.getQuestionsByLevel(level);
        } else {
            questions = dao.getAllQuestions();
        }
        
        request.setAttribute("questions", questions);
        request.setAttribute("level", level != null ? level : "Beginner");
        request.getRequestDispatcher("quiz.jsp").forward(request, response);
    }
}