#!/bin/env bash
#if grep -q "finitigruppi" $CKAN_INI; then
#echo "Not configuring DCATAPIT already done"
#else

ckan config-tool $CKAN_INI "ckanext.dcatapit.theme_group_mapping.file = ${APP_DIR}/patches/theme_to_group.ini"
ckan config-tool $CKAN_INI "ckanext.dcatapit.nonconformant_themes_mapping.file= ${APP_DIR}/patches/topics.json"
ckan config-tool $CKAN_INI "ckanext.dcatapit.theme_group_mapping.add_new_groups= true"
ckan config-tool $CKAN_INI "geonames.username=piersoft"
ckan config-tool $CKAN_INI "ckanext.multilang.localized_resources = true"

  for file in "${APP_DIR}/patches/groups/"*.json; do
   echo "Creating group from file ${file}"
   curl -i -H "X-CKAN-API-Key: $(ckan user token add ckan_admin gruppi | tail -n 1 | tr -d '\t')" -XPOST -d @$file http://0.0.0.0:5000/api/3/action/group_create
  done

ckan config-tool $CKAN_INI "ckan.build_groups = "finitigruppi" "

echo -e "\nCKAN init groups completed successfully"

#fi
