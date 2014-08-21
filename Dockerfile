FROM ubuntu:trusty
MAINTAINER Michiel de Jong
RUN echo "deb http://archive.ubuntu.com/ubuntu precise universe" >> /etc/apt/sources.list
RUN apt-get -y update
RUN apt-get install -y python python-pip python-dev software-properties-common
RUN pip install fabric fabtools
RUN apt-get install -y wget
RUN wget https://raw.githubusercontent.com/cozy/cozy-setup/master/fabfile.py
RUN apt-get install -y openssh-server
RUN useradd sudoer
RUN echo "sudoer	ALL=(ALL:ALL) ALL" >> /etc/sudoers
RUN echo "sudoer:hi" | chpasswd
RUN mkdir /home/sudoer
RUN chown sudoer /home/sudoer
RUN echo "env={'password': 'hi'}" >> ./fabfile2.py
RUN cat ./fabfile.py >> ./fabfile2.py
RUN sed 's/PrintMotd yes/PrintMotd yes/' /etc/ssh/sshd_config 1> /etc/ssh/sshd_config
ADD config/couchdb.conf /etc/supervisor/conf.d/couchdb.conf
RUN /etc/init.d/ssh start && fab -H sudoer@localhost -p hi install_tools -f ./fabfile2.py
RUN /etc/init.d/ssh start && fab -H sudoer@localhost -p hi install_node10 -f ./fabfile2.py
RUN /etc/init.d/ssh start && fab -H sudoer@localhost -p hi install_couchdb -f ./fabfile2.py
# RUN /etc/init.d/ssh start && fab -H sudoer@localhost -p hi run_couchdb -f ./fabfile2.py
RUN /etc/init.d/ssh start && fab -H sudoer@localhost -p hi install_postfix -f ./fabfile2.py
RUN /etc/init.d/ssh start && fab -H sudoer@localhost -p hi create_cozy_user -f ./fabfile2.py
RUN /etc/init.d/ssh start && fab -H sudoer@localhost -p hi config_couchdb -f ./fabfile2.py
RUN /etc/init.d/ssh start && fab -H sudoer@localhost -p hi install_monitor -f ./fabfile2.py
RUN /etc/init.d/ssh start && fab -H sudoer@localhost -p hi install_controller -f ./fabfile2.py
RUN /etc/init.d/ssh start && fab -H sudoer@localhost -p hi install_indexer -f ./fabfile2.py
RUN /etc/init.d/ssh start && fab -H sudoer@localhost -p hi install_data_system -f ./fabfile2.py
RUN /etc/init.d/ssh start && fab -H sudoer@localhost -p hi install_home -f ./fabfile2.py
RUN /etc/init.d/ssh start && fab -H sudoer@localhost -p hi install_proxy -f ./fabfile2.py
RUN /etc/init.d/ssh start && fab -H sudoer@localhost -p hi create_cert -f ./fabfile2.py
RUN /etc/init.d/ssh start && fab -H sudoer@localhost -p hi install_nginx -f ./fabfile2.py
RUN /etc/init.d/ssh start && fab -H sudoer@localhost -p hi restart_cozy -f ./fabfile2.py
RUN echo "Cozy installation finished. Now, enjoy!"
RUN userdel sudoer

EXPOSE 9104
CMD supervisord -n -c /etc/supervisor/supervisord.conf
