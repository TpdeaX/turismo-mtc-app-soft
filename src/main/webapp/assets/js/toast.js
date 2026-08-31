
const activeToasts = [];

/**
 * Shows a toast notification.
 * @param {string} title - Title of the toast.
 * @param {string} message - Message body.
 * @param {string} type - 'success', 'error', 'info', 'warning'
 * @param {string} iconName - Material Symbol name (e.g., 'check', 'error')
 */
function showToast(title, message, type = 'info', iconName = 'info') {
    const toast = document.createElement('div');
    toast.className = `toast toast-${type}`;
    toast.setAttribute('popover', 'manual');
    const duration = 5000;
    
    toast.innerHTML = `
        <div class="toast-icon">
            <span class="material-symbols-outlined">${iconName}</span>
        </div>
        <div class="toast-content">
            <h4 class="toast-title">${title}</h4>
            <p class="toast-message">${message}</p>
        </div>
        <div class="toast-progress" style="animation-duration: ${duration}ms;"></div>
    `;

    document.body.appendChild(toast); // Append to body for Popover
    try {
        toast.showPopover(); // Promote to Top Layer
    } catch (e) {
        console.warn('Popover API not supported, falling back to fixed z-index', e);
        // Fallback or Polyfill check could go here if needed
    }

    // Calculate Position
    activeToasts.push(toast);
    repositionToasts();

    // Animate In
    requestAnimationFrame(() => toast.classList.add('show'));

    let isDragging = false;
    let startX = 0;
    let currentTranslate = 0;
    let dismissTimeout;

    // Auto Dismiss
    const startDismissTimer = () => {
        dismissTimeout = setTimeout(() => dismissToast(toast), duration);
    };
    
    // Swipe Logic (Updated for popover context)
    const handleStart = (clientX) => {
        isDragging = true;
        startX = clientX;
        toast.style.transition = 'none'; 
        toast.querySelector('.toast-progress').style.animationPlayState = 'paused';
        clearTimeout(dismissTimeout);
    };
    
    const handleMove = (clientX) => {
        if (!isDragging) return;
        const diff = clientX - startX;
        if (diff < 0) currentTranslate = diff * 0.2; 
        else currentTranslate = diff;
        
        toast.style.transform = `translateX(${currentTranslate}px)`;
        toast.style.opacity = 1 - (currentTranslate / 300);
    };
    
    const handleEnd = () => {
       if (!isDragging) return;
       isDragging = false;
       toast.style.transition = 'transform 0.4s cubic-bezier(0.2, 0, 0, 1), opacity 0.4s ease, bottom 0.4s ease'; // Restore all
       
       if (currentTranslate > 100) {
           toast.style.transform = 'translateX(120%)';
           toast.style.opacity = '0';
           setTimeout(() => dismissToast(toast, true), 400); // Pass true to skip anim since we handled it
       } else {
           toast.style.transform = '';
           toast.style.opacity = '';
           toast.querySelector('.toast-progress').style.animationPlayState = 'running';
           startDismissTimer();
       }
    };

    // Mouse Events
    toast.addEventListener('mousedown', e => handleStart(e.clientX));
    window.addEventListener('mousemove', e => handleMove(e.clientX)); 
    window.addEventListener('mouseup', handleEnd);

    // Touch Events
    toast.addEventListener('touchstart', e => handleStart(e.touches[0].clientX));
    toast.addEventListener('touchmove', e => handleMove(e.touches[0].clientX));
    toast.addEventListener('touchend', handleEnd);

    startDismissTimer();
}

function repositionToasts() {
    // Stack from bottom: 24px initial, + height + gap
    let currentBottom = 24;
    activeToasts.forEach(t => {
        t.style.bottom = `${currentBottom}px`;
        currentBottom += 90; // Approximate height + gap
    });
}

function dismissToast(toast, skipAnim = false) {
    // Remove from active list immediately so others shift
    const idx = activeToasts.indexOf(toast);
    if (idx > -1) {
        activeToasts.splice(idx, 1);
        repositionToasts();
    }

    if (!skipAnim) {
        toast.classList.remove('show');
        // Ensure exit if not swiped
        if(!toast.style.transform) toast.style.transform = 'translateX(120%)';
    }
    
    setTimeout(() => {
        if(toast.parentElement) toast.remove();
    }, 400); 
}
