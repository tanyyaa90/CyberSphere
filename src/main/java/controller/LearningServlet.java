package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.*;

@WebServlet("/LearningServlet")
public class LearningServlet extends HttpServlet {

    private static final Map<String, List<String>> LEARNING_RESOURCES = createLearningResources();

    private static Map<String, List<String>> createLearningResources() {
        Map<String, List<String>> resources = new LinkedHashMap<>();

        // BEGINNER
        resources.put("Phishing Emails", Arrays.asList(
            "https://youtu.be/n9Lff-cSxLQ?si=297huOc6PCBxCtAf",
            "https://youtu.be/XBkzBrXlle0?si=Q-dFCO6LSitWAxlg",
            "https://www.fortinet.com/content/dam/fortinet/images/cyberglossary/5-red-flags-to-identify-phishing-emails.png",
            "https://consumer.ftc.gov/articles/how-recognize-avoid-phishing-scams"
        ));

        resources.put("OTP Scams", Arrays.asList(
            "https://youtu.be/UX2FC4d7liw?si=9ZjqKxrZ7oqlIKM2",
            "https://www.quickheal.co.in/knowledge-centre/recognize-otp-phishing-calls/",
            "https://youtu.be/tqXtfU3ayvc?si=alV_DjgOsnrg_9Dy",
            "https://www.linkedin.com/posts/tanushree-saxena-3a2572238_otp-scams-understanding-the-threat-and-protecting-activity-7320861896411127812-6bJ9?utm_source=li_share&utm_content=feedcontent&utm_medium=g_dt_web&utm_campaign=copy"
        ));

        resources.put("Safe Browsing", Arrays.asList(
            "https://youtu.be/yv9im3mvpsE?si=lJxBNJ8q2vUpqOcK",
            "https://swisscyberinstitute.com/blog/10-tips-browse-internet-safely/",
            "https://youtu.be/xa7qaSJeyRQ?si=ryMEvWNMOK7yD4dI",
            "https://youtu.be/PZq-04M5I4Y?si=tLUILNK-OLjwuB_b"
        ));

        resources.put("Public WiFi Risks", Arrays.asList(
            "https://youtu.be/XcghUy-8VRA?si=oaTUi_cl2eWxyeAX",
            "https://youtu.be/mqZzXUzxUYM?si=RSqcvXqJZT0-QYnA",
            "https://youtu.be/bdVkkRmJEeM?si=ow7w3aDmV_q8Cf95",
            "https://consumer.ftc.gov/media/79888"
        ));

        // INTERMEDIATE
        resources.put("Software Updates", Arrays.asList(
            "https://youtu.be/a_2MsrIKyF8?si=ZPRQMTfUIiREFqC_",
            "https://www.bu.edu/tech/support/information-security/security-for-everyone/understanding-patches-and-software-updates/",
            "https://youtu.be/o1WsviOK9fE?si=-Zflol-eiGquRrDz",
            "https://youtu.be/xc20JvvTLO4?si=cYXONKn6gSCAbdOP"
        ));

        resources.put("Malware", Arrays.asList(
            "https://youtu.be/NMYbkzjI5EY?si=_IcwbqjtwW9rnl00",
            "https://consumer.ftc.gov/articles/malware-how-protect-against-detect-and-remove-it",
            "https://youtu.be/pbG0JGY2U00?si=BdUHizRRmBBRXnqO",
            "https://youtu.be/mqzP7gJDM2s?si=L25YajdmJ0joDYRV"
        ));

        resources.put("Firewall", Arrays.asList(
            "https://youtu.be/9GZlVOafYTg?si=b1MabJ9gT-hHPrtF",
            "https://www.fortinet.com/resources/cyberglossary/firewall",
            "https://youtu.be/kDEX1HXybrU?si=o3mxQPrtKwdJMnzs",
            "https://www.datto.com/blog/what-is-a-firewall-and-why-is-it-important-in-cyber-security/"
        ));

        resources.put("Locking Devices", Arrays.asList(
            "https://youtu.be/w_EKb2eOgkc?si=zSsF1EyLfBEL0lq6",
            "https://flyconsulting.biz/pass-it-up-the-importance-of-enforcing-passwords-on-all-devices/",
            "https://youtu.be/gye9agE_zig?si=8IrDBqHJeQKLXu1G",
            "https://youtu.be/1jCryK1j5i0?si=KPylnGcuakESZ6Sy"
        ));

        // HARD
        resources.put("VPN", Arrays.asList(
            "https://youtu.be/R-JUOpCgTZc?si=uHKAJPjFsc1mtXys",
            "https://www.fortinet.com/resources/cyberglossary/are-vpns-safe",
            "https://youtu.be/_wQTRMBAvzg?si=ZL0yDUk24jvBJVgQ",
            "https://youtu.be/_-DekqEyAV0?si=l6OsIrhmp08mbUFQ"
        ));

        resources.put("Credential Stuffing", Arrays.asList(
            "https://youtu.be/kVa7exobAFA?si=LnTkd_Ih2xkrr3do",
            "https://www.fortinet.com/resources/cyberglossary/credential-stuffing",
            "https://youtu.be/jhTxbWbC9vA?si=FryF2odmf3fX9Y_c",
            "https://youtu.be/j4RSc5xd5iU?si=zNWsYDIYbOov5nf1"
        ));

        resources.put("Cryptography", Arrays.asList(
            "https://youtu.be/GQvu49c0ZZc?si=z9uI2ZVh5T0tShX9",
            "https://spyboy.blog/2025/01/23/understanding-cryptography-and-wireless-networks/",
            "https://youtu.be/jhXCTbFnK8o?si=fsMVBZPNi806NWwt",
            "https://youtu.be/6_Cxj5WKpIw?si=xIsQHo0Gd-NHWlvb"
        ));

        resources.put("Sandboxing", Arrays.asList(
            "https://youtu.be/kccgRV5uIpI?si=EAvnzfsnObseqhk0",
            "https://www.proofpoint.com/us/threat-reference/sandbox",
            "https://youtu.be/qmN9WvSxJmE?si=No1cbiEybNzTwBu5",
            "https://youtu.be/Eg9982rd-VE?si=LdxHYZQSwQGJ_j-G"
        ));

        return resources;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String[] topics = request.getParameterValues("topic");
        if (topics == null || topics.length == 0) {
            response.sendRedirect("QuizServlet");
            return;
        }

        Map<String, List<String>> topicResources = new LinkedHashMap<>();
        List<String> topicsToLearn = new ArrayList<>();

        for (String topic : topics) {

            if (topic == null) continue;

            String normalized = topic.trim().toLowerCase();

            for (String key : LEARNING_RESOURCES.keySet()) {
                if (key.toLowerCase().equals(normalized)) {
                    topicResources.put(key, LEARNING_RESOURCES.get(key));
                    topicsToLearn.add(key);
                }
            }
        }

        if (topicResources.isEmpty()) {
            response.sendRedirect("QuizServlet");
            return;
        }

        request.setAttribute("topicsToLearn", topicsToLearn);
        request.setAttribute("topicResources", topicResources);

        request.getRequestDispatcher("learning.jsp").forward(request, response);
    }
}
