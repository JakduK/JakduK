package com.jakduk.api.common;

import com.jakduk.api.common.rabbitmq.ElasticsearchRoutingKey;
import org.junit.Assert;
import org.junit.Test;

/**
 * Created by pyohwanjang on 2017. 7. 3..
 */
public class RabbitMQRoutingKeyTest {

    @Test
    public void rabbitMqRoutingKeyTest() {
        ElasticsearchRoutingKey elasticsearchRoutingKey = ElasticsearchRoutingKey.find("elasticsearch-index-document-article");

        Assert.assertTrue(ElasticsearchRoutingKey.ELASTICSEARCH_INDEX_DOCUMENT_ARTICLE.name().equals(elasticsearchRoutingKey.name()));
    }
}
