{% from "clion/map.jinja" import clion with context %}

{% if grains.os not in ('MacOS', 'Windows',) %}

clion-home-symlink:
  file.symlink:
    - name: '{{ clion.jetbrains.home }}/clion'
    - target: '{{ clion.jetbrains.realhome }}'
    - onlyif: test -d {{ clion.jetbrains.realhome }}
    - force: True

# Update system profile with PATH
clion-config:
  file.managed:
    - name: /etc/profile.d/clion.sh
    - source: salt://clion/files/clion.sh
    - template: jinja
    - mode: 644
    - user: root
    - group: root
    - context:
      home: '{{ clion.jetbrains.home }}/clion'

  # Debian alternatives
  {% if clion.linux.altpriority > 0 %}
     {% if grains.os_family not in ('Arch',) %}

# Add clion-home to alternatives system
clion-home-alt-install:
  alternatives.install:
    - name: clion-home
    - link: '{{ clion.jetbrains.home }}/clion'
    - path: '{{ clion.jetbrains.realhome }}'
    - priority: {{ clion.linux.altpriority }}

clion-home-alt-set:
  alternatives.set:
    - name: clionhome
    - path: {{ clion.jetbrains.realhome }}
    - onchanges:
      - alternatives: clion-home-alt-install

# Add intelli to alternatives system
clion-alt-install:
  alternatives.install:
    - name: clion
    - link: {{ clion.linux.symlink }}
    - path: {{ clion.jetbrains.realcmd }}
    - priority: {{ clion.linux.altpriority }}
    - require:
      - alternatives: clion-home-alt-install
      - alternatives: clion-home-alt-set

clion-alt-set:
  alternatives.set:
    - name: clion
    - path: {{ clion.jetbrains.realcmd }}
    - onchanges:
      - alternatives: clion-alt-install

      {% endif %}
  {% endif %}

{% endif %}