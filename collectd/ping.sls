{% from "collectd/map.jinja" import collectd_settings with context %}

include:
  - collectd


install_ping_lib:
  pkg.installed:
{% if salt['grains.get']('os') == 'Amazon' %}
    - name: liboping
{% else %}
    - name: liboping0 
{% endif %}

{{ collectd_settings.plugindirconfig }}/ping.conf:
  file.managed:
    - source: salt://collectd/files/ping.conf
    - user: {{ collectd_settings.user }}
    - group: {{ collectd_settings.group }}
    - mode: 644
    - template: jinja
    - require:
      - pkg: install_ping_lib
    - watch_in:
      - service: collectd-service
