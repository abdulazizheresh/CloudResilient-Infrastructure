# CloudResilient Infrastructure 🌍

Portfolio project showcasing Azure Infrastructure as Code (IaC) using Bicep, with multi-region deployment, disaster recovery, and monitoring.

## 📁 Project Structure

```
frontend/
├── index.html              # Main HTML file
├── css/
│   └── style.css          # All styling (Glassmorphism design)
├── js/
│   ├── app.js             # Main application logic
│   └── i18n.js            # Internationalization system
└── assets/
    └── (images, icons)
```

## 🌐 Supported Languages

- 🇬🇧 **English** (Default)
- 🇸🇦 **Arabic** (RTL Support)
- 🇩🇪 **German**
- 🇫🇷 **French**

Language preference is saved in localStorage and persists across sessions.

## ✨ Features

### Frontend
- ✅ **Responsive Design** - Works on all devices
- ✅ **Glassmorphism UI** - Modern, beautiful interface
- ✅ **RTL Support** - Full right-to-left for Arabic
- ✅ **Smooth Animations** - Fade-in, hover effects, loading states
- ✅ **Multi-language** - 4 languages with easy switching
- ✅ **Dark Theme** - Eye-friendly gradient background
- ✅ **Auto-refresh** - Data updates every 30 seconds
- ✅ **Toast Notifications** - User feedback for actions

### Functionality
- 📍 **Region Information** - Shows current Azure region
- 💾 **Database Status** - Connection and visitor count
- ⚙️ **System Info** - Hosting, CDN, HTTPS status
- 📊 **Statistics** - Uptime, response time, active regions
- 🚀 **Actions** - Refresh, test failover, view logs, increment counter

## 🚀 Quick Start

### Option 1: Simple File Open
```bash
# Just open index.html in your browser
open index.html  # macOS
start index.html # Windows
```

### Option 2: Live Server (Recommended)
```bash
# Install Live Server extension in VS Code
# Right-click index.html → "Open with Live Server"
```

### Option 3: Python HTTP Server
```bash
cd frontend
python -m http.server 8000
# Visit http://localhost:8000
```

### Option 4: Node.js HTTP Server
```bash
npx http-server frontend -p 8000
# Visit http://localhost:8000
```

## 🔧 Configuration

Edit `js/app.js` to configure:

```javascript
const config = {
    refreshInterval: 30000,  // Auto-refresh interval (ms)
    simulateData: true       // true = demo mode, false = real API
};
```

### Demo Mode (Current)
- Uses simulated data
- Perfect for testing UI
- No backend required

### Production Mode
1. Set `simulateData: false`
2. Deploy Azure Functions backend
3. Update `API_BASE` URL

## 🎨 Customization

### Change Colors
Edit `css/style.css`:
```css
/* Main gradient */
background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);

/* Button gradient */
background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
```

### Add New Language
Edit `js/i18n.js`:
```javascript
const translations = {
    // Add new language
    es: {
        header: {
            title: "🌍 Demo Multi-Región de Azure",
            // ... more translations
        }
    }
};
```

Then add button in `index.html`:
```html
<button class="lang-btn" data-lang="es">🇪🇸 ES</button>
```

## 📊 Data Structure

The application expects the following data structure from the API:

```json
{
    "region": "West Us",
    "timestamp": "2025-10-10T12:00:00Z",
    "visitors": 1234,
    "responseTime": 45,
    "dbStatus": "connected"
}
```

## 🔌 API Endpoints (Future)

When connecting to real Azure Functions:

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/GetInfo` | GET | Get region info and stats |
| `/api/GetVisitors` | GET | Get visitor count |
| `/api/IncrementVisitor` | POST | Increment visitor counter |
| `/api/GetLogs` | GET | Get application logs |

## 🎯 Next Steps

1. ✅ **Phase 1: Frontend** (Current) - ✅ Complete
2. ⏳ **Phase 2: Azure Functions** - Create backend API
3. ⏳ **Phase 3: Bicep Infrastructure** - Deploy with IaC
4. ⏳ **Phase 4: Multi-Region** - Setup secondary region
5. ⏳ **Phase 5: Monitoring** - Add Application Insights
6. ⏳ **Phase 6: DR Testing** - Test failover scenarios

## 📝 File Descriptions

### `index.html`
- Main structure
- Cards layout
- Language switcher
- Data binding with `data-i18n` attributes

### `css/style.css`
- Glassmorphism effects
- Responsive grid layout
- Animations and transitions
- RTL support for Arabic
- Toast notifications

### `js/i18n.js`
- Translation system
- Language switching
- localStorage persistence
- Variable replacement in translations

### `js/app.js`
- Data fetching logic
- UI updates
- User interactions
- Auto-refresh
- Error handling

## 🌟 Browser Support

- ✅ Chrome/Edge (Latest)
- ✅ Firefox (Latest)
- ✅ Safari (Latest)
- ✅ Mobile browsers

## 📱 Mobile Responsive

The design automatically adapts to:
- 📱 Mobile (< 768px)
- 💻 Tablet (768px - 1024px)
- 🖥️ Desktop (> 1024px)

## 🔒 Security Notes

- Uses HTTPS (when deployed)
- No sensitive data in frontend
- API keys in environment variables (backend)
- Key Vault for secrets (when deployed)

## 📄 License

MIT License - Feel free to use for your portfolio!

## 👨‍💻 Author

**Your Name**  
Azure Cloud Engineer | AZ-900, AZ-104, AZ-500, AZ-305 Certified

## 🙏 Acknowledgments

- Built with Azure services
- Icons from Emoji
- Inspired by modern glassmorphism design

---

**Made with ❤️ for Azure Infrastructure Portfolio**