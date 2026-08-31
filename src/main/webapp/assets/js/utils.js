/**
 * Applies the 'scrim' (backdrop) fix to Material Design 3 Dialogs.
 * @param {Array<string>} dialogIds - List of dialog IDs to apply the fix to.
 */
function fixDialogScrim(dialogIds) {
    customElements.whenDefined('md-dialog').then(() => {
        dialogIds.forEach(id => {
            const d = document.getElementById(id);
            if (d && d.shadowRoot) {
                // Check if style already exists to avoid duplication
                if(d.shadowRoot.querySelector('style[data-scrim-fix]')) return;

                // Verificar si el blur modal está habilitado en la configuración
                const blurEnabled = window.SYSTEM_CONFIG && window.SYSTEM_CONFIG.ui_blur_modal !== false;
                const blurCSS = blurEnabled ? 'backdrop-filter: blur(8px) !important;' : '';

                const style = document.createElement('style');
                style.setAttribute('data-scrim-fix', 'true');
                style.textContent = `
                    /* Base Scrim State (Closed) */
                    .scrim { 
                        z-index: -1 !important; 
                        opacity: 0 !important; 
                        pointer-events: none !important;
                        background-color: rgba(0,0,0,0.4) !important;
                        ${blurCSS}
                        display: flex !important;
                        inset: 0 !important;
                        position: fixed !important;
                        transition: opacity 0.3s ease, z-index 0s 0.3s; 
                    }
                    
                    /* Open State */
                    :host([open]) .scrim {
                        z-index: inherit !important; 
                        opacity: 1 !important; 
                        pointer-events: auto !important;
                        transition: opacity 0.4s ease, z-index 0s;
                    }

                    /* Ensure Internal Dialog Container allows Overflow for Icon */
                    .container {
                        overflow: visible !important;
                        border-radius: 28px !important;
                    }
                    
                    /* Ensure the host itself allows overflow */
                    :host {
                        overflow: visible !important;
                    }
                    
                    dialog {
                        overflow: visible !important;
                    }
                `;
                d.shadowRoot.appendChild(style);
            }
        });
    });
}

/**
 * Injects custom scrollbar styles into all Shadow Roots to ensure consistency.
 * Targeted for Material Web Components which encapsulate styles.
 */
function injectGlobalStylesToShadowRoots() {
    const scrollbarStyles = `
        /* Custom Scrollbar - Injected */
        ::-webkit-scrollbar {
            width: 10px;
            height: 10px;
        }

        ::-webkit-scrollbar-track {
            background: var(--md-sys-color-surface-container-low, #1D1B20); 
            border-radius: 4px;
        }

        ::-webkit-scrollbar-thumb {
            background: var(--md-sys-color-outline-variant, #49454F); 
            border-radius: 4px;
            border: 2px solid var(--md-sys-color-surface-container-low, #1D1B20); 
        }

        ::-webkit-scrollbar-thumb:hover {
            background: var(--md-sys-color-primary, #D0BCFF); 
        }
    `;

    const injectToRoot = (root) => {
        if (!root || root.querySelector('style[data-global-scrollbar]')) return;
        
        const style = document.createElement('style');
        style.setAttribute('data-global-scrollbar', 'true');
        style.textContent = scrollbarStyles;
        root.appendChild(style);
    };

    // 1. Inject into existing defined components
    const targetTags = ['md-dialog', 'md-outlined-select', 'md-menu', 'md-list', 'md-list-item'];
    
    targetTags.forEach(tagName => {
        customElements.whenDefined(tagName).then(() => {
            document.querySelectorAll(tagName).forEach(el => {
                if(el.shadowRoot) injectToRoot(el.shadowRoot);
            });
        });
    });

    // 2. Observe for new elements
    const observer = new MutationObserver((mutations) => {
        mutations.forEach((mutation) => {
            mutation.addedNodes.forEach((node) => {
                if (node.nodeType === 1 && node.shadowRoot) {
                    injectToRoot(node.shadowRoot);
                }
                // Deep check for children if a container was added
                if (node.nodeType === 1 && node.querySelectorAll) {
                     targetTags.forEach(tag => {
                         node.querySelectorAll(tag).forEach(el => {
                             if(el.shadowRoot) injectToRoot(el.shadowRoot);
                             // If shadowRoot not yet ready (very rare race condition), can retry or rely on whenDefined above
                         });
                     });
                }
            });
        });
    });

    observer.observe(document.body, { childList: true, subtree: true });
}

// Auto-execute on load
document.addEventListener('DOMContentLoaded', () => {
    injectGlobalStylesToShadowRoots();
});
