// API Base URL
const API_BASE = 'https://api.azuretest100.site/api';

// Configuration
const config = {
    refreshInterval: 30000, // 30 seconds
    simulateData: false // false = use real API
};

// Simulated data for testing
const simulatedData = {
    region: 'Central US',
    timestamp: new Date().toLocaleString('en-US'),
    visitors: Math.floor(Math.random() * 1000) + 100,
    responseTime: Math.floor(Math.random() * 50) + 20,
    dbStatus: 'connected'
};

// Initialize on page load
document.addEventListener('DOMContentLoaded', () => {
    // Wait for i18n to be ready
    setTimeout(() => {
        loadData();
        startAutoRefresh();
        setupStatAnimations();
    }, 100);
});

// Main function to load data
async function loadData() {
    try {
        if (config.simulateData) {
            // Simulate API delay
            await new Promise(resolve => setTimeout(resolve, 800));
            updateUI(simulatedData);
        } else {
            // Real API calls - fetch both info and visitors
            const infoResponse = await fetch(`${API_BASE}/info`);
            if (!infoResponse.ok) throw new Error('Failed to fetch info');
            const infoData = await infoResponse.json();
            
            const visitorsResponse = await fetch(`${API_BASE}/visitors`);
            if (!visitorsResponse.ok) throw new Error('Failed to fetch visitors');
            const visitorsData = await visitorsResponse.json();
            
            // ✅ Combine data from both APIs
            const data = {
                region: infoData.region,
                timestamp: infoData.timestamp,
                responseTime: infoData.responseTime,
                uptime: infoData.uptime,
                activeRegions: infoData.activeRegions,
                visitors: visitorsData.visitorCount,
                dbStatus: visitorsData.dbStatus
            };
            
            updateUI(data);
        }
    } catch (error) {
        console.error('Error loading data:', error);
        showToast(i18n.t('messages.loadError'), 'error');

        // Show error state
        document.getElementById('region').textContent = i18n.t('messages.notAvailable');
        document.getElementById('status-text').textContent = i18n.t('status.error');
        document.getElementById('status').className = 'status-indicator status-error';
        document.getElementById('db-status-text').textContent = i18n.t('status.error');
        document.getElementById('db-status').className = 'status-indicator status-error';
    }
}

// Update UI with data
function updateUI(data) {
    // Region
    document.getElementById('region').textContent = data.region;

    // Status
    const statusEl = document.getElementById('status');
    const statusTextEl = document.getElementById('status-text');
    statusEl.className = 'status-indicator status-online';
    statusTextEl.textContent = i18n.t('status.connected');

    // Timestamp
    const timestamp = new Date();
    document.getElementById('timestamp').textContent =
        timestamp.toLocaleTimeString(i18n.currentLang);

    // Database status
    const dbStatusEl = document.getElementById('db-status');
    const dbStatusTextEl = document.getElementById('db-status-text');
    if (data.dbStatus === 'connected') {
        dbStatusEl.className = 'status-indicator status-online';
        dbStatusTextEl.textContent = i18n.t('status.connected');
    } else {
        dbStatusEl.className = 'status-indicator status-error';
        dbStatusTextEl.textContent = i18n.t('status.error');
    }

    // Visitors
    document.getElementById('visitors').textContent =
        data.visitors.toLocaleString(i18n.currentLang);

    // Response time
    document.getElementById('response-time').textContent =
        `${data.responseTime}ms`;
    
    // Uptime
    if (data.uptime) {
        document.getElementById('uptime').textContent = data.uptime;
    }
    
    // Active Regions
    if (data.activeRegions) {
        document.getElementById('active-regions').textContent = data.activeRegions;
    }
}

// Refresh data manually
async function refreshData() {
    showToast(i18n.t('messages.refreshing'));
    await loadData();
    showToast(i18n.t('messages.refreshed'));
}

// Auto refresh every 30 seconds
function startAutoRefresh() {
    setInterval(() => {
        loadData();
    }, config.refreshInterval);
}

// Test failover
// Test failover
async function testFailover() {
    if (!confirm('⚠️ This will stop the current region. Continue?')) return;
    
    showToast('Testing failover...', 'info');
    
    try {
        const response = await fetch(`${API_BASE}/test-failover`, {
            method: 'POST'
        });
        
        if (!response.ok) throw new Error('Failover failed');
        
        const data = await response.json();
        showToast(`✅ ${data.message}`, 'success');
        
        setTimeout(() => {
            loadData();
            showToast('Failover complete! Now using backup region.', 'success');
        }, 20000); // 20 Seconds wait before refresh
        
    } catch (error) {
        showToast('Failover test failed: ' + error.message, 'error');
    }
}

// Increment visitor counter
async function incrementVisitor() {
    try {
        if (config.simulateData) {
            // Simulate increment
            simulatedData.visitors++;
            document.getElementById('visitors').textContent =
                simulatedData.visitors.toLocaleString(i18n.currentLang);
            showToast(i18n.t('messages.counterIncremented'));
        } else {
            // Real API call
            const response = await fetch(`${API_BASE}/increment`, {
                method: 'POST'
            });

            if (!response.ok) throw new Error('Failed to increment');

            const data = await response.json();
            // Use visitorCount from API response
            document.getElementById('visitors').textContent =
                data.visitorCount.toLocaleString(i18n.currentLang);
            showToast(i18n.t('messages.counterIncremented'));
        }
    } catch (error) {
        console.error('Error incrementing visitor:', error);
        showToast(i18n.t('messages.counterError'), 'error');
    }
}

// View logs (placeholder)
function viewLogs() {
    showToast(i18n.t('messages.logsComingSoon'));
}

// Show toast notification
function showToast(message, type = 'success') {
    const toast = document.getElementById('toast');
    toast.textContent = message;
    toast.className = `toast ${type} show`;

    setTimeout(() => {
        toast.className = 'toast';
    }, 3000);
}

// Setup stat animations
function setupStatAnimations() {
    document.querySelectorAll('.stat-item').forEach(item => {
        item.addEventListener('mouseenter', function () {
            this.style.transform = 'scale(1.05) rotate(2deg)';
        });
        item.addEventListener('mouseleave', function () {
            this.style.transform = 'scale(1) rotate(0deg)';
        });
    });
}

// Export for testing
if (typeof module !== 'undefined' && module.exports) {
    module.exports = {
        loadData,
        refreshData,
        testFailover,
        incrementVisitor,
        viewLogs
    };
}

// Dark Mode Toggle
document.addEventListener('DOMContentLoaded', () => {
    const themeToggle = document.getElementById('themeToggle');
    const themeIcon = themeToggle.querySelector('.theme-icon');
    
    // Load saved theme
    const savedTheme = localStorage.getItem('theme') || 'light';
    if (savedTheme === 'dark') {
        document.body.classList.add('dark-mode');
        themeIcon.textContent = '☀️';
    }
    
    // Toggle theme
    themeToggle.addEventListener('click', () => {
        document.body.classList.toggle('dark-mode');
        const isDark = document.body.classList.contains('dark-mode');
        
        themeIcon.textContent = isDark ? '☀️' : '🌙';
        localStorage.setItem('theme', isDark ? 'dark' : 'light');
    });
});