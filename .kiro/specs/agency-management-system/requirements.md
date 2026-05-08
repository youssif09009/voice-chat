# Requirements Document

## Introduction

This feature delivers a comprehensive **Agency Management System** for a Flutter-based voice chat application. The system is a UI-only implementation (all data is static/fake — no backend integration) that provides a full-featured admin and agent portal covering four agency types, financial dashboards, a withdrawal flow, subordinate management, referral tracking, and a multi-gateway recharge system. The app uses a dark purple theme (`#0F0F1E` background, `#1A1635` surface, `#8B5CF6` primary purple) and auto-logs in as admin on startup.

---

## Glossary

- **Agency_System**: The complete agency management feature described in this document.
- **Admin**: A privileged user who manages the entire platform and all agency types.
- **Master_Agent**: An approved agent who can recruit and manage Subordinate_Agents.
- **Subordinate_Agent**: An agent recruited by a Master_Agent; can invite users but cannot recruit further agents.
- **USDT_Agency**: An agency type that handles crypto-based (USDT) settlements.
- **Recharge_Agency**: An agency type authorized to sell or top-up platform currency (Diamonds) to users.
- **Country_Agency**: An agency type with regional management and geographic permissions.
- **Shipping_Agency**: An agency type specializing in high-volume balance transfers.
- **Diamond**: The platform's virtual currency used for gifts and transactions.
- **Earnings_Dashboard**: The UI panel displaying current-month and previous-month income, bonuses, and residual income.
- **Withdrawal_Module**: The UI flow through which agents request payouts from their residual income.
- **Recharge_Order**: A transaction record for a Diamond top-up request, carrying a status of Pending, Success, Failed, or Refunded.
- **TxID**: A blockchain transaction identifier submitted by a user as proof of a USDT payment.
- **Payment_Gateway**: One of the supported payment providers: Fawry, USDT, Google Pay, or Visa/MasterCard.
- **UID**: A unique numeric identifier assigned to each user/agent on the platform.
- **Referral_Log**: A record linking an agent's invite activity to a specific user registration or game event.
- **Agency_Dashboard**: The role-specific screen shown to an authenticated agent or admin.
- **Authorization_Guard**: The UI-level check that restricts access to the Agency_Dashboard to users with an agent or admin role.

---

## Requirements

### Requirement 1: Agency Type Schema

**User Story:** As an Admin, I want a clearly defined structure for each agency type, so that I can manage USDT, Recharge, Country, and Shipping agencies with their distinct properties.

#### Acceptance Criteria

1. THE Agency_System SHALL define four agency types: USDT_Agency, Recharge_Agency, Country_Agency, and Shipping_Agency.
2. THE Agency_System SHALL store, for each agency, a unique UID, display name, agency type, status (active / pending / suspended), and creation date.
3. WHERE an agency is of type Country_Agency, THE Agency_System SHALL store an associated geographic region or country code.
4. WHERE an agency is of type USDT_Agency, THE Agency_System SHALL store a USDT wallet address.
5. WHERE an agency is of type Recharge_Agency, THE Agency_System SHALL store an authorized Diamond credit limit.
6. WHERE an agency is of type Shipping_Agency, THE Agency_System SHALL store a maximum single-transfer balance cap.
7. THE Agency_System SHALL allow new agency types to be added by extending the type enumeration without modifying existing agency records.

---

### Requirement 2: Agency Dashboard Authorization

**User Story:** As a platform operator, I want only authorized agents and admins to access the Agency_Dashboard, so that regular users cannot view or manipulate agency data.

#### Acceptance Criteria

1. WHEN a user navigates to the Agency_Dashboard, THE Authorization_Guard SHALL verify that the user's role is either `agent` or `admin`.
2. IF the user's role is neither `agent` nor `admin`, THEN THE Authorization_Guard SHALL redirect the user to the authentication screen.
3. THE Authorization_Guard SHALL display a role-appropriate dashboard: the Admin view for `admin` role and the Agent view for `agent` role.
4. WHILE a user session is active with role `admin`, THE Agency_Dashboard SHALL display all agency management controls including agency-type management, user management, and financial oversight.
5. WHILE a user session is active with role `agent`, THE Agency_Dashboard SHALL display only that agent's own earnings, subordinates, referrals, and withdrawal controls.

---

### Requirement 3: Earnings Dashboard — Current vs Previous Month

**User Story:** As a Master_Agent, I want to see my current-month and previous-month earnings side by side, so that I can track my financial performance over time.

#### Acceptance Criteria

1. THE Earnings_Dashboard SHALL display the agent's total earnings for the current calendar month.
2. THE Earnings_Dashboard SHALL display the agent's total earnings for the previous calendar month.
3. WHEN the current-month earnings exceed the previous-month earnings, THE Earnings_Dashboard SHALL display a positive trend indicator (e.g., green arrow and percentage change).
4. WHEN the current-month earnings are less than the previous-month earnings, THE Earnings_Dashboard SHALL display a negative trend indicator (e.g., red arrow and percentage change).
5. THE Earnings_Dashboard SHALL display a breakdown of earnings by source: gift commissions, referral bonuses, and sub-agency overrides.
6. THE Earnings_Dashboard SHALL use static/fake data for all monetary values (no backend calls).

---

### Requirement 4: Reward and Bonus Calculation

**User Story:** As a Master_Agent, I want to see my performance-based bonuses calculated automatically, so that I understand what rewards I have earned this month.

#### Acceptance Criteria

1. THE Earnings_Dashboard SHALL calculate a performance bonus when the agent's current-month invite count meets or exceeds the monthly invite target.
2. THE Earnings_Dashboard SHALL calculate a Diamond-volume bonus when the agent's current-month Diamond transaction volume meets or exceeds the monthly volume target.
3. WHEN both the invite target and the volume target are met, THE Earnings_Dashboard SHALL display a combined "Full Bonus" badge.
4. THE Earnings_Dashboard SHALL display each bonus amount alongside the metric that triggered it (invite count or Diamond volume).
5. THE Earnings_Dashboard SHALL display progress bars showing current progress toward each bonus threshold.

---

### Requirement 5: Withdrawal Application Flow

**User Story:** As a Master_Agent, I want to submit a withdrawal request for my residual income, so that I can receive payouts from the platform.

#### Acceptance Criteria

1. THE Withdrawal_Module SHALL display the agent's current withdrawable residual income balance.
2. WHEN an agent taps "Request Withdrawal", THE Withdrawal_Module SHALL present a form requesting withdrawal amount, preferred payment method, and account details.
3. IF the requested withdrawal amount exceeds the available residual income balance, THEN THE Withdrawal_Module SHALL display an error message and prevent submission.
4. IF the requested withdrawal amount is less than the platform minimum withdrawal threshold (static value: 50 Diamonds), THEN THE Withdrawal_Module SHALL display an error message and prevent submission.
5. WHEN a valid withdrawal form is submitted, THE Withdrawal_Module SHALL display a confirmation screen showing the request details and a "Pending" status badge.
6. THE Withdrawal_Module SHALL display a history list of past withdrawal requests with their statuses (Pending, Approved, Rejected).
7. THE Withdrawal_Module SHALL use static/fake data for all balances and history entries (no backend calls).

---

### Requirement 6: Subordinate Agent Management

**User Story:** As a Master_Agent, I want to add and track my Subordinate_Agents by UID, so that I can build and monitor my agency network.

#### Acceptance Criteria

1. THE Agency_System SHALL allow a Master_Agent to add a Subordinate_Agent by entering the subordinate's UID.
2. WHEN a UID is entered, THE Agency_System SHALL validate that the UID is a non-empty numeric string of 6–12 digits.
3. IF the entered UID does not match any known user in the static dataset, THEN THE Agency_System SHALL display a "User not found" error.
4. THE Agency_System SHALL display a list of all Subordinate_Agents under the Master_Agent, showing each subordinate's name, UID, status, total invites, and earnings.
5. WHEN a Master_Agent taps a Subordinate_Agent entry, THE Agency_System SHALL display an expanded detail view with commission rate, join date, and invite code.
6. THE Agency_System SHALL allow a Master_Agent to suspend or reactivate a Subordinate_Agent.
7. THE Agency_System SHALL allow a Master_Agent to remove a Subordinate_Agent after confirming a deletion dialog.
8. THE Agency_System SHALL display aggregate statistics for the Master_Agent's sub-agency network: total subordinates, active count, total network invites, and total network earnings.

---

### Requirement 7: Referral Tracking

**User Story:** As a Master_Agent, I want to see a log of all referral activities linked to my invite code, so that I can monitor which users I have recruited and what game events they have triggered.

#### Acceptance Criteria

1. THE Agency_System SHALL display a Referral_Log listing each user invited via the agent's invite code, showing the invitee's username, UID, join date, and status.
2. THE Agency_System SHALL display, for each Referral_Log entry, the total gifts sent by that invitee and the commission earned by the agent from those gifts.
3. WHEN an invitee has sent gifts in the current month, THE Agency_System SHALL highlight that entry with an "Active" badge.
4. THE Agency_System SHALL display a summary row showing total referrals, total active referrals, and total commission earned from referrals.
5. THE Agency_System SHALL use static/fake data for all referral entries (no backend calls).

---

### Requirement 8: Multi-Gateway Recharge System

**User Story:** As a user or Recharge_Agency, I want to top up Diamonds using multiple payment gateways, so that I can choose the most convenient payment method.

#### Acceptance Criteria

1. THE Agency_System SHALL support the following Payment_Gateways: Fawry, USDT, Google Pay, and Visa/MasterCard.
2. WHEN a user selects a Diamond pack and taps a Payment_Gateway, THE Agency_System SHALL display the appropriate payment flow for that gateway.
3. WHERE the selected Payment_Gateway is USDT, THE Agency_System SHALL present a manual verification flow: display a wallet address, prompt the user to enter a TxID, and show a "Pending Verification" status.
4. WHEN a TxID is submitted in the USDT flow, THE Agency_System SHALL validate that the TxID is a non-empty alphanumeric string of at least 10 characters.
5. IF the TxID fails validation, THEN THE Agency_System SHALL display an inline error message and prevent submission.
6. WHEN a valid TxID is submitted, THE Agency_System SHALL display a confirmation screen with status "Pending" and the submitted TxID.
7. THE Agency_System SHALL display a Recharge_Order history list with columns: Order ID, Diamond amount, payment method, status, and date.
8. THE Agency_System SHALL support the following Recharge_Order statuses: Pending, Success, Failed, and Refunded.
9. WHEN a Recharge_Order status is Pending, THE Agency_System SHALL display a yellow status badge.
10. WHEN a Recharge_Order status is Success, THE Agency_System SHALL display a green status badge.
11. WHEN a Recharge_Order status is Failed or Refunded, THE Agency_System SHALL display a red status badge.
12. THE Agency_System SHALL use static/fake data for all Recharge_Order records (no backend calls).

---

### Requirement 9: USDT Agency Settlement Workflow

**User Story:** As an Admin, I want to review and approve or reject USDT settlement requests submitted by agents, so that crypto-based payouts are verified before Diamonds are credited.

#### Acceptance Criteria

1. THE Agency_System SHALL display a list of pending USDT settlement requests, each showing the requesting agent's name, UID, submitted TxID, requested Diamond amount, and submission date.
2. WHEN an Admin taps "Approve" on a USDT settlement request, THE Agency_System SHALL update that request's status to "Approved" and display a success confirmation.
3. WHEN an Admin taps "Reject" on a USDT settlement request, THE Agency_System SHALL prompt for a rejection reason, then update the request's status to "Rejected".
4. IF a rejection reason is not provided, THEN THE Agency_System SHALL prevent the rejection from being submitted and display a validation error.
5. THE Agency_System SHALL use static/fake data for all USDT settlement records (no backend calls).

---

### Requirement 10: Admin Agency Overview

**User Story:** As an Admin, I want a consolidated overview of all agencies across all types, so that I can monitor platform-wide agency health at a glance.

#### Acceptance Criteria

1. THE Agency_System SHALL display a summary panel showing total agency count broken down by type (USDT, Recharge, Country, Shipping).
2. THE Agency_System SHALL display total platform Diamond volume processed by Recharge_Agencies in the current month.
3. THE Agency_System SHALL display total pending withdrawal requests and their combined value.
4. THE Agency_System SHALL display total pending USDT settlement requests and their combined Diamond value.
5. WHEN an Admin taps an agency type card, THE Agency_System SHALL navigate to a filtered list showing only agencies of that type.
6. THE Agency_System SHALL display each agency in the list with its name, UID, type badge, status badge, and key metric (e.g., volume for Recharge_Agency, region for Country_Agency).
7. THE Agency_System SHALL allow an Admin to change an agency's status between active, suspended, and pending from the agency detail view.
8. THE Agency_System SHALL use static/fake data for all agency records and metrics (no backend calls).

---

### Requirement 11: UI Consistency and Theme

**User Story:** As a developer, I want all new agency screens to follow the existing dark purple design system, so that the UI is visually consistent across the entire application.

#### Acceptance Criteria

1. THE Agency_System SHALL use `AppColors.background` (`#0F0F1E`) as the scaffold background color for all new screens.
2. THE Agency_System SHALL use `AppColors.surface` (`#1A1635`) as the card and container background color.
3. THE Agency_System SHALL use `AppColors.primaryPurple` (`#8B5CF6`) as the primary accent color for buttons, indicators, and highlights.
4. THE Agency_System SHALL reuse existing shared widgets from `agency_widgets.dart` (StatCard, SectionHeader, StatusBadge, GradientButton, LeaderboardRow, TargetRow) wherever applicable.
5. THE Agency_System SHALL NOT include any UI elements related to live room interactions, medals, or host streaming.
6. THE Agency_System SHALL display all monetary values in Diamond (🪙) units unless the context is a fiat payment gateway, in which case the appropriate currency symbol SHALL be used.
