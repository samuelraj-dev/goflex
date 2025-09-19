curl -fsSL https://raw.githubusercontent.com/samuelraj-dev/goflex/refs/heads/main/bin/goflex.sh -o /tmp/goflex.sh && \
chmod +x /tmp/goflex.sh && \
sudo cp /tmp/goflex.sh /usr/local/bin/goflex && \
rm /tmp/goflex.sh && \
echo "Installed goflex to /usr/local/bin/goflex" && \
SHELL_RC="$HOME/.bashrc"; [ -n "$ZSH_VERSION" ] && SHELL_RC="$HOME/.zshrc"; \
if ! grep -q 'Goflex current' "$SHELL_RC"; then \
    echo 'export GO_HOME="$HOME/.goflex/current/go"' >> "$SHELL_RC"; \
    echo 'export PATH="$GO_HOME/bin:$PATH"' >> "$SHELL_RC"; \
    echo "# Goflex current version added to PATH" >> "$SHELL_RC"; \
    echo "Updated $SHELL_RC. Restart shell or run: source $SHELL_RC"; \
fi