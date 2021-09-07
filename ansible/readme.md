ansible使用
===

ansible官网 https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html

示例参考：https://github.com/ansible/ansible-examples

ansible中文指南 http://www.ansible.com.cn/index.html#

https://jinja.palletsprojects.com/en/3.0.x/templates/#list-of-builtin-filters







- name: "Kafka | Wait for kafka nodes ready"
  vars:
    - replicas: "{{ item.get('replicas') or kafka_default_replicas }}"
  shell: "{{ bin_dir }}/kubectl get pods -n {{ component_namespace }} | grep kafka-{{ item.get('name') }} | grep Running | wc -l"
  with_items:
    - "{{ kafka_components }}"
  register: result
  until: "{{ result.stdout|int }} == {{ replicas|int}}"
  retries: 30
  delay: 20





