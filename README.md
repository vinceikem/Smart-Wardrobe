#  Smart Wardrobe

## Overview

Smart Wardrobe is an open-source project that helps users organize, manage, and generate outfit recommendations using a polyglot architecture. This repository contains both the **frontend** and **backend** codebases, structured for easy development and deployment.

## Tech Stack

This project is built using a polyglot architecture, leveraging the following technologies:

| Component | Technology | Description |
| :--- | :--- | :--- |
| **Frontend** | Flutter / Dart | Cross-platform UI development (iOS, Android, Web). |
| **Backend** | Node.js / Express | Robust and scalable API services and business logic. |
| **API** | REST | Standard protocol for communication between frontend and backend. |
| **Version Control** | Git | Used for source control and collaboration. |

## Project Structure

```text
root/
├── backend/   # API services, authentication, business logic
├── frontend/  # Flutter app (UI + client logic)
└── README.md    # You are here
```

## Getting Started

### Prerequisites

* Node.js / npm (for backend)
* Flutter SDK (for frontend)
* Git

### Installation

Clone the repository:
```bash
git clone [https://github.com/your-username/smart-wardrobe.git](https://github.com/your-username/smart-wardrobe.git)
cd smart-wardrobe
```
Install backend dependencies:
```bash
cd backend
npm install
```
Install frontend dependencies:
```bash
cd ../frontend
flutter pub get
```

### **Running the Project**:
Start the backend:
```bash
cd backend
npm run test
```
Start the frontend:
```bash
cd ../frontend
flutter run
```

## **Contributing**
Contributions are welcome!

* Fork the repo

* Create a feature branch

* Submit a pull request

## License
This project is licensed under the MIT License. See the `LICENSE` file for details.