import os

import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')


def test_389ds_installed(host):
    package = host.package('389-ds-base')

    assert package.is_installed


def test_389ds_running_and_enabled(host):
    dirsrv = host.service('dirsrv@test')

    assert dirsrv.is_enabled
    assert dirsrv.is_enabled


def test_389ds_listening_389(host):
    socket = host.socket('tcp://0.0.0.0:389')

    assert socket.is_listening


def test_389ds_not_listening_636(host):
    socket = host.socket('tcp://0.0.0.0:636')

    assert not socket.is_listening
