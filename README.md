# Agentforce Agents Scripts Starter

This repository contains starter templates for building Agentforce Agents using scripts. It includes multiple example agents with different use cases, configuration patterns, and integration examples.

## 📋 Table of Contents

- [Overview](#overview)
- [Files in This Repository](#files-in-this-repository)
- [Getting Started](#getting-started)
- [Agent Templates](#agent-templates)
- [Configuration Reference](#configuration-reference)

## Overview

This starter kit provides production-ready agent templates built with Agentforce scripting language. Each agent demonstrates different capabilities including:
- Multi-topic conversation flows
- Variable management and state tracking
- System actions and tool integrations
- User confirmation and progress indicators
- Custom Apex integrations

## Files in This Repository

### Agent Configuration Files (YAML)

#### 1. **MyFirstAgent.yaml**
**Purpose:** Beginner-friendly customer support agent template  
**Use Case:** Process customer inquiries for orders, returns, and general product questions

**Key Features:**
- Simple multi-step conversation flow
- Customer name capture and personalization
- Order inquiry routing
- Error handling with friendly messages

**How to Use:**
1. Import this file into your Agentforce environment as a new agent configuration
2. Customize the `system.instructions` section with your specific business rules
3. Update the `config.default_agent_user` with your Salesforce user ID
4. Modify welcome and error messages in the `messages` section
5. Extend the agent with additional topics based on your support needs

**Topics Included:**
- `agent_router`: Entry point that routes to the Greeting subagent
- `Greeting`: Captures customer name and determines what help is needed

---

#### 2. **CoralCloudAgent.yaml**
**Purpose:** Advanced enterprise employee agent for CRM operations  
**Use Case:** Assist Salesforce employees with common CRM tasks, knowledge searches, and data queries

**Key Features:**
- Topic-based routing system (topic_selector)
- Multiple specialized topics (off_topic, ambiguous_question, GeneralCRM)
- Integration with Salesforce CRM search and data retrieval
- Multiple actions for querying, identifying, and updating records
- Knowledge article integration with citations support
- Multi-language support (en_US, en_GB)

**How to Use:**
1. Deploy this agent for internal employee support workflows
2. Configure knowledge sources in the `knowledge` section for your help articles
3. Customize the `GeneralCRM` topic reasoning to match your org's data retrieval needs
4. Update the action sources to match your Salesforce org's action names
5. Enable/disable citations based on your requirements

**Topics Included:**
- `topic_selector`: Routes user requests to appropriate topics
- `off_topic`: Politely redirects off-topic requests
- `ambiguous_question`: Helps users clarify vague requests
- `GeneralCRM`: Handles CRM queries and operations

**Available Actions:**
- IdentifyObjectByName: Find Salesforce objects by name
- IdentifyRecordByName: Search records by name
- QueryRecords: Retrieve records based on criteria
- QueryRecordsWithAggregate: Perform aggregation queries (count, sum, avg, etc.)
- GetActivityDetails: Fetch activity information
- GetRecordDetails: Get comprehensive record information
- UpdateRecordFields: Modify record data
- ExtractFieldsAndValuesFromUserInput: Extract parameters from user input
- Personalized_Experiences_for_Guest: Custom prompt-based action for guest experiences

---

#### 3. **InterviewerAgent.yaml**
**Purpose:** Candidate screening and interview automation  
**Use Case:** Conduct initial screening interviews following a structured interview workflow

**Key Features:**
- Multi-step interview process with state management
- Sequential topic transitions (Permission → Eligibility → Availability → Competency → Salary)
- Variable tracking to maintain interview progress
- Escalation to human agents
- Off-topic and ambiguous question handling

**How to Use:**
1. Deploy for recruiting workflows to screen candidates
2. Customize each topic's interview questions in the `reasoning.instructions` section
3. Update validation rules for each interview step based on your requirements
4. Configure the escalation topic to route to your HR team
5. Modify the final outcomes (pass_to_human vs end_interview) based on your criteria

**Interview Stages:**
1. **Permission**: Verify legal right to work
2. **Eligibility**: Check minimum qualifications (e.g., NCLEX-RN for nursing roles)
3. **Availability**: Determine start date
4. **Competency**: Assess job-related knowledge
5. **Salary**: Capture compensation expectations
6. **Human Handoff**: Pass qualified candidates to HR
7. **End Interview**: Inform unqualified candidates

**State Variables:**
- `currentInterviewStep`: Tracks position in interview workflow

---

### Support Files

#### 4. **PromptTemplate.md**
**Purpose:** Example prompt configuration for the Personalized Guest Experiences action  
**Use Case:** Template for formatting agent prompts that invoke custom Apex code

**How to Use:**
1. Copy the prompt structure for similar use cases
2. Replace placeholder variables (like `{!$Apex:PersonalizedGuestExperiences.Prompt}`) with your action output
3. Customize the formatting instructions for your specific needs
4. Use in your agent's reasoning section or as a separate prompt template

**Key Elements:**
- Bullet-list formatting for clarity
- Dynamic data injection via Apex methods
- Guest interaction messaging
- Activity/experience presentation

---

#### 5. **PersonalizedGuestExperiences.cls**
**Purpose:** Apex utility class for fetching and formatting personalized activity recommendations  
**Use Case:** Retrieve matching guest activities/experiences and format them for agent prompts

**How to Use:**

**Step 1: Deploy to Your Org**
1. Copy the full Apex code to your Salesforce org
2. Create a new Apex class named `PersonalizedGuestExperiences`
3. Deploy using Workbench, VS Code, or Salesforce CLI

**Step 2: Configure Required Objects**
The class expects the following custom fields and objects:
- **Contact**: `Interest1__c`, `Interest2__c`, `Interest3__c` (Text fields for interests)
- **Session__c**: Custom object with fields:
  - `Experience_Name__c` (Text)
  - `Date__c` (Date)
  - `Start_Time__c` (Time)
  - `Duration_Hours__c` (Number)
  - `Location__c` (Text)
  - `Is_Canceled__c` (Checkbox)
  - `Experience__r.Type__c` (Related Experience object, Text field "Type")

**Step 3: Register as Invocable Action**
1. In your agent YAML, reference this class as an action:
   ```yaml
   MyAction: @actions.PersonalizedGuestExperiences
       with "Input:myContact" = ...
   ```

2. Example integration in agent:
   ```yaml
   Personalized_Experiences_for_Guest: @actions.Personalized_Experiences_for_Guest
       with "Input:myContact" = ...
       description: "Get personalized activity recommendations"
   ```

**Method Details:**

`getSessions(List<Request> requests)` - Public invocable method
- **Input**: List of Request objects containing Contact records
- **Output**: List of Response objects containing formatted session recommendations
- **Logic**:
  1. Collects all guest interests from contacts (bulkified)
  2. Queries all sessions matching interests for today
  3. Deduplicates results
  4. Formats up to 10 sessions per guest
  5. Returns formatted strings for LLM processing

**Key Features:**
- Bulk-safe: Processes multiple contacts in single method call
- SOQL Security: Uses `WITH SECURITY_ENFORCED`
- Error Handling: Graceful exception handling with debug logging
- Formatting: Produces human-readable, LLM-friendly output

**Example Output:**
```
Recommended Sessions for Today:
- Yoga Class at 9:00 AM (1.5 hrs), Location: Studio A
- Wine Tasting at 2:00 PM (2 hrs), Location: Terrace
- Cooking Class at 6:00 PM (3 hrs), Location: Kitchen
```

---

## Getting Started

### Prerequisites
- Salesforce org with Agentforce enabled
- Basic understanding of Salesforce YAML agent configuration
- Apex development knowledge (for custom integrations)
- Appropriate user permissions for agent deployment

### Step 1: Choose Your Template
- Start with **MyFirstAgent.yaml** if you're new to Agentforce
- Use **CoralCloudAgent.yaml** for enterprise CRM automation
- Deploy **InterviewerAgent.yaml** for recruiting workflows

### Step 2: Customize for Your Use Case
1. Update `system.instructions` with your business logic
2. Modify topics and reasoning to match your workflow
3. Configure actions to call your Salesforce org's custom services
4. Update variable definitions for your data model

### Step 3: Deploy Apex Support (if needed)
1. Deploy **PersonalizedGuestExperiences.cls** to your org
2. Create required custom objects and fields
3. Register the class as an invocable action in Agentforce

### Step 4: Test and Iterate
1. Deploy agent to your org
2. Test each topic and conversation path
3. Refine prompts based on LLM responses
4. Add additional topics for new use cases

---

## Agent Templates

| Template | Use Case | Complexity | Key Topics |
|----------|----------|-----------|-----------|
| MyFirstAgent.yaml | Customer Support | Beginner | Greeting, Order Inquiry |
| CoralCloudAgent.yaml | Employee CRM Assistant | Advanced | Topic Selector, GeneralCRM, Off-Topic |
| InterviewerAgent.yaml | Recruitment | Intermediate | Permission, Eligibility, Availability, Competency, Salary |

---

## Configuration Reference

### Common YAML Sections

#### System Configuration
```yaml
system:
    instructions: "Agent behavior and guidelines"
    messages:
        welcome: "Greeting message"
        error: "Error handling message"
```

#### Agent Metadata
```yaml
config:
    developer_name: "Internal identifier"
    default_agent_user: "Salesforce user ID"
    agent_label: "Display name"
    description: "Agent purpose"
```

#### Variables
```yaml
variables:
    variableName: mutable/linked string/id
        description: "Variable purpose"
        label: "Display label"
        source: "@MessagingSession.FieldName"  # For linked variables
```

#### Topics
```yaml
topic topic_name:
    label: "Display name"
    description: "Topic purpose"
    reasoning:
        instructions: |
            Agent reasoning with conditionals and actions
        actions:
            actionName: @type.action
                with parameter = ...
                description: "Action purpose"
```

---

## Best Practices

1. **State Management**: Use variables to maintain conversation context across topics
2. **Bulk Operations**: Minimize SOQL queries using bulkification in Apex
3. **Error Handling**: Always include error messages in system.messages
4. **Security**: Use `WITH SECURITY_ENFORCED` in SOQL queries
5. **Testing**: Test edge cases and off-topic scenarios
6. **Escalation**: Configure human handoff for complex issues
7. **Localization**: Support multiple languages using additional_locales

---

## Troubleshooting

**Agent not transitioning between topics:**
- Verify action names match exactly
- Check variable assignments in setVariables actions
- Review conditional logic in routing rules

**Missing action outputs:**
- Ensure Apex class is deployed and registered
- Verify input parameters are correctly passed
- Check SOQL queries for security enforced issues

**Formatting issues in agent responses:**
- Review PromptTemplate.md formatting
- Verify Apex formatSessionsForLLM method
- Test with sample data

---

## Support and Resources

- Review each agent's comments for specific configuration guidance
- Refer to the Apex class documentation for custom integrations
- Test agents in sandbox before production deployment
