package com.jakduk.core.model.elasticsearch;

import com.jakduk.core.model.embedded.CommonWriter;
import io.searchbox.annotations.JestId;
import lombok.Data;

/**
 * @author pyohwan
 * 16. 3. 13 오후 10:56
 */

@Data
public class JakduCommentOnES {

    @JestId
    private String id;
    private String jakduScheduleId;
    private CommonWriter writer;
    private String contents;
}