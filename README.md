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

![Screenshot 2025-08-12 at 12 40 30 PM](https://github.com/user-attachments/assets/41392db6-0222-46e3-8e72-2cb0d021fabf)

Transactions

List of all expenses with date, category, and details.

![Screenshot 2025-08-12 at 12 41 17 PM](https://github.com/user-attachments/assets/db0ae265-11c2-43e6-bfa2-d1cd3664ba56)

Set Budget

Easily set or adjust monthly budgets per category.

![Screenshot 2025-08-12 at 12 41 39 PM](https://github.com/user-attachments/assets/3a1a7238-895a-4935-9352-cbaabb56f8a7)

AI Q&A Analysis

Ask CrewAI about your budget trends and overspending patterns.

![Screenshot 2025-08-12 at 12 51 04 PM](https://github.com/user-attachments/assets/b73ccc72-76cf-49be-bd33-f2135ad4b402)

⸻

🛠 Tech Stack
	•	Frontend: Flutter
	•	Backend: Flask (Python), SQLite
	•	AI: CrewAI
	•	Deployment: Docker on Raspberry Pi
	•	Networking: Tailscale VPN
