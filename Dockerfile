FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        python3 \
        python3-pip \
        python3-venv \
        python3-dev \
        build-essential \
        default-libmysqlclient-dev \
        pkg-config \
        curl \
    && rm -rf /var/lib/apt/lists/*

RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# --- Create a non-root user matching host UID/GID ---
ARG USER_ID=1000
ARG GROUP_ID=1000

# Remove default ubuntu user/group if present (frees up UID/GID 1000)
RUN userdel -r ubuntu 2>/dev/null || true \
    && groupdel ubuntu 2>/dev/null || true

RUN groupadd -g ${GROUP_ID} appuser \
    && useradd -u ${USER_ID} -g appuser -m appuser \
    && chown -R appuser:appuser /app /opt/venv

USER appuser

COPY --chown=appuser:appuser . .

EXPOSE 8000

CMD ["python3", "manage.py", "runserver", "0.0.0.0:8000"]