FROM python:latest

WORKDIR /app

COPY . /app

ENV FLASK_APP=app

RUN pip install -r requirements.txt

EXPOSE 5000

CMD ["flask", "run", "--host=0.0.0.0"]