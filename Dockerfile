# Use Python 3.10 as base image for compatibility
FROM python:3.10-slim-bullseye

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    gcc \
    g++ \
    libpq-dev \
    python3-dev \
    ffmpeg \
    openssl \
    libzeroc-ice-dev \
    && rm -rf /var/lib/apt/lists/*

# Install poetry
RUN pip install poetry python-dotenv

# Set working directory
WORKDIR /app

# Copy project files
COPY pyproject.toml poetry.lock* ./
COPY generate-certs.sh ./

# Make the certificate generation script executable
RUN chmod +x generate-certs.sh

# Configure poetry to not create virtual environment in container
RUN poetry config virtualenvs.create false

# Install dependencies
RUN poetry install --no-dev --no-interaction --no-ansi

# Copy application code
COPY . .

# Create necessary directories
RUN mkdir -p data logs certificates

# Generate certificates if they don't exist
RUN if [ ! -f certificates/cert.pem ]; then ./generate-certs.sh; fi

# Default command
CMD ["python", "-m", "opentakserver.app"]
# CMD ["poetry", "run", "python", "-m", "opentakserver.app"]
