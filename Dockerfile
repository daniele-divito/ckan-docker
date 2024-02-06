FROM ckan/ckan-base:2.10.3

# Install any extensions needed by your CKAN instance
# See Dockerfile.dev for more details and examples
### Harvester ###
RUN pip3 install -e 'git+https://github.com/ckan/ckanext-harvest.git@master#egg=ckanext-harvest' && \
    pip3 install -r ${APP_DIR}/src/ckanext-harvest/pip-requirements.txt
# will also require gather_consumer and fetch_consumer processes running (please see https://github.com/ckan/ckanext-harvest)

### Scheming ###
#RUN  pip3 install -e 'git+https://github.com/ckan/ckanext-scheming.git@master#egg=ckanext-scheming'

### Pages ###
#RUN  pip3 install -e git+https://github.com/ckan/ckanext-pages.git#egg=ckanext-pages

RUN pip3 install pylons
RUN pip3 install routes
### DCAT ###
RUN  pip3 install -e git+https://github.com/ckan/ckanext-dcat.git@master#egg=ckanext-dcat && \
     pip3 install -r https://raw.githubusercontent.com/ckan/ckanext-dcat/master/requirements.txt

# Install ckanext-dcatapit
RUN  pip3 install -e git+https://github.com/piersoft/dcatapit.git@main#egg=ckanext-dcatapit && \
     pip3 install -e ${APP_DIR}/src/ckanext-dcatapit/ 
#&& \
 #    pip3 install -r https://raw.githubusercontent.com/piersoft/dcatapit/main/dev-requirements.txt

# Install ckanext-multilang
RUN  pip3 install -e git+https://github.com/geosolutions-it/ckanext-multilang.git@master#egg=ckanext-multilang  && \
     pip3 install -e ${APP_DIR}/src/ckanext-multilang/

# DCATAPIT theme to group mapping file
COPY ckan/patches/theme_to_group.ini "${APP_DIR}/patches/theme_to_group.ini"
RUN chmod 666 "${APP_DIR}/patches/theme_to_group.ini"

# CKAN group to DCATAPIT theme mapping file
COPY ckan/patches/topics.json "${APP_DIR}/patches/topics.json"
RUN chmod 666 "${APP_DIR}/patches/topics.json"

# CKAN group to DCATAPIT theme mapping file
COPY ckan/patches/regions.rdf "${APP_DIR}/patches/regions.rdf"
RUN chmod 666 "${APP_DIR}/patches/topics.json"


COPY ckan/patches/base.py ${APP_DIR}/src/ckan/ckan/lib/base.py
COPY ckan/patches/xmlrpc.py /usr/lib/python3.10/site-packages/pylons/controllers/xmlrpc.py           
COPY ckan/patches/jsonrpc.py /usr/lib/python3.10/site-packages/pylons/controllers/jsonrpc.py
COPY ckan/patches/core.py /usr/lib/python3.10/site-packages/pylons/controllers/core.py
COPY ckan/patches/supervisord.conf /etc/supervisord.conf
COPY ckan/patches/sprite-resource-icons.png "${APP_DIR}/src/ckan/ckan/public/base/images"
COPY ckan/patches/vocabulary.py ${APP_DIR}/src/ckanext-dcatapit/ckanext/dcatapit/commands/vocabulary.py
COPY ckan/patches/processors.py ${APP_DIR}/src/ckanext-dcat/ckanext/dcat/processors.py
COPY ckan/patches/jeoquery.js ${APP_DIR}/src/ckanext-dcatapit/ckanext/dcatapit/fanstatic/jeoquery.js
COPY ckan/patches/profiledcat.py ${APP_DIR}/src/ckanext-dcat/ckanext/dcat/profiles.py
#docker cp managed-schema solr:/var/solr/data/ckan/conf/managed-schema

# Copy custom patch for access_rights and rights and custom harvesting for ISPRA, r_emiro, r_marche, BDAP
COPY ckan/patches/schema.py ${APP_DIR}/src/ckanext-dcatapit/ckanext/dcatapit/schema.py
COPY ckan/patches/interfaces.py ${APP_DIR}/src/ckanext-dcatapit/ckanext/dcatapit/interfaces.py
COPY ckan/patches/rdf.py ${APP_DIR}/src/ckanext-dcat/ckanext/dcat/harvesters/rdf.py
COPY ckan/patches/_json.py ${APP_DIR}/src/ckanext-dcat/ckanext/dcat/harvesters/_json.py
COPY ckan/patches/ckanharvester.py ${APP_DIR}/src/ckanext-harvest/ckanext/harvest/harvesters/ckanharvester.py
COPY ckan/patches/baseharv.py ${APP_DIR}/src/ckanext-harvest/ckanext/harvest/harvesters/base.py

# Copy custom initialization scripts
COPY ckan/docker-entrypoint.d/* /docker-entrypoint.d/

COPY ckan/patches/groups ${APP_DIR}/patches/groups
 

# Apply any patches needed to CKAN core or any of the built extensions (not the
# runtime mounted ones)
COPY ckan/patches ${APP_DIR}/patches

RUN for d in $APP_DIR/patches/*; do \
        if [ -d $d ]; then \
            for f in `ls $d/*.patch | sort -g`; do \
                cd $SRC_DIR/`basename "$d"` && echo "$0: Applying patch $f to $SRC_DIR/`basename $d`"; patch -p1 < "$f" ; \
            done ; \
        fi ; \
    done


