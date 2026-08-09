@echo off
echo Starting all services...

:: Redis
start "Redis" /MIN cmd /c "C:\Program Files\Redis\redis-server.exe"

:: Backend (Java)
start "Backend" /MIN cmd /c "cd /d E:\smart-learning-system\backend && mvn spring-boot:run"

:: Agent (Python)
start "Agent" /MIN cmd /c "set PYTHONUNBUFFERED=1 && E:\smart-learning-system\agent\.venv\Scripts\python.exe E:\smart-learning-system\agent\src\main.py"

:: Frontend (Vue)
start "Frontend" /MIN cmd /c "cd /d E:\smart-learning-system\frontend && npm run dev"

echo All services started! Visit http://localhost:5173
