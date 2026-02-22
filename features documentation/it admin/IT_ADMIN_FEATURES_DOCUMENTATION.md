# IT ADMIN ROLE - COMPREHENSIVE FEATURES DOCUMENTATION

## Table of Contents
1. [Overview](#overview)
2. [Dashboard & Main Navigation](#dashboard--main-navigation)
3. [System Health Monitoring](#system-health-monitoring)
4. [Server Management](#server-management)
5. [Security & Logging](#security--logging)
6. [Backup & Disaster Recovery](#backup--disaster-recovery)
7. [API Management](#api-management)
8. [Alert Management](#alert-management)
9. [Integration Management](#integration-management)
10. [AI Model Settings](#ai-model-settings)
11. [Error Logs & Monitoring](#error-logs--monitoring)
12. [Performance Reports](#performance-reports)
13. [Database Management](#database-management)
14. [Cloud Services](#cloud-services)
15. [System Settings](#system-settings)
16. [Profile Management](#profile-management)
17. [Search Functionality](#search-functionality)
18. [Feature Status Summary](#feature-status-summary)

---

## Overview

The IT Admin Role in EduVerse provides a specialized technical administration platform focused on infrastructure management, system monitoring, security operations, and technical configuration. This role is designed for IT professionals responsible for maintaining the technical health, security, and performance of the entire EduVerse platform.

**Total Screens**: 18+ dedicated IT admin screens  
**Custom Widgets**: 75+ specialized IT widgets  
**Navigation Categories**: 4 (Main Menu, Monitoring, Infrastructure, Account)  
**Widget Files**: ~150 files total

**Demo Credentials**:
- **Email**: `itadmin@eduverse.dev`
- **Password**: `ITAdmin@123`
- **User ID**: 5001
- **Status**: ACTIVE

### IT Admin vs Regular Admin

The IT Admin role differs from the regular Admin role in several key ways:

**IT Admin Focus**:
- Infrastructure and system-level operations
- Technical monitoring and performance tuning
- Security operations and threat detection
- API and integration management
- Database administration
- AI model configuration
- Disaster recovery and backup operations
- Low-level system settings

**Regular Admin Focus**:
- User management and permissions
- Course and academic content management
- Department organization
- Payment and subscription management
- Student/instructor communications
- Academic reporting and analytics
- High-level platform configuration

**IT Admin Capabilities Overview**:
- Real-time system health monitoring
- Server infrastructure management
- Advanced security logging and threat detection
- Comprehensive backup and disaster recovery
- API endpoint management and monitoring
- Alert rules and escalation policies
- Third-party integration management
- AI provider and model configuration
- Database performance monitoring
- Cloud service management and cost tracking
- Error log analysis
- Performance analytics and optimization
- System-level settings and configuration

---

## Dashboard & Main Navigation

### 1. IT Admin Dashboard Screen
**Route**: `/it-admin/dashboard`  
**File**: `lib/screens/it_admin/it_admin_dashboard_screen.dart`

#### Features:

- **IT Admin App Bar**:
  - Platform title and branding
  - Quick actions toolbar
  - Theme toggle (light/dark mode)
  - Notification bell with badge
  - Search icon
  - Profile avatar
  - Hamburger menu for drawer

- **System Metrics Grid** (8 key metrics):
  
  **1. CPU Usage**:
  - Current: 52.0%
  - Circular progress indicator
  - Color-coded (green: <70%, yellow: 70-85%, red: >85%)
  - Icon: memory_rounded
  - Real-time monitoring

  **2. Memory Usage**:
  - Current: 71.0%
  - Progress visualization
  - Trend indicator
  - Warning threshold at 85%
  - Icon: storage_rounded

  **3. Disk Usage**:
  - Current: 67.0%
  - Available space display
  - Total capacity shown
  - Cleanup suggestions when high
  - Icon: sd_storage_rounded

  **4. Network Usage**:
  - Current: 45.0%
  - Bandwidth utilization
  - In/Out traffic display
  - Latency metrics
  - Icon: wifi_rounded

  **5. API Latency**:
  - Current: 127ms
  - Average response time
  - P95/P99 percentiles
  - SLA compliance indicator
  - Icon: speed_rounded

  **6. System Uptime**:
  - Current: 99.94%
  - Days/hours/minutes display
  - Uptime history chart
  - SLA target comparison
  - Icon: timer_rounded

  **7. Active Incidents**:
  - Count: 2
  - Critical/High/Medium breakdown
  - Quick link to incidents
  - Time since last incident
  - Icon: warning_rounded

  **8. Database Connections**:
  - Active: 156
  - Max connections: 200
  - Connection pool status
  - Query performance metrics
  - Icon: storage_rounded

- **System Status Section**:
  - Service status cards (4 services):
    
    **1. API Gateway**:
    - Status: Operational (green)
    - Icon: api_rounded
    - Status text display
    - Click for details

    **2. Authentication Service**:
    - Status: Operational (green)
    - Icon: lock_rounded
    - Auth metrics
    - Health check status

    **3. Database**:
    - Status: Operational (green)
    - Icon: storage_rounded
    - Connection status
    - Replication lag

    **4. Storage Service**:
    - Status: Degraded (yellow)
    - Icon: sd_storage_rounded
    - Performance warning
    - Investigation status

  - Color-coded status indicators
  - Last check timestamp
  - Quick actions per service

- **Incidents Section**:
  - Active incidents list
  - Each incident shows:
    - ID and title
    - Priority badge (Critical/High/Medium/Low):
      - Critical: Red background
      - High: Orange background
      - Medium: Yellow background
      - Low: Blue background
    - Affected service
    - Description
    - Time elapsed
    - Current status:
      - Investigating (yellow)
      - Identified (blue)
      - Monitoring (purple)
      - Resolved (green)
    - Assigned team/person
    - Actions: View Details, Update Status, Add Note

  **Sample Incidents**:
  1. "High memory usage on API server" (High priority, Investigating)
     - Service: API Gateway
     - Description: "API server memory usage exceeded 85% threshold. Auto-scaling triggered."
     - Time: 15 min ago

  2. "Storage service degraded performance" (Medium priority, Investigating)
     - Service: Storage
     - Description: "File upload latency increased by 200%. Investigation ongoing."
     - Time: 45 min ago

- **Server Status Section**:
  - List of monitored servers (4+ servers):
    
    **Server Cards Display**:
    - Server name
    - Server type (Application/Database/Cache/Load Balancer)
    - Status badge (Operational/Degraded/Down)
    - CPU usage with progress bar
    - Memory usage with progress bar
    - Disk usage with progress bar
    - Uptime duration
    - Quick action buttons

  **Sample Servers**:
  1. API Server 01
     - Type: Application Server
     - Status: Operational
     - CPU: 52%, Memory: 71%, Disk: 45%
     - Uptime: 45 days

  2. Database Primary
     - Type: Database Server
     - Status: Operational
     - CPU: 38%, Memory: 82%, Disk: 67%
     - Uptime: 120 days

  3. Redis Cache
     - Type: Cache Server
     - Status: Operational
     - CPU: 15%, Memory: 45%, Disk: 12%
     - Uptime: 90 days

  4. Load Balancer
     - Type: Load Balancer
     - Status: Operational
     - CPU: 22%, Memory: 35%, Disk: 8%
     - Uptime: 180 days

- **Recent Activity Feed**:
  - Live activity timeline
  - Activity types:
    - Server events
    - Deployment notifications
    - Configuration changes
    - Security events
    - Backup completions
    - Alert triggers
  - Each activity shows:
    - Icon based on type
    - Activity description
    - Timestamp
    - User/system who performed action
    - Related service
  - Auto-refresh every 30 seconds
  - "View All Activity" link

- **Alerts Section**:
  - Active alerts display
  - Each alert shows:
    - Severity level (Critical/Warning/Info)
    - Alert rule name
    - Triggered condition
    - Time triggered
    - Affected resource
    - Action buttons: Acknowledge, Resolve, Snooze
  - Filter by severity
  - Badge count on high-priority alerts

- **Quick Actions Grid**:
  - 6-8 quick action buttons:
    - Restart Service
    - Clear Cache
    - Run Health Check
    - View Logs
    - Backup Now
    - Deploy Update
    - Generate Report
    - Open Terminal
  - Each with icon and label
  - Confirmation required for destructive actions
  - Access control based on permissions

- **Refresh & Auto-Refresh**:
  - Manual refresh button
  - Auto-refresh toggle
  - Refresh intervals: 10s, 30s, 1min, 5min
  - Last updated timestamp

**Current Status**: ✅ Fully functional with comprehensive dashboard  
**Backend Integration**: 🔶 Partial - Uses mock data with 500ms loading delay

---

### 2. IT Admin Drawer (Navigation Menu)
**File**: `lib/widgets/it_admin/shared/it_drawer.dart`

#### Header Section:

- **Profile Header**:
  - IT Admin icon with cyan gradient (🖥️ computer icon)
  - Green online status indicator
  - IT role badge: "🖥️ IT System Admin"
  - Close button
  - Gradient background (cyan tones)

- **Quick Stats Section**:
  - 3 key metrics in compact card:
    - **Uptime**: 99.9%
    - **Incidents**: 2 active
    - **Servers**: 8 total
  - Icon for each stat
  - Gradient background
  - Dividers between stats

#### Main Menu Section (8 items):

1. **Dashboard**
   - Route: `/it-admin/dashboard`
   - Returns to main IT admin dashboard
   - Icon: space_dashboard_rounded
   
2. **System Health**
   - Route: `/it-admin/system-health`
   - Real-time system monitoring
   - Health metrics and alerts
   - Icon: monitor_heart

3. **Server Management**
   - Route: `/it-admin/servers`
   - Manage all servers
   - Server monitoring and control
   - Icon: dns

4. **Security Logs**
   - Route: `/it-admin/security-logs`
   - View security events
   - Access logs and threat detection
   - Icon: security

5. **Backup & Recovery**
   - Route: `/it-admin/backup`
   - Backup management
   - Disaster recovery planning
   - Icon: backup

6. **API Management**
   - Route: `/it-admin/api`
   - API endpoints and keys
   - API monitoring and analytics
   - Icon: api

7. **Integrations**
   - Route: `/it-admin/integrations`
   - Third-party service integrations
   - Connection management
   - Icon: hub

8. **AI Model Settings**
   - Route: `/it-admin/ai-settings`
   - Configure AI providers
   - Model selection and API keys
   - Icon: psychology

#### Monitoring Section (3 items):

1. **Error Logs**
   - Route: `/it-admin/logs`
   - Application error tracking
   - Stack traces and debugging
   - Icon: bug_report

2. **Performance**
   - Route: `/it-admin/performance`
   - Performance metrics and reports
   - Resource utilization analytics
   - Icon: analytics

3. **Alerts**
   - Route: `/it-admin/alerts`
   - Alert rules and notifications
   - Escalation policies
   - Badge: Shows active alert count (e.g., "3")
   - Icon: notifications

#### Infrastructure Section (2 items):

1. **Database**
   - Route: `/it-admin/database`
   - Database management
   - Query performance monitoring
   - Icon: storage

2. **Cloud Services**
   - Route: `/it-admin/cloud`
   - Cloud provider management
   - Cost tracking and optimization
   - Icon: cloud

#### Account Section (3 items):

1. **Account Settings**
   - Route: `/it-admin/account-settings`
   - IT admin account preferences
   - Notification settings
   - Icon: settings

2. **Profile**
   - Route: `/it-admin/profile`
   - View IT admin profile
   - Activity history
   - Icon: person

3. **Education System Settings**
   - Route: `/it-admin/settings`
   - Platform-wide system settings
   - Technical configuration
   - Icon: admin_panel_settings

#### Navigation Features:
- Active route highlighting
- Smooth animations
- Badge support for notification counts
- Category labels (Main Menu, Monitoring, Infrastructure, Account)
- Collapsible sections
- Keyboard navigation support
- Theme-aware design

**Current Status**: ✅ Fully functional navigation  
**Backend Integration**: ✅ Complete - Proper routing with GoRouter

---

## System Health Monitoring

### 3. System Health Screen
**Route**: `/it-admin/system-health`  
**File**: `lib/screens/it_admin/it_system_health_screen.dart`

#### Features:

- **Overall Health Overview Card**:
  - **System Health Score**: 98.5/100
  - Large circular gauge with color gradient
  - Overall status badge:
    - Operational (green): 95-100
    - Degraded (yellow): 80-94
    - Critical (red): <80
  - Last assessment time
  - Trend indicator (improving/stable/declining)

- **Health Metrics Grid** (6 key metrics):

  **1. CPU Usage**:
  - Current value: 52.0%
  - Max value: 100%
  - Unit: %
  - Status: Operational
  - Trend: ↓ 5% (decreasing)
  - Icon: memory_rounded
  - Mini history chart (last 6 data points): [45, 52, 48, 55, 50, 52]
  - Color-coded progress bar

  **2. Memory Usage**:
  - Current: 71.0%
  - Max: 100%
  - Status: Operational
  - Trend: ↑ 3% (increasing)
  - Icon: storage_rounded
  - History: [65, 68, 70, 69, 71, 71]
  - Warning threshold: 85%

  **3. Disk Usage**:
  - Current: 45.0%
  - Max: 100%
  - Status: Operational
  - Trend: → 0% (stable)
  - Icon: sd_storage_rounded
  - History: [44, 44, 45, 45, 45, 45]
  - Total capacity shown

  **4. Network Throughput**:
  - Current: 125.0 Mbps
  - Max: 1000 Mbps
  - Status: Operational
  - Trend: ↑ 12% (increasing)
  - Icon: wifi_rounded
  - History: [100, 110, 115, 120, 122, 125]
  - Peak usage indicator

  **5. API Latency**:
  - Current: 45.0ms
  - Max acceptable: 200ms
  - Status: Operational
  - Trend: ↓ 8% (decreasing - good)
  - Icon: speed_rounded
  - History: [50, 48, 47, 46, 45, 45]
  - SLA compliance: ✓

  **6. System Uptime**:
  - Current: 99.9%
  - Target: 99.9%
  - Status: Operational
  - Trend: → Stable
  - Icon: timer_rounded
  - History: [99.9, 99.9, 99.9, 99.9, 99.9, 99.9]
  - Days without incident: 45

  - Each metric card shows:
    - Metric name and icon
    - Current value with unit
    - Visual progress indicator
    - Status badge
    - Trend arrow and percentage
    - Sparkline chart (mini history)
    - Click to expand for details

- **Services Status Section**:
  - List of all platform services
  - Each service card displays:
    - Service name
    - Service description
    - Status indicator:
      - Operational (green)
      - Degraded (yellow)
      - Partial Outage (orange)
      - Major Outage (red)
      - Maintenance (blue)
    - Uptime percentage
    - Last health check timestamp
    - Icon representing service type
    - Expandable for more details

  **Sample Services**:
  1. API Gateway
     - Status: Operational
     - Description: "Main API entry point"
     - Last check: 2 min ago
     - Uptime: 99.99%

  2. Authentication Service
     - Status: Operational
     - Description: "User authentication & authorization"
     - Last check: 2 min ago
     - Uptime: 99.98%

  3. Database Primary
     - Status: Operational
     - Description: "Primary PostgreSQL database"
     - Last check: 1 min ago
     - Uptime: 100%

  4. Cache Service
     - Status: Operational
     - Description: "Redis caching layer"
     - Last check: 2 min ago
     - Uptime: 99.97%

  5. Storage Service
     - Status: Degraded
     - Description: "File storage and CDN"
     - Last check: 5 min ago
     - Uptime: 98.50%
     - Warning: "High latency detected"

  6. Email Service
     - Status: Operational
     - Description: "Email notification service"
     - Last check: 3 min ago
     - Uptime: 99.95%

- **Health Alerts Section**:
  - Active health-related alerts
  - Each alert shows:
    - Severity (Critical/Warning/Info)
    - Alert message
    - Affected component
    - Time triggered
    - Recommended action
    - Acknowledge button
  - Filter by severity
  - Sort by time or priority

- **Health Trends Chart**:
  - Line graph showing system health over time
  - Time ranges: 1 hour, 6 hours, 24 hours, 7 days, 30 days
  - Multiple metrics on same chart
  - Toggle metrics visibility
  - Zoom and pan controls
  - Export chart as image

- **Quick Health Actions**:
  - Run Full Health Check
  - Generate Health Report
  - View Historical Data
  - Configure Thresholds
  - Set Up Alerts
  - Each action with confirmation

- **Filter Options**:
  - Filter by status (All/Operational/Degraded/Critical)
  - Filter by service type
  - Search by service name
  - Show/hide historical data

- **Auto-Refresh**:
  - Real-time updates every 30 seconds
  - Manual refresh button
  - Last updated timestamp
  - Refresh indicator animation

**Current Status**: ✅ Fully functional with comprehensive health monitoring  
**Backend Integration**: 🔶 Partial - Uses mock data, ready for real metrics integration

---

## Server Management

### 4. Server Management Screen
**Route**: `/it-admin/servers`  
**File**: `lib/screens/it_admin/it_server_management_screen.dart`

#### Features:

- **Server Statistics Overview**:
  - Total Servers count
  - Operational servers count
  - Servers with warnings
  - Servers down/offline
  - Average CPU usage across all servers
  - Average memory usage
  - Total storage capacity
  - Network throughput

- **Server List Display**:
  - Grid or list view toggle
  - Each server card shows:
    - Server name (e.g., "api-server-01")
    - Server type:
      - Application Server
      - Database Server
      - Cache Server
      - Load Balancer
      - Web Server
      - File Server
      - Mail Server
    - Status badge with color:
      - Operational (green)
      - Warning (yellow)
      - Critical (red)
      - Offline (gray)
      - Maintenance (blue)
    - Operating System (Linux/Windows/macOS)
    - Hostname/IP address
    - Location/Data center
    - Resource metrics:
      - CPU usage (percentage + bar)
      - Memory usage (percentage + bar)
      - Disk usage (percentage + bar)
      - Network I/O (Mbps)
    - Uptime duration
    - Last heartbeat timestamp
    - Quick action buttons

- **Resource Utilization Charts**:
  - Real-time CPU usage graph
  - Memory usage over time
  - Disk I/O statistics
  - Network traffic (in/out)
  - Time range selector (1h, 6h, 24h, 7d)
  - Compare multiple servers

- **Server Actions**:
  - **View Details**: Opens detailed server view with:
    - Full specifications
    - Installed services
    - Process list
    - Network connections
    - System logs
    - Performance history
  - **Restart Server**: 
    - Confirmation required
    - Graceful restart option
    - Force restart option
    - Restart specific services
  - **Stop/Start**:
    - Start stopped servers
    - Stop running servers
    - Schedule maintenance window
  - **Update Server**:
    - OS updates
    - Security patches
    - Software updates
    - Update schedule
  - **Run Diagnostics**:
    - Health check
    - Connectivity test
    - Performance benchmark
    - Security scan
  - **Access SSH Terminal**: 
    - Web-based SSH client
    - Secure connection
    - Command history
  - **View Logs**: 
    - System logs
    - Application logs
    - Error logs
    - Access logs
    - Filter and search
  - **Configure**: 
    - Edit server settings
    - Update environment variables
    - Modify resource limits
    - Configure monitoring

- **Bulk Operations**:
  - Select multiple servers
  - Bulk actions:
    - Update all selected
    - Restart selected servers
    - Change status
    - Run health checks
    - Generate reports
    - Tag servers
    - Move to maintenance

- **Filter & Search**:
  - Search by server name, IP, or hostname
  - Filter by:
    - Server type
    - Status
    - Location/Data center
    - Operating system
    - Resource usage (high CPU, low memory, etc.)
    - Tags
  - Sort by:
    - Name (A-Z)
    - Status
    - CPU usage (high to low)
    - Memory usage
    - Uptime
    - Last updated

- **Server Groups**:
  - Group servers by:
    - Environment (Production/Staging/Development)
    - Application
    - Location
    - Custom tags
  - Manage group settings
  - Bulk operations on groups

- **Server Provisioning**:
  - Add new server:
    - Manual entry
    - Auto-discovery
    - Import from cloud provider
  - Server templates
  - Configuration presets
  - Automated setup scripts

- **Monitoring Alerts**:
  - Set up alerts for:
    - CPU threshold exceeded
    - Memory usage high
    - Disk space low
    - Server unresponsive
    - Service down
  - Alert notification channels
  - Escalation policies

- **Server Metrics Export**:
  - Export server data
  - Format: CSV, JSON, Excel
  - Custom date range
  - Selected metrics
  - Scheduled exports

**Current Status**: 🔶 UI structure exists with comprehensive features  
**Backend Integration**: ⚠️ Future implementation - Needs server monitoring API integration

---

## Security & Logging

### 5. Security Logs Screen
**Route**: `/it-admin/security-logs`  
**File**: `lib/screens/it_admin/it_security_logs_screen.dart`

#### Features:

- **Tab Navigation** (Main tabs):
  - **Security Logs**: Detailed log entries
  - **Active Incidents**: Security incidents in progress
  - **Access Requests**: Permission/access requests
  - **Policies**: Security policies and rules
  - **AI Insights**: AI-powered security analysis

- **Security Statistics Cards**:
  - **Total Log Entries**: Count today
  - **Critical Events**: High-risk events
  - **Flagged Activities**: Suspicious activities flagged
  - **Blocked Attempts**: Login/access attempts blocked
  - **AI Threat Score**: 0-100 risk score
  - Trend indicators (up/down/stable)
  - Time period selector

- **Security Logs Tab**:

  **Filter Options**:
  - Search by user, email, IP, or event
  - Event Type filter (dropdown):
    - All Events
    - Login Success
    - Login Failed
    - Logout
    - Password Change
    - Permission Change
    - Data Access
    - Data Modification
    - API Access
    - Security Settings Changed
    - Account Locked
    - Account Unlocked
    - 2FA Enabled/Disabled
    - Suspicious Activity
    - Breach Attempt
    - Brute Force Detected
  - Risk Level filter:
    - All
    - Low (green)
    - Medium (yellow)
    - High (orange)
    - Critical (red)
  - Date range picker
  - Toggle: Show Flagged Only
  - Toggle: Show High-Risk Only
  - Location filter
  - Device/Browser filter

  **Log Entry Table**:
  Columns:
  - Timestamp (sortable)
  - User Name
  - User Email
  - Event Type (color-coded badge)
  - IP Address
  - Location (city, country)
  - Device/Browser
  - Risk Level (badge with color)
  - Flagged indicator (🚩 if flagged)
  - Actions (View Details, Flag, Block IP, Block User)

  **Sample Log Entries**:
  1. john.doe@EduVerse.edu - Login Success - 5 min ago
     - IP: 192.168.1.45
     - Location: Los Angeles, US
     - Device: Chrome on Windows
     - Risk: Low

  2. attacker@malicious.com - Breach Attempt - 12 min ago 🚩
     - IP: 45.142.212.81
     - Location: Unknown
     - Device: Unknown
     - Risk: Critical
     - Auto-flagged by AI

  3. kate.smith@EduVerse.edu - Permission Change - 30 min ago
     - IP: 192.168.1.102
     - Location: Los Angeles, US
     - Device: Safari on macOS
     - Risk: Medium

  4. api_service_01 - API Access - 1 hour ago
     - IP: 10.0.0.63
     - Device: API Client
     - Risk: Low

  5. suspicious@unknown.com - Login Failed - 2 hours ago 🚩
     - IP: 45.142.212.81
     - Location: Unknown
     - Device: Unknown
     - Risk: High
     - Multiple failed attempts

  - Expandable rows for full details
  - Color-coded risk levels
  - Hover for additional info
  - Click to view full event details

  **Log Entry Detail Sheet**:
  - Full event information
  - Complete user details
  - Full IP address and geolocation
  - Device fingerprint
  - Request headers
  - Response status
  - Related events timeline
  - Similar events from same IP/user
  - Actions:
    - Flag/Unflag
    - Block IP
    - Block User
    - Add to whitelist
    - Add note
    - Escalate to incident
    - Export entry

- **Active Incidents Tab**:
  - List of ongoing security incidents
  - Each incident shows:
    - Incident ID
    - Title and description
    - Severity (Critical/High/Medium/Low)
    - Status (New/Investigating/Contained/Resolved)
    - Affected users/systems
    - Detection time
    - Assigned investigator
    - Timeline of events
    - Related log entries
    - Actions taken
    - Next steps
  - Update incident status
  - Add investigation notes
  - Assign/reassign investigator
  - Mark as resolved
  - Generate incident report

- **Access Requests Tab**:
  - Pending access/permission requests
  - Each request shows:
    - Requester name and email
    - Requested resource/permission
    - Justification/reason
    - Request time
    - Approver assignment
    - Status (Pending/Approved/Denied)
    - Risk assessment
  - Actions:
    - Approve request
    - Deny request
    - Request more info
    - Escalate request
    - Set expiration date

- **Security Policies Tab**:
  - List of configured security policies
  - Policy categories:
    - Password policies
    - Session policies
    - Access control policies
    - Data protection policies
    - API security policies
    - Network security policies
  - Each policy shows:
    - Policy name
    - Description
    - Enabled/Disabled status
    - Last modified
    - Affected users/systems
  - Edit policy
  - Enable/disable policy
  - Test policy
  - View policy violations

  **Role Permissions Section**:
  - View permissions by role
  - Permission matrix display
  - Roles:
    - Student
    - Instructor
    - TA
    - Admin
    - IT Admin
  - Permission categories:
    - System Access
    - Data Access
    - API Access
    - Configuration Access
    - User Management
    - Content Management
  - Color-coded permission levels:
    - Full Access (green)
    - Limited Access (yellow)
    - No Access (gray)
  - Edit permissions
  - Audit permission changes

- **AI Security Insights Tab**:
  - AI-generated security insights
  - Threat intelligence
  - Anomaly detection results
  - Pattern recognition alerts
  - Predictive risk assessment
  - Recommendations:
    - "Multiple failed logins from IP X - possible brute force"
    - "Unusual access pattern detected for user Y"
    - "High-risk country access detected"
    - "Suspicious API usage pattern"
  - Confidence score for each insight
  - False positive feedback
  - Action recommendations
  - Trending threats

- **Recent Security Actions Section**:
  - Timeline of security actions taken
  - Actions include:
    - IP addresses blocked
    - Users suspended
    - Policies updated
    - Alerts triggered
    - Incidents created
    - Access revoked
  - Who performed action
  - When action occurred
  - Reason for action
  - Undo action (if applicable)

- **Export & Reporting**:
  - Export logs (CSV, JSON, PDF)
  - Date range selection
  - Filter criteria included
  - Generate security report:
    - Executive summary
    - Detailed analysis
    - Incident breakdown
    - Recommendations
    - Compliance checklist
  - Schedule automated reports
  - Email reports to stakeholders

- **Real-Time Monitoring**:
  - Live log feed
  - Auto-refresh (10s, 30s, 1min)
  - Desktop notifications for critical events
  - Sound alerts (optional)
  - WebSocket connection for real-time updates

**Current Status**: ✅ Fully functional security logging UI  
**Backend Integration**: 🔶 Partial - Uses mock data, needs real security logging backend

---

## Backup & Disaster Recovery

### 6. Backup & Recovery Screen
**Route**: `/it-admin/backup`  
**File**: `lib/screens/it_admin/it_backup_screen.dart`

#### Features:

- **Tab Navigation** (4 main tabs):
  - **Backup Jobs**: Active and scheduled backups
  - **Restore Points**: Available restore points
  - **Disaster Recovery**: DR planning and runbooks
  - **Settings**: Backup configuration

- **Backup Statistics Overview**:
  - Total backups completed (today/week/month)
  - Total storage used
  - Success rate percentage
  - Last successful backup time
  - Next scheduled backup
  - Failed backups count
  - Average backup duration
  - Backup trend chart

- **Backup Jobs Tab**:

  **Job Filter Options**:
  - Filter by backup type:
    - All
    - Full Backup
    - Incremental
    - Differential
    - Snapshot
    - Archive
  - Filter by status:
    - All
    - Running
    - Completed
    - Failed
    - Scheduled
    - Paused
  - Search by job name
  - Sort by: Name, Start Time, Duration, Size, Status

  **Backup Job Cards**:
  Each job displays:
  - Job name (e.g., "Production Database")
  - Backup type badge:
    - Full (blue)
    - Incremental (green)
    - Differential (yellow)
    - Snapshot (purple)
    - Archive (gray)
  - Status badge:
    - Completed (green) ✓
    - Running (blue) ⟳ with progress %
    - Failed (red) ✗ with error
    - Scheduled (gray) 🕒 with time
  - Start time and end time (if completed)
  - Duration (minutes/hours)
  - Backup size (GB/TB)
  - Target storage location
  - Progress bar (for running jobs)
  - Error message (if failed)
  - Actions: View Details, Retry (if failed), Cancel (if running), Delete

  **Sample Backup Jobs**:
  1. Production Database
     - Type: Full Backup
     - Status: Completed ✓
     - Started: 2 hours ago
     - Ended: 1h 45min ago
     - Duration: 15 minutes
     - Size: 256.8 GB
     - Target: AWS S3 - Primary

  2. User Files Storage
     - Type: Incremental
     - Status: Running ⟳ 67%
     - Started: 15 min ago
     - Size: 42.3 GB (so far)
     - Target: Azure Blob Storage
     - Progress bar

  3. Application Logs
     - Type: Incremental
     - Status: Completed ✓
     - Started: 4 hours ago
     - Duration: 10 minutes
     - Size: 8.2 GB
     - Target: AWS S3 - Logs

  4. VM Snapshot - Web Server
     - Type: Snapshot
     - Status: Failed ✗
     - Started: 6 hours ago
     - Size: 128.0 GB
     - Target: Local Storage
     - Error: "Disk space insufficient on target"
     - Retry button

  5. Config Archive
     - Type: Archive
     - Status: Scheduled 🕒
     - Scheduled: In 2 hours
     - Est. Size: 2.5 GB
     - Target: AWS S3 - Archive

  **Job Actions**:
  - Run backup immediately
  - Schedule new backup
  - Edit backup job
  - Pause/Resume job
  - Delete backup job
  - View backup history
  - Clone backup configuration

  **Create Backup Dialog**:
  - Backup name
  - Backup type selection
  - Source selection (database, files, VM, etc.)
  - Target storage selection
  - Scheduling options:
    - One-time (run now)
    - Daily (time selection)
    - Weekly (day + time)
    - Monthly (date + time)
    - Custom cron expression
  - Retention policy
  - Compression level
  - Encryption (enable/disable)
  - Notification settings
  - Pre/Post backup scripts

- **Restore Points Tab**:
  - List of available restore points
  - Each restore point shows:
    - Backup name
    - Backup date/time
    - Backup type
    - Backup size
    - Storage location
    - Verification status (verified/not verified)
    - Retention expiry date
    - Data integrity status
    - Actions: Restore, Download, Verify, Delete

  **Restore Operations**:
  - Select restore point
  - Restore options:
    - Full restore (replace everything)
    - Partial restore (select items)
    - Restore to different location
    - Test restore (non-destructive)
  - Restore target selection
  - Pre-restore validation
  - Restore progress tracking
  - Post-restore verification
  - Rollback if restore fails

- **Disaster Recovery Tab**:

  **DR Runbooks Section**:
  - Documented DR procedures
  - Each runbook shows:
    - Runbook name (e.g., "Database Failure Recovery")
    - Scenario description
    - Severity level
    - Estimated recovery time (ERT)
    - Recovery point objective (RPO)
    - Step-by-step procedures
    - Required resources
    - Contact list
    - Last tested date
    - Test result
  - Actions: Execute, Test, Edit, Download

  **Sample DR Runbooks**:
  1. Complete Database Failure
     - Severity: Critical
     - ERT: 30 minutes
     - RPO: 15 minutes
     - 8 steps documented
     - Last tested: 15 days ago
     - Status: Tested Successfully

  2. Application Server Crash
     - Severity: High
     - ERT: 15 minutes
     - RPO: 5 minutes
     - 6 steps documented
     - Last tested: 30 days ago

  3. Storage System Failure
     - Severity: Critical
     - ERT: 1 hour
     - RPO: 1 hour
     - 10 steps documented
     - Last tested: 45 days ago

  **DR Testing**:
  - Schedule DR drills
  - Run test scenarios
  - Document test results
  - Identify gaps
  - Update procedures
  - Generate test reports

  **DR Metrics**:
  - Current RTO (Recovery Time Objective)
  - Current RPO (Recovery Point Objective)
  - Time since last DR test
  - DR drill success rate
  - Mean time to recovery (MTTR)
  - Backup recovery success rate

- **Storage Distribution Section**:
  - Visual representation of backup storage
  - Breakdown by:
    - Backup type
    - Storage location
    - Age (recent vs. archive)
    - Data source
  - Pie chart or bar chart
  - Storage cost breakdown
  - Storage optimization suggestions

- **Integrity Check Section**:
  - Scheduled integrity checks
  - Last verification results
  - Failed integrity checks
  - Checksum verification
  - Data corruption detection
  - Auto-repair options

- **Alert Settings Section**:
  - Configure backup alerts:
    - Backup failed
    - Backup taking too long
    - Storage space low
    - Integrity check failed
    - Retention policy expiring
  - Alert channels:
    - Email
    - SMS
    - Slack
    - PagerDuty
    - Webhook
  - Alert recipients
  - Escalation policies
  - Quiet hours

- **AI Recommendations Section**:
  - AI-powered backup insights:
    - "Increase backup frequency for database X"
    - "Storage optimization: Archive old backups"
    - "Redundancy recommendation: Add secondary backup location"
    - "Cost optimization: Move cold data to cheaper storage"
  - Recommendations prioritized by impact
  - Accept/dismiss recommendations
  - Track implemented recommendations

- **Backup Settings Tab**:
  - Default backup location
  - Storage providers configuration:
    - Local storage path
    - AWS S3 (bucket, credentials)
    - Azure Blob Storage
    - Google Cloud Storage
    - FTP/SFTP
  - Encryption settings:
    - Encryption algorithm
    - Key management
    - Enable/disable encryption
  - Compression settings:
    - Compression level (0-9)
    - Compression algorithm
  - Retention policies:
    - Keep last N backups
    - Keep daily/weekly/monthly snapshots
    - Delete after X days
    - Archive old backups
  - Verification settings:
    - Auto-verify after backup
    - Verification schedule
    - Checksum algorithm
  - Bandwidth limits:
    - Throttle backup uploads
    - Schedule high-bandwidth operations
  - Email notifications:
    - Notify on success
    - Notify on failure
    - Daily summary
    - Weekly report

**Current Status**: ✅ Fully functional backup management UI  
**Backend Integration**: 🔶 Partial - Uses mock data, needs backup system implementation

---

## API Management

### 7. API Management Screen
**Route**: `/it-admin/api`  
**File**: `lib/screens/it_admin/it_api_management_screen.dart`

#### Features:

- **Tab Navigation** (2 tabs):
  - **API Endpoints**: Endpoint monitoring and management
  - **API Keys**: API key management and access control

- **API Statistics Overview**:
  - Total endpoints count
  - Active API keys
  - Requests today
  - Average response time
  - Success rate percentage
  - Error rate
  - P95 latency
  - API calls trend chart

- **API Endpoints Tab**:

  **Endpoint List Display**:
  Each endpoint card shows:
  - Endpoint name (e.g., "Get User Profile")
  - HTTP method badge:
    - GET (blue)
    - POST (green)
    - PUT (orange)
    - DELETE (red)
    - PATCH (yellow)
  - Endpoint path (e.g., "/api/v1/users/{id}")
  - API version (e.g., "v1")
  - Status badge:
    - Operational (green)
    - Degraded (yellow)
    - Deprecated (gray)
    - Disabled (red)
  - Metrics:
    - Requests today
    - Average response time (ms)
    - Success rate (%)
    - Rate limit (requests/min)
  - Mini sparkline chart
  - Actions: View Details, Edit, Disable

  **Sample API Endpoints**:
  1. Get User Profile
     - Method: GET
     - Path: /api/v1/users/{id}
     - Version: v1
     - Status: Operational
     - Requests today: 15,420
     - Avg response: 45ms
     - Success rate: 99.8%
     - Rate limit: 1000/min

  2. Create Course
     - Method: POST
     - Path: /api/v1/courses
     - Version: v1
     - Status: Operational
     - Requests today: 3,250
     - Avg response: 120ms
     - Success rate: 99.5%
     - Rate limit: 500/min

  3. Update Assignment
     - Method: PUT
     - Path: /api/v1/assignments/{id}
     - Version: v1
     - Status: Operational
     - Requests today: 8,900
     - Avg response: 85ms
     - Success rate: 99.2%
     - Rate limit: 750/min

  4. Delete Submission
     - Method: DELETE
     - Path: /api/v1/submissions/{id}
     - Version: v1
     - Status: Operational
     - Requests today: 450
     - Avg response: 35ms
     - Success rate: 100%
     - Rate limit: 200/min

  5. Get Grades (Legacy)
     - Method: GET
     - Path: /api/v0/grades
     - Version: v0
     - Status: Deprecated
     - Requests today: 120
     - Avg response: 200ms
     - Success rate: 95.0%
     - Rate limit: 100/min
     - Warning: "Deprecated - migrate to v1"

  6. Batch Upload
     - Method: POST
     - Path: /api/v1/batch/upload
     - Version: v1
     - Status: Degraded
     - Requests today: 890
     - Avg response: 2500ms (high!)
     - Success rate: 92.5%
     - Rate limit: 50/min
     - Alert: "High latency detected"

  **Endpoint Details View**:
  - Full endpoint documentation
  - Request/response schema
  - Authentication requirements
  - Rate limiting details
  - Usage statistics (detailed):
    - Requests per hour/day/week/month
    - Response time percentiles (P50, P90, P95, P99)
    - Error rate breakdown
    - Status code distribution
    - Geographic distribution
    - Top consumers
  - Request/response examples
  - Recent requests log
  - Error log
  - Performance trends

  **Endpoint Actions**:
  - Edit endpoint configuration:
    - Update rate limits
    - Change authentication requirements
    - Modify timeout settings
    - Update documentation
  - Enable/disable endpoint
  - Mark as deprecated
  - Test endpoint (API playground)
  - Generate client code
  - Export endpoint documentation

  **Filter & Search**:
  - Search by endpoint name or path
  - Filter by:
    - HTTP method
    - Status (operational/degraded/deprecated)
    - API version
    - Rate limit exceeded
  - Sort by:
    - Name
    - Requests (high to low)
    - Response time
    - Success rate
    - Error rate

- **API Keys Tab**:

  **API Key List**:
  Each API key card shows:
  - Key name (e.g., "Mobile App - Production")
  - Key ID (first/last 8 chars, e.g., "sk_prod_abc...xyz")
  - Status:
      - Active (green)
      - Revoked (red)
      - Expired (gray)
  - Owner/Creator
  - Created date
  - Last used date
  - Expiration date
  - Permissions/Scopes
  - Rate limit assigned
  - Usage statistics:
    - Total requests
    - Requests today
    - Quota usage (%)
  - Actions: View Details, Regenerate, Revoke, Edit

  **Sample API Keys**:
  1. Mobile App - Production
     - Key: sk_prod_abc...xyz
     - Status: Active
     - Owner: mobile.team@eduverse.edu
     - Created: 60 days ago
     - Last used: 2 min ago
     - Expires: In 305 days
     - Scopes: read:users, write:courses
     - Rate limit: 10,000/hour
     - Usage: 2,450/10,000 (25%)

  2. Integration - LMS Partner
     - Key: sk_prod_def...123
     - Status: Active
     - Owner: integrations@eduverse.edu
     - Created: 120 days ago
     - Last used: 1 hour ago
     - Expires: Never
     - Scopes: read:courses, read:users
     - Rate limit: 5,000/hour
     - Usage: 890/5,000 (18%)

  3. Testing Environment
     - Key: sk_test_ghi...456
     - Status: Active
     - Owner: dev.team@eduverse.edu
     - Created: 30 days ago
     - Last used: Yesterday
     - Expires: In 60 days
     - Scopes: *:* (all permissions)
     - Rate limit: 1,000/hour
     - Usage: 45/1,000 (5%)

  4. Old Mobile App
     - Key: sk_prod_jkl...789
     - Status: Revoked
     - Owner: mobile.team@eduverse.edu
     - Created: 180 days ago
     - Revoked: 30 days ago
     - Reason: "Replaced by new key"

  **Create API Key**:
  - Key name (required)
  - Description
  - Owner/Team
  - Scopes/Permissions:
    - Select from available scopes
    - Read-only vs Read-write
    - Resource-level permissions
    - Wildcard options
  - Rate limit:
    - Requests per minute
    - Requests per hour
    - Requests per day
    - Custom limits
  - Expiration:
    - Never
    - 30 days
    - 90 days
    - 1 year
    - Custom date
  - Environment:
    - Production
    - Staging
    - Development
  - IP whitelist (optional)
  - Webhook notifications
  - Generate button

  **Key Details View**:
  - Full key value (masked, with "Show" button)
  - Copy to clipboard button
  - All key information
  - Usage statistics (detailed):
    - Requests over time (chart)
    - Endpoints accessed
    - Success/error rates
    - Response times
    - Geographic distribution
  - Request log (recent 100 requests)
  - Quota usage tracking
  - Security events:
    - Unauthorized access attempts
    - Rate limit exceeded
    - IP address changes
  - Activity timeline

  **Key Management Actions**:
  - Regenerate key (creates new key, expires old)
  - Revoke key (immediate revocation)
  - Edit key settings:
    - Update scopes
    - Change rate limits
    - Update expiration
    - Modify IP whitelist
  - Rotate key (scheduled rotation)
  - Test key (API playground)
  - View audit log
  - Export key activity

  **Bulk Operations**:
  - Select multiple keys
  - Bulk revoke
  - Bulk rate limit update
  - Bulk expiration update
  - Export selected keys data

- **Quick Actions Grid**:
  - Generate API Documentation
  - View API Changelog
  - Test API Playground
  - Monitor API Health
  - View Rate Limit Status
  - Export API Metrics

- **API Health Monitoring**:
  - Overall API health score
  - Uptime percentage
  - Incident history
  - SLA compliance
  - Performance trends

- **API Documentation Link**:
  - Link to full API documentation
  - Interactive API explorer
  - Code samples in multiple languages
  - Postman collection export
  - OpenAPI/Swagger spec download

**Current Status**: ✅ Fully functional API management UI  
**Backend Integration**: 🔶 Partial - Uses mock data, needs API management backend

---

## Alert Management

### 8. Alerts Screen
**Route**: `/it-admin/alerts`  
**File**: `lib/screens/it_admin/it_alerts_screen.dart`

#### Features:

- **Alert Statistics Overview**:
  - Active alerts count
  - Resolved alerts (today/week)
  - Suppressed alerts
  - Alert noise score (0-100, lower is better)
  - Alert trend chart:
    - Active alerts history (last 7 days)
    - Resolved alerts history
  - Color-coded metrics

- **Tab Navigation**:
  - **Rules**: Alert rule management
  - **History**: Historical alerts and resolution
  - **Channels**: Notification channel configuration
  - **Escalation**: Escalation policy management
  - **Suppression**: Suppression windows and rules
  - **AI Tuning**: AI-powered alert optimization

- **Rules Tab**:

  **Alert Rules List**:
  Each rule card shows:
  - Rule name (e.g., "DB Replication Lag > 5s")
  - Description
  - Service/Component monitored
  - Severity badge:
    - Critical (red)
    - Warning (yellow)
    - Info (blue)
  - Metric monitored
  - Operator (>, <, ==, !=, >=, <=)
  - Threshold value
  - Duration (for X duration)
  - Enabled/Disabled toggle
  - Tags
  - Last triggered time
  - Trigger count (lifetime)
  - Actions: Edit, Duplicate, Test, Delete

  **Sample Alert Rules**:
  1. DB Replication Lag > 5s
     - Description: "Alert when database replication lag exceeds 5 seconds"
     - Service: Database
     - Severity: Critical
     - Metric: replication_lag
     - Condition: > 5000ms for 3 minutes
     - Status: Enabled
     - Tags: [production, database]
     - Last triggered: 2 hours ago
     - Triggered: 15 times

  2. API P95 Latency High
     - Description: "API P95 latency exceeds threshold"
     - Service: API Gateway
     - Severity: Warning
     - Metric: api_latency
     - Condition: > 500ms for 5 minutes
     - Status: Enabled
     - Tags: [api, latency]
     - Last triggered: 5 hours ago
     - Triggered: 42 times

  3. AI Queue Backup
     - Description: "AI processing queue depth exceeds normal range"
     - Service: AI Service
     - Severity: Warning
     - Metric: queue_depth
     - Condition: > 1000 for 10 minutes
     - Status: Enabled
     - Tags: [ai, queue]
     - Last triggered: 1 day ago
     - Triggered: 8 times

  4. Backup Failure Detection
     - Description: "Automated backup job failed"
     - Service: Backup Service
     - Severity: Critical
     - Metric: backup_status
     - Condition: == 0 for 1 minute
     - Status: Enabled
     - Tags: [backup, critical]
     - Last triggered: Never
     - Triggered: 0 times

  5. High Memory Usage
     - Description: "Server memory usage exceeds 85%"
     - Service: All Servers
     - Severity: Warning
     - Metric: memory_usage
     - Condition: > 85% for 10 minutes
     - Status: Enabled
     - Tags: [server, memory]
     - Last triggered: 3 hours ago
     - Triggered: 28 times

  **Create/Edit Alert Rule Dialog**:
  - Rule name (required)
  - Description
  - Service selection
  - Metric selection (dropdown of available metrics)
  - Operator selection (>, <, ==, !=, >=, <=)
  - Threshold value
  - Duration window (alert if condition true for X time)
  - Severity selection
  - Tags (comma-separated)
  - Notification channels (multi-select)
  - Escalation policy (dropdown)
  - Auto-resolve after X minutes
  - Custom alert message template
  - Runbook link (URL)
  - Test rule button
  - Save button

  **Rule Actions**:
  - Test rule (simulate conditions)
  - Mute rule temporarily
  - View triggered alerts
  - View rule history
  - Clone rule
  - Export rule configuration

- **History Tab**:
  - Historical alert records
  - Each alert shows:
    - Alert ID
    - Rule name
    - Severity
    - Triggered time
    - Resolved time (if resolved)
    - Duration (time to resolve)
    - Triggered by (which condition)
    - Affected service/resource
    - Notification sent to
    - Resolution notes
    - Resolver name
  - Filter by:
    - Date range
    - Severity
    - Service
    - Status (active/resolved)
    - Resolver
  - Sort by: Time, Duration, Severity
  - Export alert history

- **Channels Tab**:
  - Notification channel management
  - Channel types:
    - Email
    - SMS
    - Slack
    - Microsoft Teams
    - PagerDuty
    - Webhook
    - Discord
  - Each channel shows:
    - Channel name
    - Type icon
    - Status (enabled/disabled/error)
    - Configuration (masked)
    - Last used
    - Success rate
    - Test button
  - Add new channel
  - Edit channel
  - Test channel (send test notification)
  - Delete channel

  **Channel Configuration**:
  - Email:
    - SMTP settings
    - Recipient list
    - Email template
  - SMS:
    - Provider (Twilio, etc.)
    - Phone numbers
    - Message template
  - Slack:
    - Webhook URL
    - Channel name
    - Bot token
    - Mention users
  - Webhook:
    - URL endpoint
    - HTTP method
    - Headers
    - Body template
    - Authentication

- **Escalation Tab**:
  - Escalation policy management
  - Each policy shows:
    - Policy name
    - Description
    - Escalation levels (steps)
    - Applied to (rules)
    - Last used
  
  **Escalation Levels Example**:
  1. Level 1 (0 minutes):
     - Notify: on-call engineer (Slack + SMS)
     - Wait: 15 minutes
  2. Level 2 (15 minutes):
     - Notify: team lead (SMS + Phone call)
     - Wait: 30 minutes
  3. Level 3 (45 minutes):
     - Notify: director (All channels)
     - Create incident ticket

  - Add/edit escalation policy
  - Test escalation
  - View escalation history

- **Suppression Tab**:
  - Suppression window management
  - Suppress alerts during:
    - Maintenance windows
    - Deployments
    - Known issues
    - Non-business hours
  - Each suppression shows:
    - Suppression name
    - Type (scheduled/manual)
    - Start and end time
    - Affected rules/services
    - Reason
    - Created by
    - Status (active/scheduled/expired)
  - Create suppression window:
    - Name
    - Start/end time
    - Recurring (yes/no)
    - Affected rules (select)
    - Reason (text)
  - Active suppressions highlighted
  - Expire suppression early

- **AI Tuning Tab**:
  - AI-powered alert optimization
  
  **AI Suggestions**:
  - "Rule 'High CPU' triggers too frequently (42 times today) - consider increasing threshold"
  - "Rule 'Disk Space' has 95% false positive rate - adjust conditions"
  - "Create new rule: Detected anomaly pattern in API latency"
  - "Consolidate rules: 3 similar memory rules can be merged"

  **Noisy Rules Detection**:
  - List of rules with high trigger frequency
  - False positive rate
  - Recommendations:
    - Increase threshold
    - Increase duration
    - Add conditions
    - Disable rule
  - Accept/reject suggestions
  - Track implemented suggestions

  **Alert Metrics**:
  - Alert noise score (0-100)
  - Average time to acknowledge
  - Average time to resolve
  - False positive rate
  - True positive rate
  - Alert fatigue indicators

  **Anomaly Detection**:
  - AI-detected anomalies not covered by rules
  - Suggestion to create new rules
  - Confidence score
  - Historical pattern analysis

**Current Status**: ✅ Fully functional alert management UI  
**Backend Integration**: 🔶 Partial - Uses mock data, needs alert system implementation

---

## Integration Management

### 9. Integration Management Screen
**Route**: `/it-admin/integrations`  
**File**: `lib/screens/it_admin/it_integration_screen.dart`

#### Features:

- **Integration Statistics**:
  - Total integrations count
  - Active connections
  - Failed connections
  - Last sync time
  - Data synced today
  - Error rate

- **Integration Categories**:
  - Authentication & SSO
  - Cloud Storage
  - Communication
  - Analytics
  - Payment Gateways
  - Learning Tools
  - AI Services
  - Monitoring

- **Integration Cards**:
  Each integration shows:
  - Service logo/icon
  - Integration name
  - Category badge
  - Status:
    - Connected (green)
    - Not Connected (gray)
    - Error (red)
    - Syncing (blue)
  - Description
  - Last sync time
  - Data synced
  - Actions: Connect, Configure, Disconnect, Test

  **Available Integrations**:
  
  **Authentication & SSO**:
  - Google OAuth 2.0
  - Microsoft Azure AD
  - Okta
  - Auth0
  - SAML 2.0

  **Cloud Storage**:
  - AWS S3
  - Google Cloud Storage
  - Azure Blob Storage
  - Dropbox
  - OneDrive

  **Communication**:
  - SendGrid (Email)
  - Twilio (SMS)
  - Slack
  - Microsoft Teams
  - Discord

  **Analytics**:
  - Google Analytics
  - Mixpanel
  - Amplitude
  - Segment

  **Payment Gateways**:
  - Stripe
  - PayPal
  - Square
  - Braintree

  **Learning Tools**:
  - Canvas LMS
  - Moodle
  - Blackboard
  - Google Classroom

  **AI Services**:
  - OpenAI API
  - Claude (Anthropic)
  - Google Gemini
  - Azure OpenAI

  **Monitoring**:
  - Datadog
  - New Relic
  - Sentry
  - Grafana

- **Integration Detail Sheet**:
  - Full integration information
  - Configuration options
  - API credentials (masked)
  - Sync settings
  - Webhook configuration
  - Rate limits
  - Usage statistics
  - Error logs
  - Test connection button

- **Connect Integration Flow**:
  1. Select integration
  2. Configure settings:
     - API keys/credentials
     - OAuth flow (if applicable)
     - Endpoint URLs
     - Sync frequency
     - Data mappings
  3. Test connection
  4. Activate integration

- **Integration Configuration**:
  - API credentials input
  - OAuth connection flow
  - Webhook URLs
  - Sync frequency (manual/hourly/daily)
  - Data field mapping
  - Enable/disable specific features
  - Error notification settings

- **Sync Management**:
  - Manual sync trigger
  - Scheduled sync configuration
  - Last sync status
  - Sync history
  - Sync conflicts resolution
  - Rollback sync

- **Webhook Management**:
  - Configure incoming webhooks
  - Configure outgoing webhooks
  - Event types selection
  - Webhook signature verification
  - Webhook logs
  - Test webhook
  - Webhook retry policy

- **Filter & Search**:
  - Search by integration name
  - Filter by:
    - Category
    - Status (connected/not connected/error)
    - Provider
  - Sort by: Name, Status, Last Sync

- **Integration Health**:
  - Connection status
  - Response time
  - Success rate
  - Error rate
  - Last successful operation
  - Uptime percentage

**Current Status**: 🔶 UI structure exists  
**Backend Integration**: ⚠️ Future implementation - Integration framework needed

---

## AI Model Settings

### 10. AI Model Settings Screen
**Route**: `/it-admin/ai-settings`  
**File**: `lib/screens/it_admin/it_ai_model_settings_screen.dart`

#### Features:

- **AI Request Statistics**:
  - Success rate percentage
  - Active providers count
  - Requests per minute
  - Total requests today
  - Cost today
  - Average response time
  - Token usage

- **AI Provider Configuration**:
  
  **Provider Selection**:
  - OpenAI
  - Claude (Anthropic)
  - Google Gemini
  - Azure OpenAI
  - Custom providers

  **Selected Provider Settings**:
  - Provider name
  - API endpoint URL
  - API key input (masked)
  - Organization ID (if applicable)
  - Model selection dropdown
  - Auto-rotate API keys (toggle)
  - Rate limit settings
  - Timeout settings
  - Retry policy

  **OpenAI Models**:
  - GPT-4 Turbo
  - GPT-4
  - GPT-3.5 Turbo
  - GPT-3.5
  - DALL-E 3
  - Whisper
  - Text-Embedding-Ada-002

  **Claude Models**:
  - Claude 3.5 Sonnet
  - Claude 3 Opus
  - Claude 3 Sonnet
  - Claude 3 Haiku
  - Claude 2.1
  - Claude 2

  **Gemini Models**:
  - Gemini 1.5 Pro
  - Gemini 1.0 Pro
  - Gemini Pro Vision

- **Model Configuration**:
  - Temperature (0.0 - 2.0)
  - Max tokens
  - Top P
  - Frequency penalty
  - Presence penalty
  - Stop sequences
  - Best of (for completion models)

- **Governance Rules Section**:
  - Content filtering:
    - Hate speech detection
    - Violence detection
    - Sexual content detection
    - Self-harm detection
    - Profanity filter
  - PII detection and masking:
    - Email addresses
    - Phone numbers
    - Credit card numbers
    - Social security numbers
    - Names and addresses
  - Rate limiting:
    - Per user limits
    - Per role limits
    - Global limits
  - Cost controls:
    - Daily budget limit
    - Monthly budget limit
    - Per-request cost limit
    - Alert thresholds
  - Usage policies:
    - Allowed use cases
    - Restricted use cases
    - Audit logging
    - Data retention

- **System Limits Section**:
  - Max concurrent requests
  - Request queue size
  - Request timeout (seconds)
  - Max tokens per request
  - Max requests per user per day
  - Max cost per user per day
  - Cooldown period after limit
  - Override limits for specific users/roles

- **Request Logs Section**:
  - Recent AI requests (last 100)
  - Each log entry shows:
    - Request ID
    - Timestamp
    - User ID and name
    - Provider (OpenAI/Claude/Gemini)
    - Model used
    - Status:
      - Success (green)
      - Failed (red)
      - Rate Limited (yellow)
      - Filtered (orange)
    - Tokens used (if success)
    - Response time (ms)
    - Cost estimate
    - Error message (if failed)
  - Filter by:
    - Date range
    - User
    - Provider
    - Model
    - Status
  - Search by request ID or user
  - Export logs

  **Sample Request Logs**:
  1. john.doe@EduVerse.edu - 2 min ago
     - Provider: OpenAI
     - Model: GPT-4 Turbo
     - Status: Success ✓
     - Tokens: 1,250
     - Response time: 1,200ms
     - Cost: $0.03

  2. jane.smith@EduVerse.edu - 5 min ago
     - Provider: Claude
     - Model: Claude 3.5 Sonnet
     - Status: Success ✓
     - Tokens: 890
     - Response time: 950ms
     - Cost: $0.02

  3. api_service_01 - 12 min ago
     - Provider: OpenAI
     - Model: GPT-4 Turbo
     - Status: Rate Limited
     - Error: "Rate limit exceeded"

  4. mike.wilson@EduVerse.edu - 25 min ago
     - Provider: Gemini
     - Model: Gemini 1.5 Pro
     - Status: Failed
     - Error: "Connection timeout"

- **API Key Management**:
  - Multiple API keys per provider
  - Key rotation schedule
  - Key usage tracking
  - Key health status
  - Add/edit/revoke keys
  - Key-specific rate limits

- **Cost Tracking**:
  - Daily cost breakdown
  - Monthly cost trends
  - Cost by provider
  - Cost by model
  - Cost by user/department
  - Budget alerts
  - Cost optimization suggestions

- **Performance Monitoring**:
  - Average response time by model
  - Success rate by provider
  - Token usage trends
  - Request volume trends
  - Error rate tracking
  - Latency percentiles (P50, P90, P95, P99)

- **Configuration Save Dialog**:
  - Review changes
  - Impact assessment
  - Affected users
  - Estimated cost changes
  - Confirmation required
  - Test before applying
  - Rollback option

- **Unsaved Changes Warning**:
  - Indicator when changes are not saved
  - Prompt before leaving page
  - Save/Discard/Cancel options

**Current Status**: ✅ Fully functional AI settings UI  
**Backend Integration**: 🔶 Partial - Uses mock data, needs AI provider integration

---

## Error Logs & Monitoring

### 11. Error Logs Screen
**Route**: `/it-admin/logs`  
**File**: `lib/screens/it_admin/it_error_logs_screen.dart`

#### Features:

- **Error Statistics Overview**:
  - Total errors today
  - Critical errors count
  - Error rate (errors/requests)
  - Most common error
  - Errors by service breakdown
  - Error trend chart (last 24 hours)

- **Error Logs Section**:
  - Real-time error log feed
  - Each error entry shows:
    - Timestamp
    - Error level badge:
      - CRITICAL (red)
      - ERROR (orange)
      - WARNING (yellow)
      - INFO (blue)
      - DEBUG (gray)
    - Error message (truncated)
    - Service/Component
    - User (if applicable)
    - Request ID
    - Stack trace (expandable)
    - Actions: View Details, Assign, Resolve

  **Error Detail View**:
  - Full error message
  - Complete stack trace
  - Service information
  - User context
  - Request details:
    - HTTP method and endpoint
    - Request headers
    - Request body
    - Query parameters
  - Response details
  - Environment information
  - Related errors
  - Resolution history
  - Add notes
  - Assign to developer
  - Mark as resolved
  - Create GitHub issue

- **Filter & Search**:
  - Search by error message, user, or request ID
  - Filter by:
    - Error level (Critical/Error/Warning/Info/Debug)
    - Service
    - Time range
    - Status (new/assigned/resolved)
    - User
  - Sort by:
    - Time (newest/oldest)
    - Severity
    - Frequency
    - Service

- **Error Grouping**:
  - Group similar errors
  - Show count per group
  - Identify patterns
  - Bulk actions on groups

- **Quick Actions**:
  - Clear resolved errors
  - Export error logs
  - Generate error report
  - Configure error alerting
  - View error analytics

- **Error Analytics**:
  - Error distribution by service
  - Error distribution by time
  - Error distribution by user
  - Most frequent errors
  - Error resolution time
  - Error recurrence rate

**Current Status**: 🔶 UI structure exists  
**Backend Integration**: ⚠️ Future implementation - Error logging system needed

---

## Performance Reports

### 12. Performance Reports Screen
**Route**: `/it-admin/performance`  
**File**: `lib/screens/it_admin/it_performance_report_screen.dart`

#### Features:

- **Time Period Selector**:
  - Last Hour
  - Last 6 Hours
  - Last 24 Hours
  - Last 7 Days
  - Last 30 Days
  - Custom Date Range

- **Performance Overview Cards**:
  - Average Response Time
  - Request Throughput (requests/sec)
  - Error Rate (%)
  - CPU Usage Average
  - Memory Usage Average
  - Active Users
  - Database Query Time
  - Cache Hit Rate

- **Performance Trends Section**:
  - Multi-line chart showing:
    - Response time trend
    - Throughput trend
    - Error rate trend
  - Interactive chart
  - Toggle metrics visibility
  - Zoom and pan
  - Export chart

- **Resource Utilization Section**:
  - CPU usage by service
  - Memory usage by service
  - Disk I/O by service
  - Network bandwidth by service
  - Bar charts or pie charts
  - Top consumers highlighted

- **Server Health Metrics**:
  - Individual server performance
  - Comparison across servers
  - Identify bottlenecks
  - Capacity planning insights

- **Recent Alerts Section**:
  - Performance-related alerts
  - Alert severity
  - Time triggered
  - Current status
  - Link to alert details

- **Database Performance**:
  - Query performance metrics
  - Slow query log
  - Connection pool status
  - Cache efficiency
  - Index usage

- **API Performance**:
  - Endpoint response times
  - Slowest endpoints
  - Most called endpoints
  - Error rates per endpoint

- **Export Reports**:
  - PDF report generation
  - Excel export
  - CSV export
  - Schedule automated reports

**Current Status**: 🔶 UI structure exists  
**Backend Integration**: ⚠️ Future implementation - Performance monitoring backend needed

---

## Database Management

### 13. Database Management Screen
**Route**: `/it-admin/database`  
**File**: `lib/screens/it_admin/it_database_screen.dart`

#### Features:

- **Database Statistics Overview**:
  - Total databases
  - Total storage used
  - Active connections
  - Queries per second
  - Avg query time
  - Cache hit rate

- **Database Instance List**:
  Each database shows:
  - Database name (e.g., "edu-primary")
  - Database type:
    - PostgreSQL
    - MongoDB
    - Redis
    - Elasticsearch
    - MySQL
    - SQLite
  - Version
  - Status (Operational/Degraded/Down)
  - Host and port
  - Storage used / Total storage
  - Active connections / Max connections
  - Query latency (ms)
  - Actions: Connect, Configure, Backup, Optimize

  **Sample Databases**:
  1. edu-primary (PostgreSQL 15.2)
     - Status: Operational
     - Host: db-primary.edu.local:5432
     - Storage: 245.5 GB / 500 GB (49%)
     - Connections: 85 / 200
     - Latency: 2.5ms

  2. edu-replica (PostgreSQL 15.2)
     - Status: Operational
     - Host: db-replica.edu.local:5432
     - Storage: 245.2 GB / 500 GB (49%)
     - Connections: 45 / 200
     - Latency: 3.2ms

  3. edu-analytics (MongoDB 6.0)
     - Status: Operational
     - Host: mongo.edu.local:27017
     - Storage: 128.7 GB / 250 GB (51%)
     - Connections: 25 / 100
     - Latency: 5.8ms

  4. edu-cache (Redis 7.2)
     - Status: Degraded
     - Host: redis.edu.local:6379
     - Storage: 4.2 GB / 16 GB (26%)
     - Connections: 150 / 500
     - Latency: 0.3ms

  5. edu-search (Elasticsearch 8.11)
     - Status: Operational
     - Host: search.edu.local:9200
     - Storage: 85.3 GB / 200 GB (43%)
     - Connections: 12 / 50
     - Latency: 15.2ms

- **Table/Collection List Section**:
  - List of tables in selected database
  - Each table shows:
    - Table name
    - Row count
    - Size (GB/MB)
    - Last updated
    - Actions: View, Optimize, Export

  **Sample Tables**:
  - users: 125,000 rows, 45.2 GB, 2 min ago
  - courses: 3,500 rows, 12.8 GB, 5 min ago
  - assignments: 28,000 rows, 8.5 GB, 1 hour ago
  - submissions: 450,000 rows, 125.8 GB, 10 min ago
  - enrollments: 75,000 rows, 5.2 GB, 30 min ago

- **Database Actions**:
  - **Connect**: Open database console/SQL client
  - **Backup**: Trigger manual backup
  - **Restore**: Restore from backup point
  - **Optimize**: Run optimization tasks:
    - Vacuum (PostgreSQL)
    - Reindex
    - Analyze
    - Cleanup
  - **Query**: Run SQL queries
  - **Export**: Export database/table data
  - **Import**: Import data
  - **Clone**: Create database copy
  - **Delete**: Remove database (with confirmation)

- **Query Performance**:
  - Slow query log
  - Query execution plans
  - Query optimization suggestions
  - Kill long-running queries

- **Connection Management**:
  - Active connections list
  - Kill specific connections
  - Connection pool configuration
  - Connection limits

- **Replication Status**:
  - Replication lag
  - Replica health
  - Sync status
  - Failover configuration

- **Maintenance Tasks**:
  - Scheduled maintenance windows
  - Auto-vacuum settings
  - Index maintenance
  - Statistics updates

**Current Status**: ✅ Fully functional database management UI  
**Backend Integration**: 🔶 Partial - Uses mock data, needs database management API

---

## Cloud Services

### 14. Cloud Services Screen
**Route**: `/it-admin/cloud`  
**File**: `lib/screens/it_admin/it_cloud_services_screen.dart`

#### Features:

- **Cloud Statistics Overview**:
  - Total services
  - Active services
  - Monthly cost (total)
  - Regions count
  - Cost trend (up/down)
  - Usage alerts

- **Cloud Provider Breakdown**:
  - AWS: X services, $Y cost
  - Azure: X services, $Y cost
  - Google Cloud: X services, $Y cost
  - Others

- **Cloud Service List**:
  Each service shows:
  - Service name (e.g., "edu-web-app")
  - Cloud provider logo/icon:
    - AWS
    - Azure
    - Google Cloud Platform (GCP)
    - DigitalOcean
    - Others
  - Service type:
    - Compute (EC2, VM)
    - Serverless (Lambda, Functions)
    - Storage (S3, Blob)
    - Database (RDS, CosmosDB)
    - CDN
    - Networking
  - Status (Operational/Degraded/Down)
  - Region/Location
  - Monthly cost
  - Usage percentage
  - Last sync time
  - Actions: View Details, Configure, Scale, Stop

  **Sample Cloud Services**:
  1. edu-web-app
     - Provider: AWS
     - Type: Compute (EC2)
     - Status: Operational
     - Region: us-east-1
     - Cost: $450.00/month
     - Usage: 65%
     - Last sync: 2 min ago

  2. edu-api-gateway
     - Provider: AWS
     - Type: Serverless (Lambda)
     - Status: Operational
     - Region: us-east-1
     - Cost: $120.50/month
     - Usage: 45%
     - Last sync: 5 min ago

  3. edu-storage
     - Provider: Azure
     - Type: Storage (Blob)
     - Status: Operational
     - Region: eastus
     - Cost: $280.00/month
     - Usage: 78%
     - Last sync: 1 min ago

  4. edu-cdn
     - Provider: GCP
     - Type: CDN
     - Status: Operational
     - Region: global
     - Cost: $95.25/month
     - Usage: 52%
     - Last sync: 3 min ago

  5. edu-ml-training
     - Provider: AWS
     - Type: Compute (GPU)
     - Status: Degraded
     - Region: us-west-2
     - Cost: $890.00/month
     - Usage: 92%
     - Last sync: 10 min ago
     - Warning: High usage

  6. edu-backup
     - Provider: Azure
     - Type: Storage
     - Status: Operational
     - Region: westeurope
     - Cost: $150.00/month
     - Usage: 35%
     - Last sync: 15 min ago

- **Service Detail View**:
  - Full service information
  - Resource specifications
  - Configuration details
  - Cost breakdown
  - Usage metrics over time
  - Scaling options
  - Logs and monitoring
  - Tags and metadata

- **Cost Management**:
  - Cost by service
  - Cost by provider
  - Cost by region
  - Cost trends
  - Budget alerts
  - Cost optimization recommendations:
    - Right-size instances
    - Reserved instances
    - Spot instances
    - Storage tier optimization
    - Remove unused resources

- **Filter & Search**:
  - Search by service name
  - Filter by:
    - Provider (AWS/Azure/GCP/All)
    - Service type
    - Status
    - Region
    - Cost range
  - Sort by:
    - Name
    - Cost (high to low)
    - Usage
    - Provider

- **Quick Actions**:
  - Sync all services
  - View cost breakdown
  - Generate cost report
  - Set up budget alerts
  - Optimize costs
  - View recommendations

- **Resource Tagging**:
  - Tag cloud resources
  - Tag management
  - Cost allocation by tags
  - Filter by tags

**Current Status**: ✅ Fully functional cloud services UI  
**Backend Integration**: 🔶 Partial - Uses mock data, needs cloud provider API integration

---

## System Settings

### 15. System Settings Screen
**Route**: `/it-admin/settings`  
**File**: `lib/screens/it_admin/it_system_settings_screen.dart`

#### Features:

- **System Configuration Categories**:
  
  **General System Settings**:
  - System name
  - System timezone
  - Date/time format
  - Default language
  - Maintenance mode toggle
  - Debug mode toggle

  **Performance Settings**:
  - Cache settings:
    - Cache TTL
    - Cache size limits
    - Cache warming
  - Connection pooling:
    - Pool size
    - Pool timeout
  - Rate limiting:
    - Global rate limits
    - Per-user limits
    - API rate limits
  - Queue configuration:
    - Queue workers
    - Queue timeout
    - Priority settings

  **Security Settings**:
  - Session timeout
  - Password requirements
  - Two-factor authentication policy
  - IP whitelist/blacklist
  - CORS settings
  - SSL/TLS configuration
  - Security headers
  - API security policies

  **Database Settings**:
  - Connection strings
  - Connection pool size
  - Query timeout
  - Transaction timeout
  - Backup schedule
  - Replication settings

  **Email Settings**:
  - SMTP configuration
  - Default sender
  - Email templates
  - Rate limits
  - Bounce handling

  **Logging Settings**:
  - Log level (DEBUG/INFO/WARNING/ERROR)
  - Log retention period
  - Log storage location
  - Log rotation policy
  - Structured logging toggle

  **Monitoring Settings**:
  - Monitoring endpoints
  - Health check intervals
  - Metrics collection
  - Alert thresholds
  - Monitoring integrations

  **Feature Flags**:
  - Enable/disable features
  - Feature rollout percentage
  - Feature targeting by user/role
  - A/B testing configuration

  **Storage Settings**:
  - File upload limits
  - Storage quotas
  - Storage providers
  - CDN configuration
  - Asset optimization

  **API Settings**:
  - API versioning
  - API deprecation notices
  - CORS policies
  - Webhook endpoints
  - API documentation URL

- **Configuration Management**:
  - Edit settings
  - Test configuration
  - Validate changes
  - Save changes
  - Revert changes
  - Export configuration
  - Import configuration
  - Configuration history
  - Rollback to previous version

- **Environment Management**:
  - View environment variables
  - Edit environment variables
  - Secure variable storage
  - Environment-specific configs:
    - Development
    - Staging
    - Production

**Current Status**: 🔶 UI structure exists  
**Backend Integration**: ⚠️ Future implementation - System settings management needed

---

## Profile Management

### 16. IT Admin Profile Screen
**Route**: `/it-admin/profile`  
**File**: `lib/screens/it_admin/it_profile_screen.dart`

#### Features:

- **Tab Navigation** (4 tabs):
  - **Personal**: Profile information
  - **Security**: Security settings
  - **Notifications**: Notification preferences
  - **Preferences**: User preferences

- **Personal Tab**:
  - Profile picture
  - Full name
  - Email address
  - Phone number
  - Role badge: IT Admin
  - Department
  - Employee ID
  - Join date
  - Edit profile button

- **Security Tab**:
  - Password change section:
    - Current password
    - New password
    - Confirm password
    - Password strength meter
    - Change password button
  - Two-Factor Authentication:
    - Enable/disable toggle
    - Setup QR code
    - Backup codes
    - Trusted devices list
  - Active sessions:
    - List of logged-in sessions
    - Device/browser info
    - IP address
    - Last activity
    - Sign out button
  - API keys:
    - Personal API keys
    - Create new key
    - Revoke key
  - Security log:
    - Recent security events
    - Login history
    - Password changes

- **Notifications Tab**:
  - Email notifications:
    - System alerts
    - Security alerts
    - Backup notifications
    - Performance alerts
    - Error notifications
    - Daily summary
  - SMS notifications:
    - Critical alerts only
    - All alerts
    - Off
  - Push notifications:
    - Browser notifications
    - Mobile app notifications
  - Notification schedule:
    - Business hours only
    - 24/7
    - Custom schedule
  - Quiet hours:
    - Enable quiet hours
    - Start time
    - End time

- **Preferences Tab**:
  - Theme preference:
    - Light
    - Dark
    - System default
  - Default dashboard view
  - Time zone
  - Date format
  - Number format
  - Language
  - Items per page
  - Auto-refresh intervals
  - Chart preferences

- **Activity Timeline**:
  - Recent IT admin activities
  - Actions performed
  - Systems accessed
  - Changes made
  - Time stamps

- **Quick Actions**:
  - Edit profile
  - Change password
  - Download activity log
  - Export profile data
  - Delete account (with confirmation)

**Current Status**: ✅ Fully functional profile UI  
**Backend Integration**: 🔶 Partial - Uses mock data

---

### 17. Edit Profile Screen
**Route**: `/it-admin/profile/edit`  
**File**: `lib/screens/it_admin/it_edit_profile_screen.dart`

#### Features:

- Profile picture upload/change
- Personal information form:
  - First name
  - Last name
  - Email (with verification if changed)
  - Phone number
  - Department
  - Bio
- Contact preferences
- Save/Cancel buttons
- Validation
- Success/error notifications

**Current Status**: 🔶 UI structure exists  
**Backend Integration**: ⚠️ Future implementation - Profile update API needed

---

## Search Functionality

### 18. IT Admin Search Screen
**Route**: `/it-admin/search`  
**File**: `lib/screens/it_admin/search/it_search_screen.dart`

#### Features:

- **Search Header**:
  - Large search input
  - Search icon
  - Voice search (future)
  - Back button

- **Search Suggestions**:
  - Auto-complete
  - Recent searches
  - Popular searches
  - Search history

- **Search Categories**:
  - Servers
  - Services
  - Databases
  - API Endpoints
  - Users
  - Logs
  - Integrations
  - Documentation
  - Settings

- **Search Results**:
  - Category chips (filter by category)
  - Result cards showing:
    - Title
    - Category badge
    - Description
    - Relevance score
    - Last modified
    - Quick actions
  - Pagination
  - Sort options

- **Filter Sheet**:
  - Category filters
  - Date range
  - Status filters
  - Type filters

- **Recent Searches**:
  - List of recent queries
  - Click to re-search
  - Clear history

- **Browse Categories**:
  - When no search query
  - Quick links to main sections
  - Popular items

- **Empty State**:
  - No results found message
  - Search tips
  - Suggested searches

**Current Status**: 🔶 UI structure exists  
**Backend Integration**: ⚠️ Future implementation - Search indexing needed

---

## Feature Status Summary

### ✅ Fully Functional Features (UI + Partial Backend)
1. IT Admin Dashboard - Complete dashboard with system metrics and monitoring
2. IT Admin Drawer Navigation - Full navigation menu with categorization
3. System Health Screen - Comprehensive health monitoring with metrics
4. Security Logs Screen - Advanced security logging with AI insights
5. Backup Screen - Complete backup management with DR planning
6. API Management Screen - Endpoint and API key management
7. Alerts Screen - Alert rule management with AI tuning
8. AI Model Settings Screen - AI provider configuration with governance
9. Database Screen - Database management and monitoring
10. Cloud Services Screen - Cloud service management and cost tracking
11. IT Profile Screen - Profile management with security settings

### 🔶 Partial Implementation (UI Complete, Backend Needed)
1. Server Management Screen - UI ready, needs server monitoring API
2. Integration Screen - UI exists, needs integration framework
3. Error Logs Screen - Structure exists, needs error logging system
4. Performance Reports Screen - UI ready, needs performance monitoring backend
5. System Settings Screen - Structure exists, needs settings management
6. Edit Profile Screen - Form exists, needs profile update API
7. Search Screen - UI exists, needs search indexing

### ⚠️ Future Implementation Needed
1. Real-time monitoring system for live metrics
2. Server management and SSH access
3. Advanced security threat detection
4. Automated disaster recovery system
5. API gateway integration
6. Alert escalation and notification delivery
7. Third-party integration framework
8. AI provider API integrations
9. Distributed logging system
10. Performance monitoring and APM
11. Database query optimization tools
12. Multi-cloud management APIs
13. Advanced search and indexing
14. Automated backup verification
15. Infrastructure as Code (IaC) support

### 📊 IT Admin Platform Statistics
- **Total Screens**: 18+ dedicated IT admin screens
- **Total Widgets**: 75+ specialized IT widgets
- **Total Files**: ~150 implementation files
- **Navigation Categories**: 4 (Main Menu, Monitoring, Infrastructure, Account)
- **Navigation Items**: 16 total menu items
- **Monitoring Capabilities**: 8+ different metric types
- **Security Features**: 6+ security tabs and sections
- **Backup Types**: 5 (Full, Incremental, Differential, Snapshot, Archive)
- **Cloud Providers**: 3 major (AWS, Azure, GCP)
- **Database Types**: 5+ (PostgreSQL, MongoDB, Redis, Elasticsearch, MySQL)
- **AI Providers**: 4 (OpenAI, Claude, Gemini, Azure OpenAI)
- **Alert Severity Levels**: 4 (Critical, Warning, Info, Low)
- **Integration Categories**: 8 categories with 30+ services

---

## Color Scheme & Theming

**IT Admin Color Palette** (defined in `lib/widgets/it_admin/shared/it_colors.dart`):
- **Primary**: Cyan gradient (#0891B2 to #22D3EE)
- **Secondary**: Teal tones
- **Success**: Green (#10B981)
- **Warning**: Yellow/Orange (#F59E0B)
- **Error**: Red (#EF4444)
- **Info**: Blue (#3B82F6)

**Dark Mode Support**: ✅ Full dark/light theme support across all screens

**Responsive Design**: ✅ Adapts to desktop, tablet, and mobile screen sizes

---

## Technical Architecture

**State Management**: BLoC Pattern with Cubits
- `ThemeBloc` for theme management
- Other Cubits to be added for various IT admin features

**Routing**: GoRouter for declarative routing with `/it-admin/*` prefix

**Localization**: Full i18n support with `AppLocalizations`

**Data Models**:
- Service status and metrics models
- Server information models
- Security log entry models
- Backup job models
- API endpoint and key models
- Alert rule models
- Integration models
- AI request models
- Database instance models
- Cloud service models

**Widgets Organization**:
- Dashboard widgets (17 files)
- System health widgets (5 files)
- Cloud services widgets (4 files)
- Server management widgets (4 files)
- Backup widgets (11 files)
- Security logs widgets (10 files)
- API management widgets (5 files)
- Alerts widgets (10 files)
- Profile widgets (10 files)
- AI model settings widgets (6 files)
- Performance report widgets (7 files)
- Search widgets (8 files)
- Error logs widgets (4 files)
- Database widgets (6 files)
- Integration widgets (8 files)
- Settings widgets (3 files)

---

## IT Admin Responsibilities & Capabilities

The IT Admin role in EduVerse has technical infrastructure control with capabilities to:

### Infrastructure Management:
- Monitor system health and performance metrics
- Manage all servers and infrastructure components
- Configure and optimize cloud services
- Manage database instances and performance
- Control backup and disaster recovery operations
- Monitor and optimize resource utilization

### Security Operations:
- Monitor security logs and detect threats
- Investigate security incidents
- Configure security policies and rules
- Manage access controls and permissions
- Track and respond to security alerts
- Conduct security audits

### API & Integration Management:
- Monitor API endpoints and performance
- Manage API keys and access control
- Configure rate limits and quotas
- Set up third-party integrations
- Monitor integration health
- Manage webhooks and event subscriptions

### Monitoring & Alerting:
- Configure alert rules and thresholds
- Set up escalation policies
- Manage notification channels
- Monitor system metrics and KPIs
- Track and resolve incidents
- Optimize alert noise

### AI & Advanced Features:
- Configure AI providers and models
- Set up AI governance rules
- Monitor AI usage and costs
- Manage API keys for AI services
- Track AI request logs
- Optimize AI performance

### Operations:
- View and analyze error logs
- Generate performance reports
- Monitor database performance
- Manage cloud service costs
- Configure system settings
- Handle disaster recovery

---

## Navigation Hierarchy

```
IT Admin Dashboard
├── Main Menu (8 items)
│   ├── Dashboard
│   ├── System Health
│   ├── Server Management
│   ├── Security Logs
│   ├── Backup & Recovery
│   ├── API Management
│   ├── Integrations
│   └── AI Model Settings
├── Monitoring (3 items)
│   ├── Error Logs
│   ├── Performance
│   └── Alerts (with badge)
├── Infrastructure (2 items)
│   ├── Database
│   └── Cloud Services
└── Account (3 items)
    ├── Account Settings
    ├── Profile
    └── Education System Settings
```

---

## Conclusion

The IT Admin Role in EduVerse is a specialized, technical administration platform with 18+ screens focused on infrastructure management, system monitoring, security operations, and technical configuration. The interface provides deep technical insights and controls for IT professionals to maintain the health, security, and performance of the entire EduVerse platform.

**Key Strengths**:
- Comprehensive infrastructure monitoring
- Advanced security logging and threat detection
- Robust backup and disaster recovery
- Detailed API and integration management
- AI provider configuration and governance
- Real-time alert management
- Cloud service cost optimization
- Database performance monitoring
- Technical system configuration
- Specialized IT admin color scheme (cyan/teal)

**Differences from Regular Admin**:
- Focus on technical/infrastructure vs user management
- Low-level system operations vs high-level platform administration
- Performance optimization vs content management
- Security operations vs academic operations
- Infrastructure costs vs payment processing
- API management vs communication management
- Technical monitoring vs analytics reporting

**Next Steps for Full Production Readiness**:
- Integrate real-time monitoring systems
- Connect to server management APIs
- Implement distributed logging system
- Set up alert notification delivery
- Integrate with cloud provider APIs
- Connect AI provider APIs
- Implement backup verification
- Set up automated health checks
- Enable SSH/terminal access
- Integrate APM (Application Performance Monitoring)
- Connect to infrastructure monitoring tools (Datadog, New Relic)
- Implement automated incident response
- Set up infrastructure as code (IaC) support

---

**Documentation Version**: 1.0  
**Last Updated**: February 2026  
**Platform**: EduVerse Learning Management System  
**Role**: IT Admin  
**Framework**: Flutter  
**State Management**: BLoC Pattern  
**Demo Credentials**: itadmin@eduverse.dev / ITAdmin@123
