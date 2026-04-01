let quizState = {
    user: { firstName: '', lastName: '' },
    sublevelScores: {
        level1: 0, level2: 0, level3: 0, level4: 0, level5: 0
    },
    certificateUnlocked: true // already validated by servlet
};

function initializeUser() {
    quizState.user.firstName =
        document.getElementById('userFirstName').value;

    quizState.user.lastName =
        document.getElementById('userLastName').value;
}

function calculateOverallGrade() {
    const scores = Object.values(quizState.sublevelScores);
    const total = scores.reduce((a,b)=>a+b,0);
    const avg = total / scores.length;

    if (avg >= 90) return { grade:'A', percentage:avg };
    if (avg >= 80) return { grade:'B', percentage:avg };
    if (avg >= 70) return { grade:'C', percentage:avg };
    if (avg >= 60) return { grade:'D', percentage:avg };
    return { grade:'F', percentage:avg };
}

function showCertificate() {

    initializeUser();

    const modal = document.getElementById('certificateModal');
    const template = document.getElementById('certificateTemplate');
    const container = document.getElementById('certificateContainer');

    const certificate = template.content.cloneNode(true);

    const fullName =
        quizState.user.firstName + " " + quizState.user.lastName;

    certificate.getElementById('certName').textContent = fullName;

    const result = calculateOverallGrade();

    certificate.getElementById('certGrade')
        .textContent = `${result.grade} (${result.percentage.toFixed(1)}%)`;

    const today = new Date().toLocaleDateString('en-US',{
        year:'numeric', month:'long', day:'numeric'
    });

    certificate.getElementById('certDate').textContent = today;

    container.innerHTML = '';
    container.appendChild(certificate);

    modal.style.display = 'block';
}

function downloadCertificate() {

    const certificate = document.querySelector('.certificate');

    html2canvas(certificate,{
        scale:2,
        useCORS:true,
        backgroundColor:"#ffffff"
    }).then(canvas=>{

        const link = document.createElement('a');

        link.download =
            `CyberSphere_Certificate_${Date.now()}.png`;

        link.href = canvas.toDataURL();

        link.click();
    });
}

document.addEventListener('DOMContentLoaded',()=>{

    showCertificate();

    document.querySelector('.close').onclick =
        ()=> document.getElementById('certificateModal').style.display='none';

    document.getElementById('downloadCertificate')
        .onclick = downloadCertificate;
});