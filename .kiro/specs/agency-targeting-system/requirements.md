# Requirements Document

## Introduction

This feature adds a **Targeting System** to the existing agency admin dashboard, inspired by the Heylla app model. The system is a UI-only implementation (all data is static/fake — no backend integration). It introduces performance targets for agents with tiered rewards (Bronze → Silver → Gold → Platinum), a "My Targets" screen on the agent side with progress tracking and a "Claim Reward" flow, an admin-side Targets tab for creating and assigning targets, and a target-completion leaderboard. The app uses a dark purple theme (`#0F0F1E` background, `#1A1635` surface, `#8B5CF6` primary purple).

---

## Glossary

- **Targeting_System**: The complete targeting feature described in this document.
- **Admin**: A privileged user who manages the platform and can create, edit, and assign targets.
- **Agent**: A platform user with an agent role who receives and works toward assigned targets.
- **Target**: A performance goal assigned to one or more agents, defined by a type, goal value, tier, reward, and deadline.
- **Target_Type**: The category of a target. Supported types: Invite, Diamond_Earning, Active_Hours, Gift_Sending, Recharge_Volume.
- **Tier**: The reward level associated with a target's completion percentage. Tiers are: Bronze (0–25%), Silver (26–50%), Gold (51–75%), Platinum (76–100%).
- **Reward**: The benefit granted to an agent upon reaching a tier threshold: Diamonds, a bonus percentage, or a special badge.
- **Progress**: The ratio of an agent's current metric value to the target's goal value, expressed as a percentage (0–100).
- **Claim_Reward**: The action an agent takes to collect a reward for a completed (100%) target.
- **Rewards_Wallet**: The accumulated record of claimed and unclaimed rewards for an agent.
- **Targets_Tab**: The new admin dashboard tab (7th tab) dedicated to target management.
- **My_Targets_Screen**: The agent-facing screen showing all targets assigned to the logged-in agent.
- **Target_Leaderboard**: A ranked list of agents ordered by the number of targets completed in the current month.
- **Assignment_Scope**: Defines who a target is assigned to: a specific agent by UID, or all agents of a given agency type.

---

## Requirements

### Requirement 1: Target Data Model

**User Story:** As a developer, I want a well-defined static data model for targets, so that all screens share a consistent structure without backend calls.

#### Acceptance Criteria

1. THE Targeting_System SHALL define a Target record containing: a unique ID, Target_Type, goal value (numeric), deadline (date string), tier thresholds, reward definition, Assignment_Scope, and per-agent progress entries.
2. THE Targeting_System SHALL support the following Target_Types: `invite`, `diamond_earning`, `active_hours`, `gift_sending`, and `recharge_volume`.
3. THE Targeting_System SHALL define four Tier levels — Bronze, Silver, Gold, Platinum — each with a minimum completion percentage threshold (25%, 50%, 75%, 100% respectively) and an associated reward value.
4. THE Targeting_System SHALL store, for each agent assigned a target, the agent's current metric value, computed Progress percentage, tier reached, reward claimed status, and reward amount.
5. THE Targeting_System SHALL use static/fake data for all target records and agent progress entries (no backend calls).

---

### Requirement 2: Admin — Targets Tab

**User Story:** As an Admin, I want a dedicated Targets tab in the admin dashboard, so that I can manage all performance targets from one place.

#### Acceptance Criteria

1. THE Targets_Tab SHALL be added as the 7th tab in the Admin_Dashboard, labelled "🎯 Targets".
2. THE Targets_Tab SHALL display a summary row of stat cards showing: total active targets, total agents with at least one assigned target, total completed targets (Progress = 100%) this month, and total unclaimed rewards across all agents.
3. THE Targets_Tab SHALL display a scrollable list of all targets, each showing: Target_Type icon, goal value, deadline, tier badge of the highest tier reached by any agent, and a count of agents assigned vs. agents who completed it.
4. WHEN an Admin taps a target in the list, THE Targets_Tab SHALL display an expanded detail view showing per-agent progress rows (agent name, Progress bar, current value / goal value, tier badge, claimed status).
5. THE Targets_Tab SHALL provide a "＋ New Target" button that opens a creation form.
6. WHEN an Admin taps "＋ New Target", THE Targeting_System SHALL display a form with fields: Target_Type (dropdown), goal value (numeric input), deadline (date string input), Assignment_Scope (all agents or specific UID), and reward per tier (four numeric inputs for Bronze/Silver/Gold/Platinum).
7. WHEN the creation form is submitted with all required fields filled, THE Targeting_System SHALL add the new target to the static target list and display a success confirmation.
8. IF any required field in the creation form is empty or invalid, THEN THE Targeting_System SHALL display an inline validation error and prevent submission.
9. THE Targets_Tab SHALL allow an Admin to delete an existing target after confirming a deletion dialog.
10. THE Targeting_System SHALL use static/fake data for all admin target operations (no backend calls).

---

### Requirement 3: Agent — My Targets Screen

**User Story:** As an Agent, I want a "My Targets" screen showing all my assigned targets with progress and rewards, so that I can track my performance and claim earned rewards.

#### Acceptance Criteria

1. THE My_Targets_Screen SHALL be accessible from the agent dashboard's existing "🎯 Targets" tab.
2. THE My_Targets_Screen SHALL display a summary showing: total targets assigned, targets completed (Progress = 100%), and total rewards earned (sum of all claimed reward amounts).
3. THE My_Targets_Screen SHALL display each assigned target as a card containing: Target_Type icon and label, goal value, deadline, a Progress bar, current value / goal value, and the current Tier badge.
4. WHILE a target's Progress is less than 100%, THE My_Targets_Screen SHALL display the Progress bar in the tier's associated color and show the next tier threshold as a milestone marker.
5. WHEN a target's Progress reaches 100%, THE My_Targets_Screen SHALL display a "Claim Reward" button on that target's card.
6. WHEN an Agent taps "Claim Reward", THE Targeting_System SHALL mark the reward as claimed, update the Rewards_Wallet balance, and replace the button with a "✅ Claimed" indicator.
7. IF a target's reward has already been claimed, THEN THE My_Targets_Screen SHALL display a "✅ Claimed" indicator instead of the "Claim Reward" button.
8. THE My_Targets_Screen SHALL display a Tier badge for each target using the following color scheme: Bronze = `#CD7F32`, Silver = `#C0C0C0`, Gold = `#FFD700`, Platinum = `#E5E4E2` with a special sparkle icon.
9. THE My_Targets_Screen SHALL use static/fake data for all target and progress values (no backend calls).

---

### Requirement 4: Tier Progression and Rewards

**User Story:** As an Agent, I want to see which tier I have reached for each target and what reward I will receive, so that I am motivated to push toward higher tiers.

#### Acceptance Criteria

1. THE Targeting_System SHALL compute the current Tier for each agent-target pair based on Progress: Bronze for Progress 1–25%, Silver for 26–50%, Gold for 51–75%, Platinum for 76–100%.
2. WHEN Progress is 0%, THE Targeting_System SHALL display no tier badge (unstarted state).
3. THE My_Targets_Screen SHALL display the reward amount for each tier on the target card, highlighting the currently reached tier and greying out higher tiers not yet achieved.
4. WHEN an agent reaches Platinum tier (Progress ≥ 76%), THE My_Targets_Screen SHALL display a special "⭐ Platinum" badge with a distinct visual treatment (gradient border or shimmer effect).
5. THE Targeting_System SHALL accumulate reward amounts in the Rewards_Wallet only when the agent taps "Claim Reward" for a completed (100%) target.
6. THE My_Targets_Screen SHALL display the Rewards_Wallet balance as a persistent header showing total claimed Diamonds and count of unclaimed completed targets.

---

### Requirement 5: Rewards Wallet

**User Story:** As an Agent, I want a Rewards Wallet showing my accumulated rewards, so that I can see my total earnings from completed targets.

#### Acceptance Criteria

1. THE Rewards_Wallet SHALL display the total Diamonds claimed from all completed targets.
2. THE Rewards_Wallet SHALL display a count of completed targets with unclaimed rewards, prompting the agent to claim them.
3. WHEN all completed target rewards have been claimed, THE Rewards_Wallet SHALL display a "All rewards claimed! 🎉" message.
4. THE Rewards_Wallet SHALL display a history list of claimed rewards, each entry showing: Target_Type icon, reward amount in Diamonds, tier level, and claim date.
5. THE Targeting_System SHALL use static/fake data for all Rewards_Wallet entries (no backend calls).

---

### Requirement 6: Target Completion Leaderboard

**User Story:** As an Admin and as an Agent, I want to see a leaderboard of agents ranked by targets completed this month, so that top performers are recognized.

#### Acceptance Criteria

1. THE Target_Leaderboard SHALL display agents ranked in descending order by the number of targets completed (Progress = 100%) in the current month.
2. THE Target_Leaderboard SHALL show, for each ranked agent: rank position, username, number of targets completed, and total Diamonds earned from target rewards.
3. THE Target_Leaderboard SHALL use the existing `LeaderboardRow` widget from `agency_widgets.dart` for each row.
4. THE Target_Leaderboard SHALL be accessible from both the Targets_Tab (admin view) and the My_Targets_Screen (agent view) as a sub-section or navigable panel.
5. THE Target_Leaderboard SHALL highlight the top 3 agents with rank medals (🥇, 🥈, 🥉) consistent with the existing `LeaderboardRow` widget behavior.
6. THE Targeting_System SHALL use static/fake data for all leaderboard entries (no backend calls).

---

### Requirement 7: UI Consistency and DDC Safety

**User Story:** As a developer, I want all new targeting screens to follow the existing design system and Flutter DDC constraints, so that the UI is visually consistent and crash-free.

#### Acceptance Criteria

1. THE Targeting_System SHALL use `AppColors.background` (`#0F0F1E`) as the scaffold background for all new screens.
2. THE Targeting_System SHALL use `AppColors.surface` (`#1A1635`) as the card and container background color.
3. THE Targeting_System SHALL use `AppColors.primaryPurple` (`#8B5CF6`) as the primary accent color for buttons, indicators, and highlights.
4. THE Targeting_System SHALL reuse existing shared widgets from `agency_widgets.dart` (`StatCard`, `SectionHeader`, `StatusBadge`, `GradientButton`, `LeaderboardRow`, `TargetRow`) wherever applicable.
5. THE Targeting_System SHALL extend the existing `TargetRow` widget or create a new `TieredTargetRow` widget that adds tier badge and "Claim Reward" button support without breaking existing usages.
6. WHEN any `build()` method in a new widget class would exceed approximately 80 lines, THE Targeting_System SHALL split it into separate named widget classes to comply with DDC crash-prevention constraints.
7. THE Targeting_System SHALL NOT introduce any backend calls, network requests, or async data fetching beyond what already exists in `AgencyApi`.
