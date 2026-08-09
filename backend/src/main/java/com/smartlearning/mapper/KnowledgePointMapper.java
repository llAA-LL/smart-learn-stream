package com.smartlearning.mapper;

import com.smartlearning.entity.KnowledgePoint;
import com.smartlearning.entity.KpPrerequisite;
import org.apache.ibatis.annotations.*;
import java.util.List;

@Mapper
public interface KnowledgePointMapper {

    @Select("SELECT kp.*, c.name as course_name FROM knowledge_points kp LEFT JOIN courses c ON kp.course_id = c.id ORDER BY kp.level, kp.id")
    List<KnowledgePoint> findAll();

    @Select("SELECT kp.*, c.name as course_name FROM knowledge_points kp LEFT JOIN courses c ON kp.course_id = c.id WHERE kp.id = #{id}")
    KnowledgePoint findById(Long id);

    @Select("SELECT kp.*, c.name as course_name FROM knowledge_points kp LEFT JOIN courses c ON kp.course_id = c.id WHERE kp.course_id = #{courseId} ORDER BY kp.level")
    List<KnowledgePoint> findByCourseId(Long courseId);

    @Insert("INSERT INTO knowledge_points (name, description, learning_content, course_id, level, x_position, y_position) VALUES (#{name}, #{description}, #{learningContent}, #{courseId}, #{level}, #{xPosition}, #{yPosition})")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int insert(KnowledgePoint kp);

    @Update("UPDATE knowledge_points SET name=#{name}, description=#{description}, learning_content=#{learningContent}, course_id=#{courseId}, level=#{level}, x_position=#{xPosition}, y_position=#{yPosition} WHERE id=#{id}")
    int update(KnowledgePoint kp);

    @Delete("DELETE FROM knowledge_points WHERE id=#{id}")
    int delete(Long id);

    // Prerequisites
    @Insert("INSERT INTO kp_prerequisites (kp_id, prerequisite_kp_id) VALUES (#{kpId}, #{prerequisiteKpId})")
    int insertPrerequisite(KpPrerequisite prereq);

    @Delete("DELETE FROM kp_prerequisites WHERE kp_id = #{kpId}")
    int deletePrerequisites(Long kpId);

    @Select("SELECT prerequisite_kp_id FROM kp_prerequisites WHERE kp_id = #{kpId}")
    List<Long> findPrerequisiteIds(Long kpId);

    @Select("SELECT * FROM kp_prerequisites WHERE kp_id = #{kpId} OR prerequisite_kp_id = #{kpId}")
    List<KpPrerequisite> findRelatedEdges(Long kpId);

    @Select("SELECT * FROM kp_prerequisites")
    List<KpPrerequisite> findAllEdges();
}
