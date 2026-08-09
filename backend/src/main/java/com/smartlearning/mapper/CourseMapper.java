package com.smartlearning.mapper;

import com.smartlearning.entity.Course;
import org.apache.ibatis.annotations.*;
import java.util.List;

@Mapper
public interface CourseMapper {

    @Select("SELECT * FROM courses ORDER BY created_at DESC")
    List<Course> findAll();

    @Select("SELECT COUNT(*) FROM courses")
    int countAll();

    @Select("SELECT * FROM courses ORDER BY created_at DESC LIMIT #{offset}, #{limit}")
    List<Course> findPage(@Param("offset") int offset, @Param("limit") int limit);

    @Select("SELECT * FROM courses WHERE id = #{id}")
    Course findById(Long id);

    @Select("SELECT * FROM courses WHERE category = #{category}")
    List<Course> findByCategory(String category);

    @Insert("INSERT INTO courses (name, description, category, created_by) VALUES (#{name}, #{description}, #{category}, #{createdBy})")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int insert(Course course);

    @Update("UPDATE courses SET name=#{name}, description=#{description}, category=#{category} WHERE id=#{id}")
    int update(Course course);

    @Delete("DELETE FROM courses WHERE id=#{id}")
    int delete(Long id);
}
