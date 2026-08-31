<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<style>
/* 
    Global Image Loader Styles 
    Injects a spinner over images while they load.
*/

/* The container of the image must be relative for absolute positioning of the spinner */
.img-loading-container {
    position: relative !important;
    display: inline-block; /* Ensure it wraps the image tightly if possible, though layout dependent */
}

/* Spinner Element */
.global-image-spinner {
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    width: 32px;
    height: 32px;
    z-index: 5;
    pointer-events: none; /* Let clicks pass through */
    display: flex;
    justify-content: center;
    align-items: center;
}

/* Spinner Circle */
.global-image-spinner::after {
    content: "";
    display: block;
    width: 24px;
    height: 24px;
    border-radius: 50%;
    border: 3px solid rgba(255, 255, 255, 0.3); /* Light track */
    border-top-color: var(--md-sys-color-primary, #D81B60); /* Brand Color */
    animation: global-spin 1s ease-in-out infinite;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

@keyframes global-spin {
    to { transform: rotate(360deg); }
}

/* 
   Hide spinner when specific class is added 
   (Used if we want to force hide via JS without removing DOM)
*/
.global-image-spinner.hidden {
    display: none;
}
</style>

<script>
(function() {
    // Configuration
    const DEBUG_LOADER = false; // Set true to log
    
    /**
     * Creates and injects a spinner for a given image element
     * @param {HTMLImageElement} img 
     */
    function attachSpinner(img) {
        // Validation: Ignore very small icons or tracking pixels to avoid clutter
        // We can't know size before load usually, but if width/height attributes exist we can check
        if (img.getAttribute('width') && parseInt(img.getAttribute('width')) < 20) return;
        if (img.getAttribute('height') && parseInt(img.getAttribute('height')) < 20) return;
        
        // Ignore if already has spinner
        if (img.dataset.hasSpinner === "true") return;

        // Check if already loaded or broken
        if (img.complete) {
            if (img.naturalWidth > 0) return; // Loaded and good
            // If broken, maybe we still want to show something? For now, nothing.
            // But if complete is true and naturalWidth is 0, it might be an empty src or broken.
        }

        // Mark as having spinner
        img.dataset.hasSpinner = "true";

        // Create Spinner
        const spinner = document.createElement('div');
        spinner.className = 'global-image-spinner';
        
        // Determine Parent
        const parent = img.parentElement;
        
        // We need to ensure the parent can hold the absolute spinner
        // We add a class to the parent to enforce position: relative if needed
        // But we must be careful not to break layouts (like flex/grid items)
        // Generally adding 'position: relative' to a flex item is safe.
        // CHECK: If parent is a <picture> or simple wrapper, good. 
        // If parent is body or something huge, might be weird.
        
        // Strategy: We won't force 'position: relative' via inline style unless necessary.
        // We will add a class.
        if (getComputedStyle(parent).position === 'static') {
            parent.style.position = 'relative'; 
        }

        // Inject Spinner
        // Insert after image to sit on top (standard stacking context)
        // But before next sibling
        parent.insertBefore(spinner, img.nextSibling);
        
        // Center spinner over image
        // The CSS .global-image-spinner handles centering if parent is relative
        
        // Handlers
        const removeSpinner = () => {
            if (spinner.isConnected) {
                spinner.remove();
            }
            img.dataset.hasSpinner = "false";
        };

        img.addEventListener('load', removeSpinner, { once: true });
        img.addEventListener('error', removeSpinner, { once: true });
        
        // Safety timeout (in case load event never fires or was missed)
        setTimeout(() => {
            if (img.complete) removeSpinner();
        }, 100); 

        // Hard fallback
        setTimeout(removeSpinner, 10000); 
    }

    /**
     * Observer for new nodes
     */
    const observer = new MutationObserver((mutations) => {
        mutations.forEach((mutation) => {
            mutation.addedNodes.forEach((node) => {
                if (node.nodeType === 1) { // Element
                    if (node.tagName === 'IMG') {
                        attachSpinner(node);
                    } else if (node.querySelectorAll) {
                        // Check children
                        const imgs = node.querySelectorAll('img');
                        imgs.forEach(attachSpinner);
                    }
                }
            });
        });
    });

    /**
     * Init
     */
    function init() {
        // Start watching
        observer.observe(document.body, {
            childList: true,
            subtree: true
        });

        // Scan existing
        document.querySelectorAll('img').forEach(attachSpinner);
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }

})();
</script>
