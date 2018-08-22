FROM java:8-jre
MAINTAINER yechen <897958480@qq.com>

ENV ES_VERSION="5.0.0"

# es需要使用非root用户启动
# es5之后的版本需要修改/etc/sysctl.conf 手动加上vm.max_map_count=262144否则报错
# 更好的解决办法 可以修改宿主的  该配置项  sudo sysctl -w vm.max_map_count=655360


RUN cd /tmp && curl -OL https://github.com/medcl/elasticsearch-rtf/archive/${ES_VERSION}.zip && \
	unzip ${ES_VERSION}.zip -d /usr/share && rm /tmp/${ES_VERSION}.zip && \
	mv /usr/share/elasticsearch-rtf-${ES_VERSION} /usr/share/elasticsearch && \
	groupadd es && useradd -g es es && \
	for path in data config logs config/scripts; do mkdir -p "/usr/share/elasticsearch/$path"; done && \
	chown -R es:es /usr/share/elasticsearch && \
	cd /usr/share/elasticsearch/bin && \
	sh -c '/bin/echo -e "y\n" | ./elasticsearch-plugin install x-pack' && \
	sed -ri 's/^index.analysis.analyzer.default.type: keyword/#index.analysis.analyzer.default.type: keyword/;s/^#index.analysis.analyzer.default.type: mmseg/index.analysis.analyzer.default.type: mmseg/' /usr/share/elasticsearch/config/elasticsearch.yml

COPY ./config /usr/share/elasticsearch/config

ENV PATH /usr/share/elasticsearch/bin:$PATH

VOLUME /usr/share/elasticsearch/config

VOLUME /usr/share/elasticsearch/data

VOLUME /usr/share/elasticsearch/logs

USER es

EXPOSE 9200 9300

CMD ["elasticsearch"]