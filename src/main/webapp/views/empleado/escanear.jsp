<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <title>Escanear QR | Grupo Peruana</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <meta name="theme-color" content="#EC407A">
    
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Rounded:opsz,wght,FILL,GRAD@24,400,1,0" rel="stylesheet">

    <script src="https://unpkg.com/html5-qrcode" type="text/javascript"></script>

    <style>
    /* ========================================
       QR SCANNER - Premium Mobile Design
       ======================================== */
       
    :root {
        --primary: #EC407A;
        --primary-soft: rgba(236, 64, 122, 0.12);
        --success: #4CAF50;
        --success-soft: rgba(76, 175, 80, 0.12);
        --error: #F44336;
        --error-soft: rgba(244, 67, 54, 0.12);
        --surface: #FFFFFF;
        --surface-container: #F8F9FA;
        --text-primary: #1C1B1F;
        --text-secondary: #49454F;
        --radius-lg: 24px;
        --radius-md: 16px;
        --ease-spring: cubic-bezier(0.34, 1.56, 0.64, 1);
        --ease-smooth: cubic-bezier(0.25, 0.8, 0.25, 1);
    }

    [data-theme="dark"] {
        --surface: #1E1E1E;
        --surface-container: #2C2C2C;
        --text-primary: #E6E1E5;
        --text-secondary: #CAC4D0;
    }

    @keyframes fadeInUp {
        from { opacity: 0; transform: translateY(20px); }
        to { opacity: 1; transform: translateY(0); }
    }

    @keyframes pulse {
        0%, 100% { transform: scale(1); opacity: 1; }
        50% { transform: scale(1.05); opacity: 0.8; }
    }

    @keyframes scanLine {
        0%, 100% { top: 0; }
        50% { top: calc(100% - 4px); }
    }

    /* ===== SCANNER HEADER ===== */
    .scanner-header {
        text-align: center;
        padding: 16px 0 24px;
        animation: fadeInUp 0.5s var(--ease-smooth);
    }

    .scanner-icon {
        width: 64px;
        height: 64px;
        border-radius: 50%;
        background: linear-gradient(135deg, var(--primary) 0%, #AB47BC 100%);
        display: flex;
        align-items: center;
        justify-content: center;
        margin: 0 auto 16px;
        box-shadow: 0 8px 24px rgba(236, 64, 122, 0.3);
    }

    .scanner-icon .material-symbols-rounded {
        font-size: 32px;
        color: white;
    }

    .scanner-title {
        font-size: 1.5rem;
        font-weight: 700;
        color: var(--text-primary);
        margin: 0 0 8px 0;
    }

    .scanner-subtitle {
        font-size: 0.9rem;
        color: var(--text-secondary);
        margin: 0;
    }

    /* ===== ERROR ALERT ===== */
    .scan-alert {
        background: var(--error-soft);
        color: #C62828;
        padding: 16px;
        border-radius: var(--radius-md);
        margin-bottom: 20px;
        display: flex;
        align-items: center;
        gap: 12px;
        animation: fadeInUp 0.5s var(--ease-smooth);
    }

    .scan-alert .material-symbols-rounded {
        font-size: 24px;
    }

    /* ===== QR READER CONTAINER ===== */
    .qr-container {
        background: var(--surface);
        border-radius: var(--radius-lg);
        overflow: hidden;
        box-shadow: 0 8px 32px rgba(0,0,0,0.1);
        margin-bottom: 20px;
        animation: fadeInUp 0.6s var(--ease-smooth);
    }

    #reader {
        width: 100%;
        border-radius: var(--radius-lg);
        overflow: hidden;
    }

    #reader video {
        border-radius: var(--radius-lg);
    }

    /* Override QR Scanner library styles */
    #reader button {
        background: linear-gradient(135deg, var(--primary) 0%, #C7396D 100%) !important;
        color: white !important;
        border: none !important;
        padding: 12px 24px !important;
        border-radius: 28px !important;
        font-family: 'Outfit', sans-serif !important;
        font-weight: 600 !important;
        margin-top: 12px !important;
        cursor: pointer !important;
        box-shadow: 0 4px 16px rgba(236, 64, 122, 0.3) !important;
    }

    #reader select {
        padding: 12px 16px !important;
        border-radius: 12px !important;
        border: 2px solid var(--primary) !important;
        font-family: 'Outfit', sans-serif !important;
        background: var(--surface) !important;
        color: var(--text-primary) !important;
    }

    /* ===== EVIDENCE SECTION ===== */
    .evidence-section {
        display: none;
        animation: fadeInUp 0.5s var(--ease-smooth);
    }

    .evidence-section.show {
        display: block;
    }

    .evidence-header {
        text-align: center;
        margin-bottom: 20px;
    }

    .evidence-header h3 {
        color: var(--success);
        font-size: 1.2rem;
        margin: 0 0 8px 0;
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 8px;
    }

    .evidence-header p {
        color: var(--text-secondary);
        margin: 0;
        font-size: 0.9rem;
    }

    .camera-container {
        background: black;
        border-radius: var(--radius-lg);
        overflow: hidden;
        position: relative;
        aspect-ratio: 4/3;
        box-shadow: 0 8px 32px rgba(0,0,0,0.2);
    }

    #camera-stream {
        width: 100%;
        height: 100%;
        object-fit: cover;
    }

    #camera-canvas {
        display: none;
    }

    .capture-btn {
        width: 100%;
        padding: 16px;
        margin-top: 20px;
        background: linear-gradient(135deg, var(--success) 0%, #388E3C 100%);
        color: white;
        border: none;
        border-radius: 28px;
        font-size: 1rem;
        font-weight: 600;
        font-family: 'Outfit', sans-serif;
        cursor: pointer;
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 10px;
        box-shadow: 0 6px 20px rgba(76, 175, 80, 0.3);
        transition: all 0.3s var(--ease-spring);
    }

    .capture-btn:active {
        transform: scale(0.96);
    }

    .capture-btn:disabled {
        opacity: 0.6;
        cursor: not-allowed;
    }

    .capture-btn .material-symbols-rounded {
        font-size: 24px;
    }

    /* ===== CANCEL BUTTON ===== */
    .cancel-btn {
        width: 100%;
        padding: 14px;
        margin-top: 12px;
        background: transparent;
        color: var(--text-secondary);
        border: 2px solid var(--text-secondary);
        border-radius: 28px;
        font-size: 0.95rem;
        font-weight: 600;
        font-family: 'Outfit', sans-serif;
        cursor: pointer;
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 8px;
        transition: all 0.3s var(--ease-spring);
        text-decoration: none;
    }

    .cancel-btn:active {
        transform: scale(0.96);
        background: var(--primary-soft);
        border-color: var(--primary);
        color: var(--primary);
    }

    /* ===== SCANNING ANIMATION ===== */
    .scan-overlay {
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        pointer-events: none;
    }

    .scan-line {
        position: absolute;
        left: 10%;
        right: 10%;
        height: 4px;
        background: linear-gradient(90deg, transparent, var(--primary), transparent);
        border-radius: 2px;
        animation: scanLine 2s ease-in-out infinite;
        box-shadow: 0 0 20px var(--primary);
    }

    /* Corner markers */
    .corner {
        position: absolute;
        width: 24px;
        height: 24px;
        border-color: white;
        border-style: solid;
        border-width: 0;
    }

    .corner.tl { top: 10%; left: 10%; border-top-width: 3px; border-left-width: 3px; border-radius: 8px 0 0 0; }
    .corner.tr { top: 10%; right: 10%; border-top-width: 3px; border-right-width: 3px; border-radius: 0 8px 0 0; }
    .corner.bl { bottom: 10%; left: 10%; border-bottom-width: 3px; border-left-width: 3px; border-radius: 0 0 0 8px; }
    .corner.br { bottom: 10%; right: 10%; border-bottom-width: 3px; border-right-width: 3px; border-radius: 0 0 8px 0; }
    </style>
</head>
<body>

<jsp:include page="../shared/loading-screen.jsp"/>
<jsp:include page="../shared/mobile-layout.jsp"/>

<main class="mobile-content">
    <!-- Scanner Header -->
    <div class="scanner-header" id="scannerHeader">
        <div class="scanner-icon">
            <span class="material-symbols-rounded">qr_code_scanner</span>
        </div>
        <h1 class="scanner-title" id="pageTitle">Escanear QR</h1>
        <p class="scanner-subtitle" id="pageSubtitle">Apunta la cámara al código QR de asistencia</p>
    </div>
    
    <!-- Error Alert -->
    <% if (request.getAttribute("error") != null) { %>
        <div class="scan-alert">
            <span class="material-symbols-rounded">error</span>
            <span><%= request.getAttribute("error") %></span>
        </div>
    <% } %>

    <!-- QR Reader -->
    <div class="qr-container" id="qrContainer">
        <div id="reader"></div>
    </div>

    <!-- Evidence Section (Camera for photo) -->
    <div class="evidence-section" id="evidenceSection">
        <div class="evidence-header">
            <h3>
                <span class="material-symbols-rounded">check_circle</span>
                ¡QR Detectado!
            </h3>
            <p>Toma una foto como evidencia para completar</p>
        </div>
        
        <div class="camera-container">
            <video id="camera-stream" autoplay playsinline></video>
            <canvas id="camera-canvas"></canvas>
            <div class="scan-overlay">
                <div class="corner tl"></div>
                <div class="corner tr"></div>
                <div class="corner bl"></div>
                <div class="corner br"></div>
            </div>
        </div>

        <button class="capture-btn" onclick="tomarFotoYEnviar()" id="captureBtn">
            <span class="material-symbols-rounded">camera</span>
            <span>Tomar Foto y Finalizar</span>
        </button>
    </div>

    <!-- Cancel Button -->
    <a href="${pageContext.request.contextPath}/empleado" class="cancel-btn" id="cancelBtn">
        <span class="material-symbols-rounded">arrow_back</span>
        <span>Volver al Inicio</span>
    </a>

    <!-- Hidden Form -->
    <form id="formScan" action="${pageContext.request.contextPath}/qr" method="post" enctype="multipart/form-data">
        <input type="hidden" name="qrToken" id="inputToken">
        <input type="file" name="foto" id="inputFoto" style="display:none;">
    </form>
</main>

<script>
    var html5QrcodeScanner = new Html5QrcodeScanner("reader", { 
        fps: 10, 
        qrbox: { width: 250, height: 250 },
        rememberLastUsedCamera: true,
        showTorchButtonIfSupported: true
    });
    
    let videoStream = null;

    function onScanSuccess(decodedText, decodedResult) {
        // Stop scanner and hide
        html5QrcodeScanner.clear();
        document.getElementById('qrContainer').style.display = 'none';
        document.getElementById('cancelBtn').style.display = 'none';

        // Save token
        document.getElementById('inputToken').value = decodedText;

        // Update header
        document.getElementById('pageTitle').textContent = 'Verificar Identidad';
        document.getElementById('pageSubtitle').textContent = 'QR detectado. Toma una foto para confirmar.';

        // Show evidence section
        document.getElementById('evidenceSection').classList.add('show');

        // Start camera for selfie
        iniciarCamara();
    }

    html5QrcodeScanner.render(onScanSuccess);

    async function iniciarCamara() {
        const video = document.getElementById('camera-stream');
        try {
            videoStream = await navigator.mediaDevices.getUserMedia({ 
                video: { facingMode: "user" } 
            });
            video.srcObject = videoStream;
        } catch (err) {
            alert("Error al acceder a la cámara: " + err);
        }
    }

    function tomarFotoYEnviar() {
        const video = document.getElementById('camera-stream');
        const canvas = document.getElementById('camera-canvas');
        const context = canvas.getContext('2d');
        const btn = document.getElementById('captureBtn');
        
        canvas.width = video.videoWidth;
        canvas.height = video.videoHeight;
        context.drawImage(video, 0, 0, canvas.width, canvas.height);
        
        canvas.toBlob(blob => {
            const fileInput = document.getElementById('inputFoto');
            const dataTransfer = new DataTransfer();
            const file = new File([blob], "evidencia_qr_" + Date.now() + ".jpg", { type: "image/jpeg" });
            dataTransfer.items.add(file);
            fileInput.files = dataTransfer.files;

            // Update button state
            btn.innerHTML = '<span class="material-symbols-rounded">hourglass_top</span><span>Enviando...</span>';
            btn.disabled = true;
            
            // Submit form
            document.getElementById('formScan').submit();

        }, 'image/jpeg', 0.8);
    }
</script>

</body>
</html>
