import os
import subprocess
from flask import Flask, request, jsonify
import requests

app = Flask(__name__)
UPLOAD_FOLDER = r"C:\uploads"
SCAN_RESULTS_API = "http://host.docker.internal:6000/api/scan-results"  # Replace with your endpoint

os.makedirs(UPLOAD_FOLDER, exist_ok=True)

def scan_file_with_defender(file_path):

    defender_path = r"C:\Program Files\Windows Defender\MpCmdRun.exe"

    try:
        
        result = subprocess.run(
            [defender_path, "-Scan", "-ScanType", "3", "-File", file_path],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            shell=True
        )

        output = result.stdout + result.stderr

        if "found no threats" in output:
            status = "clean"
        elif "threat" in output.lower() or "detected" in output.lower():
            status = "infected"
        else:
            status = "unknown"

        return {"file": file_path, "status": status, "details": output}
    except Exception as e:
        return {"file": file_path, "status": "error", "details": str(e)}

@app.route("/upload", methods=["POST"])
def upload_file():
    
    if "file" not in request.files:
        return jsonify({"error": "No file provided"}), 400

    file = request.files["file"]
    if file.filename == "":
        return jsonify({"error": "No file selected"}), 400

    file_path = os.path.join(UPLOAD_FOLDER, file.filename)
    file.save(file_path)

    scan_result = scan_file_with_defender(file_path)

    try:
        response = requests.post(SCAN_RESULTS_API, json=scan_result)
        response.raise_for_status()
        api_response = response.json()
    except Exception as e:
        api_response = {"error": str(e)}

    try:
        os.remove(file_path)
    except Exception as e:
        return jsonify({"error": f"Failed to delete file: {str(e)}", "scan_result": scan_result}), 500

    return jsonify({"scan_result": scan_result, "api_response": api_response})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)