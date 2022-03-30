FROM python:3.8

WORKDIR /server

ENV LOG_DIR = /server/log

RUN mkdir -p $LOG_DIR

#env magic
RUN echo "AWS_ACCESS_KEY_ID=${access_key}" >> /etc/environment
RUN echo "AWS_SECRET_ACCESS_KEY=${secret_key}" >> /etc/environment
RUN echo "AWS_DEFAULT_REGION=$(curl http://169.254.169.254/latest/dynamic/instance-identity/document|grep region|awk -F\" '{print $4}')" >> /etc/environment
RUN echo "EC2_INSTANCE_ID=$(wget -q -O - http://169.254.169.254/latest/meta-data/instance-id)" >> /etc/environment
RUN echo "PORT=80" >> /etc/environment
RUN echo "FLASK_APP=server" >> /etc/environment
RUN for env in $(cat /etc/environment); do export $(echo $env | sed -e 's/"//g'); done

COPY requirements.txt .

RUN pip install -r requirements.txt >> $LOG_DIR/mrg_pip.log

COPY . .

EXPOSE 8080

CMD ["python", "server.py"]