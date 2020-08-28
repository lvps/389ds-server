import os

from testinfra.utils.ansible_runner import AnsibleRunner

serverid = 'default'

testinfra_hosts = AnsibleRunner(os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')


def test_389ds_installed(host):
    package = host.package('389-ds-base')

    assert package.is_installed


def test_389ds_running_and_enabled(host):
    dirsrv = host.service(f'dirsrv@{serverid}')

    assert dirsrv.is_enabled


def test_389ds_listening_389(host):
    socket = host.socket('tcp://0.0.0.0:389')

    assert socket.is_listening


def test_389ds_listening_636(host):
    socket = host.socket('tcp://0.0.0.0:636')

    assert socket.is_listening
