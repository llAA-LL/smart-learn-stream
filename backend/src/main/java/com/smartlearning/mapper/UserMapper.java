package com.smartlearning.mapper;

import com.smartlearning.entity.User;
import org.apache.ibatis.annotations.*;

@Mapper
public interface UserMapper {

    @Select("SELECT * FROM users WHERE username = #{username}")
    User findByUsername(String username);

    @Select("SELECT * FROM users WHERE id = #{id}")
    User findById(Long id);

    @Insert("INSERT INTO users (username, password, real_name, role) VALUES (#{username}, #{password}, #{realName}, #{role})")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int insert(User user);
}
