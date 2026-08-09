package com.smartlearning.dto;

import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 通用分页结果。
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class PagedResult<T> {
    private List<T> list;
    private long total;
    private int page;
    private int pageSize;

    public long getTotalPages() {
        return pageSize > 0 ? (total + pageSize - 1) / pageSize : 0;
    }
}
