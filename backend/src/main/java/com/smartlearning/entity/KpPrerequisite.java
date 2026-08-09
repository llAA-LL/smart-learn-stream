package com.smartlearning.entity;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class KpPrerequisite {
    private Long id;
    private Long kpId;
    private Long prerequisiteKpId;
}
