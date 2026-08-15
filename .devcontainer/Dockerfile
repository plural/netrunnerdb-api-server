FROM mcr.microsoft.com/devcontainers/ruby:3.4-bookworm

# Default value to allow debug server to serve content over GitHub Codespace's port forwarding service
# The value is a comma-separated list of allowed domains
ENV RAILS_DEVELOPMENT_HOSTS=".githubpreview.dev,.preview.app.github.dev,.app.github.dev"

# 1. Pre-install matching Bundler version and language server
RUN gem install "bundler:>= 4.0.0" ruby-lsp ruby-lsp-rails ruby-lsp-rails-factory-bot ruby-lsp-rspec

# 2. Pre-create volume mount points with non-root ownership
RUN mkdir -p /home/vscode/.bundle /commandhistory \
    && chown -R vscode:rvm /home/vscode/.bundle /commandhistory /usr/local/rvm \
    && chmod -R g+w /usr/local/rvm

# 3. Direct RubyGems and Bundler to user-level persistent volume
ENV GEM_HOME="/home/vscode/.bundle"
ENV GEM_PATH="/home/vscode/.bundle:/usr/local/rvm/gems/default:/usr/local/rvm/gems/default@global"
ENV PATH="/home/vscode/.bundle/bin:${PATH}"
