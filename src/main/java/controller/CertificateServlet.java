package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;
import java.sql.*;
import java.text.SimpleDateFormat;

@WebServlet("/CertificateServlet")
public class CertificateServlet extends HttpServlet {

	private static final String DB_URL = System.getenv("DB_URL");
	private static final String DB_USER = System.getenv("DB_USER");
	private static final String DB_PASS = System.getenv("DB_PASS");

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Integer userId = (Integer) session.getAttribute("userId");

        if (userId == null) { response.sendRedirect("login.jsp"); return; }

        String level = request.getParameter("level");
        if (level == null || level.isEmpty()) { response.sendRedirect("select_level.jsp"); return; }

        boolean hasCompleted = checkLevelCompletion(userId, level);
        if (!hasCompleted) {
            response.sendRedirect("select_sublevel.jsp?level=" + level
                + "&error=Complete+all+5+sublevels+with+35%25+score+first");
            return;
        }

        String firstName = "", lastName = "", earnedDate = "";
        int    totalScore = 0, totalQuestions = 0;
        double avgPercentage = 0;

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);

            // ── User name ──────────────────────────────────────
            ps = conn.prepareStatement(
                "SELECT first_name, last_name FROM users WHERE id = ?");
            ps.setInt(1, userId);
            rs = ps.executeQuery();
            if (rs.next()) {
                firstName = rs.getString("first_name") != null ? rs.getString("first_name") : "";
                lastName  = rs.getString("last_name")  != null ? rs.getString("last_name")  : "";
            }
            rs.close(); ps.close();

            // ── Best score per sublevel (MySQL 5.x compatible) ─
            // For each sublevel, pick the single attempt with the
            // highest percentage, then aggregate across all 5.
            // Avoids ROW_NUMBER() which requires MySQL 8+.
            String scoreSql =
                "SELECT SUM(a.score)           AS total_score, " +
                "       SUM(a.total_questions)  AS total_q, " +
                "       AVG(a.percentage)        AS avg_pct " +
                "FROM quiz_attempts a " +
                "INNER JOIN ( " +
                "    SELECT sub_level, MAX(percentage) AS max_pct " +
                "    FROM quiz_attempts " +
                "    WHERE user_id = ? AND level = ? " +
                "    GROUP BY sub_level " +
                ") best " +
                "ON  a.sub_level  = best.sub_level " +
                "AND a.percentage = best.max_pct " +
                "AND a.user_id    = ? " +
                "AND a.level      = ? " +
                "GROUP BY a.user_id";   // collapse to one row

            ps = conn.prepareStatement(scoreSql);
            ps.setInt(1, userId);
            ps.setString(2, level);
            ps.setInt(3, userId);
            ps.setString(4, level);
            rs = ps.executeQuery();
            if (rs.next()) {
                totalScore     = rs.getInt("total_score");
                totalQuestions = rs.getInt("total_q");
                avgPercentage  = rs.getDouble("avg_pct");
            }
            rs.close(); ps.close();

            // ── If still 0 (edge case: no GROUP BY row returned)
            // fall back: just sum ALL best attempts manually ──
            if (totalQuestions == 0) {
                String fallbackSql =
                    "SELECT sub_level, " +
                    "       MAX(percentage)      AS best_pct, " +
                    "       MAX(score)            AS best_score, " +
                    "       MAX(total_questions)  AS tq " +
                    "FROM quiz_attempts " +
                    "WHERE user_id = ? AND level = ? " +
                    "GROUP BY sub_level";
                ps = conn.prepareStatement(fallbackSql);
                ps.setInt(1, userId);
                ps.setString(2, level);
                rs = ps.executeQuery();
                double pctSum = 0; int subCount = 0;
                while (rs.next()) {
                    totalScore     += rs.getInt("best_score");
                    totalQuestions += rs.getInt("tq");
                    pctSum         += rs.getDouble("best_pct");
                    subCount++;
                }
                avgPercentage = subCount > 0 ? pctSum / subCount : 0;
                rs.close(); ps.close();
            }

            // ── Certificate issued date ────────────────────────
            ps = conn.prepareStatement(
                "SELECT earned_at FROM certificates WHERE user_id = ? AND level = ?");
            ps.setInt(1, userId);
            ps.setString(2, level);
            rs = ps.executeQuery();
            if (rs.next()) {
                earnedDate = new SimpleDateFormat("MMMM dd, yyyy")
                    .format(rs.getTimestamp("earned_at"));
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (rs   != null) try { rs.close();   } catch (Exception ignored) {}
            if (ps   != null) try { ps.close();   } catch (Exception ignored) {}
            if (conn != null) try { conn.close(); } catch (Exception ignored) {}
        }

        // ── Grade from average of best scores per sublevel ─────
        int overallPct = (int) Math.round(avgPercentage);
        String grade, gradeLabel;
        if      (overallPct >= 90) { grade = "A"; gradeLabel = "Excellent";    }
        else if (overallPct >= 80) { grade = "B"; gradeLabel = "Very Good";    }
        else if (overallPct >= 70) { grade = "C"; gradeLabel = "Good";         }
        else if (overallPct >= 60) { grade = "D"; gradeLabel = "Satisfactory"; }
        else                       { grade = "E"; gradeLabel = "Pass";         }

        String fullName     = (firstName + " " + lastName).trim();
        String levelDisplay = level.substring(0, 1).toUpperCase() + level.substring(1);
        String ctxPath      = request.getContextPath();

        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();

        out.println("<!DOCTYPE html><html><head><meta charset='UTF-8'>");
        out.println("<title>Certificate – " + levelDisplay + " | CyberSphere</title>");
        out.println("<link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css'>");
        out.println("<script src='https://cdnjs.cloudflare.com/ajax/libs/html2canvas/1.4.1/html2canvas.min.js'></script>");
        out.println("<script src='https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js'></script>");
        out.println("<style>");
        out.println("*,*::before,*::after{margin:0;padding:0;box-sizing:border-box;}");
        out.println("body{background:#0a0c10;font-family:'Georgia',serif;min-height:100vh;display:flex;flex-direction:column;align-items:center;justify-content:center;padding:30px 20px;gap:24px;}");
        out.println("#cert-wrap{width:1050px;height:680px;background:linear-gradient(160deg,#fffdf5 0%,#fff8e7 60%,#fef3d0 100%);border-radius:18px;box-shadow:0 30px 80px rgba(0,0,0,0.6);position:relative;overflow:hidden;display:flex;flex-direction:column;}");
        out.println(".left-stripe,.right-stripe{position:absolute;top:0;width:8px;height:100%;background:linear-gradient(180deg,#c9a227 0%,#f0d060 50%,#c9a227 100%);}");
        out.println(".left-stripe{left:0;}.right-stripe{right:0;}");
        out.println(".cert-outer{position:absolute;inset:14px;border:2.5px solid #c9a227;border-radius:10px;pointer-events:none;}");
        out.println(".cert-inner{position:absolute;inset:22px;border:1px solid #e5c96a;border-radius:6px;pointer-events:none;}");
        out.println(".corner{position:absolute;font-size:28px;color:#c9a227;line-height:1;}");
        out.println(".corner.tl{top:20px;left:20px;}.corner.tr{top:20px;right:20px;}.corner.bl{bottom:20px;left:20px;}.corner.br{bottom:20px;right:20px;}");
        out.println(".cert-header{display:flex;flex-direction:column;align-items:center;justify-content:center;padding:28px 60px 16px;gap:6px;border-bottom:1.5px solid #d4b84a;}");
        out.println(".logo-wrap{display:flex;align-items:center;gap:10px;}");
        out.println(".logo-wrap img{height:48px;width:auto;}");
        out.println(".logo-wrap .logo-fallback{font-size:34px;color:#3a5c42;display:none;}");
        out.println(".cert-title-text{font-size:13px;letter-spacing:4px;text-transform:uppercase;color:#7a6520;font-family:'Georgia',serif;}");
        out.println(".cert-body{flex:1;display:grid;grid-template-columns:220px 1px 1fr;gap:0 32px;padding:22px 32px 18px;align-items:center;}");
        out.println(".divider{width:1px;height:85%;background:linear-gradient(180deg,transparent,#c9a227 15%,#c9a227 85%,transparent);align-self:center;}");
        out.println(".left-panel{display:flex;flex-direction:column;align-items:center;justify-content:center;gap:14px;text-align:center;}");
        out.println(".seal{width:100px;height:100px;border-radius:50%;border:3px solid #c9a227;background:radial-gradient(circle,#fffbe8,#f5e6a0);display:flex;flex-direction:column;align-items:center;justify-content:center;gap:3px;box-shadow:0 0 0 5px #fff8e0,0 0 0 7px #c9a227;}");
        out.println(".seal i{font-size:30px;color:#c9a227;}.seal span{font-size:8px;color:#7a6520;letter-spacing:1px;text-transform:uppercase;text-align:center;line-height:1.4;}");
        out.println(".sig-block{text-align:center;}.sig-line{width:130px;height:1px;background:#2c3e2f;margin:0 auto 5px;}.sig-label{font-size:9px;color:#6b7a6e;letter-spacing:2px;text-transform:uppercase;}");
        out.println(".right-panel{display:flex;flex-direction:column;justify-content:center;gap:8px;padding-right:12px;}");
        out.println(".presented-to{font-size:11px;color:#7a6520;letter-spacing:2px;text-transform:uppercase;}");
        out.println(".recipient{font-family:'Georgia',serif;font-size:44px;font-weight:700;color:#1e2d21;line-height:1.1;border-bottom:2px solid #c9a227;padding-bottom:8px;margin-bottom:2px;}");
        out.println(".for-completing{font-size:12px;color:#5a6e5d;}");
        out.println(".level-name{font-size:24px;font-weight:700;color:#2c3e2f;letter-spacing:0.5px;}");
        out.println(".quiz-body{font-size:13px;color:#5a6e5d;line-height:1.6;}");
        out.println(".grade-pill{display:inline-flex;align-items:center;gap:10px;background:#2c3e2f;color:#f5e6a0;padding:6px 20px;border-radius:30px;font-size:14px;font-family:'Georgia',serif;margin-top:4px;width:fit-content;}");
        out.println(".grade-pill .g-letter{font-size:24px;font-weight:700;color:#f0d060;}.grade-pill .g-sep{color:#c9a227;margin:0 4px;}");
        out.println(".meta-row{display:flex;gap:24px;align-items:center;font-size:11px;color:#6b7a6e;border-top:1px solid #e0c96a;padding-top:8px;margin-top:4px;}");
        out.println(".meta-row i{color:#c9a227;margin-right:4px;}");
        out.println(".btn-row{display:flex;gap:12px;justify-content:center;flex-wrap:wrap;}");
        out.println(".btn{padding:12px 26px;border-radius:10px;font-size:14px;font-family:'Inter',sans-serif;font-weight:600;cursor:pointer;border:none;display:inline-flex;align-items:center;gap:8px;text-decoration:none;transition:all 0.2s;}");
        out.println(".btn-print{background:#2c3e2f;color:#fff;}.btn-print:hover{background:#1e2d21;transform:translateY(-2px);}");
        out.println(".btn-download{background:#c9a227;color:#1e2d21;}.btn-download:hover{background:#b08c1a;transform:translateY(-2px);}");
        out.println(".btn-back{background:#1a1e24;color:#9ca3af;border:1px solid #2a2f3a;}.btn-back:hover{background:#22272e;color:#fff;transform:translateY(-2px);}");
        out.println("@media print{body{background:#fff;padding:0;justify-content:flex-start;}.btn-row{display:none;}#cert-wrap{box-shadow:none;border-radius:0;width:100%;height:auto;}}");
        out.println("</style></head><body>");

        out.println("<div id='cert-wrap'>");
        out.println("  <div class='left-stripe'></div><div class='right-stripe'></div>");
        out.println("  <div class='cert-outer'></div><div class='cert-inner'></div>");
        out.println("  <div class='corner tl'>✦</div><div class='corner tr'>✦</div>");
        out.println("  <div class='corner bl'>✦</div><div class='corner br'>✦</div>");

        // TOP HEADER
        out.println("  <div class='cert-header'>");
        out.println("    <div class='logo-wrap'>");
        out.println("      <img src='" + ctxPath + "/images/logo.svg' alt='CyberSphere'");
        out.println("           onerror=\"this.style.display='none';document.getElementById('lf').style.display='inline'\">");
        out.println("      <span id='lf' class='logo-fallback'>🛡️ CyberSphere</span>");
        out.println("    </div>");
        out.println("    <div class='cert-title-text'>Certificate of Achievement</div>");
        out.println("  </div>");

        // BODY
        out.println("  <div class='cert-body'>");
        out.println("    <div class='left-panel'>");
        out.println("      <div class='seal'><i class='fas fa-shield-halved'></i><span>Certified<br>Achievement</span></div>");
        out.println("      <div class='sig-block'><div class='sig-line'></div><div class='sig-label'>CyberSphere Authority</div></div>");
        out.println("    </div>");
        out.println("    <div class='divider'></div>");
        out.println("    <div class='right-panel'>");
        out.println("      <div class='presented-to'>This certificate is proudly presented to</div>");
        out.println("      <div class='recipient'>" + fullName + "</div>");
        out.println("      <div class='for-completing'>for successfully completing the</div>");
        out.println("      <div class='level-name'>" + levelDisplay + " Level</div>");
        out.println("      <div class='quiz-body'>Cybersecurity Awareness Quiz with a grade of <strong style='color:#2c3e2f'>" + grade + " &mdash; " + gradeLabel + "</strong>, demonstrating proficiency in identifying and preventing cyber threats.</div>");
        out.println("      <div class='grade-pill'>");
        out.println("        <span class='g-letter'>" + grade + "</span>");
        out.println("        <span>" + gradeLabel + "</span>");
        out.println("        <span class='g-sep'>|</span>");
        out.println("        <span>" + overallPct + "%</span>");
        out.println("      </div>");
        out.println("      <div class='meta-row'>");
        out.println("        <span><i class='fas fa-medal'></i>Grade: " + grade + " &mdash; " + gradeLabel + "</span>");
        out.println("        <span><i class='fas fa-calendar-alt'></i>Issued: " + earnedDate + "</span>");
        out.println("      </div>");
        out.println("    </div>");
        out.println("  </div>");
        out.println("</div>");

        out.println("<div class='btn-row'>");
        out.println("  <button class='btn btn-print' onclick='window.print()'><i class='fas fa-print'></i> Print Certificate</button>");
        out.println("  <button class='btn btn-download' onclick='downloadPDF()'><i class='fas fa-download'></i> Download PDF</button>");
        out.println("  <a href='select_level.jsp' class='btn btn-back'><i class='fas fa-arrow-left'></i> Back to Levels</a>");
        out.println("</div>");

        out.println("<script>");
        out.println("async function downloadPDF(){");
        out.println("  const btn=document.querySelector('.btn-download');");
        out.println("  btn.innerHTML=\"<i class='fas fa-spinner fa-spin'></i> Generating...\";btn.disabled=true;");
        out.println("  try{");
        out.println("    const canvas=await html2canvas(document.getElementById('cert-wrap'),{scale:2,useCORS:true,backgroundColor:'#fff8e7'});");
        out.println("    const {jsPDF}=window.jspdf;");
        out.println("    const pdf=new jsPDF({orientation:'landscape',unit:'mm',format:'a4'});");
        out.println("    pdf.addImage(canvas.toDataURL('image/jpeg',0.95),'JPEG',0,0,pdf.internal.pageSize.getWidth(),pdf.internal.pageSize.getHeight());");
        out.println("    pdf.save('CyberSphere_Certificate_" + levelDisplay + ".pdf');");
        out.println("  }catch(e){alert('Download failed. Please use Print instead.');}");
        out.println("  finally{btn.innerHTML=\"<i class='fas fa-download'></i> Download PDF\";btn.disabled=false;}");
        out.println("}");
        out.println("</script>");
        out.println("</body></html>");
    }

    private boolean checkLevelCompletion(int userId, String level) {
        Connection conn=null; PreparedStatement ps=null; ResultSet rs=null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn=DriverManager.getConnection(DB_URL,DB_USER,DB_PASS);
            ps=conn.prepareStatement(
                "SELECT COUNT(DISTINCT sub_level) AS c FROM quiz_attempts " +
                "WHERE user_id=? AND level=? AND percentage>=35");
            ps.setInt(1,userId); ps.setString(2,level);
            rs=ps.executeQuery();
            if(rs.next()) return rs.getInt("c")==5;
        } catch(Exception e){e.printStackTrace();}
        finally{
            if(rs!=null)try{rs.close();}catch(Exception ignored){}
            if(ps!=null)try{ps.close();}catch(Exception ignored){}
            if(conn!=null)try{conn.close();}catch(Exception ignored){}
        }
        return false;
    }
}