# IS 3033 Lab 06: starter Dockerfile.
# This file builds and runs. It is also wrong in three ways.
# Your job in Step 4 is to find and fix them until the scan is green.

FROM python:latest

ENV AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
ENV AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY

WORKDIR /app
COPY app.py /app/app.py

EXPOSE 8080
CMD ["python", "/app/app.py"]
