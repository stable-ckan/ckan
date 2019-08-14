CKAN: The Open Source Data Portal Software
==========================================

.. image:: https://img.shields.io/badge/license-AGPL-blue.svg?style=flat
    :target: https://opensource.org/licenses/AGPL-3.0
    :alt: License

.. image:: https://img.shields.io/badge/docs-latest-brightgreen.svg?style=flat
    :target: http://docs.ckan.org
    :alt: Documentation
.. image:: https://img.shields.io/badge/support-StackOverflow-yellowgreen.svg?style=flat
    :target: https://stackoverflow.com/questions/tagged/ckan
    :alt: Support on StackOverflow

.. image:: https://circleci.com/gh/ckan/ckan.svg?style=shield
    :target: https://circleci.com/gh/ckan/ckan
    :alt: Build Status

.. image:: https://coveralls.io/repos/github/ckan/ckan/badge.svg?branch=master
    :target: https://coveralls.io/github/ckan/ckan?branch=master
    :alt: Coverage Status

**CKAN is the world’s leading open-source data portal platform**.
CKAN makes it easy to publish, share and work with data. It's a data management
system that provides a powerful platform for cataloging, storing and accessing
datasets with a rich front-end, full API (for both data and catalog), visualization
tools and more. Read more at `ckan.org <http://ckan.org/>`_.


Installation
------------

See the `CKAN Documentation <http://docs.ckan.org>`_ for installation instructions.

Para um processo mais simplificado de instalação do Ckan deve seguir os passos abaixo:

Instale o git na sua distribuição linux (foi testado com o Ubuntu na versão 19.04)

1 - Crie o usuario para o postgres que sera usado pelo Ckan: `sudo -u postgres createuser -S -D -R -P ckan_default` (https://docs.ckan.org/en/2.8/maintaining/installing/install-from-source.html#setup-a-postgresql-database)
2 - Crie o banco de dados do postgres que sera usado: `sudo -u postgres createdb -O ckan_default ckan_default -E utf-8` (https://docs.ckan.org/en/2.8/maintaining/installing/install-from-source.html#setup-a-postgresql-database)
3 - Deve baixar o https://www.apache.org/dyn/closer.lua/lucene/solr/8.2.0/solr-8.2.0.tgz
4 - Executem o comando `git clone https://github.com/stable-ckan/ckan.git ckan`
5 - Entrar na pasta ckan e git checkout release-ckan-2.8.2 
6 - executar o comando sudo ckan/bin/solr_init/install_solr_service.sh <CAMINHO DO solr-8.2.0.tgz>
7 - Entrar na pasta ckan e executar o comando sudo bin/install.sh
8 - Executar o comando git clone https://github.com/stable-ckan/datapusher.git datapusher
9 - Entrar na pasta datapusher e executar o comando git checkout release-0.0.12
10 - Executar o comando sudo datapusher/bin/install.sh
11 - Editem o arquivo /etc/ckan/default/production.ini para editar o campo sqlalchemy.url = postgresql://ckan_default:pass@localhost/ckan_default para o banco que esta usando
12 - Altere o ckan.site_id = default de /etc/ckan/default/production.ini
13 - Altere o ckan.site_url para o endereço que o ckan sera usado no /etc/ckan/default/production.ini
14 - Edite o solr_url = http://127.0.0.1:8983/solr/ckan no /etc/ckan/default/production.ini
15 - Sete as configurações para o datastore em /etc/ckan/default/production.ini:
    ckan.datastore.write_url = postgresql://ckan_default:ckan@localhost/datastore_default
    ckan.datastore.read_url = postgresql://datastore_default:ckan@localhost/datastore_default
16 - Altere para ckan.plugins = stats text_view image_view recline_view datastore datapusher no /etc/ckan/default/production.ini
    
Support
-------
For general discussion around CKAN, you can write to the `Google Group`_.

If you need help with CKAN or want to ask a question, use either the
`ckan-dev`_ mailing list or the `CKAN tag on Stack Overflow`_ (try
searching the Stack Overflow and ckan-dev `archives`_ for an answer to your
question first).

If you've found a bug in CKAN, open a new issue on CKAN's `GitHub Issues`_ (try
searching first to see if there's already an issue for your bug).

If you find a potential security vulnerability please email security@ckan.org,
rather than creating a public issue on GitHub.

.. _Google Group: https://groups.google.com/forum/#!forum/ckan-global-user-group
.. _CKAN tag on Stack Overflow: http://stackoverflow.com/questions/tagged/ckan
.. _ckan-dev: https://lists.okfn.org/mailman/listinfo/ckan-dev
.. _archives: https://www.google.com/search?q=%22%5Bckan-dev%5D%22+site%3Alists.okfn.org.
.. _GitHub Issues: https://github.com/ckan/ckan/issues


Contributing to CKAN
--------------------

For contributing to CKAN or its documentation, see
`CONTRIBUTING <https://github.com/ckan/ckan/blob/master/CONTRIBUTING.rst>`_.

If you want to talk about CKAN development say hi to the CKAN developers on the
`ckan-dev`_ mailing list, in the `#ckan`_ IRC channel, or on `BotBot`_.

If you've figured out how to do something with CKAN and want to document it for
others, make a new page on the `CKAN wiki`_, and tell us about it on
ckan-dev mailing list.

.. _ckan-dev: http://lists.okfn.org/mailman/listinfo/ckan-dev
.. _#ckan: http://webchat.freenode.net/?channels=ckan
.. _CKAN Wiki: https://github.com/ckan/ckan/wiki
.. _BotBot: https://botbot.me/freenode/ckan/


Copying and License
-------------------

This material is copyright (c) 2006-2018 Open Knowledge International and contributors.

It is open and licensed under the GNU Affero General Public License (AGPL) v3.0
whose full text may be found at:

http://www.fsf.org/licensing/licenses/agpl-3.0.html
