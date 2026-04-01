<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Question" %>
<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    List<Question> questions = (List<Question>) request.getAttribute("questions");
    if (questions == null || questions.isEmpty()) {
        response.sendRedirect("select_level.jsp");
        return;
    }

    String level    = (String) request.getAttribute("level");
    String sublevel = (String) request.getAttribute("sublevel");
    if (level    == null) level    = "Beginner";
    if (sublevel == null) sublevel = "1";

    int total = questions.size();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quiz | CyberSphere</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        *, *::before, *::after { margin:0; padding:0; box-sizing:border-box; }

        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            background: #0a0c10;
            min-height: 100vh;
            color: #e5e7eb;
            position: relative;
            overflow-x: hidden;
        }

        body::before {
            content: '';
            position: fixed; inset: 0;
            background-image: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="%2344634d" stroke-width="1" opacity="0.04"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/><circle cx="12" cy="12" r="3"/></svg>');
            background-size: 60px 60px;
            pointer-events: none;
            z-index: 0;
        }

        .page {
            max-width: 780px;
            margin: 36px auto;
            padding: 0 20px 60px;
            position: relative;
            z-index: 1;
        }

        .topbar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 28px;
            gap: 16px;
        }

        .back-link {
            display: inline-flex;
            align-items: center;
            gap: 7px;
            color: #6b7280;
            text-decoration: none;
            font-size: 14px;
            transition: color .2s;
            flex-shrink: 0;
        }
        .back-link:hover { color: #e5e7eb; }

        .level-pill {
            background: #162119;
            color: #86efac;
            border: 1px solid #1e4a28;
            padding: 6px 16px;
            border-radius: 20px;
            font-size: 13px;
            font-weight: 500;
            text-transform: capitalize;
            flex-shrink: 0;
        }

        /* ── STEP DOTS ── */
        .steps {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 0;
            margin-bottom: 32px;
        }

        .step-dot {
            width: 32px; height: 32px;
            border-radius: 50%;
            background: #13171d;
            border: 2px solid #1e2228;
            display: flex; align-items: center; justify-content: center;
            font-size: 12px; font-weight: 600;
            color: #4b5563;
            transition: all .35s cubic-bezier(.34,1.56,.64,1);
            position: relative; z-index: 1;
            flex-shrink: 0;
        }
        .step-dot.done   { background: #162119; border-color: #44634d; color: #86efac; }
        .step-dot.active {
            background: #44634d; border-color: #44634d; color: #fff;
            box-shadow: 0 0 0 4px rgba(68,99,77,.25), 0 0 14px rgba(68,99,77,.35);
            transform: scale(1.1);
        }
        .step-dot.wrong  { background: #2a0f0f; border-color: #7f1d1d; color: #f87171; }

        .step-line {
            flex: 1;
            height: 2px;
            background: #1e2228;
            transition: background .45s ease;
            max-width: 48px;
        }
        .step-line.done { background: #44634d; }

        /* ── CARD ── */
        .q-card {
            background: #0f1115;
            border: 1px solid #1e2228;
            border-radius: 20px;
            overflow: hidden;
            box-shadow: 0 20px 50px rgba(0,0,0,.5);
        }

        .q-header {
            background: #13171d;
            border-bottom: 1px solid #1e2228;
            padding: 18px 28px;
            display: flex;
            align-items: center;
            gap: 16px;
        }

        .q-counter { display: flex; align-items: baseline; gap: 4px; }
        .q-num   {
            font-size: 28px; font-weight: 700; color: #fff; line-height: 1;
            transition: transform .3s cubic-bezier(.34,1.56,.64,1);
            display: inline-block;
        }
        .q-total { font-size: 14px; color: #4b5563; }

        .q-divider { width: 1px; height: 36px; background: #1e2228; }

        .q-prog-wrap  { flex: 1; }
        .q-prog-label { font-size: 11px; color: #6b7280; text-transform: uppercase;
                        letter-spacing: .06em; margin-bottom: 6px; }
        .q-prog-bg    { height: 5px; background: #1e2228; border-radius: 10px; overflow: hidden; }
        .q-prog-fill  {
            height: 100%;
            background: linear-gradient(90deg,#44634d,#5a8066);
            border-radius: 10px;
            transition: width .5s cubic-bezier(.4,0,.2,1);
            box-shadow: 0 0 8px rgba(68,99,77,.45);
        }

        .q-body { padding: 32px 28px; }

        /* ── QUESTION TRANSITIONS ── */
        .question        { display: none; }
        .question.active { display: block; animation: slideIn .32s cubic-bezier(.4,0,.2,1); }
        .question.exiting{ animation: slideOut .22s cubic-bezier(.4,0,.2,1) forwards; }

        @keyframes slideIn {
            from { opacity:0; transform:translateX(26px); }
            to   { opacity:1; transform:translateX(0); }
        }
        @keyframes slideOut {
            from { opacity:1; transform:translateX(0); }
            to   { opacity:0; transform:translateX(-26px); }
        }

        .q-text {
            font-size: 19px; font-weight: 500; color: #fff;
            line-height: 1.6; margin-bottom: 28px;
        }

        .options { display: flex; flex-direction: column; gap: 10px; }

        /* ── OPTION ── */
        .option {
            display: flex; align-items: center; gap: 14px;
            padding: 14px 18px;
            background: #13171d;
            border: 1px solid #1e2228;
            border-radius: 12px;
            cursor: pointer; color: #9ca3af;
            transition: all .2s cubic-bezier(.4,0,.2,1);
            user-select: none;
            position: relative; overflow: hidden;
        }

        /* Mouse-tracking ripple */
        .option .ripple-layer {
            position: absolute; inset: 0;
            background: radial-gradient(circle at var(--rx,50%) var(--ry,50%),
                rgba(68,99,77,.16) 0%, transparent 65%);
            opacity: 0;
            transition: opacity .35s;
            pointer-events: none;
        }
        .option:hover:not(.locked) .ripple-layer { opacity: 1; }

        .option:hover:not(.locked):not(.opt-correct):not(.opt-wrong):not(.opt-highlight) {
            border-color: #44634d;
            background: #162119;
            color: #e5e7eb;
            transform: translateX(4px);
        }

        .opt-letter {
            width: 32px; height: 32px; border-radius: 8px;
            background: #1e2228; border: 1px solid #2a2f3a;
            display: flex; align-items: center; justify-content: center;
            font-size: 13px; font-weight: 700; color: #6b7280;
            flex-shrink: 0; transition: all .2s;
        }
        .opt-text { font-size: 15px; line-height: 1.45; flex: 1; }
        .opt-icon {
            font-size: 16px; margin-left: auto; opacity: 0;
            transition: opacity .2s, transform .35s cubic-bezier(.34,1.56,.64,1);
            transform: scale(0);
        }

        /* ── CORRECT ── */
        .opt-correct {
            background:#0d1f12 !important; border-color:#44634d !important; color:#86efac !important;
            animation: correctPop .38s cubic-bezier(.34,1.56,.64,1);
        }
        @keyframes correctPop {
            0%  { transform: scale(.97); }
            55% { transform: scale(1.025); }
            100%{ transform: scale(1); }
        }
        .opt-correct .opt-letter { background:#44634d !important; border-color:#44634d !important; color:#fff !important; }
        .opt-correct .opt-icon   { opacity:1; color:#86efac; transform: scale(1); }

        /* ── WRONG ── */
        .opt-wrong {
            background:#1f0c0c !important; border-color:#ef4444 !important; color:#f87171 !important;
            animation: wrongShake .38s ease;
        }
        @keyframes wrongShake {
            0%,100%{ transform:translateX(0); }
            20%    { transform:translateX(-7px); }
            40%    { transform:translateX(7px); }
            60%    { transform:translateX(-4px); }
            80%    { transform:translateX(4px); }
        }
        .opt-wrong .opt-letter { background:#ef4444 !important; border-color:#ef4444 !important; color:#fff !important; }
        .opt-wrong .opt-icon   { opacity:1; color:#f87171; transform:scale(1); }

        /* ── HIGHLIGHT ── */
        .opt-highlight {
            background:#0d1f12 !important; border-color:#44634d !important; color:#86efac !important;
            animation: highlightPulse 1.2s ease infinite alternate;
        }
        @keyframes highlightPulse {
            from { box-shadow: 0 0 0 0 rgba(68,99,77,.08); }
            to   { box-shadow: 0 0 0 5px rgba(68,99,77,.18); }
        }
        .opt-highlight .opt-letter { background:#44634d !important; border-color:#44634d !important; color:#fff !important; }
        .opt-highlight .opt-icon   { opacity:1; color:#86efac; transform:scale(1); }

        /* ── EXPLANATION ── */
        .explanation {
            display: none; margin-top: 20px;
            background: #13171d; border: 1px solid #1e4a28;
            border-left: 4px solid #44634d; border-radius: 12px;
            padding: 16px 18px; animation: fadeSlide .3s ease;
        }
        @keyframes fadeSlide {
            from { opacity:0; transform:translateY(-8px); }
            to   { opacity:1; transform:translateY(0); }
        }
        .expl-head {
            display: flex; align-items: center; gap: 8px;
            font-size: 12px; font-weight: 600;
            text-transform: uppercase; letter-spacing: .06em;
            color: #44634d; margin-bottom: 8px;
        }
        .expl-text { font-size: 14px; color: #9ca3af; line-height: 1.65; }

        /* ── FOOTER ── */
        .q-footer {
            padding: 20px 28px; border-top: 1px solid #1e2228;
            display: flex; justify-content: space-between;
            align-items: center; background: #0d1014;
        }

        .btn {
            display: inline-flex; align-items: center; gap: 8px;
            padding: 12px 24px; border-radius: 10px;
            font-size: 14px; font-weight: 500;
            cursor: pointer; border: none;
            transition: all .2s cubic-bezier(.4,0,.2,1);
        }
        .btn-next { background:#44634d; color:#fff; }
        .btn-next:hover:not(:disabled) {
            background:#365340;
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(68,99,77,.3);
        }
        .btn-next:active:not(:disabled) { transform: translateY(0); }
        .btn-next:disabled { background:#1e2228; color:#4b5563; cursor:not-allowed; }

        .btn-submit { background:#1a4a2a; color:#86efac; border:1px solid #2a6a3a; }
        .btn-submit:hover:not(:disabled) {
            background:#44634d; color:#fff; border-color:#44634d;
            transform: translateY(-2px);
            box-shadow: 0 8px 24px rgba(68,99,77,.4);
        }
        .btn-submit:active:not(:disabled) { transform: translateY(0); }
        .btn-submit:disabled { background:#1e2228; color:#4b5563; border-color:#1e2228; cursor:not-allowed; }

        /* ── ANSWERED DOTS ── */
        .answered-badge {
            font-size: 12px; color: #6b7280;
            display: flex; align-items: center; gap: 6px;
        }
        .answered-badge .dot {
            width: 6px; height: 6px; border-radius: 50%;
            background: #2a2f3a;
            transition: all .4s cubic-bezier(.34,1.56,.64,1);
        }
        .answered-badge .dot.filled       { background: #44634d; box-shadow: 0 0 5px rgba(68,99,77,.5); }
        .answered-badge .dot.filled-wrong { background: #ef4444; box-shadow: 0 0 5px rgba(239,68,68,.4); }

        /* ── STREAK TOAST ── */
        .streak-toast {
            position: fixed; bottom: 28px; left: 50%;
            transform: translateX(-50%) translateY(70px);
            background: #162119;
            border: 1px solid #44634d;
            border-radius: 40px;
            padding: 10px 22px;
            font-size: 14px; font-weight: 600; color: #86efac;
            display: flex; align-items: center; gap: 8px;
            transition: transform .4s cubic-bezier(.34,1.56,.64,1), opacity .3s;
            opacity: 0; z-index: 100; pointer-events: none;
            box-shadow: 0 8px 28px rgba(68,99,77,.25);
        }
        .streak-toast.show {
            transform: translateX(-50%) translateY(0);
            opacity: 1;
        }

        /* ── CONFETTI ── */
        #confettiCanvas {
            position: fixed; inset: 0;
            pointer-events: none; z-index: 200;
        }

        @media (max-width:600px) {
            .page { padding:0 12px 40px; }
            .q-header { padding:14px 18px; }
            .q-body   { padding:22px 18px; }
            .q-footer { padding:16px 18px; }
            .q-text   { font-size:16px; }
            .topbar   { flex-wrap:wrap; }
            .step-dot { width:26px; height:26px; font-size:10px; }
        }

        /* ── EXIT CONFIRM MODAL ── */
        .modal-backdrop {
            position: fixed; inset: 0;
            background: rgba(0,0,0,.65);
            backdrop-filter: blur(4px);
            z-index: 500;
            display: none; align-items: center; justify-content: center;
        }
        .modal-backdrop.show { display: flex; animation: backdropIn .2s ease; }
        @keyframes backdropIn {
            from { opacity:0; } to { opacity:1; }
        }
        .modal {
            background: #13171d;
            border: 1px solid #1e2228;
            border-radius: 18px;
            padding: 32px 28px;
            max-width: 380px; width: 90%;
            text-align: center;
            animation: modalIn .28s cubic-bezier(.34,1.56,.64,1);
            box-shadow: 0 24px 60px rgba(0,0,0,.6);
        }
        @keyframes modalIn {
            from { opacity:0; transform:scale(.9) translateY(12px); }
            to   { opacity:1; transform:scale(1)  translateY(0); }
        }
        .modal-icon {
            width: 52px; height: 52px; border-radius: 50%;
            background: #1f1208;
            border: 1px solid #7c3a10;
            display: flex; align-items: center; justify-content: center;
            margin: 0 auto 18px;
            font-size: 22px; color: #fb923c;
        }
        .modal-title {
            font-size: 17px; font-weight: 600; color: #fff;
            margin-bottom: 8px;
        }
        .modal-body {
            font-size: 14px; color: #6b7280;
            line-height: 1.6; margin-bottom: 24px;
        }
        .modal-actions { display: flex; gap: 10px; justify-content: center; }
        .modal-btn {
            padding: 10px 22px; border-radius: 10px;
            font-size: 14px; font-weight: 500;
            cursor: pointer; border: none;
            transition: all .2s;
        }
        .modal-btn-cancel {
            background: #1e2228; color: #9ca3af;
            border: 1px solid #2a2f3a;
        }
        .modal-btn-cancel:hover { background: #2a2f3a; color: #e5e7eb; }
        .modal-btn-exit {
            background: #7c1d1d; color: #fca5a5;
            border: 1px solid #991b1b;
        }
        .modal-btn-exit:hover { background: #991b1b; color: #fff; }
    </style>
</head>
<body>

<canvas id="confettiCanvas"></canvas>

<!-- Exit confirmation modal -->
<div class="modal-backdrop" id="exitModal">
    <div class="modal">
        <div class="modal-icon"><i class="fas fa-triangle-exclamation"></i></div>
        <div class="modal-title">Leave the quiz?</div>
        <div class="modal-body">Your progress will be lost and the quiz will restart from the beginning next time.</div>
        <div class="modal-actions">
            <button class="modal-btn modal-btn-cancel" id="modalStay">Stay</button>
            <button class="modal-btn modal-btn-exit"   id="modalLeave">Yes, Exit</button>
        </div>
    </div>
</div>

<div class="streak-toast" id="streakToast">
    <i class="fas fa-fire" style="color:#f97316"></i>
    <span id="streakText">2 in a row!</span>
</div>

<div class="page">

    <div class="topbar">
        <a href="select_sublevel.jsp?level=<%= level %>" class="back-link">
            <i class="fas fa-arrow-left"></i> Back
        </a>
        <span class="level-pill">
            <i class="fas fa-tag" style="margin-right:5px;font-size:11px"></i><%= level %>
        </span>
    </div>

    <!-- Step dots — identical structure to original -->
    <div class="steps" id="stepDots">
        <% for(int i = 0; i < total; i++) { %>
            <div class="step-dot <%= i==0 ? "active" : "" %>" id="dot<%= i %>"><%= i+1 %></div>
            <% if(i < total-1) { %>
                <div class="step-line" id="line<%= i %>"></div>
            <% } %>
        <% } %>
    </div>

    <form action="QuizServlet" method="post" id="quizForm">
    <div class="q-card">

        <div class="q-header">
            <div class="q-counter">
                <span class="q-num" id="qNum">1</span>
                <span class="q-total">/ <%= total %></span>
            </div>
            <div class="q-divider"></div>
            <div class="q-prog-wrap">
                <div class="q-prog-label">Progress</div>
                <div class="q-prog-bg">
                    <div class="q-prog-fill" id="progFill" style="width:<%= (100/total) %>%"></div>
                </div>
            </div>
        </div>

        <div class="q-body">
        <% for(int i = 0; i < total; i++) {
               Question q = questions.get(i);
        %>
        <div class="question <%= i==0 ? "active" : "" %>"
             data-index="<%= i %>"
             data-correct="<%= q.getCorrectAnswer() %>"
             data-explanation="<%= q.getExplanation() != null
                 ? q.getExplanation().replace("\"","&quot;").replace("<","&lt;") : "" %>">

            <p class="q-text"><%= q.getQuestionText() %></p>

            <div class="options">
                <% String[] letters = {"A","B","C","D"};
                   String[] opts = {q.getOptionA(), q.getOptionB(), q.getOptionC(), q.getOptionD()};
                   for(int j = 0; j < 4; j++) {
                       if(opts[j] == null || opts[j].isEmpty()) continue;
                %>
                <div class="option" data-option="<%= letters[j] %>">
                    <div class="ripple-layer"></div>
                    <div class="opt-letter"><%= letters[j] %></div>
                    <div class="opt-text"><%= opts[j] %></div>
                    <div class="opt-icon">
                        <i class="fas fa-check-circle check-icon" style="display:none"></i>
                        <i class="fas fa-times-circle wrong-icon" style="display:none"></i>
                    </div>
                </div>
                <% } %>
            </div>

            <div class="explanation" id="expl<%= i %>">
                <div class="expl-head"><i class="fas fa-lightbulb"></i> Explanation</div>
                <div class="expl-text" id="explText<%= i %>"></div>
            </div>

            <input type="hidden" name="answer_<%= q.getId() %>" class="answer-input">
        </div>
        <% } %>
        </div>

        <div class="q-footer">
            <div class="answered-badge" id="answeredBadge">
                <% for(int i=0;i<total;i++) { %>
                    <div class="dot" id="adot<%= i %>"></div>
                <% } %>
                <span id="answeredCount">0</span>/<%= total %> answered
            </div>
            <div style="display:flex;gap:10px;align-items:center">
                <button type="button" class="btn btn-next" id="nextBtn" disabled>
                    Next <i class="fas fa-arrow-right"></i>
                </button>
                <button type="button" class="btn btn-submit" id="submitBtn"
                        style="display:none" disabled>
                    <i class="fas fa-check"></i> Submit Quiz
                </button>
            </div>
        </div>

    </div>
    </form>
</div>

<script>
/* ── EXIT GUARD ── */
// Push a dummy history state so the browser back button fires popstate instead of navigating away
history.pushState({ quizPage: true }, '');

let quizSubmitting = false; // flipped to true only on intentional quiz submit

window.addEventListener('popstate', function () {
    if (quizSubmitting) return;
    showExitModal();
    // Re-push so the URL stays put and the next back-press also fires popstate
    history.pushState({ quizPage: true }, '');
});

// Native browser dialog for tab-close / refresh
window.addEventListener('beforeunload', function (e) {
    if (quizSubmitting) return;
    e.preventDefault();
    e.returnValue = '';
});

function showExitModal() {
    document.getElementById('exitModal').classList.add('show');
}
function hideExitModal() {
    document.getElementById('exitModal').classList.remove('show');
}

document.getElementById('modalStay').addEventListener('click', hideExitModal);

// Click outside modal box to dismiss
document.getElementById('exitModal').addEventListener('click', function (e) {
    if (e.target === this) hideExitModal();
});

document.getElementById('modalLeave').addEventListener('click', function () {
    quizSubmitting = true; // stop beforeunload firing
    window.location.href = 'select_sublevel.jsp?level=<%= level %>';
});

/* ── CONFETTI (green palette to match site) ── */
const confettiCanvas = document.getElementById('confettiCanvas');
const cCtx = confettiCanvas.getContext('2d');
confettiCanvas.width  = window.innerWidth;
confettiCanvas.height = window.innerHeight;
window.addEventListener('resize', () => {
    confettiCanvas.width  = window.innerWidth;
    confettiCanvas.height = window.innerHeight;
});
let bits = [], cfRunning = false;
function launchConfetti() {
    bits = Array.from({length:55}, () => ({
        x: Math.random()*confettiCanvas.width, y:-10,
        r: Math.random()*6+3,
        color:['#44634d','#86efac','#5a8066','#a7f3d0','#d1fae5'][Math.floor(Math.random()*5)],
        vx:(Math.random()-.5)*5, vy:Math.random()*3+2,
        rot:Math.random()*360, rv:(Math.random()-.5)*7,
        rect:Math.random()>.5
    }));
    if(!cfRunning){cfRunning=true;animateCF();}
}
function animateCF(){
    cCtx.clearRect(0,0,confettiCanvas.width,confettiCanvas.height);
    bits=bits.filter(b=>b.y<confettiCanvas.height+20);
    bits.forEach(b=>{
        cCtx.save(); cCtx.translate(b.x,b.y); cCtx.rotate(b.rot*Math.PI/180);
        cCtx.fillStyle=b.color;
        if(b.rect) cCtx.fillRect(-b.r/2,-b.r/2,b.r,b.r*1.6);
        else{cCtx.beginPath();cCtx.arc(0,0,b.r/2,0,Math.PI*2);cCtx.fill();}
        cCtx.restore();
        b.x+=b.vx; b.y+=b.vy; b.rot+=b.rv; b.vy+=.07;
    });
    if(bits.length) requestAnimationFrame(animateCF);
    else cfRunning=false;
}

/* ── STREAK TOAST ── */
let streakTimer;
function showStreak(n){
    const t=document.getElementById('streakToast');
    const m={2:'2 in a row!',3:'3 streak! 🔥',4:'4 streak! On fire!',5:'5 in a row! 🔥🔥'};
    document.getElementById('streakText').textContent = m[n]||(n+' in a row!');
    t.classList.add('show');
    clearTimeout(streakTimer);
    streakTimer=setTimeout(()=>t.classList.remove('show'),2200);
}

/* ── QUIZ LOGIC ── */
document.addEventListener("DOMContentLoaded", function () {

    const total     = <%= total %>;
    const questions = document.querySelectorAll(".question");
    const progFill  = document.getElementById("progFill");
    const qNum      = document.getElementById("qNum");
    const nextBtn   = document.getElementById("nextBtn");
    const submitBtn = document.getElementById("submitBtn");
    const quizForm  = document.getElementById("quizForm");

    let currentIndex  = 0;
    let answered      = new Array(total).fill(false);
    let answeredCount = 0;
    let streak        = 0;

    function updateDots(idx) {
        for (let i = 0; i < total; i++) {
            const dot  = document.getElementById("dot"  + i);
            const line = document.getElementById("line" + i);
            if (!dot.classList.contains('wrong')) {
                dot.className = "step-dot" + (i < idx ? " done" : i === idx ? " active" : "");
            }
            if (line) line.className = "step-line" + (i < idx ? " done" : "");
        }
    }

    function updateProgress(idx) {
        progFill.style.width = Math.round(((idx + 1) / total) * 100) + "%";
        // Bounce the number
        qNum.style.transform = 'scale(1.3)';
        setTimeout(() => { qNum.textContent = idx + 1; qNum.style.transform = 'scale(1)'; }, 140);
        updateDots(idx);
        const isLast = idx === total - 1;
        if (isLast) {
            nextBtn.style.display   = "none";
            submitBtn.style.display = "inline-flex";
            submitBtn.disabled      = !answered[idx];
        } else {
            nextBtn.style.display   = "inline-flex";
            submitBtn.style.display = "none";
            nextBtn.disabled        = !answered[idx];
        }
    }

    updateProgress(0);

    /* Ripple tracking */
    document.querySelectorAll(".option").forEach(opt => {
        opt.addEventListener("mousemove", function(e) {
            if (this.classList.contains('locked')) return;
            const rect = this.getBoundingClientRect();
            this.style.setProperty('--rx', ((e.clientX - rect.left) / rect.width * 100) + '%');
            this.style.setProperty('--ry', ((e.clientY - rect.top)  / rect.height * 100) + '%');
        });
    });

    /* Answer click */
    document.querySelectorAll(".option").forEach(opt => {
        opt.addEventListener("click", function () {
            const qDiv = this.closest(".question");
            const idx  = parseInt(qDiv.dataset.index);
            if (answered[idx]) return;

            answered[idx] = true;
            answeredCount++;

            const selected  = this.dataset.option;
            const correct   = qDiv.dataset.correct;
            const isCorrect = selected === correct;
            const allOpts   = qDiv.querySelectorAll(".option");

            allOpts.forEach(o => {
                o.classList.add('locked');
                o.style.pointerEvents = "none";
                o.classList.remove("opt-correct","opt-wrong","opt-highlight");
                o.querySelector(".check-icon").style.display = "none";
                o.querySelector(".wrong-icon").style.display = "none";
            });

            if (isCorrect) {
                this.classList.add("opt-correct");
                this.querySelector(".check-icon").style.display = "inline";
                streak++;
                if (streak >= 2) showStreak(streak);
                if (streak >= 3) launchConfetti();
            } else {
                this.classList.add("opt-wrong");
                this.querySelector(".wrong-icon").style.display = "inline";
                streak = 0;
                // Mark step dot red
                const stepDot = document.getElementById("dot" + idx);
                stepDot.className = "step-dot wrong";
                allOpts.forEach(o => {
                    if (o.dataset.option === correct) {
                        o.classList.add("opt-highlight");
                        o.querySelector(".check-icon").style.display = "inline";
                    }
                });
            }

            qDiv.querySelector(".answer-input").value = selected;

            // Show explanation
            const explBox  = document.getElementById("expl"     + idx);
            const explText = document.getElementById("explText" + idx);
            explText.textContent = qDiv.dataset.explanation || "No explanation available.";
            explBox.style.display = "block";

            // Update answered footer dots with colour
            const adot = document.getElementById("adot" + idx);
            adot.classList.add(isCorrect ? 'filled' : 'filled-wrong');
            document.getElementById("answeredCount").textContent = answeredCount;

            if (idx === total - 1) submitBtn.disabled = false;
            else                   nextBtn.disabled   = false;
        });
    });

    /* Next — slide transition */
    nextBtn.addEventListener("click", function () {
        if (!answered[currentIndex]) return;
        const cur = questions[currentIndex];
        cur.classList.add('exiting');
        setTimeout(() => {
            cur.classList.remove('active','exiting');
            currentIndex++;
            questions[currentIndex].classList.add('active');
            updateProgress(currentIndex);
            nextBtn.disabled = !answered[currentIndex];
            window.scrollTo({ top: 0, behavior: "smooth" });
        }, 210);
    });

    submitBtn.addEventListener("click", function () {
        if (!answered[currentIndex]) return;
        quizSubmitting = true; // allow navigation — quiz is being submitted
        launchConfetti();
        setTimeout(() => quizForm.submit(), 550);
    });

});
</script>
</body>
</html>
