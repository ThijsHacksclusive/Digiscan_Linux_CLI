# 🛡️ Scanner Project

Bash-based toolkit for web application auditing using `testssl.sh`, `ffuf`, `curl`, and custom checks.

---

## 📦 Installation

Clone the project and run the install script:

```bash
sudo git clone https://github.com/ThijsHacksclusive/Digiscan_Linux_CLI.git; sudo chmod -R +x Digiscan/; cd Digiscan; cd scanner; sudo chmod +x ttab; sudo mv ttab /usr/local/bin/
./install.sh

#  scanner/
#  ├── install.sh                   # 👈 New setup script
#  ├── README.md                    # 👈 Project instructions
#  ├── scanner_met_menu.sh         # Main launcher
#  ├── test.sh                     # Called by the menu script
#  ├── results/                    # Output of scans
#  ├── scans/                      # All logic scripts and CSVs
#  │   ├── testssl_eisen/
#  │   ├── testssl_results_csvverzameling/
#  │   ├── scan_ssl.sh
#  │   ├── scan_headers.sh
#  │   └── ...
#  └── testssl.sh/                 # Cloned automatically if not present
