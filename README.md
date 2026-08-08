# Intelligent IoT Data Management Platform 

A modular platform for intelligent anomaly detection and visualization of time series sensor data from IoT devices.

## Overview

The Intelligent IoT Data Management Platform is designed to provide a smarter way to manage, analyze, and visualize sensor data collected from a variety of Internet of Things (IoT) devices. By leveraging real-time data collection and advanced analytics, the platform automatically monitors incoming sensor streams, identifies faults and anomalies, and presents insights through a modern, interactive dashboard. The system is suitable for a wide range of IoT use cases, from smart home applications to industrial monitoring and automation.

## Goals

- **Detect anomalies and faults in real-time sensor data:**  
  The platform continuously analyzes incoming time series data to discover unusual patterns that may indicate system faults or critical issues. Early detection enables proactive maintenance and smarter decision-making.

- **Visualize correlations and anomalies:**  
  Users can view sensor data trends, correlations between different sensor streams, and detected anomalies through intuitive, interactive visualizations. This helps users understand relationships in their data and quickly spot problems.

- **Support integration with live data sources:**  
  The backend is architected to allow easy integration with live data streams, making it possible to connect to real-world sensors and receive insights in real time.

## Tech Stack

### Frontend
- **React.js** for building a dynamic application with a responsive user interface.
- **Rechart.js & chart.js** for displaying charts.  
- **Tailwind CSS** for fast, consistent, and modern styling, ensuring the UI is both attractive and user-friendly.

### Backend
- **Node.js** provides a performant server environment for handling API requests, data validation, and session management.
- **WebSocket** enables real-time, bidirectional communication, making instant data updates and live visualizations possible.

### Data Science
- **Python** with libraries such as Pandas and NumPy for data manipulation and cleaning.
- **Jupyter** is used during development for exploratory data analysis and prototyping models.
- **Plotly** provides rich, interactive charts and graphs for advanced visualizations.
- **Flask** exposes machine learning models and data processing workflows as APIs for easy backend integration.

### DevOps & Collaboration
- **Docker** ensures consistent environments and simplifies deployment across different systems.
- **GitHub** is used for version control, collaboration, and continuous development/deployment, with clear project tracking and code review processes.

## Features
- **Correlation analysis and anomaly detection:**  
  The system identifies relationships between sensor streams using correlation analysis, and detects outliers using multiple machine learning approaches, including Z-score, Isolation Forest, LSTM, and One-Class SVM.

- **Interactive dashboard with graph visualizations:**  
  The web application provides a graph dashboard for visualizing sensor data, correlations, and anomalies. Light and dark mode options are included for user comfort.

- **Export options (PNG, CSV):**  
  Users can export processed data and visualizations for further analysis or reporting.

- **Authentication (login/registration):**  
  Secure endpoints enable user login and registration, with planned support for role-based access control.

- **Real-time data streaming (WebSocket-ready):**  
  The backend is set up to support real-time streaming, so users can connect live sensors for up-to-date analysis and insights.

- **Modular, Dockerized structure:**  
  Every component is modular and containerized, making the system easy to extend, maintain, and deploy.

## Next Steps

- **Heatmaps for correlations, sensor grouping, draggable graphs:**  
  Future updates will add support for more advanced visualizations, including heatmaps to show sensor relationships, grouping of related sensors, and draggable time windows for easier analysis.

- **Full pipeline automation and real-time integration:**  
  The goal is to automate the entire process—from data filtering and correlation analysis to anomaly detection—so users can get results in real-time with minimal manual intervention.

- **Enhanced mobile responsiveness and UI controls:**  
  The frontend will be improved for better usability on mobile devices and large sensor networks, with optimized dropdowns, filters, and controls.

- **Expanded documentation and onboarding:**  
  Clearer guides and training material will be provided to help new users and contributors get started quickly.

## Contributing

We welcome data scientists, developers, and IoT engineers to build upon and extend this project! The codebase is modular, clean, and well-documented, making it easy to add new features or integrate new data sources. Docker and .env files ensure a flexible and consistent development environment. Whether you want to improve the machine learning models, enhance the frontend, or integrate with new sensors, your contributions are valued. Check out open issues and feature requests on GitHub to get started—pick up where we left off and keep building!

## Docker Development Setup

The repository now includes a local Docker development environment for the active frontend, backend, and PostgreSQL database.

### Services

- `db`: PostgreSQL 16 with the schema loaded from `backend/src/db/schema.sql`
- `backend`: Node.js Express API on `http://localhost:3000`
- `frontend`: Vite React app on `http://localhost:5173`

### Start the stack

Run the following from the repository root:

```bash
docker compose up --build
```

### Stop the stack

```bash
docker compose down
```

To also remove the database volume:

```bash
docker compose down -v
```

### Notes

- The frontend proxies `/api` requests to the backend container, so browser requests work without hardcoding container hostnames.
- The backend connects to PostgreSQL using the Compose service name `db`.
- The Docker backend includes default ThingSpeak polling values and uses the public test channel `12397`. Replace them if you want to poll your own ThingSpeak channel.
- Source folders are mounted into the containers for live development updates.
- Existing draft Docker assets under `Docker/` were left in place, but `docker-compose.yml` at the repository root is the supported local setup.

## Contact

Questions, suggestions, or want to join the project?  
Reach out by opening a GitHub issue or pull request. Training material and onboarding docs are available for new contributors.

Good luck, and enjoy the journey! 🌟
