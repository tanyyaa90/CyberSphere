// theme.js - Include this in all pages

class ThemeManager {
    constructor() {
        this.themeToggle = document.getElementById('themeToggle');
        this.init();
    }
    
    init() {
        // Check for saved theme or prefer-color-scheme
        const savedTheme = localStorage.getItem('theme');
        const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
        
        if (savedTheme === 'dark' || (!savedTheme && prefersDark)) {
            this.enableDarkTheme();
        } else {
            this.enableLightTheme();
        }
        
        // Add event listener
        if (this.themeToggle) {
            this.themeToggle.addEventListener('click', () => this.toggleTheme());
        }
        
        // Listen for system theme changes
        window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', (e) => {
            if (!localStorage.getItem('theme')) {
                e.matches ? this.enableDarkTheme() : this.enableLightTheme();
            }
        });
    }
    
    enableDarkTheme() {
        document.body.classList.add('dark-theme');
        localStorage.setItem('theme', 'dark');
        this.updateThemeIcon('dark');
        this.updateMetaThemeColor('#0f172a');
        this.dispatchThemeChange('dark');
    }
    
    enableLightTheme() {
        document.body.classList.remove('dark-theme');
        localStorage.setItem('theme', 'light');
        this.updateThemeIcon('light');
        this.updateMetaThemeColor('#f8fafc');
        this.dispatchThemeChange('light');
    }
    
    toggleTheme() {
        if (document.body.classList.contains('dark-theme')) {
            this.enableLightTheme();
        } else {
            this.enableDarkTheme();
        }
        
        // Add animation to button
        if (this.themeToggle) {
            this.themeToggle.style.transform = 'rotate(180deg)';
            setTimeout(() => {
                this.themeToggle.style.transform = '';
            }, 300);
        }
    }
    
    updateThemeIcon(theme) {
        if (!this.themeToggle) return;
        
        const moonIcon = this.themeToggle.querySelector('.fa-moon');
        const sunIcon = this.themeToggle.querySelector('.fa-sun');
        
        if (theme === 'dark') {
            moonIcon.style.display = 'none';
            sunIcon.style.display = 'block';
        } else {
            moonIcon.style.display = 'block';
            sunIcon.style.display = 'none';
        }
    }
    
    updateMetaThemeColor(color) {
        let metaThemeColor = document.querySelector('meta[name="theme-color"]');
        if (!metaThemeColor) {
            metaThemeColor = document.createElement('meta');
            metaThemeColor.name = 'theme-color';
            document.head.appendChild(metaThemeColor);
        }
        metaThemeColor.content = color;
    }
    
    dispatchThemeChange(theme) {
        // Dispatch event for other components to listen to
        const event = new CustomEvent('themechange', { detail: { theme } });
        document.dispatchEvent(event);
    }
}

// Initialize theme manager when DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
    window.themeManager = new ThemeManager();
});