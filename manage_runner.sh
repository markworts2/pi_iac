#!/bin/bash

# manage-runner.sh.j2 - Template for runner management script

# This file should be saved as templates/manage-runner.sh.j2

RUNNER_DIR=”{{ runner_dir }}”
SERVICE_NAME=“actions.runner.{{ github_repo_url.split(’/’)[-2] }}-{{ github_repo_url.split(’/’)[-1] }}.{{ runner_name }}.service”

case “$1” in
start)
echo “Starting GitHub Actions Runner…”
sudo systemctl start “$SERVICE_NAME”
;;
stop)
echo “Stopping GitHub Actions Runner…”
sudo systemctl stop “$SERVICE_NAME”
;;
restart)
echo “Restarting GitHub Actions Runner…”
sudo systemctl restart “$SERVICE_NAME”
;;
status)
echo “Checking GitHub Actions Runner status…”
sudo systemctl status “$SERVICE_NAME”
;;
logs)
echo “Viewing runner logs (press Ctrl+C to exit)…”
sudo journalctl -u “$SERVICE_NAME” -f
;;
enable)
echo “Enabling runner service to start on boot…”
sudo systemctl enable “$SERVICE_NAME”
;;
disable)
echo “Disabling runner service from starting on boot…”
sudo systemctl disable “$SERVICE_NAME”
;;
info)
echo “Runner Information:”
echo “  Name: {{ runner_name }}”
echo “  Labels: {{ runner_labels }},{{ runner_arch | default(‘unknown’) }}”
echo “  Directory: {{ runner_dir }}”
echo “  Service: $SERVICE_NAME”
echo “  User: {{ runner_user }}”
echo “  Repository: {{ github_repo_url }}”
;;
update)
echo “To update the runner:”
echo “1. Stop the service: $0 stop”
echo “2. Run the Ansible playbook with updated runner_version”
echo “3. Or manually download and extract new version to {{ runner_dir }}”
echo “4. Run: cd {{ runner_dir }} && ./config.sh –replace –token <new_token>”
echo “5. Start the service: $0 start”
;;
uninstall)
read -p “Are you sure you want to uninstall the runner? (y/N): “ confirm
if [[ $confirm =~ ^[Yy]$ ]]; then
echo “Uninstalling runner…”
sudo systemctl stop “$SERVICE_NAME” || true
sudo systemctl disable “$SERVICE_NAME” || true
cd “$RUNNER_DIR” && sudo ./svc.sh uninstall {{ runner_user }} || true
echo “Runner service uninstalled.”
echo “To remove from GitHub, run: cd {{ runner_dir }} && ./config.sh remove –token <removal_token>”
fi
;;
*)
echo “Usage: $0 {start|stop|restart|status|logs|enable|disable|info|update|uninstall}”
echo
echo “Commands:”
echo “  start     - Start the runner service”
echo “  stop      - Stop the runner service”
echo “  restart   - Restart the runner service”
echo “  status    - Check runner service status”
echo “  logs      - View runner logs”
echo “  enable    - Enable service to start on boot”
echo “  disable   - Disable service from starting on boot”
echo “  info      - Show runner information”
echo “  update    - Show update instructions”
echo “  uninstall - Uninstall the runner service”
exit 1
;;
esac
