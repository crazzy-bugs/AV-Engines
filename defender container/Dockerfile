FROM dockurr/windows:latest

WORKDIR /app

RUN powershell -Command \
    Set-ExecutionPolicy Bypass -Scope Process -Force; \
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; \
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')); \
    choco install -y python pip

RUN pip install --upgrade pip && \
    pip install flask requests

COPY defenderscan.py .

EXPOSE 5000

CMD ["python", "defenderscan.py"]