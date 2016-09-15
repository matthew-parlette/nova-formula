{%- from "nova/map.jinja" import nova with context %}

include:
  - keystone

nova_keystone_user:
  keystone.user_present:
    - name: nova
    - email: {{ salt['pillar.get']('nova:email', 'nova@openstack.com') }}
    - password: {{ salt['pillar.get']('nova:password') }}
    - tenant: service
    - enable: True
    - roles:
        service:
          - admin
    - require:
      - file: /tmp/wait-port.sh
      - keystone: keystone_default_tenants
      - keystone: keystone_default_roles

nova_keystone_service:
  keystone.service_present:
    - name: nova
    - service_type: compute
    - description: Openstack Compute
    - require:
      - file: /tmp/wait-port.sh

nova_keystone_endpoint:
  keystone.endpoint_present:
    - name: nova
    - publicurl: http://{{ salt["pillar.get"]("nova:public_ip") }}:8774/v2.1/%\(tenant_id\)s
    - internalurl: http://{{ salt["pillar.get"]("nova:internal_ip") }}:8774/v2.1/%\(tenant_id\)s
    - adminurl: http://{{ salt["pillar.get"]("nova:admin_ip") }}:8774/v2.1/%\(tenant_id\)s
    - require:
      - file: /tmp/wait-port.sh
