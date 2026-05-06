# PAL: Journal

This app helps you visually represent your total profits and losses over a large timeframe.
The name "**PAL: Journal**" simply comes from the term used in investments or finances; "**PnL**". This basically means **Profits and Losses**. I simply swapped the `n` with `A`. As for the `journal` part, this simply means that there are additional personal touches you can do for tracking your **PnL**.

## Preview

Below are some previews of the app in action.

## Supported Platforms

The plan for this app, is to be able to support both mobile (**Android**) and desktop (**Windows**) platforms.

| Platform | Support | Version |
| -------- | ------- | ------- |
| **Android** | ✅ Fully supported! | From v0.2.0+ |
| **IOS** | 🟥 Not supported. | - |
| **Windows** | 🟨 Mostly supported (_95%_) | From v0.1.0+ |
| **MacOS** | 🟥 Not supported. | - |
| **Linux** | 🟧 Not yet tested. | - |

## Setup / Installation

Please refer to the instructions shown in the **releases** tab to the right.
Installation should be as easy as just downloading the installer.

## Feature List

| Feature | Description | Version |
| ------- | ----------- | ------- |
| **Algebraic PnL Calendar** | A visual ledger tracking daily Net Income (profits minus losses) _(A calendar that shows exactly how much you made or spent each day at a glance)_. | v0.1.0 |
| **Local Edge Storage (Isar)** | Secure, lightning-fast database architecture for instantaneous read/write operations _(Your data is saved instantly and securely right on your device, requiring no internet connection)_. | v0.1.0 |
| **Analytics Dashboard** | Comprehensive data visualization for trend analysis and cash-flow tracking _(Beautiful charts and summaries that break down where your money is going over time)_. | v0.1.0 |
| **Data Portability Tools** | CSV parsing capabilities for external spreadsheet reconciliation and data migration _(Easily back up your data to a spreadsheet, or load older data into the app)_. | v0.2.0 |
| **Global Settings** | Core application configurations and user preferences. | v0.2.0 |
| **Dynamic Material 3 UI** | Modern, responsive interface with adaptive color theming and animated transitions _(Simply put: The app looks beautiful, feels premium, and adjusts to your preferred visual style)_. | v0.3.0 |
| **Dashboard Query Filters** | Granular timeframe selectors and data-filtering mechanisms for the analytics engine _(Easily switch between viewing your stats for the week, the month, the year, or a custom date range)_. | v0.4.0 |
| **Smart Financial Targets** | Configurable monthly thresholds (Budgets and Profit Goals) with real-time progress tracking _(Set a limit on what you want to spend or a target for what you want to earn, and the app will track your progress)_. | v0.5.0 |
| **Zero-Based Reconciliation** | Advanced daily ledgers that automatically balance categorized transaction breakdowns into a unified daily net total _(You can log every detail of your day's income and expenses, and the app will automatically do the math to ensure everything balances perfectly)_. | v0.6.0 |
| **Granular Category Tracking** | Isolated trend analysis for specific cash flow streams _(Want to see exactly how much you spend on "Food" over the entire year? This will let you filter and track specific tags)_. | v0.7.0 |
| **Real-Time Forex Conversion** | Automated currency localization for international tracking _(Traveling or getting paid in a different currency? The app will automatically convert it to your main currency)_. | v0.8.0 |
| **Cloud Ledger Sync** (_Mobile Only Feature_) | Cross-platform data synchronization via authenticated accounts _(Log in to automatically back up your data and seamlessly access it on your phone)_. | v0.10.0 |
| **Quantified Wealth Goals** | Milestone tracking for non-monetary assets like gold, coding projects, or learning progress. | v0.11.0 |
| **Advanced Inventory Log** | A historical ledger for completed milestones with two-way swipe actions for non-destructive editing. | v0.12.0 |
| **Universal Portability Tools** | Multi-category CSV parsing for PnL, Quantified Goals, and Monthly Targets across all platforms. | v0.13.0 |

## Issues

1. **Cloud Sync Scope**: The cloud-based data syncing is optimized for mobile (Android).
2. **Windows Synchronization**: Due to SDK constraints on Windows, data synchronization is handled through the Universal Portability Tools. Users on Windows should use the CSV Category Export/Import (located in Settings) to move PnL, Goals, and Targets data between devices manually.
