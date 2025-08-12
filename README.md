# budget_tracker_flutter

🚀 Features

📱 Flutter Mobile App
	•	Dashboard View: Displays total budget, expenses, and remaining balance.
	•	Category Summary: Visual bar chart of spending by category.
	•	Detailed Transactions: View itemized spending with dates and notes.
	•	Budget Management: Add/update budget allocations per category.
	•	AI Q&A Assistant: Ask natural language questions about your spending patterns.

🧠 CrewAI-powered Analysis
	•	Integrated CrewAI API to analyse spending habits.
	•	Supports complex queries like:
“In which categories did I exceed my budget in the last 3 months and by how much?”
	•	Provides actionable insights and over-budget alerts.

🖥 Backend (Flask API + SQLite)
	•	REST API for retrieving and storing:
	•	Transactions
	•	Budgets
	•	Lightweight SQLite database for local data persistence.

⚙ Infrastructure
	•	Both Flask API and CrewAI Application API containerized using Docker.
	•	Deployed on Raspberry Pi for a low-cost, always-on backend.
	•	Accessible remotely via Tailscale VPN.

⸻

🏗 Architecture

Workflow:
	1.	Flutter Mobile App → Fetches budget & transaction data from Flask API.
	2.	Flask API → Reads/writes data in a SQLite database.
	3.	Mobile App → Sends analytical questions to CrewAI API.
	4.	CrewAI API → Processes data & returns insights.
	5.	Both APIs run in Docker containers on a Raspberry Pi, accessible anywhere via Tailscale VPN.

⸻

📷 Screenshots

Dashboard

Shows total budget, total expenses, and a visual spending summary.

![Dashboard Screenshot](Screenshot%202025-08-12%20at%2012.40.30 PM.jpeg)

Transactions

List of all expenses with date, category, and details.

![Transactions Screenshot](Screenshot%202025-08-12%20at%2012.41.17 PM.jpeg)

Set Budget

Easily set or adjust monthly budgets per category.

![Set Budget Screenshot](Screenshot%202025-08-12%20at%2012.41.39 PM.jpeg)

AI Q&A Analysis

Ask CrewAI about your budget trends and overspending patterns.

![Ask About Budget Screenshot](Screenshot%202025-08-12%20at%2012.51.04 PM.jpeg)

⸻

🛠 Tech Stack
	•	Frontend: Flutter
	•	Backend: Flask (Python), SQLite
	•	AI: CrewAI
	•	Deployment: Docker on Raspberry Pi
	•	Networking: Tailscale VPN
