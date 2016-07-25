{% from "collectd/map.jinja" import collectd_settings with context %}

include:
  - collectd.service

collectd:
{% if salt['grains.get']('os') == 'Amazon' %}
  pkgrepo.managed:
    - humanname: CollectD
    - baseurl: "https://pkg.ci.collectd.org/rpm/collectd-5.5/epel-6-x86_64"
    - file: /etc/yum.repos.d/collectd.repo
    - gpgcheck: 0
{% else %}
  pkgrepo.managed:
    - humanname: CollectD
    - name: "deb http://pkg.ci.collectd.org/deb {{ collectd_settings.distr }} collectd-{{ collectd_settings.version }}"
    - dist: {{ collectd_settings.distr }}
    - file: /etc/apt/sources.list.d/collectd.list
    - keyid: B8543576
    - keyserver: keyserver.ubuntu.com
{% endif %}
  pkg.installed:
    - name: {{ collectd_settings.pkg }}
    {%- if collectd_settings.pkg_version is defined and collectd_settings.pkg_version %}
    - version: '{{ collectd_settings.pkg_version }}'
    {%- endif %}
    - require:
      - pkgrepo: collectd

{{ collectd_settings.plugindirconfig }}:
  file.directory:
    - user: {{ collectd_settings.user }}
    - group: {{ collectd_settings.group }}
    - dir_mode: 755
    - file_mode: 644
    - makedirs: True
    - require_in:
      - service: collectd-service # set proper file mode before service runs

{{ collectd_settings.config }}:
  file.managed:
    - source: salt://collectd/files/collectd.conf
    - user: {{ collectd_settings.user }}
    - group: {{ collectd_settings.group }}
    - mode: 644
    - template: jinja
    - watch_in:
      - service: collectd-service

{{ collectd_settings.plugindirconfig }}/default.conf:
  file.managed:
    - source: salt://collectd/files/default.conf
    - user: {{ collectd_settings.user }}
    - group: {{ collectd_settings.group }}
    - mode: 644
    - template: jinja
    - watch_in:
      - service: collectd-service
