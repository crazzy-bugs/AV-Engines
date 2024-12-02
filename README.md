# Mutli AV Pipeline

Welcome to the **Parallel Script Runner** repository! This project automates the simultaneous execution of three scripts: `malstr_check.sh`, `kappa.sh`, and `sigcheck.sh`, with the results logged into separate files. Follow the steps below to set up and run this repository.

---

## 📂 Project Structure

```
.
.
├── comodo/                 # Comodo AV script
├── escan/                  # Eset Node32 script
├── mcafee/                 # McAfee AV script
├── test_build/             # Test configurations
├── windows-defender/       # Windows Defender script
├── static_analysis.sh      # Unified script for static malware analysis
├── capa.exe                # Static analysis tool (YARA ruleset matching)
├── Sigcheck.zip            # Static metadata analysis tool
├── Strings.zip             # Malicious string analysis tool
├── D:/Test/Logs/           # Output log directory
```

---

## 🚀 Setup Instructions

1. **Clone or Download the Repository:**
   ```bash
   git clone https://github.com/your-username/parallel-script-runner.git
   cd parallel-script-runner
   ```

2. **Prepare Required Tools:**
   - Download and extract the following tools:
     - **Strings**
     - **Sigcheck**
   - Copy the extracted contents along with `capa.exe` into:
     - `C:/Windows/System32`, or
     - Add the directory containing these files to your system's environment `PATH` variable.

3. **Verify Prerequisites:**
   Ensure the following commands are accessible from any terminal:
   - `capa.exe`
   - `strings`
   - `sigcheck`

---

## 🔧 How to Run

1. Place your input file in a known directory.
2. Run the master script with the file path as an argument:
   ```bash
   ./run_scripts_parallel.sh <absolute-path-to-input-file>
   ```

   Example:
   ```bash
   ./run_scripts_parallel.sh "C:/Users/Example/input_file.exe"
   ```

3. Logs will be saved in `D:/Test/Logs`:
   - `malstr_check.log`
   - `kappa.log`
   - `sigcheck.log`

---

## ✨ Features

- Executes three scripts (`malstr_check.sh`, `kappa.sh`, and `sigcheck.sh`) in parallel.
- Stores outputs in dedicated log files.
- Automatically overwrites logs on every run.

---

## 🛠️ Troubleshooting

### Logs Not Found
Ensure the directory `D:/Test/Logs` exists or is created automatically by the script.

### Commands Not Found
Double-check that `capa.exe`, `strings`, and `sigcheck` are in `C:/Windows/System32` or included in the environment `PATH`.

---

## 📜 License
This project is licensed under the [MIT License](LICENSE).

---

## 🤝 Contributing
Feel free to fork this repository and submit pull requests. Any contributions are greatly appreciated!

