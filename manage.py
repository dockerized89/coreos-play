import os
from subprocess import Popen, PIPE, STDOUT
import logging

import re
from ruamel import yaml
import sys

import shutil

logging.basicConfig(level=logging.INFO)


def __send_cmd(command):
    logging.info("executing command: %s", command)
    process = Popen(command.split(" "), stdout=PIPE, stdin=PIPE, stderr=STDOUT)
    stdout = process.communicate()[0]
    logging.debug("stdout: %s", stdout.decode())
    return stdout.decode()

def get_cluster_size(config='config.rb'):
    regex = '\$.*_instances=.*'
    pattern = re.compile(regex)
    result = []
    with open(config, 'r') as config_file:
        for line in config_file:
            match = pattern.search(line)
            if match is not None:
                result.append(int(match.group()[-1].split('=')[0]))

    return (sum(result))

def main():
    nr_of_instances = get_cluster_size()
    discovery_token = __send_cmd("curl -s ""https://discovery.etcd.io/new?size={0}".format(nr_of_instances))
    shutil.copy("user-data.tmpl", "user-data")

    with open("user-data", "r") as data:
        user_data = yaml.load(data, yaml.RoundTripLoader)


    user_data['coreos']['etcd2']['discovery'] = discovery_token

    with open("user-data", "w") as user_data_file:
        yaml.dump(user_data, user_data_file, Dumper=yaml.RoundTripDumper, default_flow_style=False)

    os.system("vagrant box update")
    os.system("vagrant up --provision --parallel")
if __name__ == '__main__':
    main()
