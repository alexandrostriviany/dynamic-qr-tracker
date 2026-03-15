# Dynamic QR Code Tracker

Free dynamic QR codes with full scan statistics using Firebase Hosting + Google Analytics 4.

**How it works:** QR code points to a Firebase-hosted redirect page. The page fires a GA4 tracking event (capturing location, device, time, campaign), then redirects the user to the final destination. Change the destination anytime by editing the config and redeploying — the QR code itself never changes.

**Cost:** $0/month for up to ~5 million scans/month.

## Project Structure

```
dynamic-qr-tracker/
  .github/workflows/
    deploy.yml       # Auto-deploy to Firebase on push to main
  public/
    index.html       # Redirect page with GA4 tracking
    404.html         # Fallback for unknown routes
  config.json        # Route definitions (reference only)
  firebase.json      # Firebase Hosting config
  .firebaserc        # Firebase project ID
  deploy.sh          # One-command deploy (local)
```

## Prerequisites

1. **Google account** (free)
2. **Node.js** (v18+)
3. **Firebase CLI:**
   ```bash
   npm install -g firebase-tools
   ```
## Setup Guide

### Step 1: Create a Firebase project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Create a project"** (or "Add project")
3. Name it (e.g., `my-qr-tracker`)
4. Disable Google Analytics for the Firebase project (we'll use GA4 separately for more control)
5. Click **Create**

### Step 2: Create a GA4 property

1. Go to [Google Analytics](https://analytics.google.com/)
2. Click **Admin** (gear icon) > **Create** > **Property**
3. Name it (e.g., `QR Tracker`)
4. Click through the setup wizard
5. Choose **Web** as the platform
6. Enter your Firebase Hosting URL as the website (e.g., `my-qr-tracker.web.app`)
7. Copy the **Measurement ID** — it looks like `G-XXXXXXXXXX`

### Step 3: Configure the project

1. **Set your Firebase project ID** in `.firebaserc`:
   ```json
   {
     "projects": {
       "default": "my-qr-tracker"
     }
   }
   ```

2. **Set your GA4 Measurement ID and routes** in `public/index.html`:

   Find the `CONFIG` object near the top and edit it:
   ```javascript
   var CONFIG = {
     GA_ID: 'G-XXXXXXXXXX',                  // Your GA4 Measurement ID
     DEFAULT_URL: 'https://your-site.com',    // Fallback destination
     ROUTES: {
       'default': 'https://your-site.com',
       'menu':    'https://your-site.com/menu',
       'promo':   'https://your-site.com/spring-sale'
     }
   };
   ```

   Also replace the two occurrences of `GA_MEASUREMENT_ID` in the `<script>` tags at the top:
   ```html
   <script async src="https://www.googletagmanager.com/gtag/js?id=G-XXXXXXXXXX"></script>
   ...
   gtag('config', 'G-XXXXXXXXXX', { send_page_view: false });
   ```

### Step 4: Login and deploy

```bash
# Login to Firebase (one-time)
firebase login

# Deploy
./deploy.sh
# or: firebase deploy --only hosting
```

Your site is now live at `https://my-qr-tracker.web.app`.

### Step 5: Create QR codes

Use any QR code generator app with these URLs:

| Route | URL to encode |
|-------|------------|
| Default | `https://my-qr-tracker.web.app/?utm_source=flyer&utm_medium=qr&utm_campaign=default` |
| Menu | `https://my-qr-tracker.web.app/?r=menu&utm_source=poster&utm_medium=qr&utm_campaign=menu` |
| Promo | `https://my-qr-tracker.web.app/?r=promo&utm_source=email&utm_medium=qr&utm_campaign=promo` |

Paste the URL into your preferred QR design tool to generate the image.

## How Routing Works

The redirect page reads the `?r=` query parameter to pick the destination:

- `?r=menu` → looks up `CONFIG.ROUTES['menu']` → redirects to that URL
- `?r=promo` → looks up `CONFIG.ROUTES['promo']` → redirects to that URL
- No `?r=` or unknown key → redirects to `CONFIG.DEFAULT_URL`

**UTM parameters** (`utm_source`, `utm_medium`, `utm_campaign`, `utm_term`, `utm_content`) are captured by GA4 for campaign attribution. They do NOT affect the redirect destination.

## Changing the Destination (Dynamic QR)

This is the "dynamic" part. To change where a QR code points:

1. Edit `CONFIG.ROUTES` in `public/index.html`
2. Run `firebase deploy --only hosting`

The QR code image stays the same. The redirect destination changes instantly.

## Viewing Statistics in GA4

### Real-time (last 30 minutes)
1. Go to [Google Analytics](https://analytics.google.com/)
2. **Reports** > **Realtime**
3. You'll see active users and events as they happen

### Detailed reports (24-48 hour delay)
1. **Reports** > **Acquisition** > **Traffic acquisition**
   - Filter by Medium = `qr` to see all QR traffic
   - Break down by Campaign to see per-route stats
2. **Reports** > **Engagement** > **Events**
   - Look for the `qr_scan` event
   - Click it to see route_key breakdown, destinations, etc.

### Custom exploration
1. **Explore** > **Blank exploration**
2. Add dimensions: `Event name`, `Campaign`, custom params (`route_key`)
3. Add metrics: `Event count`, `Total users`
4. Filter to `qr_scan` events

### What you'll see per scan

| Metric | Source |
|--------|--------|
| Country, city | Auto (IP-based) |
| Device (phone/tablet/desktop) | Auto |
| Browser, OS | Auto |
| Time of scan | Auto |
| Campaign source | From `utm_source` parameter |
| Which QR code (route) | From `route_key` custom parameter |
| New vs returning | Auto (cookie-based) |

## CI/CD (GitHub Actions)

**`.github/workflows/deploy.yml`** auto-deploys to Firebase Hosting when you push changes to `main` (only triggers when `public/`, `firebase.json`, or `.firebaserc` change). PRs get a temporary preview URL.

**Setup:**

1. In Firebase Console > Project Settings > **Service accounts** > **Generate new private key**
2. In your GitHub repo > Settings > Secrets and variables > Actions:
   - Add secret: `FIREBASE_SERVICE_ACCOUNT` — paste the entire JSON key file contents
   - Add variable: `FIREBASE_PROJECT_ID` — your project ID (e.g., `my-qr-tracker`)

That's it. Every push to `main` auto-deploys.

## Preview Before Going Live

Firebase supports preview channels for testing without affecting production:

```bash
# Deploy to a temporary preview URL
firebase hosting:channel:deploy preview

# This gives you a URL like:
# https://my-qr-tracker--preview-xxxxxxx.web.app
```

## Custom Domain (Optional)

1. In Firebase Console > Hosting > **Add custom domain**
2. Enter your domain (e.g., `go.yourbrand.com`)
3. Add the DNS records Firebase provides
4. SSL is provisioned automatically (may take up to 24h)

Your QR codes would then use `https://go.yourbrand.com/?r=menu&utm_source=...`

## Limits and Costs

| Resource | Free Tier | What Happens if Exceeded |
|----------|-----------|-------------------------|
| Firebase bandwidth | 10 GB/month (~5M scans) | Site goes offline until next month |
| Firebase storage | 10 GB | Cannot deploy new versions |
| GA4 events | 10M/month | Data may be sampled |
| GA4 data retention | 14 months (configurable) | Older event-level data expires |

**To remove the bandwidth risk:** upgrade to Firebase Blaze plan (pay-as-you-go). You still get 10 GB free, then pay $0.15/GB. A credit card is required but you won't be charged unless you exceed 10 GB.

## Known Limitations

- **Ad blockers**: ~10-20% of mobile users block GA4, causing undercount
- **Reporting delay**: GA4 detailed reports take 24-48 hours to populate
- **GDPR (EU users)**: You should add a cookie consent banner if your audience is in the EU
- **No server-side routing**: All routes are defined in the client-side JavaScript. For dynamic server-side routing, you would need Firebase Cloud Functions (adds complexity)

## Useful Commands

```bash
# Login
firebase login

# Deploy to production
firebase deploy --only hosting

# Deploy to preview channel
firebase hosting:channel:deploy preview

# List active channels
firebase hosting:channel:list

# Delete a preview channel
firebase hosting:channel:delete preview

# View deploy history
firebase hosting:releases:list
```
