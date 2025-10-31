# Use the official Python 3.12.1 image as the base image
FROM python:3.12.1-slim-bookworm

# Install uv (a modern Python package manager) globally
# RUN pip install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# Set environment variable to create and use a virtual environment inside /app/.venv
ENV PATH="/app/.venv/bin:$PATH"

# Set the working directory inside the container
WORKDIR /app


# Copy the project configuration files into the container
# pyproject.toml     → project metadata and dependencies
# uv.lock            → locked dependency versions (for reproducibility)
# .python-version    → Python version specification
COPY "pyproject.toml" "uv.lock" ".python-version" ./

# Install dependencies exactly as locked in uv.lock, without updating them
RUN uv sync --locked

# Copy application code and model data into the container
COPY "predict.py" "model.bin" ./

# Expose TCP port 9696 so it can be accessed from outside the container
EXPOSE 9696

# Run the application using uvicorn (ASGI server)
# predict:app → refers to 'app' object inside predict.py
# --host 0.0.0.0 → listen on all interfaces
# --port 9696    → listen on port 9696
# 
ENTRYPOINT ["uvicorn", "predict:app", "--host", "0.0.0.0", "--port", "9696"]